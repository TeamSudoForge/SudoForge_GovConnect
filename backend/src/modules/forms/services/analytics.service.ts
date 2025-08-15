import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { FormResponse, Service, Department } from '../entities';
import { FormAnalyticsResponse, DayOfWeekAnalytics, OverallAnalyticsResponse } from '../dto/analytics.dto';

@Injectable()
export class AnalyticsService {
  constructor(
    @InjectRepository(FormResponse)
    private responseRepository: Repository<FormResponse>,
    @InjectRepository(Service)
    private serviceRepository: Repository<Service>,
    @InjectRepository(Department)
    private departmentRepository: Repository<Department>,
  ) {}

  async getFormAnalytics(serviceId: number): Promise<FormAnalyticsResponse> {
    const service = await this.serviceRepository.findOne({
      where: { service_id: serviceId },
      relations: ['department']
    });

    if (!service) {
      throw new Error(`Service with ID ${serviceId} not found`);
    }

    const currentDate = new Date();
    const currentYear = currentDate.getFullYear();
    const currentMonth = currentDate.getMonth() + 1; // JavaScript months are 0-indexed

    // Get all responses for the current month
    const currentMonthResponses = await this.responseRepository
      .createQueryBuilder('response')
      .where('response.service_id = :serviceId', { serviceId })
      .andWhere('EXTRACT(YEAR FROM response.submitted_at) = :year', { year: currentYear })
      .andWhere('EXTRACT(MONTH FROM response.submitted_at) = :month', { month: currentMonth })
      .getMany();

    // Calculate weekly analytics (Monday to Sunday averages)
    const weeklyAnalytics = await this.calculateWeeklyAnalytics(serviceId, currentYear, currentMonth);

    // Get status breakdown
    const statusBreakdown = await this.getStatusBreakdown(serviceId);

    return {
      service_id: serviceId,
      service_name: service.name,
      current_month: {
        year: currentYear,
        month: currentMonth,
        total_responses: currentMonthResponses.length
      },
      weekly_analytics: weeklyAnalytics,
      status_breakdown: statusBreakdown
    };
  }

  private async calculateWeeklyAnalytics(
    serviceId: number,
    year: number,
    month: number
  ): Promise<DayOfWeekAnalytics[]> {
    const daysOfWeek = [
      { day: 'Monday', dayNumber: 1 },
      { day: 'Tuesday', dayNumber: 2 },
      { day: 'Wednesday', dayNumber: 3 },
      { day: 'Thursday', dayNumber: 4 },
      { day: 'Friday', dayNumber: 5 },
      { day: 'Saturday', dayNumber: 6 },
      { day: 'Sunday', dayNumber: 0 }
    ];

    const weeklyAnalytics: DayOfWeekAnalytics[] = [];

    for (const dayInfo of daysOfWeek) {
      // Get responses for this day of week in the current month
      const responses = await this.responseRepository
        .createQueryBuilder('response')
        .where('response.service_id = :serviceId', { serviceId })
        .andWhere('EXTRACT(YEAR FROM response.submitted_at) = :year', { year })
        .andWhere('EXTRACT(MONTH FROM response.submitted_at) = :month', { month })
        .andWhere('EXTRACT(DOW FROM response.submitted_at) = :dayOfWeek', { dayOfWeek: dayInfo.dayNumber })
        .getMany();

      // Count unique days this day of week occurred in the current month
      const uniqueDays = await this.responseRepository
        .createQueryBuilder('response')
        .select('DISTINCT DATE(response.submitted_at)', 'date')
        .where('response.service_id = :serviceId', { serviceId })
        .andWhere('EXTRACT(YEAR FROM response.submitted_at) = :year', { year })
        .andWhere('EXTRACT(MONTH FROM response.submitted_at) = :month', { month })
        .andWhere('EXTRACT(DOW FROM response.submitted_at) = :dayOfWeek', { dayOfWeek: dayInfo.dayNumber })
        .getRawMany();

      const totalResponses = responses.length;
      const daysOccurred = Math.max(uniqueDays.length, 1); // Avoid division by zero
      const averageResponses = Math.round((totalResponses / daysOccurred) * 100) / 100; // Round to 2 decimal places

      weeklyAnalytics.push({
        day: dayInfo.day,
        dayNumber: dayInfo.dayNumber,
        averageResponses,
        totalResponses
      });
    }

    return weeklyAnalytics;
  }

  private async getStatusBreakdown(serviceId: number): Promise<{ pending: number; approved: number; rejected: number; [key: string]: number }> {
    const statusCounts = await this.responseRepository
      .createQueryBuilder('response')
      .select('response.status', 'status')
      .addSelect('COUNT(*)', 'count')
      .where('response.service_id = :serviceId', { serviceId })
      .groupBy('response.status')
      .getRawMany();

    const breakdown: { pending: number; approved: number; rejected: number; [key: string]: number } = {
      pending: 0,
      approved: 0,
      rejected: 0
    };

    statusCounts.forEach(item => {
      breakdown[item.status] = parseInt(item.count, 10);
    });

    return breakdown;
  }

  async getOverallAnalytics(): Promise<OverallAnalyticsResponse> {
    // Get total counts
    const totalServices = await this.serviceRepository.count({ where: { is_active: true } });
    const totalResponses = await this.responseRepository.count();
    const totalDepartments = await this.departmentRepository.count();

    // Get most popular services (top 5)
    const popularServices = await this.responseRepository
      .createQueryBuilder('response')
      .select('response.service_id', 'service_id')
      .addSelect('service.name', 'service_name')
      .addSelect('COUNT(*)', 'response_count')
      .leftJoin('response.service', 'service')
      .groupBy('response.service_id, service.name')
      .orderBy('response_count', 'DESC')
      .limit(5)
      .getRawMany();

    const mostPopularServices = popularServices.map(service => ({
      service_id: parseInt(service.service_id, 10),
      service_name: service.service_name,
      response_count: parseInt(service.response_count, 10)
    }));

    return {
      total_services: totalServices,
      total_responses: totalResponses,
      total_departments: totalDepartments,
      most_popular_services: mostPopularServices
    };
  }

  async getDepartmentAnalytics(departmentId: number) {
    const department = await this.departmentRepository.findOne({
      where: { department_id: departmentId },
      relations: ['services']
    });

    if (!department) {
      throw new Error(`Department with ID ${departmentId} not found`);
    }

    const serviceIds = department.services.map(service => service.service_id);
    
    if (serviceIds.length === 0) {
      return {
        department_id: departmentId,
        department_name: department.name,
        total_services: 0,
        total_responses: 0,
        services: []
      };
    }

    const totalResponses = await this.responseRepository
      .createQueryBuilder('response')
      .where('response.service_id IN (:...serviceIds)', { serviceIds })
      .getCount();

    const serviceAnalytics = await Promise.all(
      department.services.map(async (service) => {
        const responseCount = await this.responseRepository.count({
          where: { service_id: service.service_id }
        });

        return {
          service_id: service.service_id,
          service_name: service.name,
          response_count: responseCount
        };
      })
    );

    return {
      department_id: departmentId,
      department_name: department.name,
      total_services: department.services.length,
      total_responses: totalResponses,
      services: serviceAnalytics
    };
  }
}

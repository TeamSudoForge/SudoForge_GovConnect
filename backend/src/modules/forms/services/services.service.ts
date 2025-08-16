import { Injectable, NotFoundException, ForbiddenException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Service } from '../entities/service.entity';
import { Department } from '../entities/department.entity';
import { CreateServiceDto, UpdateServiceDto } from '../dto/service.dto';

@Injectable()
export class ServicesService {
  constructor(
    @InjectRepository(Service)
    private serviceRepository: Repository<Service>,
    @InjectRepository(Department)
    private departmentRepository: Repository<Department>,
  ) {}

  async createService(departmentId: number, createServiceDto: CreateServiceDto): Promise<Service> {
    // Verify department exists
    const department = await this.departmentRepository.findOne({
      where: { department_id: departmentId }
    });

    if (!department) {
      throw new NotFoundException(`Department with ID ${departmentId} not found`);
    }

    const service = this.serviceRepository.create({
      ...createServiceDto,
      department_id: departmentId,
      is_active: true,
    });

    const savedService = await this.serviceRepository.save(service);
    return savedService;
  }

  async getServicesByDepartment(departmentId: number, isActive?: boolean): Promise<Service[]> {
    const where: any = { department_id: departmentId };
    
    if (isActive !== undefined) {
      where.is_active = isActive;
    }

    return await this.serviceRepository.find({
      where,
      relations: ['department'],
      order: { createdAt: 'DESC' }
    });
  }

  async getServiceById(serviceId: number, departmentId: number): Promise<Service> {
    const service = await this.serviceRepository.findOne({
      where: { 
        service_id: serviceId,
        department_id: departmentId 
      },
      relations: ['department', 'formFields', 'responses']
    });

    if (!service) {
      throw new NotFoundException(`Service with ID ${serviceId} not found or access denied`);
    }

    return service;
  }

  async updateService(serviceId: number, departmentId: number, updateServiceDto: UpdateServiceDto): Promise<Service> {
    const service = await this.serviceRepository.findOne({
      where: { 
        service_id: serviceId,
        department_id: departmentId 
      }
    });

    if (!service) {
      throw new NotFoundException(`Service with ID ${serviceId} not found or access denied`);
    }

    // Update service properties
    Object.assign(service, updateServiceDto);
    
    return await this.serviceRepository.save(service);
  }

  async deleteService(serviceId: number, departmentId: number): Promise<void> {
    const service = await this.serviceRepository.findOne({
      where: { 
        service_id: serviceId,
        department_id: departmentId 
      }
    });

    if (!service) {
      throw new NotFoundException(`Service with ID ${serviceId} not found or access denied`);
    }

    // Soft delete by setting is_active to false
    service.is_active = false;
    await this.serviceRepository.save(service);
  }

  async toggleServiceStatus(serviceId: number, departmentId: number): Promise<Service> {
    const service = await this.serviceRepository.findOne({
      where: { 
        service_id: serviceId,
        department_id: departmentId 
      }
    });

    if (!service) {
      throw new NotFoundException(`Service with ID ${serviceId} not found or access denied`);
    }

    service.is_active = !service.is_active;
    return await this.serviceRepository.save(service);
  }

  // Admin methods (for getting all services across departments)
  async getAllServices(isActive?: boolean): Promise<Service[]> {
    const where: any = {};
    
    if (isActive !== undefined) {
      where.is_active = isActive;
    }

    return await this.serviceRepository.find({
      where,
      relations: ['department'],
      order: { createdAt: 'DESC' }
    });
  }

  async getServicesByDepartmentId(departmentId: number): Promise<Service[]> {
    return await this.serviceRepository.find({
      where: { department_id: departmentId },
      relations: ['department'],
      order: { createdAt: 'DESC' }
    });
  }
}

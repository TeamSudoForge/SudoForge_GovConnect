// AppointmentService for booking, updating, and viewing appointments
import {
  Injectable,
  NotFoundException,
  BadRequestException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Appointment } from 'src/database/entities/appointment.entity';
import { Timeslot } from 'src/database/entities/timeslot.entity';
import { Service } from 'src/modules/forms/entities/service.entity';
import { Department } from 'src/modules/forms/entities/department.entity';
import {
  CreateAppointmentDto,
  UpdateAppointmentDto,
  AppointmentResponseDto,
} from './appointments.dto';
import QRCode from 'qrcode';

@Injectable()
export class AppointmentService {
  constructor(
    @InjectRepository(Appointment)
    private appointmentRepo: Repository<Appointment>,
    @InjectRepository(Timeslot) private timeslotRepo: Repository<Timeslot>,
    @InjectRepository(Service) private serviceRepo: Repository<Service>,
    @InjectRepository(Department)
    private departmentRepo: Repository<Department>,
  ) {}

  async bookAppointment(
    userId: number,
    dto: CreateAppointmentDto,
  ): Promise<AppointmentResponseDto> {
    const slot = await this.timeslotRepo.findOne({
      where: { id: dto.timeslotId },
      lock: { mode: 'pessimistic_write' },
    });
    if (!slot) throw new NotFoundException('Timeslot not found');
    if (slot.reservedCount >= slot.capacity)
      throw new BadRequestException('Timeslot full');

    slot.reservedCount += 1;
    await this.timeslotRepo.save(slot);

    const service = await this.serviceRepo.findOne({
      where: { service_id: dto.serviceId },
    });
    if (!service) throw new NotFoundException('Service not found');
    const department = await this.departmentRepo.findOne({
      where: { department_id: dto.departmentId },
    });
    if (!department) throw new NotFoundException('Department not found');

    // Example: requiredDocuments from service (could be a field or relation)
    const requiredDocuments = service['requiredDocuments'] || [];

    const ref = `UABS-${dto.serviceId}-${Date.now()}-${Math.random().toString(36).slice(2, 7).toUpperCase()}`;
    const qrPayload = {
      ref,
      serviceId: dto.serviceId,
      timeslotId: dto.timeslotId,
      userId,
    };
    const qrCodeUrl = await this.generateQrCode(JSON.stringify(qrPayload));

    const appointment = this.appointmentRepo.create({
      ref,
      user: { id: userId } as any,
      service: { service_id: dto.serviceId } as any,
      department: { department_id: dto.departmentId } as any,
      timeslot: { id: dto.timeslotId } as any,
      qrCodeUrl,
    });
    await this.appointmentRepo.save(appointment);

    return {
      ref,
      status: 'CONFIRMED',
      qrCodeUrl,
      service: {
        id: service.service_id,
        name: service.name,
        requiredDocuments,
      },
      department: {
        id: department.department_id,
        name: department.name,
      },
      timeslot: {
        startAt: slot.startAt.toISOString(),
        endAt: slot.endAt.toISOString(),
      },
    };
  }

  async updateAppointment(
    ref: string,
    dto: UpdateAppointmentDto,
  ): Promise<AppointmentResponseDto> {
    const appointment = await this.appointmentRepo.findOne({
      where: { ref },
      relations: ['service', 'department', 'timeslot'],
    });
    if (!appointment) throw new NotFoundException('Appointment not found');

    if (dto.timeslotId) {
      const slot = await this.timeslotRepo.findOne({
        where: { id: dto.timeslotId },
        lock: { mode: 'pessimistic_write' },
      });
      if (!slot) throw new NotFoundException('Timeslot not found');
      if (slot.reservedCount >= slot.capacity)
        throw new BadRequestException('Timeslot full');
      slot.reservedCount += 1;
      await this.timeslotRepo.save(slot);
      appointment.timeslot = slot;
    }
    if (dto.departmentId) {
      const department = await this.departmentRepo.findOne({
        where: { department_id: dto.departmentId },
      });
      if (!department) throw new NotFoundException('Department not found');
      appointment.department = department;
    }
    await this.appointmentRepo.save(appointment);

    // Example: requiredDocuments from service (could be a field or relation)
    const requiredDocuments = appointment.service['requiredDocuments'] || [];

    return {
      ref: appointment.ref,
      status: appointment.status,
      qrCodeUrl: appointment.qrCodeUrl,
      service: {
        id: appointment.service.service_id,
        name: appointment.service.name,
        requiredDocuments,
      },
      department: {
        id: appointment.department.department_id,
        name: appointment.department.name,
      },
      timeslot: {
        startAt: appointment.timeslot.startAt.toISOString(),
        endAt: appointment.timeslot.endAt.toISOString(),
      },
    };
  }

  async getAppointment(ref: string): Promise<AppointmentResponseDto> {
    const appointment = await this.appointmentRepo.findOne({
      where: { ref },
      relations: ['service', 'department', 'timeslot'],
    });
    if (!appointment) throw new NotFoundException('Appointment not found');
    // Example: requiredDocuments from service (could be a field or relation)
    const requiredDocuments = appointment.service['requiredDocuments'] || [];
    return {
      ref: appointment.ref,
      status: appointment.status,
      qrCodeUrl: appointment.qrCodeUrl,
      service: {
        id: appointment.service.service_id,
        name: appointment.service.name,
        requiredDocuments,
      },
      department: {
        id: appointment.department.department_id,
        name: appointment.department.name,
      },
      timeslot: {
        startAt: appointment.timeslot.startAt.toISOString(),
        endAt: appointment.timeslot.endAt.toISOString(),
      },
    };
  }
  private async generateQrCode(data: string): Promise<string> {
    try {
      return await QRCode.toDataURL(data);
    } catch (error) {
      throw new BadRequestException('Failed to generate QR code');
    }
  }
}

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
import { NotificationService } from '../notifications/notification.service';
import { User } from 'src/database/entities';

@Injectable()
export class AppointmentService {
  constructor(
    @InjectRepository(Appointment)
    private appointmentRepo: Repository<Appointment>,
    @InjectRepository(Timeslot) private timeslotRepo: Repository<Timeslot>,
    @InjectRepository(Service) private serviceRepo: Repository<Service>,
    @InjectRepository(Notification)
    private notificationRepo: Repository<Notification>,
    @InjectRepository(Department)
    private departmentRepo: Repository<Department>,
    private notificationService: NotificationService,
  ) {}

  async bookAppointment(
    user: User,
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
    const requiredDocuments = Array.isArray(service['requiredDocuments'])
      ? service['requiredDocuments'].map(
          (doc: any) => doc.name ?? doc.id ?? String(doc),
        )
      : [];

    const ref = `UABS-${dto.serviceId}-${Date.now()}-${Math.random().toString(36).slice(2, 7).toUpperCase()}`;
    const qrPayload = {
      ref,
      serviceId: dto.serviceId,
      timeslotId: dto.timeslotId,
      userId: user.id,
    };
    const qrCodeUrl = await this.generateQrCode(JSON.stringify(qrPayload));

    const appointment = this.appointmentRepo.create({
      ref,
      user: user,
      service: { service_id: dto.serviceId } as any,
      department: { department_id: dto.departmentId } as any,
      timeslot: { id: dto.timeslotId } as any,
      qrCodeUrl,
    });
    await this.appointmentRepo.save(appointment);

    await this.notificationService.createAppointmentConfirmation(
      user,
      {
        serviceName: service.name,
        departmentName: department.name,
        appointmentDate: slot.startAt.toISOString().split('T')[0],
        appointmentTime: slot.startAt.toISOString().split('T')[1].slice(0, 5),
        location:
          typeof department.contact_phone === 'string'
            ? department.contact_phone
            : '',
        referenceNumber: ref,
        qrCodeUrl,
        mapUrl: department['mapUrl'] || '',
      },
      slot.startAt,
    );

    await this.notificationService.createAppointmentReminder(
      user,
      {
        serviceName: service.name,
        departmentName: department.name,
        appointmentDate: slot.startAt.toISOString().split('T')[0],
        appointmentTime: slot.startAt.toISOString().split('T')[1].slice(0, 5),
        location:
          typeof department.contact_phone === 'string'
            ? department.contact_phone
            : '',
        referenceNumber: ref,
        requiredDocuments,
        qrCodeUrl,
      },
      new Date(slot.startAt.getTime() - 24 * 60 * 60 * 1000), // 24 hours before
    );

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
      relations: ['service', 'department', 'timeslot', 'user'],
    });
    if (!appointment) throw new NotFoundException('Appointment not found');

    let timeslotChanged = false;
    let newSlot = appointment.timeslot;

    if (dto.timeslotId && dto.timeslotId !== appointment.timeslot.id) {
      const slot = await this.timeslotRepo.findOne({
        where: { id: dto.timeslotId },
        lock: { mode: 'pessimistic_write' },
      });
      if (!slot) throw new NotFoundException('Timeslot not found');
      if (slot.reservedCount >= slot.capacity)
        throw new BadRequestException('Timeslot full');
      slot.reservedCount += 1;
      await this.timeslotRepo.save(slot);

      // Decrement reservedCount of previous slot
      appointment.timeslot.reservedCount -= 1;
      await this.timeslotRepo.save(appointment.timeslot);

      appointment.timeslot = slot;
      newSlot = slot;
      //   timeslotChanged = true;
    }

    if (
      dto.departmentId &&
      dto.departmentId !== appointment.department.department_id
    ) {
      const department = await this.departmentRepo.findOne({
        where: { department_id: dto.departmentId },
      });
      if (!department) throw new NotFoundException('Department not found');
      appointment.department = department;
    }

    // Save updated appointment
    appointment.status = 'CONFIRMED';
    await this.appointmentRepo.save(appointment);
    // Delete previous notifications scheduled for this appointment that haven't been sent
    await this.notificationRepo.delete({
      appointment: { ref: appointment.ref },
      sent: false,
    });

    // Send confirmation notification
    await this.notificationService.createAppointmentConfirmation(
      appointment.user,
      {
        serviceName: appointment.service.name,
        departmentName: appointment.department.name,
        appointmentDate: newSlot.startAt.toISOString().split('T')[0],
        appointmentTime: newSlot.startAt
          .toISOString()
          .split('T')[1]
          .slice(0, 5),
        location:
          typeof appointment.department.contact_phone === 'string'
            ? appointment.department.contact_phone
            : '',
        referenceNumber: appointment.ref,
        qrCodeUrl: appointment.qrCodeUrl,
        mapUrl: appointment.department['mapUrl'] || '',
      },
      newSlot.startAt,
    );

    // Send reminder notification 24 hours before
    const requiredDocuments = Array.isArray(
      appointment.service['requiredDocuments'],
    )
      ? appointment.service['requiredDocuments'].map(
          (doc: any) => doc.name ?? doc.id ?? String(doc),
        )
      : [];

    await this.notificationService.createAppointmentReminder(
      appointment.user,
      {
        serviceName: appointment.service.name,
        departmentName: appointment.department.name,
        appointmentDate: newSlot.startAt.toISOString().split('T')[0],
        appointmentTime: newSlot.startAt
          .toISOString()
          .split('T')[1]
          .slice(0, 5),
        location:
          typeof appointment.department.contact_phone === 'string'
            ? appointment.department.contact_phone
            : '',
        referenceNumber: appointment.ref,
        requiredDocuments,
        qrCodeUrl: appointment.qrCodeUrl,
      },
      new Date(newSlot.startAt.getTime() - 24 * 60 * 60 * 1000), // 24 hours before
    );

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
        startAt: newSlot.startAt.toISOString(),
        endAt: newSlot.endAt.toISOString(),
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

  async getUserAppointments(
    userId: string,
    page: number = 1,
    pageSize: number = 10,
    status?: 'CONFIRMED' | 'CANCELLED',
  ): Promise<{
    data: Appointment[];
    total: number;
    page: number;
    pageSize: number;
  }> {
    const query = this.appointmentRepo.createQueryBuilder('appointment')
      .where('appointment.userId = :userId', { userId });
    if (status) {
      query.andWhere('appointment.status = :status', { status });
    }
    query.skip((page - 1) * pageSize).take(pageSize);
    const [data, total] = await query.getManyAndCount();
    return { data, total, page, pageSize };
  }

  private async generateQrCode(data: string): Promise<string> {
    try {
      return await QRCode.toDataURL(data);
    } catch (error) {
      throw new BadRequestException('Failed to generate QR code');
    }
  }
}

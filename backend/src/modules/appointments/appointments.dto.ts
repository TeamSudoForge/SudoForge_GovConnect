// DTOs for appointment booking, updating, and response
import { IsEnum, IsNotEmpty, IsNumber, IsOptional } from 'class-validator';

export class CreateAppointmentDto {
  @IsNumber()
  serviceId: number;

  @IsNumber()
  departmentId: number;

  @IsNumber()
  timeslotId: number;
}

export class UpdateAppointmentDto {
  @IsOptional()
  @IsNumber()
  timeslotId?: number;

  @IsOptional()
  @IsNumber()
  departmentId?: number;
}

export class AppointmentResponseDto {
  ref: string;
  status: 'CONFIRMED' | 'CANCELLED';
  qrCodeUrl: string;
  service: {
    id: number;
    name: string;
    requiredDocuments: string[];
  };
  department: {
    id: number;
    name: string;
    location?: string;
  };
  timeslot: {
    startAt: string;
    endAt: string;
  };
}

import { IsEmail, IsString, MinLength, IsOptional } from 'class-validator';

export class DepartmentLoginDto {
  @IsEmail()
  email: string;

  @IsString()
  @MinLength(6)
  password: string;
}

export class DepartmentRegisterDto {
  @IsString()
  name: string;

  @IsEmail()
  email: string;

  @IsString()
  @MinLength(6)
  password: string;

  @IsOptional()
  @IsString()
  description?: string;

  @IsOptional()
  @IsEmail()
  contact_email?: string;

  @IsOptional()
  @IsString()
  contact_phone?: string;
}

export class DepartmentResponseDto {
  department_id: number;
  name: string;
  email: string;
  description?: string;
  contact_email?: string;
  contact_phone?: string;
  isActive: boolean;
  role: string;
  createdAt: Date;
  updatedAt: Date;
}

export class DepartmentAuthResponseDto {
  department: DepartmentResponseDto;
  accessToken: string;
  refreshToken: string;
  expiresIn: number;
}

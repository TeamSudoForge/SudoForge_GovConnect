import { Injectable, UnauthorizedException, ConflictException, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcryptjs';
import { Department } from '../../modules/forms/entities/department.entity';
import { DepartmentLoginDto, DepartmentRegisterDto, DepartmentAuthResponseDto, DepartmentResponseDto } from './dto/department-auth.dto';

@Injectable()
export class DepartmentAuthService {
  constructor(
    @InjectRepository(Department)
    private readonly departmentRepository: Repository<Department>,
    private readonly jwtService: JwtService,
  ) {}

  async register(registerDto: DepartmentRegisterDto): Promise<DepartmentAuthResponseDto> {
    const { email, password, name, description, contact_email, contact_phone } = registerDto;

    // Check if department already exists
    const existingDepartment = await this.departmentRepository.findOne({
      where: { email },
    });

    if (existingDepartment) {
      throw new ConflictException('Department with this email already exists');
    }

    // Hash password
    const saltRounds = 10;
    const passwordHash = await bcrypt.hash(password, saltRounds);

    // Create new department
    const department = this.departmentRepository.create({
      name,
      email,
      passwordHash,
      description,
      contact_email,
      contact_phone,
      isActive: true,
      role: 'department',
    });

    const savedDepartment = await this.departmentRepository.save(department);

    // Generate tokens
    const tokens = await this.generateTokens(savedDepartment);

    return {
      department: this.mapToResponseDto(savedDepartment),
      ...tokens,
    };
  }

  async login(loginDto: DepartmentLoginDto): Promise<DepartmentAuthResponseDto> {
    const { email, password } = loginDto;

    // Find department by email
    const department = await this.departmentRepository.findOne({
      where: { email },
    });

    if (!department) {
      throw new UnauthorizedException('Invalid credentials');
    }

    if (!department.isActive) {
      throw new UnauthorizedException('Department account is deactivated');
    }

    // Verify password
    const isPasswordValid = await bcrypt.compare(password, department.passwordHash);
    if (!isPasswordValid) {
      throw new UnauthorizedException('Invalid credentials');
    }

    // Generate tokens
    const tokens = await this.generateTokens(department);

    return {
      department: this.mapToResponseDto(department),
      ...tokens,
    };
  }

  async validateDepartment(departmentId: number): Promise<Department> {
    const department = await this.departmentRepository.findOne({
      where: { department_id: departmentId, isActive: true },
    });

    if (!department) {
      throw new NotFoundException('Department not found');
    }

    return department;
  }

  async findByEmail(email: string): Promise<Department | null> {
    return await this.departmentRepository.findOne({
      where: { email },
    });
  }

  private async generateTokens(department: Department): Promise<{ accessToken: string; refreshToken: string; expiresIn: number }> {
    const payload = {
      sub: department.department_id,
      email: department.email,
      role: department.role,
      type: 'department',
    };

    const accessToken = this.jwtService.sign(payload, { expiresIn: '1h' });
    const refreshToken = this.jwtService.sign(payload, { expiresIn: '7d' });

    return {
      accessToken,
      refreshToken,
      expiresIn: 3600, // 1 hour in seconds
    };
  }

  private mapToResponseDto(department: Department): DepartmentResponseDto {
    return {
      department_id: department.department_id,
      name: department.name,
      email: department.email,
      description: department.description,
      contact_email: department.contact_email,
      contact_phone: department.contact_phone,
      isActive: department.isActive,
      role: department.role,
      createdAt: department.createdAt,
      updatedAt: department.updatedAt,
    };
  }
}

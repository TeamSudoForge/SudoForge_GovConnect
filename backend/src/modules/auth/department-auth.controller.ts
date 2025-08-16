import {
  Controller,
  Post,
  Body,
  HttpCode,
  HttpStatus,
  Get,
  UseGuards,
  Request,
} from '@nestjs/common';
import { DepartmentAuthService } from './department-auth.service';
import { DepartmentLoginDto, DepartmentRegisterDto, DepartmentAuthResponseDto } from './dto/department-auth.dto';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';

@Controller('auth/department')
export class DepartmentAuthController {
  constructor(private readonly departmentAuthService: DepartmentAuthService) {}

  @Post('register')
  async register(@Body() registerDto: DepartmentRegisterDto): Promise<DepartmentAuthResponseDto> {
    return await this.departmentAuthService.register(registerDto);
  }

  @Post('login')
  @HttpCode(HttpStatus.OK)
  async login(@Body() loginDto: DepartmentLoginDto): Promise<DepartmentAuthResponseDto> {
    return await this.departmentAuthService.login(loginDto);
  }

  @Get('profile')
  @UseGuards(JwtAuthGuard)
  async getProfile(@Request() req) {
    // Check if the authenticated user is a department
    if (req.user.type !== 'department') {
      throw new Error('Access denied: Department access required');
    }
    
    const department = await this.departmentAuthService.validateDepartment(req.user.sub);
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

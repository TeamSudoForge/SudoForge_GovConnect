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
import { OfficialsAuthService } from './officials-auth.service';
import { OfficialLoginDto, OfficialRegisterDto, OfficialAuthResponseDto } from './dto/officials-auth.dto';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';

@Controller('auth/officials')
export class OfficialsAuthController {
  constructor(private readonly officialsAuthService: OfficialsAuthService) {}

  @Post('register')
  async register(@Body() registerDto: OfficialRegisterDto): Promise<OfficialAuthResponseDto> {
    return await this.officialsAuthService.register(registerDto);
  }

  @Post('login')
  @HttpCode(HttpStatus.OK)
  async login(@Body() loginDto: OfficialLoginDto): Promise<OfficialAuthResponseDto> {
    return await this.officialsAuthService.login(loginDto);
  }

  @Get('profile')
  @UseGuards(JwtAuthGuard)
  async getProfile(@Request() req) {
    // Check if the authenticated user is an official
    if (req.user.type !== 'official') {
      throw new Error('Access denied: Official access required');
    }
    
    const official = await this.officialsAuthService.validateOfficial(req.user.sub);
    return {
      official_id: official.official_id,
      name: official.name,
      email: official.email,
      designation: official.designation,
      department: official.department,
      contact_phone: official.contact_phone,
      isActive: official.isActive,
      role: official.role,
      createdAt: official.createdAt,
      updatedAt: official.updatedAt,
    };
  }
}
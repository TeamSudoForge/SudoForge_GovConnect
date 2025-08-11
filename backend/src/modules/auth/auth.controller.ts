import {
  Controller,
  Post,
  Get,
  Body,
  UseGuards,
  Request,
  Delete,
  Param,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import { AuthService } from './auth.service';
import {
  RegisterDto,
  LoginDto,
  RefreshTokenDto,
  PasskeyRegistrationDto,
  AuthResponseDto,
} from './dto/auth.dto';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { LocalAuthGuard } from '../../common/guards/local-auth.guard';
import { User } from '../../database/entities';

@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Post('register')
  async register(@Body() registerDto: RegisterDto): Promise<AuthResponseDto> {
    return this.authService.register(registerDto);
  }

  @Post('login')
  @HttpCode(HttpStatus.OK)
  async login(@Body() loginDto: LoginDto): Promise<AuthResponseDto> {
    return this.authService.login(loginDto);
  }

  @Post('refresh')
  @HttpCode(HttpStatus.OK)
  async refresh(@Body() refreshTokenDto: RefreshTokenDto): Promise<AuthResponseDto> {
    return this.authService.refreshToken(refreshTokenDto);
  }

  @UseGuards(JwtAuthGuard)
  @Get('profile')
  getProfile(@Request() req: { user: User }) {
    return {
      id: req.user.id,
      email: req.user.email,
      username: req.user.username,
      firstName: req.user.firstName,
      lastName: req.user.lastName,
      role: req.user.role,
    };
  }

  // Passkey endpoints
  @UseGuards(JwtAuthGuard)
  @Post('passkey/register/begin')
  async beginPasskeyRegistration(
    @Request() req: { user: User },
    @Body() dto: PasskeyRegistrationDto,
  ) {
    return this.authService.generatePasskeyRegistrationOptions(
      req.user.id,
      dto.displayName,
    );
  }

  @UseGuards(JwtAuthGuard)
  @Post('passkey/register/complete')
  async completePasskeyRegistration(
    @Request() req: { user: User },
    @Body() credential: any,
  ) {
    await this.authService.verifyPasskeyRegistration(
      req.user.id,
      credential.displayName,
      credential,
    );
    return { success: true };
  }

  @Post('passkey/authenticate/begin')
  async beginPasskeyAuthentication() {
    return this.authService.generatePasskeyAuthenticationOptions();
  }

  @Post('passkey/authenticate/complete')
  @HttpCode(HttpStatus.OK)
  async completePasskeyAuthentication(@Body() credential: any): Promise<AuthResponseDto> {
    return this.authService.verifyPasskeyAuthentication(credential);
  }

  @UseGuards(JwtAuthGuard)
  @Get('passkeys')
  async getPasskeys(@Request() req: { user: User }) {
    return this.authService.getUserPasskeys(req.user.id);
  }

  @UseGuards(JwtAuthGuard)
  @Delete('passkeys/:id')
  async deletePasskey(@Request() req: { user: User }, @Param('id') passkeyId: string) {
    await this.authService.deletePasskey(req.user.id, passkeyId);
    return { success: true };
  }
}

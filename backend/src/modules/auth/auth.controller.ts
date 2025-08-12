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
  Req,
  UnauthorizedException,
} from '@nestjs/common';
import { AuthService } from './auth.service';
import {
  RegisterDto,
  LoginDto,
  RefreshTokenDto,
  PasskeyRegistrationDto,
  AuthResponseDto,
  UserDto,
} from './dto/auth.dto';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { LocalAuthGuard } from '../../common/guards/local-auth.guard';
import { User } from '../../database/entities';
import { Verify2faDto } from './two-factor/dto/verify-2fa.dto';
import { TwoFactorService } from './two-factor/two-factor.service';

@Controller('auth')
export class AuthController {
  constructor(
    private readonly authService: AuthService,
    private readonly twoFactorService: TwoFactorService,
  ) {}

  @Post('register')
  async register(@Body() registerDto: RegisterDto): Promise<AuthResponseDto> {
    return this.authService.register(registerDto);
  }

  @Post('login')
  @HttpCode(HttpStatus.OK)
  async login(@Body() loginDto: LoginDto) {
    const user = await this.authService.validateUser(loginDto.email, loginDto.password);

    if (!user) {
      throw new UnauthorizedException('Invalid credentials');
    }
    if (!(user.email && user.id)) {
      throw new UnauthorizedException('User not found');
    }
    // Check if user has 2FA enabled
    if (await this.twoFactorService.isTwoFactorEnabled(user.id)) {
      await this.twoFactorService.generateAndSendVerificationCode(user.email);
      return {
        message: 'Verification code sent to your email',
        requires2FA: true,
        email: user.email,
      };
    }

    // No 2FA, proceed with normal login
    return this.authService.loginWithUser(user);
  }

  @Post('verify-2fa')
  @HttpCode(HttpStatus.OK)
  async verify2fa(@Body() verify2faDto: Verify2faDto) {
    const isValid = await this.twoFactorService.verifyCode(
      verify2faDto.email,
      verify2faDto.verificationCode,
    );

    if (!isValid) {
      throw new UnauthorizedException('Invalid verification code');
    }

    const user = await this.authService.findByEmail(verify2faDto.email);
    return this.authService.loginWithUser(user);
  }

  @Post('enable-2fa')
  @UseGuards(JwtAuthGuard)
  @HttpCode(HttpStatus.OK)
  async enable2fa(@Req() req) {
    const user = req.user as { id: string };
    await this.twoFactorService.enableTwoFactor(user.id);
    return { message: 'Two-factor authentication enabled successfully' };
  }

  @Post('disable-2fa')
  @UseGuards(JwtAuthGuard)
  @HttpCode(HttpStatus.OK)
  async disable2fa(@Req() req) {
    const user = req.user as { id: string };
    await this.twoFactorService.disableTwoFactor(user.id);
    return { message: 'Two-factor authentication disabled successfully' };
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


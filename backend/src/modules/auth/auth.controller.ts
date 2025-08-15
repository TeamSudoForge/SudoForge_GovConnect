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
  Logger,
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
import { EmailVerificationService } from './email-verification/email-verification.service';
import { VerifyEmailDto, ResendVerificationCodeDto } from './email-verification/dto/email-verification.dto';

@Controller('auth')
export class AuthController {
  private readonly logger = new Logger(AuthController.name); // Add logger instance
  
  constructor(
    private readonly authService: AuthService,
    private readonly twoFactorService: TwoFactorService,
    private readonly emailVerificationService: EmailVerificationService,
  ) {}

  @Post('register')
  async register(@Body() registerDto: RegisterDto): Promise<AuthResponseDto> {
    const result = await this.authService.register(registerDto);
    
    // Send email verification code after registration
    if (result.requiresEmailVerification) {
      try {
        const user = await this.authService.findByEmail(registerDto.email);
        await this.emailVerificationService.generateAndSendVerificationCode(user.id);
      } catch (error) {
        this.logger.warn(`Failed to send verification email during registration: ${error.message}`);
        // Don't throw error here, registration was successful
      }
    }
    
    return result;
  }

  @Post('login')
  @HttpCode(HttpStatus.OK)
  async login(@Body() loginDto: LoginDto) {
    const user = await this.authService.validateUser(loginDto.email, loginDto.password);

    if (!user) {
      throw new UnauthorizedException('Invalid credentials');
    }

    // Check if email is verified first
    if (!user.isEmailVerified) {
      try {
        await this.emailVerificationService.generateAndSendVerificationCode(user.id);
        return {
          message: 'Please verify your email address. Verification code sent to your email.',
          requiresEmailVerification: true,
          email: user.email,
        };
      } catch (error) {
        // If we can't send verification email, still inform user they need to verify
        return {
          message: 'Please verify your email address to continue.',
          requiresEmailVerification: true,
          email: user.email,
        };
      }
    }
    
    try {
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
    } catch (error) {
      // If error is due to missing table, still allow login but disable 2FA
      if (error.code === '42P01' && error.message.includes('two_factor_codes')) {
        this.logger.error('Two-factor authentication table missing. Bypassing 2FA check.');
        return this.authService.loginWithUser(user);
      }
      throw error;
    }
  }

  @Post('verify-email')
  @HttpCode(HttpStatus.OK)
  async verifyEmail(@Body() verifyEmailDto: VerifyEmailDto) {
    const isValid = await this.emailVerificationService.verifyEmailCode(
      verifyEmailDto.email,
      verifyEmailDto.verificationCode,
    );

    if (!isValid) {
      throw new UnauthorizedException('Invalid or expired verification code');
    }

    const user = await this.authService.findByEmail(verifyEmailDto.email);
    return this.authService.loginWithUser(user);
  }

  @Post('resend-verification-code')
  @HttpCode(HttpStatus.OK)
  async resendVerificationCode(@Body() resendDto: ResendVerificationCodeDto) {
    try {
      await this.emailVerificationService.resendVerificationCode(resendDto.email);
      return { message: 'Verification code sent to your email' };
    } catch (error) {
      if (error.message.includes('wait') || error.message.includes('Too many')) {
        throw new UnauthorizedException(error.message);
      }
      throw new UnauthorizedException('Failed to send verification code. Please try again.');
    }
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


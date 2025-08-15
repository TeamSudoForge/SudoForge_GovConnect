import {
  Controller,
  Post,
  Body,
  Get,
  UseGuards,
  Req,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import { PasskeyService } from './passkey.service';
import {
  RegisterPasskeyFinishDto,
  AuthenticatePasskeyStartDto,
  AuthenticatePasskeyFinishDto,
} from './dto/passkey.dto';
import type { Request } from 'express';
import { AuthService } from '../auth.service';
import { JwtAuthGuard } from 'src/common/guards/jwt-auth.guard';

@Controller('passkey')
export class PasskeyController {
  constructor(
    private readonly passkeyService: PasskeyService,
    private readonly authService: AuthService,
  ) {}

  @UseGuards(JwtAuthGuard)
  @Get('register/start')
  async registerStart(@Req() req: Request) {
    // @ts-ignore
    return this.passkeyService.generateRegistrationOptions(req.user.id);
  }

  @UseGuards(JwtAuthGuard)
  @Post('register/finish')
  @HttpCode(HttpStatus.OK)
  async registerFinish(
    @Req() req: Request,
    @Body() body: RegisterPasskeyFinishDto,
  ) {
    // @ts-ignore
    return this.passkeyService.verifyRegistration(req.user.id, body);
  }

  @Post('authenticate/start')
  @HttpCode(HttpStatus.OK)
  async authenticateStart(@Body() body: AuthenticatePasskeyStartDto) {
    return this.passkeyService.generateAuthenticationOptions(body.username);
  }

  @Post('authenticate/finish')
  @HttpCode(HttpStatus.OK)
  async authenticateFinish(@Body() body: AuthenticatePasskeyFinishDto) {
    const { verified, user } =
      await this.passkeyService.verifyAuthentication(
        // @ts-ignore
        body.username,
        body,
      );

    if (verified) {
      return this.authService.login(user);
    }

    return { verified };
  }
}

import { IsEmail, IsString, Length, IsUUID } from 'class-validator';

export class VerifyEmailDto {
  @IsEmail()
  email: string;

  @IsString()
  @Length(6, 6)
  verificationCode: string;
}

export class ResendVerificationCodeDto {
  @IsEmail()
  email: string;
}

export class SendVerificationEmailDto {
  @IsUUID()
  userId: string;
}

import { IsEmail, IsString, Length } from 'class-validator';

export class Verify2faDto {
  @IsEmail()
  email: string;

  @IsString()
  @Length(6, 6)
  verificationCode: string;
}

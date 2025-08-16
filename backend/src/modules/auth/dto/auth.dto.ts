import { IsEmail, IsString, MinLength, IsNotEmpty } from 'class-validator';

export class RegisterDto {
  @IsEmail()
  email: string;

  @IsString()
  @MinLength(8)
  password: string;

  @IsString()
  @IsNotEmpty()
  firstName: string;

  @IsString()
  @IsNotEmpty()
  lastName: string;

  @IsString()
  @IsNotEmpty()
  username: string;
}

export class LoginDto {
  @IsEmail()
  email: string;

  @IsString()
  @MinLength(1)
  password: string;
}

export class RefreshTokenDto {
  @IsString()
  @IsNotEmpty()
  refreshToken: string;
}

export class PasskeyRegistrationDto {
  @IsString()
  @IsNotEmpty()
  displayName: string;
}

export class PasskeyAuthenticationDto {
  @IsString()
  @IsNotEmpty()
  credentialId: string;
}

export interface AuthResponseDto {
  user?: {
    id: string;
    email: string;
    username: string;
    firstName: string;
    lastName: string;
    role: string;
  };
  accessToken?: string;
  refreshToken?: string;
  message?: string;
  requires2FA?: boolean;
  requiresEmailVerification?: boolean;
  email?: string;
}

export interface PasskeyOptionsDto {
  challenge: string;
  rp: {
    name: string;
    id: string;
  };
  user: {
    id: string;
    name: string;
    displayName: string;
  };
  pubKeyCredParams: Array<{
    alg: number;
    type: string;
  }>;
  authenticatorSelection?: {
    authenticatorAttachment?: string;
    userVerification?: string;
    requireResidentKey?: boolean;
  };
  attestation?: string;
  timeout?: number;
  excludeCredentials?: Array<{
    id: string;
    type: string;
    transports?: string[];
  }>;
}

export class UserDto {
  id: string;
  email: string;
  username: string;
  firstName: string;
  lastName: string;
  role: string;

  constructor(partial: Partial<UserDto>) {
    Object.assign(this, partial);
  }
}

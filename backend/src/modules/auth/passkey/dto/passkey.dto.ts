import type { AuthenticationResponseJSON, AuthenticatorAssertionResponseJSON, AuthenticatorAttestationResponseJSON, RegistrationResponseJSON } from '@simplewebauthn/server';
import { IsString, IsNotEmpty, IsObject, IsOptional } from 'class-validator';


export class RegisterPasskeyFinishDto implements RegistrationResponseJSON {
  @IsString()
  @IsNotEmpty()
  id: string;

  @IsString()
  @IsNotEmpty()
  rawId: string;

  @IsObject()
  @IsNotEmpty()
  response: AuthenticatorAttestationResponseJSON;

  @IsString()
  @IsNotEmpty()
  type: 'public-key';

  @IsObject()
  @IsOptional()
  clientExtensionResults: any;
}

export class AuthenticatePasskeyStartDto {
  @IsString()
  @IsNotEmpty()
  username: string;
}

export class AuthenticatePasskeyFinishDto implements AuthenticationResponseJSON {
  @IsString()
  @IsNotEmpty()
  id: string;

  @IsString()
  @IsNotEmpty()
  rawId: string;

  @IsObject()
  @IsNotEmpty()
  response: AuthenticatorAssertionResponseJSON;

  @IsString()
  @IsNotEmpty()
  type: 'public-key';

  @IsObject()
  @IsOptional()
  clientExtensionResults: any;
}

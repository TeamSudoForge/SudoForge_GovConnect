import { IsString, IsNotEmpty, IsOptional, IsUUID, IsObject } from 'class-validator';

export class SendMessageDto {
  @IsString()
  message: string;

  @IsUUID()
  @IsOptional()
  sessionId?: string;

  @IsObject()
  @IsOptional()
  metadata?: Record<string, any>;
}
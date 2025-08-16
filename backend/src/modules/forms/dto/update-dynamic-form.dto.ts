import { IsString, IsOptional, IsBoolean, IsNumber, IsArray, ValidateNested } from 'class-validator';
import { Type } from 'class-transformer';
import { CreateDynamicFormSectionDto } from './create-dynamic-form.dto';

export class UpdateDynamicFormDto {
  @IsString()
  @IsOptional()
  title?: string;

  @IsString()
  @IsOptional()
  description?: string;

  @IsBoolean()
  @IsOptional()
  isActive?: boolean;

  @IsNumber()
  @IsOptional()
  version?: number;

  @IsOptional()
  metadata?: any;

  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => CreateDynamicFormSectionDto)
  @IsOptional()
  sections?: CreateDynamicFormSectionDto[];
}

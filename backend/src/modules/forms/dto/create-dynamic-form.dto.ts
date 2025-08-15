import { IsString, IsOptional, IsBoolean, IsNumber, IsEnum, IsArray, ValidateNested, IsNotEmpty } from 'class-validator';
import { Type } from 'class-transformer';
import { FieldType } from '../../../database/entities';

export class CreateDynamicFormFieldDto {
  @IsString()
  @IsNotEmpty()
  label: string;

  @IsString()
  @IsNotEmpty()
  fieldName: string;

  @IsEnum(FieldType)
  fieldType: FieldType;

  @IsBoolean()
  @IsOptional()
  isRequired?: boolean = false;

  @IsString()
  @IsOptional()
  placeholder?: string;

  @IsString()
  @IsOptional()
  helpText?: string;

  @IsNumber()
  @IsOptional()
  orderIndex?: number = 1;

  @IsOptional()
  validationRules?: any;

  @IsOptional()
  options?: any; // For dropdown, radio buttons, checkboxes

  @IsOptional()
  metadata?: any;
}

export class CreateDynamicFormSectionDto {
  @IsString()
  @IsNotEmpty()
  title: string;

  @IsString()
  @IsOptional()
  description?: string;

  @IsNumber()
  @IsOptional()
  pageNumber?: number = 1;

  @IsNumber()
  @IsOptional()
  orderIndex?: number = 1;

  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => CreateDynamicFormFieldDto)
  fields: CreateDynamicFormFieldDto[];
}

export class CreateDynamicFormDto {
  @IsString()
  @IsNotEmpty()
  title: string;

  @IsString()
  @IsOptional()
  description?: string;

  @IsBoolean()
  @IsOptional()
  isActive?: boolean = true;

  @IsNumber()
  @IsOptional()
  version?: number = 1;

  @IsOptional()
  metadata?: any;

  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => CreateDynamicFormSectionDto)
  sections: CreateDynamicFormSectionDto[];
}

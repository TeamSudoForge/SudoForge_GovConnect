import { IsString, IsOptional, IsNotEmpty, IsNumber, IsBoolean, IsArray, ValidateNested } from 'class-validator';
import { Type } from 'class-transformer';

export class CreateFieldAttributeDto {
  @IsString()
  @IsNotEmpty()
  attr_key: string;

  @IsString()
  @IsNotEmpty()
  attr_value: string;
}

export class CreateFieldDto {
  @IsNumber()
  @IsNotEmpty()
  ftype_id: number;

  @IsString()
  @IsNotEmpty()
  label: string;

  @IsString()
  @IsOptional()
  placeholder?: string;

  @IsBoolean()
  @IsOptional()
  is_required?: boolean;

  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => CreateFieldAttributeDto)
  @IsOptional()
  attributes?: CreateFieldAttributeDto[];
}

export class CreateFormFieldDto {
  @IsNumber()
  @IsNotEmpty()
  field_id: number;

  @IsNumber()
  @IsNotEmpty()
  order_index: number;

  @IsString()
  @IsOptional()
  section?: string;
}

export class CreateServiceDto {
  @IsString()
  @IsNotEmpty()
  name: string;

  @IsString()
  @IsNotEmpty()
  description: string;

  @IsNumber()
  @IsNotEmpty()
  department_id: number;

  @IsBoolean()
  @IsOptional()
  is_active?: boolean;
}

export class CreateFormDto {
  @ValidateNested()
  @Type(() => CreateServiceDto)
  service: CreateServiceDto;

  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => CreateFormFieldDto)
  form_fields: CreateFormFieldDto[];

  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => CreateFieldDto)
  @IsOptional()
  new_fields?: CreateFieldDto[];
}

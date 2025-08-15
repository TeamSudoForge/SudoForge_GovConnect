import { IsString, IsNotEmpty, IsArray, ValidateNested, IsOptional } from 'class-validator';
import { Type } from 'class-transformer';

export class FormResponseValueDto {
  @IsNotEmpty()
  field_id: number;

  @IsString()
  @IsNotEmpty()
  value: string;
}

export class CreateFormResponseDto {
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => FormResponseValueDto)
  values: FormResponseValueDto[];
}

export class UpdateFormResponseStatusDto {
  @IsString()
  @IsNotEmpty()
  status: string;

  @IsString()
  @IsOptional()
  comment?: string;
}

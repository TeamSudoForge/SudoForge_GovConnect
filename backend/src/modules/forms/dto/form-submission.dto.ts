import { IsOptional, IsEnum, IsUUID, IsNotEmpty } from 'class-validator';
import { SubmissionStatus } from 'src/database/entities';

export class CreateFormSubmissionDto {
  @IsUUID()
  @IsNotEmpty()
  formId: string;

  @IsNotEmpty()
  submissionData: any;

  @IsEnum(SubmissionStatus)
  @IsOptional()
  status?: SubmissionStatus = SubmissionStatus.DRAFT;
}

export class UpdateFormSubmissionDto {
  @IsOptional()
  submissionData?: any;

  @IsEnum(SubmissionStatus)
  @IsOptional()
  status?: SubmissionStatus;

  @IsOptional()
  reviewNotes?: string;
}

import { Injectable, NotFoundException, ForbiddenException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { FormResponse, FormResponseValue, Service, Field } from '../entities';
import { CreateFormResponseDto, UpdateFormResponseStatusDto } from '../dto/form-response.dto';

@Injectable()
export class FormResponsesService {
  constructor(
    @InjectRepository(FormResponse)
    private responseRepository: Repository<FormResponse>,
    @InjectRepository(FormResponseValue)
    private responseValueRepository: Repository<FormResponseValue>,
    @InjectRepository(Service)
    private serviceRepository: Repository<Service>,
    @InjectRepository(Field)
    private fieldRepository: Repository<Field>,
  ) {}

  async submitResponse(
    serviceId: number,
    userId: string,
    responseData: CreateFormResponseDto
  ): Promise<FormResponse> {
    // Verify service exists and is active
    const service = await this.serviceRepository.findOne({
      where: { service_id: serviceId, is_active: true },
      relations: ['formFields', 'formFields.field']
    });

    if (!service) {
      throw new NotFoundException(`Service with ID ${serviceId} not found or inactive`);
    }

    // Validate that all required fields are provided
    const requiredFields = service.formFields
      .filter(formField => formField.field.is_required)
      .map(formField => formField.field.field_id);

    const providedFields = responseData.values.map(value => value.field_id);
    const missingRequiredFields = requiredFields.filter(
      fieldId => !providedFields.includes(fieldId)
    );

    if (missingRequiredFields.length > 0) {
      throw new ForbiddenException(`Missing required fields: ${missingRequiredFields.join(', ')}`);
    }

    // Create form response
    const response = this.responseRepository.create({
      service_id: serviceId,
      user_id: userId,
      status: 'pending'
    });
    const savedResponse = await this.responseRepository.save(response);

    // Create response values
    const responseValues = responseData.values.map(value =>
      this.responseValueRepository.create({
        response_id: savedResponse.response_id,
        field_id: value.field_id,
        value: value.value
      })
    );
    await this.responseValueRepository.save(responseValues);

    // Return response with relations
    return await this.getResponseById(savedResponse.response_id);
  }

  async getResponseById(responseId: number): Promise<FormResponse> {
    const response = await this.responseRepository.findOne({
      where: { response_id: responseId },
      relations: [
        'service',
        'service.department',
        'user',
        'values',
        'values.field',
        'values.field.fieldType'
      ]
    });

    if (!response) {
      throw new NotFoundException(`Response with ID ${responseId} not found`);
    }

    return response;
  }

  async getResponsesByService(serviceId: number): Promise<FormResponse[]> {
    return await this.responseRepository.find({
      where: { service_id: serviceId },
      relations: ['user', 'values', 'values.field'],
      order: { submittedAt: 'DESC' }
    });
  }

  async getResponsesByUser(userId: string): Promise<FormResponse[]> {
    return await this.responseRepository.find({
      where: { user_id: userId },
      relations: ['service', 'service.department', 'values', 'values.field'],
      order: { submittedAt: 'DESC' }
    });
  }

  async updateResponseStatus(
    responseId: number,
    statusData: UpdateFormResponseStatusDto
  ): Promise<FormResponse> {
    const response = await this.responseRepository.findOne({
      where: { response_id: responseId }
    });

    if (!response) {
      throw new NotFoundException(`Response with ID ${responseId} not found`);
    }

    response.status = statusData.status;
    await this.responseRepository.save(response);

    return await this.getResponseById(responseId);
  }

  async deleteResponse(responseId: number): Promise<void> {
    const response = await this.responseRepository.findOne({
      where: { response_id: responseId }
    });

    if (!response) {
      throw new NotFoundException(`Response with ID ${responseId} not found`);
    }

    // Delete response values first (cascade should handle this, but being explicit)
    await this.responseValueRepository.delete({ response_id: responseId });
    
    // Delete the response
    await this.responseRepository.delete(responseId);
  }
}

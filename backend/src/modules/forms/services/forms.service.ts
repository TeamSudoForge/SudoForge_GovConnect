import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, DataSource } from 'typeorm';
import { Service, FormField, Field, FieldType, FieldAttribute } from '../entities';
import { CreateFormDto, CreateFieldDto, CreateFormFieldDto } from '../dto/create-form.dto';

@Injectable()
export class FormsService {
  constructor(
    @InjectRepository(Service)
    private serviceRepository: Repository<Service>,
    @InjectRepository(FormField)
    private formFieldRepository: Repository<FormField>,
    @InjectRepository(Field)
    private fieldRepository: Repository<Field>,
    @InjectRepository(FieldType)
    private fieldTypeRepository: Repository<FieldType>,
    @InjectRepository(FieldAttribute)
    private fieldAttributeRepository: Repository<FieldAttribute>,
    private dataSource: DataSource,
  ) {}

  async createForm(createFormDto: CreateFormDto): Promise<Service> {
    const queryRunner = this.dataSource.createQueryRunner();
    await queryRunner.connect();
    await queryRunner.startTransaction();

    try {
      // Create the service
      const service = this.serviceRepository.create(createFormDto.service);
      const savedService = await queryRunner.manager.save(service);

      // Create new fields if provided
      const fieldMap = new Map<number, number>(); // temp_id -> actual_id mapping
      if (createFormDto.new_fields && createFormDto.new_fields.length > 0) {
        for (let i = 0; i < createFormDto.new_fields.length; i++) {
          const newFieldDto = createFormDto.new_fields[i];
          
          // Verify field type exists
          const fieldType = await queryRunner.manager.findOne(FieldType, {
            where: { ftype_id: newFieldDto.ftype_id }
          });
          if (!fieldType) {
            throw new BadRequestException(`Field type with ID ${newFieldDto.ftype_id} not found`);
          }

          // Create the field
          const field = this.fieldRepository.create({
            ftype_id: newFieldDto.ftype_id,
            label: newFieldDto.label,
            placeholder: newFieldDto.placeholder,
            is_required: newFieldDto.is_required || false,
          });
          const savedField = await queryRunner.manager.save(field);

          // Create field attributes if provided
          if (newFieldDto.attributes && newFieldDto.attributes.length > 0) {
            const attributes = newFieldDto.attributes.map(attr => 
              this.fieldAttributeRepository.create({
                field_id: savedField.field_id,
                attr_key: attr.attr_key,
                attr_value: attr.attr_value,
              })
            );
            await queryRunner.manager.save(attributes);
          }

          fieldMap.set(-i - 1, savedField.field_id); // Negative temp IDs for new fields
        }
      }

      // Create form field mappings
      const formFields = createFormDto.form_fields.map(formFieldDto => {
        const actualFieldId = formFieldDto.field_id < 0 
          ? fieldMap.get(formFieldDto.field_id) 
          : formFieldDto.field_id;

        if (!actualFieldId) {
          throw new BadRequestException(`Invalid field_id: ${formFieldDto.field_id}`);
        }

        return this.formFieldRepository.create({
          service_id: savedService.service_id,
          field_id: actualFieldId,
          order_index: formFieldDto.order_index,
          section: formFieldDto.section,
        });
      });

      await queryRunner.manager.save(formFields);
      await queryRunner.commitTransaction();

      // Return service with relations
      return await this.getFormById(savedService.service_id);
    } catch (error) {
      await queryRunner.rollbackTransaction();
      throw error;
    } finally {
      await queryRunner.release();
    }
  }

  async getFormById(serviceId: number): Promise<Service> {
    const service = await this.serviceRepository.findOne({
      where: { service_id: serviceId },
      relations: [
        'department',
        'formFields',
        'formFields.field',
        'formFields.field.fieldType',
        'formFields.field.attributes'
      ],
    });

    if (!service) {
      throw new NotFoundException(`Service with ID ${serviceId} not found`);
    }

    return service;
  }

  async getAllForms(): Promise<Service[]> {
    return await this.serviceRepository.find({
      relations: ['department'],
      where: { is_active: true },
      order: { createdAt: 'DESC' },
    });
  }

  async updateForm(serviceId: number, updateData: Partial<CreateFormDto>): Promise<Service> {
    const service = await this.serviceRepository.findOne({
      where: { service_id: serviceId }
    });

    if (!service) {
      throw new NotFoundException(`Service with ID ${serviceId} not found`);
    }

    // Update service details if provided
    if (updateData.service) {
      Object.assign(service, updateData.service);
      await this.serviceRepository.save(service);
    }

    // Update form fields if provided
    if (updateData.form_fields) {
      // Remove existing form fields
      await this.formFieldRepository.delete({ service_id: serviceId });

      // Add new form fields
      const formFields = updateData.form_fields.map(formFieldDto =>
        this.formFieldRepository.create({
          service_id: serviceId,
          field_id: formFieldDto.field_id,
          order_index: formFieldDto.order_index,
          section: formFieldDto.section,
        })
      );
      await this.formFieldRepository.save(formFields);
    }

    return await this.getFormById(serviceId);
  }

  async deleteForm(serviceId: number): Promise<void> {
    const service = await this.serviceRepository.findOne({
      where: { service_id: serviceId }
    });

    if (!service) {
      throw new NotFoundException(`Service with ID ${serviceId} not found`);
    }

    // Soft delete by setting is_active to false
    service.is_active = false;
    await this.serviceRepository.save(service);
  }

  async getAllFieldTypes(): Promise<FieldType[]> {
    return await this.fieldTypeRepository.find({
      order: { name: 'ASC' }
    });
  }

  async getAllFields(): Promise<Field[]> {
    return await this.fieldRepository.find({
      relations: ['fieldType', 'attributes'],
      order: { createdAt: 'DESC' }
    });
  }
}

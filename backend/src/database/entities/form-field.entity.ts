import { Entity, Column, PrimaryGeneratedColumn, CreateDateColumn, UpdateDateColumn, ManyToOne, JoinColumn } from 'typeorm';
import { FormSection } from './form-section.entity';

export enum FieldType {
  TEXT = 'text',
  PHONE_NUMBER = 'phone_number',
  EMAIL = 'email',
  DOCUMENT_UPLOAD = 'document_upload',
  DATE = 'date',
  DROPDOWN = 'dropdown',
  RADIO_BUTTON = 'radio_button',
  CHECKBOX = 'checkbox',
  TEXTAREA = 'textarea',
  NUMBER = 'number',
  DEPENDENCY_FORM = 'dependency_form'
}

@Entity('dynamic_form_fields')
export class FormField {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ length: 255 })
  label: string;

  @Column({ length: 100 })
  fieldName: string;

  @Column({
    type: 'enum',
    enum: FieldType,
    default: FieldType.TEXT
  })
  fieldType: FieldType;

  @Column({ default: false })
  isRequired: boolean;

  @Column('text', { nullable: true })
  placeholder: string;

  @Column('text', { nullable: true })
  helpText: string;

  @Column({ default: 1 })
  orderIndex: number;

  @Column('json', { nullable: true })
  validationRules: any;

  @Column('json', { nullable: true })
  options: any; // For dropdown, radio buttons, checkboxes

  @Column('json', { nullable: true })
  metadata: any;

  @Column('uuid')
  sectionId: string;

  @ManyToOne(() => FormSection, section => section.fields, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'sectionId' })
  section: FormSection;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}

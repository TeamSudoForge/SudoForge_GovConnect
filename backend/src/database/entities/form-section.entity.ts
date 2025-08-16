import { Entity, Column, PrimaryGeneratedColumn, CreateDateColumn, UpdateDateColumn, ManyToOne, OneToMany, JoinColumn } from 'typeorm';
import { Form } from './form.entity';
import { FormField } from './form-field.entity';

@Entity('form_sections')
export class FormSection {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ length: 255 })
  title: string;

  @Column('text', { nullable: true })
  description: string;

  @Column({ default: 1 })
  pageNumber: number;

  @Column({ default: 1 })
  orderIndex: number;

  @Column('uuid')
  formId: string;

  @ManyToOne(() => Form, form => form.sections, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'formId' })
  form: Form;

  @OneToMany(() => FormField, field => field.section, { cascade: true })
  fields: FormField[];

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}

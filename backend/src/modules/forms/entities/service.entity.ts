import {
  Entity,
  Column,
  PrimaryGeneratedColumn,
  ManyToOne,
  OneToMany,
  JoinColumn,
  CreateDateColumn,
  UpdateDateColumn,
} from 'typeorm';
import { Department } from './department.entity';
import { FormField } from './form-field.entity';
import { FormResponse } from './form-response.entity';
import { Timeslot } from '../../../database/entities/timeslot.entity';
import { RequiredDocument } from '../../../database/entities/required-document.entity';

@Entity('services')
export class Service {
  @PrimaryGeneratedColumn()
  service_id: number;

  @Column()
  name: string;

  @Column({ type: 'text' })
  description: string;

  @Column()
  department_id: number;

  @Column({ default: true })
  is_active: boolean;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt: Date;

  @ManyToOne(() => Department, (department) => department.services)
  @JoinColumn({ name: 'department_id' })
  department: Department;

  @OneToMany(() => Timeslot, (timeslot) => timeslot.service)
  timeslots: Timeslot[];

  @OneToMany(() => FormField, (formField) => formField.service)
  formFields: FormField[];

  @OneToMany(() => FormResponse, (response) => response.service)
  responses: FormResponse[];

  @OneToMany(() => RequiredDocument, (doc) => doc.service)
  requiredDocuments: RequiredDocument[];
}

import {
  Entity,
  Column,
  PrimaryGeneratedColumn,
  ManyToOne,
  JoinColumn,
  CreateDateColumn,
  UpdateDateColumn,
} from 'typeorm';
import { Service } from './service.entity';
import { Field } from './field.entity';

@Entity('form_fields')
export class FormField {
  @PrimaryGeneratedColumn()
  form_field_id: number;

  @Column()
  service_id: number;

  @Column()
  field_id: number;

  @Column()
  order_index: number;

  @Column({ nullable: true })
  section: string;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt: Date;

  @ManyToOne(() => Service, (service) => service.formFields)
  @JoinColumn({ name: 'service_id' })
  service: Service;

  @ManyToOne(() => Field, (field) => field.formFields)
  @JoinColumn({ name: 'field_id' })
  field: Field;
}

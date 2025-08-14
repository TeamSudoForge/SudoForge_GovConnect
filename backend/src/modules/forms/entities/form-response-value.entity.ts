import {
  Entity,
  Column,
  PrimaryGeneratedColumn,
  ManyToOne,
  JoinColumn,
  CreateDateColumn,
} from 'typeorm';
import { FormResponse } from './form-response.entity';
import { Field } from './field.entity';

@Entity('form_response_values')
export class FormResponseValue {
  @PrimaryGeneratedColumn()
  value_id: number;

  @Column()
  response_id: number;

  @Column()
  field_id: number;

  @Column({ type: 'text' })
  value: string;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @ManyToOne(() => FormResponse, (response) => response.values)
  @JoinColumn({ name: 'response_id' })
  response: FormResponse;

  @ManyToOne(() => Field, (field) => field.responseValues)
  @JoinColumn({ name: 'field_id' })
  field: Field;
}

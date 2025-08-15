import {
  Entity,
  Column,
  PrimaryGeneratedColumn,
  ManyToOne,
  JoinColumn,
  CreateDateColumn,
  UpdateDateColumn,
} from 'typeorm';
import { Field } from './field.entity';

@Entity('field_attributes')
export class FieldAttribute {
  @PrimaryGeneratedColumn()
  attr_id: number;

  @Column()
  field_id: number;

  @Column()
  attr_key: string;

  @Column()
  attr_value: string;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt: Date;

  @ManyToOne(() => Field, (field) => field.attributes)
  @JoinColumn({ name: 'field_id' })
  field: Field;
}

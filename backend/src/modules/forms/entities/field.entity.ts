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
import { FieldType } from './field-type.entity';
import { FieldAttribute } from './field-attribute.entity';
import { FormField } from './form-field.entity';
import { FormResponseValue } from './form-response-value.entity';

@Entity('fields')
export class Field {
  @PrimaryGeneratedColumn()
  field_id: number;

  @Column()
  ftype_id: number;

  @Column()
  label: string;

  @Column({ nullable: true })
  placeholder: string;

  @Column({ default: false })
  is_required: boolean;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt: Date;

  @ManyToOne(() => FieldType, (fieldType) => fieldType.fields)
  @JoinColumn({ name: 'ftype_id' })
  fieldType: FieldType;

  @OneToMany(() => FieldAttribute, (attribute) => attribute.field)
  attributes: FieldAttribute[];

  @OneToMany(() => FormField, (formField) => formField.field)
  formFields: FormField[];

  @OneToMany(() => FormResponseValue, (value) => value.field)
  responseValues: FormResponseValue[];
}

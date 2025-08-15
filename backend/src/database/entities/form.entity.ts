import { Entity, Column, PrimaryGeneratedColumn, CreateDateColumn, UpdateDateColumn, OneToMany } from 'typeorm';
import { FormSection } from './form-section.entity';

@Entity('forms')
export class Form {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ length: 255 })
  title: string;

  @Column('text', { nullable: true })
  description: string;

  @Column({ default: true })
  isActive: boolean;

  @Column({ default: 1 })
  version: number;

  @Column('json', { nullable: true })
  metadata: any;

  @OneToMany(() => FormSection, section => section.form, { cascade: true })
  sections: FormSection[];

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}

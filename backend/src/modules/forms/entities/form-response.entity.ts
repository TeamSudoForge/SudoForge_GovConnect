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
import { Service } from './service.entity';
import { User } from '../../../database/entities/user.entity';
import { FormResponseValue } from './form-response-value.entity';

@Entity('form_responses')
export class FormResponse {
  @PrimaryGeneratedColumn()
  response_id: number;

  @Column()
  service_id: number;

  @Column()
  user_id: string;

  @Column({ default: 'pending' })
  status: string;

  @CreateDateColumn({ name: 'submitted_at' })
  submittedAt: Date;

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt: Date;

  @ManyToOne(() => Service, (service) => service.responses)
  @JoinColumn({ name: 'service_id' })
  service: Service;

  @ManyToOne(() => User)
  @JoinColumn({ name: 'user_id' })
  user: User;

  @OneToMany(() => FormResponseValue, (value) => value.response)
  values: FormResponseValue[];
}

import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  ManyToOne,
  CreateDateColumn,
} from 'typeorm';
import { User } from './user.entity';
import { Timeslot } from './timeslot.entity';
import { Service } from '../../modules/forms/entities/service.entity';
import { Department } from '../../modules/forms/entities/department.entity';

@Entity('appointments')
export class Appointment {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ unique: true })
  ref: string;

  @ManyToOne(() => User)
  user: User;

  @Column({ type: 'uuid' })
  userId: string;

  @ManyToOne(() => Service)
  service: Service;

  @ManyToOne(() => Department)
  department: Department;

  @ManyToOne(() => Timeslot)
  timeslot: Timeslot;

  @Column({ default: 'CONFIRMED' })
  status: 'CONFIRMED' | 'CANCELLED';

  @Column({ nullable: true })
  qrCodeUrl: string;

  @CreateDateColumn()
  createdAt: Date;
}

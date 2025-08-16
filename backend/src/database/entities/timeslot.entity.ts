import { Service } from 'src/modules/forms/entities';
import { Entity, PrimaryGeneratedColumn, Column, ManyToOne } from 'typeorm';

@Entity('timeslots')
export class Timeslot {
  @PrimaryGeneratedColumn()
  id: number;

  @ManyToOne(() => Service, (service) => service.timeslots)
  service: Service;

  @Column({ type: 'timestamptz' })
  startAt: Date;

  @Column({ type: 'timestamptz' })
  endAt: Date;

  @Column({ default: 1 })
  capacity: number;

  @Column({ default: 0 })
  reservedCount: number;
}

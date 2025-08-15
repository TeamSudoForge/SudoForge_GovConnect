import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  ManyToOne,
  JoinColumn,
  CreateDateColumn,
} from 'typeorm';
import { User } from '../../../../database/entities/user.entity';

@Entity('passkeys')
export class Passkey {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ name: 'user_id' })
  userId: string;

  @ManyToOne(() => User)
  @JoinColumn({ name: 'user_id' })
  user: User;

  @Column({ unique: true })
  credentialId: string;

  @Column({ type: 'text' })
  publicKey: string;

  @Column({ type: 'bigint' })
  counter: number;

  @Column({ type: 'simple-array', nullable: true })
  transports: string[];

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;
}

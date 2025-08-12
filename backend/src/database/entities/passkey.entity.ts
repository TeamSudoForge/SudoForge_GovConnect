import {
  Entity,
  Column,
  PrimaryGeneratedColumn,
  CreateDateColumn,
  UpdateDateColumn,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import { User } from './user.entity';

@Entity('passkeys')
export class Passkey {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ name: 'user_id' })
  userId: string;

  @Column({ name: 'credential_id', type: 'text' })
  credentialId: string;

  @Column({ name: 'credential_public_key', type: 'text' })
  credentialPublicKey: string;

  @Column({ name: 'credential_counter', type: 'bigint', default: 0 })
  credentialCounter: number;

  @Column({ name: 'credential_device_type', nullable: true })
  credentialDeviceType?: string;

  @Column({ name: 'credential_backed_up', type: 'boolean', default: false })
  credentialBackedUp: boolean;

  @Column({ name: 'transports', type: 'simple-array', nullable: true })
  transports?: string[];

  @Column({ name: 'display_name' })
  displayName: string;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt: Date;

  @ManyToOne(() => User, (user) => user.passkeys)
  @JoinColumn({ name: 'user_id' })
  user: User;
}

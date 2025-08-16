import {
  Entity,
  Column,
  PrimaryGeneratedColumn,
  CreateDateColumn,
  UpdateDateColumn,
  OneToMany,
} from 'typeorm';
import { AuthSession } from './auth-session.entity';
import { Passkey } from './passkey.entity';
import { Notification } from './notification.entity';

@Entity('users')
export class User {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ unique: true })
  username: string;

  @Column({ unique: true })
  email: string;

  @Column({ name: 'password_hash' })
  passwordHash: string;

  @Column({ name: 'first_name' })
  firstName: string;

  @Column({ name: 'last_name' })
  lastName: string;

  @Column({ default: 'user' })
  role: string;

  @Column({ name: 'is_two_factor_enabled', default: false })
  isTwoFactorEnabled: boolean;

  @Column({ name: 'is_email_verified', default: true })
  isEmailVerified: boolean;

  @Column({ name: 'fcm_token', type: 'varchar', nullable: true })
  fcmToken: string | null;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt: Date;

  @OneToMany(() => AuthSession, (session) => session.user)
  sessions: AuthSession[];

  @OneToMany(() => Passkey, (passkey) => passkey.user)
  passkeys: Passkey[];

  @OneToMany(() => Notification, (notification) => notification.user)
  notifications: Notification[];
}

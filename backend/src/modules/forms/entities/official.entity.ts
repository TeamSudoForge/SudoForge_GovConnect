import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  BeforeInsert,
  BeforeUpdate,
} from 'typeorm';
import * as bcrypt from 'bcryptjs';

@Entity('officials')
export class Official {
  @PrimaryGeneratedColumn()
  official_id: number;

  @Column()
  name: string;

  @Column({ unique: true })
  email: string;

  @Column()
  password_hash: string;

  @Column({ nullable: true })
  designation?: string;

  @Column({ nullable: true })
  department?: string;

  @Column({ nullable: true })
  contact_phone?: string;

  @Column({ default: true })
  isActive: boolean;

  @Column({ default: 'official' })
  role: string;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;

  // Hash password before saving
  @BeforeInsert()
  @BeforeUpdate()
  async hashPassword() {
    if (this.password_hash && !this.password_hash.startsWith('$2b$')) {
      const saltRounds = parseInt(process.env.BCRYPT_ROUNDS || '12', 10);
      this.password_hash = await bcrypt.hash(this.password_hash, saltRounds);
    }
  }

  // Method to validate password
  async validatePassword(password: string): Promise<boolean> {
    return bcrypt.compare(password, this.password_hash);
  }
}
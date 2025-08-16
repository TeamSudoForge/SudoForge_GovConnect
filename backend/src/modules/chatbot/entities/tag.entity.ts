import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  ManyToMany,
} from 'typeorm';
import { FaqQuestion } from './faq-question.entity';

@Entity('tags')
export class Tag {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ unique: true })
  name: string;

  @Column()
  nameEn: string;

  @Column()
  nameSi: string;

  @Column()
  nameTa: string;

  @Column()
  category: string;

  @Column({ nullable: true })
  icon?: string;

  @Column({ default: 0 })
  order: number;

  @Column({ default: true })
  isActive: boolean;

  @ManyToMany(() => FaqQuestion, faqQuestion => faqQuestion.tags)
  faqQuestions: FaqQuestion[];

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}
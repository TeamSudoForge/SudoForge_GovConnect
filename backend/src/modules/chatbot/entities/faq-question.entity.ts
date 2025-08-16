import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  ManyToMany,
  JoinTable,
} from 'typeorm';
import { Tag } from './tag.entity';

@Entity('faq_questions')
export class FaqQuestion {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ type: 'text' })
  questionEn: string;

  @Column({ type: 'text' })
  questionSi: string;

  @Column({ type: 'text' })
  questionTa: string;

  @Column({ type: 'text' })
  answerEn: string;

  @Column({ type: 'text' })
  answerSi: string;

  @Column({ type: 'text' })
  answerTa: string;

  @Column()
  category: string;

  @Column({ default: 0 })
  order: number;

  @Column({ default: 0 })
  viewCount: number;

  @Column({ default: true })
  isActive: boolean;

  @ManyToMany(() => Tag, tag => tag.faqQuestions)
  @JoinTable({
    name: 'faq_question_tags',
    joinColumn: { name: 'faqQuestionId', referencedColumnName: 'id' },
    inverseJoinColumn: { name: 'tagId', referencedColumnName: 'id' },
  })
  tags: Tag[];

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}
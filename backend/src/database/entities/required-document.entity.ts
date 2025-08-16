import { Entity, PrimaryGeneratedColumn, Column, ManyToOne } from 'typeorm';
import { Service } from 'src/modules/forms/entities/service.entity';

@Entity('required_documents')
export class RequiredDocument {
  @PrimaryGeneratedColumn()
  id: number;

  @ManyToOne(() => Service, (service) => service.requiredDocuments, {
    onDelete: 'CASCADE',
  })
  service: Service;

  @Column()
  name: string;
}

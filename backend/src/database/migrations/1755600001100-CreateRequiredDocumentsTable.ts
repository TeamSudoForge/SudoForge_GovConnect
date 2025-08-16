import { MigrationInterface, QueryRunner } from 'typeorm';

export class CreateRequiredDocumentsTable1755600001100
  implements MigrationInterface
{
  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`
      CREATE TABLE IF NOT EXISTS required_documents (
        id SERIAL PRIMARY KEY,
        service_id INT NOT NULL REFERENCES services(service_id) ON DELETE CASCADE,
        name VARCHAR(255) NOT NULL
      );
    `);
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`
      DROP TABLE IF EXISTS required_documents;
    `);
  }
}

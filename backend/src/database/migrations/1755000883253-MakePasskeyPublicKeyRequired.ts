import { MigrationInterface, QueryRunner, TableColumn } from 'typeorm';

export class MakePasskeyPublicKeyRequired1755000883253 implements MigrationInterface {
  public async up(queryRunner: QueryRunner): Promise<void> {
    // First, ensure any existing rows have a default value for public_key
    await queryRunner.query(`
      UPDATE passkeys 
      SET public_key = 'migration-placeholder' 
      WHERE public_key IS NULL OR public_key = ''
    `);

    // Then alter the column to be NOT NULL with a direct SQL command
    await queryRunner.query(`
      ALTER TABLE passkeys 
      ALTER COLUMN public_key SET NOT NULL
    `);
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    // Make the column nullable again if needed
    await queryRunner.query(`
      ALTER TABLE passkeys 
      ALTER COLUMN public_key DROP NOT NULL
    `);
  }
}

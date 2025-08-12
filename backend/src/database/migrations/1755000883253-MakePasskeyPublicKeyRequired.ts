import { MigrationInterface, QueryRunner, TableColumn } from 'typeorm';

export class MakePasskeyPublicKeyRequired1692841540003 implements MigrationInterface {
  public async up(queryRunner: QueryRunner): Promise<void> {
    // First, ensure any existing rows have a default value for public_key
    await queryRunner.query(`
      UPDATE passkeys 
      SET public_key = 'migration-placeholder' 
      WHERE public_key IS NULL
    `);

    // Then alter the column to be NOT NULL
    await queryRunner.changeColumn(
      'passkeys',
      'public_key',
      new TableColumn({
        name: 'public_key',
        type: 'text',
        isNullable: false,
      })
    );
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    // Make the column nullable again if needed
    await queryRunner.changeColumn(
      'passkeys',
      'public_key',
      new TableColumn({
        name: 'public_key',
        type: 'text',
        isNullable: true,
      })
    );
  }
}

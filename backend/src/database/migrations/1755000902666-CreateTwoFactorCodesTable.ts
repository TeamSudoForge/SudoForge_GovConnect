import { MigrationInterface, QueryRunner, Table, TableForeignKey } from 'typeorm';

export class CreateTwoFactorCodesTable1692841540004 implements MigrationInterface {
  public async up(queryRunner: QueryRunner): Promise<void> {
    // Check if the table already exists
    const tableExists = await queryRunner.hasTable('two_factor_codes');
    if (tableExists) {
      console.log('two_factor_codes table already exists, skipping creation');
      return;
    }

    // Create the table
    await queryRunner.createTable(
      new Table({
        name: 'two_factor_codes',
        columns: [
          {
            name: 'id',
            type: 'uuid',
            isPrimary: true,
            generationStrategy: 'uuid',
            default: 'uuid_generate_v4()',
          },
          {
            name: 'user_id',
            type: 'uuid',
            isNullable: false,
          },
          {
            name: 'code',
            type: 'varchar',
            length: '6',
            isNullable: false,
          },
          {
            name: 'expires_at',
            type: 'timestamp',
            isNullable: false,
          },
          {
            name: 'created_at',
            type: 'timestamp',
            default: 'now()',
            isNullable: false,
          },
        ],
      }),
    );

    // Create foreign key constraint
    await queryRunner.createForeignKey(
      'two_factor_codes',
      new TableForeignKey({
        columnNames: ['user_id'],
        referencedColumnNames: ['id'],
        referencedTableName: 'users',
        onDelete: 'CASCADE',
      }),
    );
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    // Check if the table exists before attempting to drop
    const tableExists = await queryRunner.hasTable('two_factor_codes');
    if (!tableExists) {
      return;
    }

    // Drop foreign keys first
    const table = await queryRunner.getTable('two_factor_codes');
    if (table) {
      const foreignKeys = table.foreignKeys.filter(
        (fk) => fk.columnNames.indexOf('user_id') !== -1,
      );
      
      for (const foreignKey of foreignKeys) {
        await queryRunner.dropForeignKey('two_factor_codes', foreignKey);
      }
    }

    // Drop the table
    await queryRunner.dropTable('two_factor_codes');
  }
}

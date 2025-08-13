import { MigrationInterface, QueryRunner, Table, TableForeignKey, TableColumn } from 'typeorm';

export class CreatePasskeysTable1692841540002 implements MigrationInterface {
  public async up(queryRunner: QueryRunner): Promise<void> {
    // Check if the table exists first
    const tableExists = await queryRunner.hasTable('passkeys');
    
    if (!tableExists) {
      await queryRunner.createTable(
        new Table({
          name: 'passkeys',
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
            },
            {
              name: 'credential_id',
              type: 'varchar',
              isUnique: true,
            },
            {
              name: 'public_key',
              type: 'text',
              isNullable: false,
              default: "'default-public-key'",
            },
            {
              name: 'counter',
              type: 'integer',
              default: 0,
            },
            {
              name: 'display_name',
              type: 'varchar',
            },
            {
              name: 'created_at',
              type: 'timestamp',
              default: 'now()',
            },
            {
              name: 'updated_at',
              type: 'timestamp',
              default: 'now()',
            },
          ],
        })
      );

      await queryRunner.createForeignKey(
        'passkeys',
        new TableForeignKey({
          columnNames: ['user_id'],
          referencedColumnNames: ['id'],
          referencedTableName: 'users',
          onDelete: 'CASCADE',
        })
      );
    } else {
      // Table exists, check if the column exists
      const table = await queryRunner.getTable('passkeys');
      if (table) {
        const publicKeyColumn = table.findColumnByName('public_key');
        
        if (!publicKeyColumn) {
          // First add the column as nullable
          await queryRunner.addColumn(
            'passkeys',
            new TableColumn({
              name: 'public_key',
              type: 'text',
              isNullable: true,
            })
          );
          
          // Then update all existing rows with a default value
          await queryRunner.query(`
            UPDATE passkeys 
            SET public_key = 'migration-placeholder-key' 
            WHERE public_key IS NULL
          `);
          
          // Finally alter the column to be NOT NULL
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
      }
    }
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    const table = await queryRunner.getTable('passkeys');
    if (table) {
      const foreignKey = table.foreignKeys.find(
        (fk) => fk.columnNames.indexOf('user_id') !== -1
      );
      if (foreignKey) {
        await queryRunner.dropForeignKey('passkeys', foreignKey);
      }
      await queryRunner.dropTable('passkeys');
    }
  }
}

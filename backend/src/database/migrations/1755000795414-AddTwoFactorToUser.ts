import { MigrationInterface, QueryRunner, TableColumn } from 'typeorm';

export class AddTwoFactorToUser1692841539000 implements MigrationInterface {
  public async up(queryRunner: QueryRunner): Promise<void> {
    // Check if the table exists
    const tableExists = await queryRunner.hasTable('users');
    if (!tableExists) {
      console.log('Users table does not exist, skipping AddTwoFactorToUser migration');
      return;
    }

    // Check if the column already exists
    const table = await queryRunner.getTable('users');
    const column = table?.findColumnByName('is_two_factor_enabled');
    
    if (!column) {
      await queryRunner.addColumn(
        'users',
        new TableColumn({
          name: 'is_two_factor_enabled',
          type: 'boolean',
          default: false,
          isNullable: false,
        }),
      );
      console.log('Added is_two_factor_enabled column to users table');
    } else {
      console.log('Column is_two_factor_enabled already exists in users table');
    }
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    // Check if the table exists
    const tableExists = await queryRunner.hasTable('users');
    if (!tableExists) {
      return;
    }

    // Check if the column exists before trying to drop it
    const table = await queryRunner.getTable('users');
    const column = table?.findColumnByName('is_two_factor_enabled');  
    if (column) {
      await queryRunner.dropColumn('users', 'is_two_factor_enabled');
    }
  }
}

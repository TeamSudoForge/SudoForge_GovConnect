import { MigrationInterface, QueryRunner, TableColumn, Table, Index } from 'typeorm';

export class AddEmailVerificationToUser1755094274512 implements MigrationInterface {
  public async up(queryRunner: QueryRunner): Promise<void> {
    // Check if the users table exists
    const tableExists = await queryRunner.hasTable('users');
    if (!tableExists) {
      console.log('Users table does not exist, skipping AddEmailVerificationToUser migration');
      return;
    }

    // Add is_email_verified column to users table
    const table = await queryRunner.getTable('users');
    const column = table?.findColumnByName('is_email_verified');
    
    if (!column) {
      await queryRunner.addColumn(
        'users',
        new TableColumn({
          name: 'is_email_verified',
          type: 'boolean',
          default: true, // Set existing users as verified for backward compatibility
          isNullable: false,
        }),
      );
      console.log('Added is_email_verified column to users table');
    } else {
      console.log('Column is_email_verified already exists in users table');
    }

    // Create email_verification_codes table
    const emailVerificationTableExists = await queryRunner.hasTable('email_verification_codes');
    if (!emailVerificationTableExists) {
      await queryRunner.createTable(
        new Table({
          name: 'email_verification_codes',
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
              default: 'NOW()',
              isNullable: false,
            },
            {
              name: 'last_sent_at',
              type: 'timestamp',
              default: 'NOW()',
              isNullable: false,
            },
          ],
          foreignKeys: [
            {
              columnNames: ['user_id'],
              referencedTableName: 'users',
              referencedColumnNames: ['id'],
              onDelete: 'CASCADE',
            },
          ],
        }),
        true,
      );

      // TODO: Create indexes for good performance
        // await queryRunner.createIndex(
        // 'email_verification_codes',
        // new Index({
        //     name: 'IDX_email_verification_codes_user_id',
        //     columnNames: ['user_id']
        // })
        // );

        // await queryRunner.createIndex(
        // 'email_verification_codes',
        // new Index({
        //     name: 'IDX_email_verification_codes_expires_at',
        //     columnNames: ['expires_at']
        // })
        // );

      console.log('Created email_verification_codes table with indexes');
    } else {
      console.log('email_verification_codes table already exists');
    }
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    // Drop email_verification_codes table
    const emailVerificationTableExists = await queryRunner.hasTable('email_verification_codes');
    if (emailVerificationTableExists) {
      await queryRunner.dropTable('email_verification_codes');
    }

    // Remove is_email_verified column from users table
    const tableExists = await queryRunner.hasTable('users');
    if (tableExists) {
      const table = await queryRunner.getTable('users');
      const column = table?.findColumnByName('is_email_verified');
      if (column) {
        await queryRunner.dropColumn('users', 'is_email_verified');
      }
    }
  }
}

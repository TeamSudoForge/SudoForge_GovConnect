import { MigrationInterface, QueryRunner, TableColumn } from 'typeorm';

export class AddPasskeyChallengeToUser1755000860000
  implements MigrationInterface
{
  public async up(queryRunner: QueryRunner): Promise<void> {
    // Check if the users table exists
    const tableExists = await queryRunner.hasTable('users');
    if (!tableExists) {
      console.log(
        'Users table does not exist, skipping AddPasskeyChallengeToUser migration',
      );
      return;
    }

    // Add passkey_challenge column to users table
    const table = await queryRunner.getTable('users');
    const column = table?.findColumnByName('passkey_challenge');

    if (!column) {
      await queryRunner.addColumn(
        'users',
        new TableColumn({
          name: 'passkey_challenge',
          type: 'text',
          isNullable: true,
        }),
      );
      console.log('Added passkey_challenge column to users table');
    } else {
      console.log('Column passkey_challenge already exists in users table');
    }
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    // Remove passkey_challenge column from users table
    const tableExists = await queryRunner.hasTable('users');
    if (tableExists) {
      const table = await queryRunner.getTable('users');
      const column = table?.findColumnByName('passkey_challenge');
      if (column) {
        await queryRunner.dropColumn('users', 'passkey_challenge');
        console.log('Removed passkey_challenge column from users table');
      }
    }
  }
}

import { MigrationInterface, QueryRunner, TableColumn } from 'typeorm';

export class AddFcmTokenToUser1755158400000 implements MigrationInterface {
  public async up(queryRunner: QueryRunner): Promise<void> {
    const table = await queryRunner.getTable('users');
    const fcmTokenColumn = table?.findColumnByName('fcm_token');
    
    if (!fcmTokenColumn) {
      await queryRunner.addColumn(
        'users',
        new TableColumn({
          name: 'fcm_token',
          type: 'varchar',
          isNullable: true,
        }),
      );
    }
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    const table = await queryRunner.getTable('users');
    const fcmTokenColumn = table?.findColumnByName('fcm_token');
    
    if (fcmTokenColumn) {
      await queryRunner.dropColumn('users', 'fcm_token');
    }
  }
}

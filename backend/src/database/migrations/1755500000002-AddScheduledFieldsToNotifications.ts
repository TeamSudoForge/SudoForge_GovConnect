import { MigrationInterface, QueryRunner, TableColumn } from 'typeorm';

export class AddScheduledFieldsToNotifications1755500000002
  implements MigrationInterface
{
  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.addColumn(
      'notifications',
      new TableColumn({
        name: 'scheduledAt',
        type: 'timestamp',
        isNullable: true,
      }),
    );
    await queryRunner.addColumn(
      'notifications',
      new TableColumn({
        name: 'sent',
        type: 'boolean',
        default: false,
      }),
    );
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.dropColumn('notifications', 'scheduledAt');
    await queryRunner.dropColumn('notifications', 'sent');
  }
}

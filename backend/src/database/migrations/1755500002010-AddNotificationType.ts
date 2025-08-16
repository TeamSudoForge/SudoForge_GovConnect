import { MigrationInterface, QueryRunner } from 'typeorm';

export class AddNotificationType1755500002010 implements MigrationInterface {
  name = 'AddNotificationType1755500002010';

  public async up(queryRunner: QueryRunner): Promise<void> {
    // Create the enum type
    await queryRunner.query(`
            CREATE TYPE "notification_type_enum" AS ENUM (
                'general',
                'appointment_confirmation',
                'appointment_reminder',
                'status_update',
                'document_request',
                'verification',
                'system'
            )
        `);

    // Add the column with default value
    await queryRunner.query(`
            ALTER TABLE "notifications"
            ADD COLUMN "type" "notification_type_enum" NOT NULL DEFAULT 'general'
        `);
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    // Remove the column first
    await queryRunner.query(`
            ALTER TABLE "notifications"
            DROP COLUMN "type"
        `);

    // Then drop the enum type
    await queryRunner.query(`
            DROP TYPE "notification_type_enum"
        `);
  }
}

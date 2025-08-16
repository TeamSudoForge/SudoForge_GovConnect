import { MigrationInterface, QueryRunner } from 'typeorm';

export class AddUserIdToNotificationsTable1755500002000 implements MigrationInterface {
  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`
      ALTER TABLE "notifications" DROP COLUMN IF EXISTS "userId";
    `);
    await queryRunner.query(`
      ALTER TABLE "notifications"
      ADD COLUMN "user_id" uuid;
    `);
    await queryRunner.query(`
      ALTER TABLE "notifications"
      ADD CONSTRAINT "FK_notifications_user_id" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE;
    `);
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`
      ALTER TABLE "notifications" ADD COLUMN "userId" uuid;
    `);
    await queryRunner.query(`
      ALTER TABLE "notifications" DROP CONSTRAINT "FK_notifications_user_id";
    `);
    await queryRunner.query(`
      ALTER TABLE "notifications" DROP COLUMN "user_id";
    `);
  }
}

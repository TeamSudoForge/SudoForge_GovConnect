import { MigrationInterface, QueryRunner } from "typeorm";

export class AddDepartmentAuth1755314544922 implements MigrationInterface {

    public async up(queryRunner: QueryRunner): Promise<void> {
        // Add authentication fields to departments table
        await queryRunner.query(`
            ALTER TABLE "departments" 
            ADD COLUMN "email" character varying,
            ADD COLUMN "password_hash" character varying,
            ADD COLUMN "isActive" boolean NOT NULL DEFAULT true,
            ADD COLUMN "role" character varying NOT NULL DEFAULT 'department'
        `);

        // Update existing departments with placeholder emails to make them unique
        await queryRunner.query(`
            UPDATE "departments" 
            SET "email" = 'dept-' || department_id || '@placeholder.gov',
                "password_hash" = '$2b$10$placeholder.hash.value.for.existing.departments'
            WHERE "email" IS NULL OR "email" = ''
        `);

        // Now make email NOT NULL and add unique constraint
        await queryRunner.query(`
            ALTER TABLE "departments" 
            ALTER COLUMN "email" SET NOT NULL,
            ALTER COLUMN "password_hash" SET NOT NULL
        `);

        // Add unique constraint on email
        await queryRunner.query(`
            ALTER TABLE "departments" 
            ADD CONSTRAINT "UQ_departments_email" UNIQUE ("email")
        `);
    }

    public async down(queryRunner: QueryRunner): Promise<void> {
        // Remove the unique constraint
        await queryRunner.query(`
            ALTER TABLE "departments" 
            DROP CONSTRAINT "UQ_departments_email"
        `);

        // Drop the authentication columns
        await queryRunner.query(`
            ALTER TABLE "departments" 
            DROP COLUMN "email",
            DROP COLUMN "password_hash",
            DROP COLUMN "isActive",
            DROP COLUMN "role"
        `);
    }

}

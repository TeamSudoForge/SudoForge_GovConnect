import { MigrationInterface, QueryRunner } from "typeorm";

export class CreateNewDynamicFormsTables1755500000001 implements MigrationInterface {

    public async up(queryRunner: QueryRunner): Promise<void> {
        // Create forms table
        await queryRunner.query(`
            CREATE TABLE "forms" (
                "id" uuid NOT NULL DEFAULT uuid_generate_v4(),
                "title" character varying(255) NOT NULL,
                "description" text,
                "isActive" boolean NOT NULL DEFAULT true,
                "version" integer NOT NULL DEFAULT 1,
                "metadata" json,
                "createdAt" TIMESTAMP NOT NULL DEFAULT now(),
                "updatedAt" TIMESTAMP NOT NULL DEFAULT now(),
                CONSTRAINT "PK_forms" PRIMARY KEY ("id")
            )
        `);

        // Create form_sections table
        await queryRunner.query(`
            CREATE TABLE "form_sections" (
                "id" uuid NOT NULL DEFAULT uuid_generate_v4(),
                "title" character varying(255) NOT NULL,
                "description" text,
                "pageNumber" integer NOT NULL DEFAULT 1,
                "orderIndex" integer NOT NULL DEFAULT 1,
                "formId" uuid NOT NULL,
                "createdAt" TIMESTAMP NOT NULL DEFAULT now(),
                "updatedAt" TIMESTAMP NOT NULL DEFAULT now(),
                CONSTRAINT "PK_form_sections" PRIMARY KEY ("id"),
                CONSTRAINT "FK_form_sections_formId" FOREIGN KEY ("formId") REFERENCES "forms"("id") ON DELETE CASCADE
            )
        `);

        // Create NEW form_fields table for dynamic forms (different from existing form_fields)
        await queryRunner.query(`
            CREATE TABLE "dynamic_form_fields" (
                "id" uuid NOT NULL DEFAULT uuid_generate_v4(),
                "label" character varying(255) NOT NULL,
                "fieldName" character varying(100) NOT NULL,
                "fieldType" character varying NOT NULL DEFAULT 'text',
                "isRequired" boolean NOT NULL DEFAULT false,
                "placeholder" text,
                "helpText" text,
                "orderIndex" integer NOT NULL DEFAULT 1,
                "validationRules" json,
                "options" json,
                "metadata" json,
                "sectionId" uuid NOT NULL,
                "createdAt" TIMESTAMP NOT NULL DEFAULT now(),
                "updatedAt" TIMESTAMP NOT NULL DEFAULT now(),
                CONSTRAINT "PK_dynamic_form_fields" PRIMARY KEY ("id"),
                CONSTRAINT "FK_dynamic_form_fields_sectionId" FOREIGN KEY ("sectionId") REFERENCES "form_sections"("id") ON DELETE CASCADE,
                CONSTRAINT "CHK_dynamic_form_fields_fieldType" CHECK ("fieldType" IN ('text', 'phone_number', 'email', 'document_upload', 'date', 'dropdown', 'radio_button', 'checkbox', 'textarea', 'number'))
            )
        `);

        // Create form_submissions table
        await queryRunner.query(`
            CREATE TABLE "form_submissions" (
                "id" uuid NOT NULL DEFAULT uuid_generate_v4(),
                "formId" uuid NOT NULL,
                "userId" uuid NOT NULL,
                "status" character varying NOT NULL DEFAULT 'draft',
                "fieldValues" json NOT NULL DEFAULT '[]',
                "submittedAt" TIMESTAMP,
                "createdAt" TIMESTAMP NOT NULL DEFAULT now(),
                "updatedAt" TIMESTAMP NOT NULL DEFAULT now(),
                CONSTRAINT "PK_form_submissions" PRIMARY KEY ("id"),
                CONSTRAINT "FK_form_submissions_formId" FOREIGN KEY ("formId") REFERENCES "forms"("id") ON DELETE CASCADE,
                CONSTRAINT "FK_form_submissions_userId" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE CASCADE,
                CONSTRAINT "CHK_form_submissions_status" CHECK ("status" IN ('draft', 'submitted', 'under_review', 'approved', 'rejected'))
            )
        `);

        // Create indexes for better performance
        await queryRunner.query(`CREATE INDEX "IDX_form_sections_formId" ON "form_sections" ("formId")`);
        await queryRunner.query(`CREATE INDEX "IDX_dynamic_form_fields_sectionId" ON "dynamic_form_fields" ("sectionId")`);
        await queryRunner.query(`CREATE INDEX "IDX_form_submissions_formId" ON "form_submissions" ("formId")`);
        await queryRunner.query(`CREATE INDEX "IDX_form_submissions_userId" ON "form_submissions" ("userId")`);
        await queryRunner.query(`CREATE INDEX "IDX_form_submissions_status" ON "form_submissions" ("status")`);
    }

    public async down(queryRunner: QueryRunner): Promise<void> {
        // Drop indexes
        await queryRunner.query(`DROP INDEX "IDX_form_submissions_status"`);
        await queryRunner.query(`DROP INDEX "IDX_form_submissions_userId"`);
        await queryRunner.query(`DROP INDEX "IDX_form_submissions_formId"`);
        await queryRunner.query(`DROP INDEX "IDX_dynamic_form_fields_sectionId"`);
        await queryRunner.query(`DROP INDEX "IDX_form_sections_formId"`);

        // Drop tables in reverse order due to foreign key constraints
        await queryRunner.query(`DROP TABLE "form_submissions"`);
        await queryRunner.query(`DROP TABLE "dynamic_form_fields"`);
        await queryRunner.query(`DROP TABLE "form_sections"`);
        await queryRunner.query(`DROP TABLE "forms"`);
    }
}

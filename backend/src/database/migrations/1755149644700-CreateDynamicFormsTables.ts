import { MigrationInterface, QueryRunner } from "typeorm";

export class CreateDynamicFormsTables1755149644700 implements MigrationInterface {

    public async up(queryRunner: QueryRunner): Promise<void> {
        // Create departments table
        await queryRunner.query(`
          CREATE TABLE "departments" (
            "department_id" SERIAL NOT NULL,
            "name" character varying NOT NULL,
            "description" text,
            "contact_email" character varying,
            "contact_phone" character varying,
            "created_at" TIMESTAMP NOT NULL DEFAULT now(),
            "updated_at" TIMESTAMP NOT NULL DEFAULT now(),
            CONSTRAINT "PK_departments" PRIMARY KEY ("department_id")
          )
        `);

        // Create field_types table
        await queryRunner.query(`
          CREATE TABLE "field_types" (
            "ftype_id" SERIAL NOT NULL,
            "name" character varying NOT NULL,
            "description" character varying,
            "created_at" TIMESTAMP NOT NULL DEFAULT now(),
            "updated_at" TIMESTAMP NOT NULL DEFAULT now(),
            CONSTRAINT "PK_field_types" PRIMARY KEY ("ftype_id"),
            CONSTRAINT "UQ_field_types_name" UNIQUE ("name")
          )
        `);

        // Create fields table
        await queryRunner.query(`
          CREATE TABLE "fields" (
            "field_id" SERIAL NOT NULL,
            "ftype_id" integer NOT NULL,
            "label" character varying NOT NULL,
            "placeholder" character varying,
            "is_required" boolean NOT NULL DEFAULT false,
            "created_at" TIMESTAMP NOT NULL DEFAULT now(),
            "updated_at" TIMESTAMP NOT NULL DEFAULT now(),
            CONSTRAINT "PK_fields" PRIMARY KEY ("field_id")
          )
        `);

        // Create field_attributes table
        await queryRunner.query(`
          CREATE TABLE "field_attributes" (
            "attr_id" SERIAL NOT NULL,
            "field_id" integer NOT NULL,
            "attr_key" character varying NOT NULL,
            "attr_value" character varying NOT NULL,
            "created_at" TIMESTAMP NOT NULL DEFAULT now(),
            "updated_at" TIMESTAMP NOT NULL DEFAULT now(),
            CONSTRAINT "PK_field_attributes" PRIMARY KEY ("attr_id")
          )
        `);

        // Create services table
        await queryRunner.query(`
          CREATE TABLE "services" (
            "service_id" SERIAL NOT NULL,
            "name" character varying NOT NULL,
            "description" text NOT NULL,
            "department_id" integer NOT NULL,
            "is_active" boolean NOT NULL DEFAULT true,
            "created_at" TIMESTAMP NOT NULL DEFAULT now(),
            "updated_at" TIMESTAMP NOT NULL DEFAULT now(),
            CONSTRAINT "PK_services" PRIMARY KEY ("service_id")
          )
        `);

        // Create form_fields table
        await queryRunner.query(`
          CREATE TABLE "form_fields" (
            "form_field_id" SERIAL NOT NULL,
            "service_id" integer NOT NULL,
            "field_id" integer NOT NULL,
            "order_index" integer NOT NULL,
            "section" character varying,
            "created_at" TIMESTAMP NOT NULL DEFAULT now(),
            "updated_at" TIMESTAMP NOT NULL DEFAULT now(),
            CONSTRAINT "PK_form_fields" PRIMARY KEY ("form_field_id")
          )
        `);

        // Create form_responses table
        await queryRunner.query(`
          CREATE TABLE "form_responses" (
            "response_id" SERIAL NOT NULL,
            "service_id" integer NOT NULL,
            "user_id" uuid NOT NULL,
            "status" character varying NOT NULL DEFAULT 'pending',
            "submitted_at" TIMESTAMP NOT NULL DEFAULT now(),
            "updated_at" TIMESTAMP NOT NULL DEFAULT now(),
            CONSTRAINT "PK_form_responses" PRIMARY KEY ("response_id")
          )
        `);

        // Create form_response_values table
        await queryRunner.query(`
          CREATE TABLE "form_response_values" (
            "value_id" SERIAL NOT NULL,
            "response_id" integer NOT NULL,
            "field_id" integer NOT NULL,
            "value" text NOT NULL,
            "created_at" TIMESTAMP NOT NULL DEFAULT now(),
            CONSTRAINT "PK_form_response_values" PRIMARY KEY ("value_id")
          )
        `);

        // Add foreign key constraints
        await queryRunner.query(`
          ALTER TABLE "fields" ADD CONSTRAINT "FK_fields_field_type" 
          FOREIGN KEY ("ftype_id") REFERENCES "field_types"("ftype_id") ON DELETE CASCADE ON UPDATE NO ACTION
        `);

        await queryRunner.query(`
          ALTER TABLE "field_attributes" ADD CONSTRAINT "FK_field_attributes_field" 
          FOREIGN KEY ("field_id") REFERENCES "fields"("field_id") ON DELETE CASCADE ON UPDATE NO ACTION
        `);

        await queryRunner.query(`
          ALTER TABLE "services" ADD CONSTRAINT "FK_services_department" 
          FOREIGN KEY ("department_id") REFERENCES "departments"("department_id") ON DELETE CASCADE ON UPDATE NO ACTION
        `);

        await queryRunner.query(`
          ALTER TABLE "form_fields" ADD CONSTRAINT "FK_form_fields_service" 
          FOREIGN KEY ("service_id") REFERENCES "services"("service_id") ON DELETE CASCADE ON UPDATE NO ACTION
        `);

        await queryRunner.query(`
          ALTER TABLE "form_fields" ADD CONSTRAINT "FK_form_fields_field" 
          FOREIGN KEY ("field_id") REFERENCES "fields"("field_id") ON DELETE CASCADE ON UPDATE NO ACTION
        `);

        await queryRunner.query(`
          ALTER TABLE "form_responses" ADD CONSTRAINT "FK_form_responses_service" 
          FOREIGN KEY ("service_id") REFERENCES "services"("service_id") ON DELETE CASCADE ON UPDATE NO ACTION
        `);

        await queryRunner.query(`
          ALTER TABLE "form_responses" ADD CONSTRAINT "FK_form_responses_user" 
          FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE NO ACTION
        `);

        await queryRunner.query(`
          ALTER TABLE "form_response_values" ADD CONSTRAINT "FK_form_response_values_response" 
          FOREIGN KEY ("response_id") REFERENCES "form_responses"("response_id") ON DELETE CASCADE ON UPDATE NO ACTION
        `);

        await queryRunner.query(`
          ALTER TABLE "form_response_values" ADD CONSTRAINT "FK_form_response_values_field" 
          FOREIGN KEY ("field_id") REFERENCES "fields"("field_id") ON DELETE CASCADE ON UPDATE NO ACTION
        `);

        // Create indexes for better performance
        await queryRunner.query(`CREATE INDEX "IDX_fields_ftype_id" ON "fields" ("ftype_id")`);
        await queryRunner.query(`CREATE INDEX "IDX_field_attributes_field_id" ON "field_attributes" ("field_id")`);
        await queryRunner.query(`CREATE INDEX "IDX_services_department_id" ON "services" ("department_id")`);
        await queryRunner.query(`CREATE INDEX "IDX_form_fields_service_id" ON "form_fields" ("service_id")`);
        await queryRunner.query(`CREATE INDEX "IDX_form_fields_field_id" ON "form_fields" ("field_id")`);
        await queryRunner.query(`CREATE INDEX "IDX_form_responses_service_id" ON "form_responses" ("service_id")`);
        await queryRunner.query(`CREATE INDEX "IDX_form_responses_user_id" ON "form_responses" ("user_id")`);
        await queryRunner.query(`CREATE INDEX "IDX_form_responses_submitted_at" ON "form_responses" ("submitted_at")`);
        await queryRunner.query(`CREATE INDEX "IDX_form_response_values_response_id" ON "form_response_values" ("response_id")`);
        await queryRunner.query(`CREATE INDEX "IDX_form_response_values_field_id" ON "form_response_values" ("field_id")`);

        // Seed field types
        await queryRunner.query(`
          INSERT INTO "field_types" ("name", "description") VALUES 
          ('text', 'Text input field'),
          ('number', 'Numeric input field'),
          ('email', 'Email input field'),
          ('password', 'Password input field'),
          ('textarea', 'Multi-line text area'),
          ('select', 'Dropdown selection'),
          ('radio', 'Radio button selection'),
          ('checkbox', 'Checkbox input'),
          ('file', 'File upload'),
          ('date', 'Date picker'),
          ('datetime', 'Date and time picker'),
          ('time', 'Time picker'),
          ('url', 'URL input'),
          ('tel', 'Telephone number'),
          ('range', 'Range slider'),
          ('color', 'Color picker'),
          ('hidden', 'Hidden field')
        `);

        // Add update triggers
        await queryRunner.query(`
          CREATE TRIGGER update_departments_updated_at BEFORE UPDATE ON departments 
          FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();
        `);

        await queryRunner.query(`
          CREATE TRIGGER update_field_types_updated_at BEFORE UPDATE ON field_types 
          FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();
        `);

        await queryRunner.query(`
          CREATE TRIGGER update_fields_updated_at BEFORE UPDATE ON fields 
          FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();
        `);

        await queryRunner.query(`
          CREATE TRIGGER update_field_attributes_updated_at BEFORE UPDATE ON field_attributes 
          FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();
        `);

        await queryRunner.query(`
          CREATE TRIGGER update_services_updated_at BEFORE UPDATE ON services 
          FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();
        `);

        await queryRunner.query(`
          CREATE TRIGGER update_form_fields_updated_at BEFORE UPDATE ON form_fields 
          FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();
        `);

        await queryRunner.query(`
          CREATE TRIGGER update_form_responses_updated_at BEFORE UPDATE ON form_responses 
          FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();
        `);
    }

    public async down(queryRunner: QueryRunner): Promise<void> {
        // Drop triggers
        await queryRunner.query(`DROP TRIGGER IF EXISTS update_form_responses_updated_at ON form_responses`);
        await queryRunner.query(`DROP TRIGGER IF EXISTS update_form_fields_updated_at ON form_fields`);
        await queryRunner.query(`DROP TRIGGER IF EXISTS update_services_updated_at ON services`);
        await queryRunner.query(`DROP TRIGGER IF EXISTS update_field_attributes_updated_at ON field_attributes`);
        await queryRunner.query(`DROP TRIGGER IF EXISTS update_fields_updated_at ON fields`);
        await queryRunner.query(`DROP TRIGGER IF EXISTS update_field_types_updated_at ON field_types`);
        await queryRunner.query(`DROP TRIGGER IF EXISTS update_departments_updated_at ON departments`);

        // Drop indexes
        await queryRunner.query(`DROP INDEX "IDX_form_response_values_field_id"`);
        await queryRunner.query(`DROP INDEX "IDX_form_response_values_response_id"`);
        await queryRunner.query(`DROP INDEX "IDX_form_responses_submitted_at"`);
        await queryRunner.query(`DROP INDEX "IDX_form_responses_user_id"`);
        await queryRunner.query(`DROP INDEX "IDX_form_responses_service_id"`);
        await queryRunner.query(`DROP INDEX "IDX_form_fields_field_id"`);
        await queryRunner.query(`DROP INDEX "IDX_form_fields_service_id"`);
        await queryRunner.query(`DROP INDEX "IDX_services_department_id"`);
        await queryRunner.query(`DROP INDEX "IDX_field_attributes_field_id"`);
        await queryRunner.query(`DROP INDEX "IDX_fields_ftype_id"`);

        // Drop foreign key constraints and tables in reverse order
        await queryRunner.query(`ALTER TABLE "form_response_values" DROP CONSTRAINT "FK_form_response_values_field"`);
        await queryRunner.query(`ALTER TABLE "form_response_values" DROP CONSTRAINT "FK_form_response_values_response"`);
        await queryRunner.query(`ALTER TABLE "form_responses" DROP CONSTRAINT "FK_form_responses_user"`);
        await queryRunner.query(`ALTER TABLE "form_responses" DROP CONSTRAINT "FK_form_responses_service"`);
        await queryRunner.query(`ALTER TABLE "form_fields" DROP CONSTRAINT "FK_form_fields_field"`);
        await queryRunner.query(`ALTER TABLE "form_fields" DROP CONSTRAINT "FK_form_fields_service"`);
        await queryRunner.query(`ALTER TABLE "services" DROP CONSTRAINT "FK_services_department"`);
        await queryRunner.query(`ALTER TABLE "field_attributes" DROP CONSTRAINT "FK_field_attributes_field"`);
        await queryRunner.query(`ALTER TABLE "fields" DROP CONSTRAINT "FK_fields_field_type"`);

        await queryRunner.query(`DROP TABLE "form_response_values"`);
        await queryRunner.query(`DROP TABLE "form_responses"`);
        await queryRunner.query(`DROP TABLE "form_fields"`);
        await queryRunner.query(`DROP TABLE "services"`);
        await queryRunner.query(`DROP TABLE "field_attributes"`);
        await queryRunner.query(`DROP TABLE "fields"`);
        await queryRunner.query(`DROP TABLE "field_types"`);
        await queryRunner.query(`DROP TABLE "departments"`);
    }

}

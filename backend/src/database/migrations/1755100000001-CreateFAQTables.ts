import { MigrationInterface, QueryRunner } from 'typeorm';

export class CreateFAQTables1755100000001 implements MigrationInterface {
  name = 'CreateFAQTables1755100000001';

  public async up(queryRunner: QueryRunner): Promise<void> {
    // Create tags table
    await queryRunner.query(`
      CREATE TABLE "tags" (
        "id" uuid NOT NULL DEFAULT uuid_generate_v4(),
        "name" character varying NOT NULL,
        "nameEn" character varying NOT NULL,
        "nameSi" character varying NOT NULL,
        "nameTa" character varying NOT NULL,
        "category" character varying NOT NULL,
        "icon" character varying,
        "order" integer NOT NULL DEFAULT 0,
        "isActive" boolean NOT NULL DEFAULT true,
        "createdAt" TIMESTAMP NOT NULL DEFAULT now(),
        "updatedAt" TIMESTAMP NOT NULL DEFAULT now(),
        CONSTRAINT "UQ_tag_name" UNIQUE ("name"),
        CONSTRAINT "PK_tags" PRIMARY KEY ("id")
      )
    `);

    // Create FAQ questions table
    await queryRunner.query(`
      CREATE TABLE "faq_questions" (
        "id" uuid NOT NULL DEFAULT uuid_generate_v4(),
        "questionEn" text NOT NULL,
        "questionSi" text NOT NULL,
        "questionTa" text NOT NULL,
        "answerEn" text NOT NULL,
        "answerSi" text NOT NULL,
        "answerTa" text NOT NULL,
        "category" character varying NOT NULL,
        "order" integer NOT NULL DEFAULT 0,
        "viewCount" integer NOT NULL DEFAULT 0,
        "isActive" boolean NOT NULL DEFAULT true,
        "createdAt" TIMESTAMP NOT NULL DEFAULT now(),
        "updatedAt" TIMESTAMP NOT NULL DEFAULT now(),
        CONSTRAINT "PK_faq_questions" PRIMARY KEY ("id")
      )
    `);

    // Create many-to-many relation table for FAQ questions and tags
    await queryRunner.query(`
      CREATE TABLE "faq_question_tags" (
        "faqQuestionId" uuid NOT NULL,
        "tagId" uuid NOT NULL,
        CONSTRAINT "PK_faq_question_tags" PRIMARY KEY ("faqQuestionId", "tagId")
      )
    `);

    // Create indexes
    await queryRunner.query(`CREATE INDEX "IDX_faq_questions_category" ON "faq_questions" ("category")`);
    await queryRunner.query(`CREATE INDEX "IDX_tags_category" ON "tags" ("category")`);
    await queryRunner.query(`CREATE INDEX "IDX_faq_question_tags_faqQuestionId" ON "faq_question_tags" ("faqQuestionId")`);
    await queryRunner.query(`CREATE INDEX "IDX_faq_question_tags_tagId" ON "faq_question_tags" ("tagId")`);

    // Add foreign keys
    await queryRunner.query(`
      ALTER TABLE "faq_question_tags"
      ADD CONSTRAINT "FK_faq_question_tags_faqQuestionId"
      FOREIGN KEY ("faqQuestionId") REFERENCES "faq_questions"("id")
      ON DELETE CASCADE ON UPDATE NO ACTION
    `);

    await queryRunner.query(`
      ALTER TABLE "faq_question_tags"
      ADD CONSTRAINT "FK_faq_question_tags_tagId"
      FOREIGN KEY ("tagId") REFERENCES "tags"("id")
      ON DELETE CASCADE ON UPDATE NO ACTION
    `);
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`ALTER TABLE "faq_question_tags" DROP CONSTRAINT "FK_faq_question_tags_tagId"`);
    await queryRunner.query(`ALTER TABLE "faq_question_tags" DROP CONSTRAINT "FK_faq_question_tags_faqQuestionId"`);
    await queryRunner.query(`DROP INDEX "IDX_faq_question_tags_tagId"`);
    await queryRunner.query(`DROP INDEX "IDX_faq_question_tags_faqQuestionId"`);
    await queryRunner.query(`DROP INDEX "IDX_tags_category"`);
    await queryRunner.query(`DROP INDEX "IDX_faq_questions_category"`);
    await queryRunner.query(`DROP TABLE "faq_question_tags"`);
    await queryRunner.query(`DROP TABLE "faq_questions"`);
    await queryRunner.query(`DROP TABLE "tags"`);
  }
}
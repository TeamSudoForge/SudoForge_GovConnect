import { MigrationInterface, QueryRunner } from "typeorm";

export class CreateChatTables1755100000000 implements MigrationInterface {
    name = 'CreateChatTables1755100000000'

    public async up(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`CREATE TABLE "chat_sessions" ("id" uuid NOT NULL DEFAULT uuid_generate_v4(), "userId" uuid, "title" character varying(100) NOT NULL, "status" character varying(20) NOT NULL DEFAULT 'active', "createdAt" TIMESTAMP NOT NULL DEFAULT now(), "updatedAt" TIMESTAMP NOT NULL DEFAULT now(), "context" jsonb, CONSTRAINT "PK_chat_sessions_id" PRIMARY KEY ("id"))`);
        await queryRunner.query(`CREATE TABLE "chat_messages" ("id" uuid NOT NULL DEFAULT uuid_generate_v4(), "userId" uuid, "message" text NOT NULL, "sender" character varying(20) NOT NULL, "sessionId" uuid, "createdAt" TIMESTAMP NOT NULL DEFAULT now(), "metadata" jsonb, CONSTRAINT "PK_chat_messages_id" PRIMARY KEY ("id"))`);
        await queryRunner.query(`ALTER TABLE "chat_sessions" ADD CONSTRAINT "FK_chat_sessions_userId" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE NO ACTION ON UPDATE NO ACTION`);
        await queryRunner.query(`ALTER TABLE "chat_messages" ADD CONSTRAINT "FK_chat_messages_userId" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE NO ACTION ON UPDATE NO ACTION`);
        await queryRunner.query(`CREATE INDEX "IDX_chat_sessions_userId" ON "chat_sessions" ("userId")`);
        await queryRunner.query(`CREATE INDEX "IDX_chat_messages_sessionId" ON "chat_messages" ("sessionId")`);
    }

    public async down(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`DROP INDEX "IDX_chat_messages_sessionId"`);
        await queryRunner.query(`DROP INDEX "IDX_chat_sessions_userId"`);
        await queryRunner.query(`ALTER TABLE "chat_messages" DROP CONSTRAINT "FK_chat_messages_userId"`);
        await queryRunner.query(`ALTER TABLE "chat_sessions" DROP CONSTRAINT "FK_chat_sessions_userId"`);
        await queryRunner.query(`DROP TABLE "chat_messages"`);
        await queryRunner.query(`DROP TABLE "chat_sessions"`);
    }
}
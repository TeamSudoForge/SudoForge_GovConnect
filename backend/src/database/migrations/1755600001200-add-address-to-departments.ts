import { MigrationInterface, QueryRunner } from 'typeorm';

export class AddAddressToDepartments1755600001200
  implements MigrationInterface
{
  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `ALTER TABLE "departments" ADD COLUMN "address" varchar(255) NULL`,
    );
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`ALTER TABLE "departments" DROP COLUMN "address"`);
  }
}

import { MigrationInterface, QueryRunner, TableColumn } from "typeorm";

export class AddTwoFactorToUser1754976669702 implements MigrationInterface {

    public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.addColumn(
      'users',
      new TableColumn({
        name: 'is_two_factor_enabled',
        type: 'boolean',
        default: false,
        isNullable: false,
      }),
    );
    }

    public async down(queryRunner: QueryRunner): Promise<void> {
            await queryRunner.dropColumn('users', 'is_two_factor_enabled');
    }

}

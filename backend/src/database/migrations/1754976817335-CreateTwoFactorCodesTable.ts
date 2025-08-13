import { MigrationInterface, QueryRunner, Table, TableForeignKey } from "typeorm";

export class CreateTwoFactorCodesTable1754976817335 implements MigrationInterface {

    public async up(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.createTable(
              new Table({
                name: 'two_factor_codes',
                columns: [
                  {
                    name: 'id',
                    type: 'uuid',
                    isPrimary: true,
                    generationStrategy: 'uuid',
                    default: 'uuid_generate_v4()',
                  },
                  {
                    name: 'user_id',
                    type: 'uuid',
                  },
                  {
                    name: 'code',
                    type: 'varchar',
                    length: '6',
                  },
                  {
                    name: 'expires_at',
                    type: 'timestamp',
                  },
                  {
                    name: 'created_at',
                    type: 'timestamp',
                    default: 'now()',
                  },
                ],
              }),
            );

            await queryRunner.createForeignKey(
                  'two_factor_codes',
                  new TableForeignKey({
                    columnNames: ['user_id'],
                    referencedColumnNames: ['id'],
                    referencedTableName: 'users',
                    onDelete: 'CASCADE',
                  }),
                );
    }

    public async down(queryRunner: QueryRunner): Promise<void> {
            await queryRunner.dropTable('two_factor_codes');
    }

}

import { MigrationInterface, QueryRunner } from 'typeorm';

export class CreateAppointmentsAndTimeslotsTables1755600001000
  implements MigrationInterface
{
  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`
      CREATE TABLE IF NOT EXISTS timeslots (
        id SERIAL PRIMARY KEY,
        service_id INT NOT NULL REFERENCES services(service_id) ON DELETE CASCADE,
        start_at TIMESTAMPTZ NOT NULL,
        end_at TIMESTAMPTZ NOT NULL,
        capacity INT NOT NULL DEFAULT 1,
        reserved_count INT NOT NULL DEFAULT 0,
        CONSTRAINT timeslot_unique UNIQUE (service_id, start_at)
      );

      CREATE TABLE IF NOT EXISTS appointments (
        id SERIAL PRIMARY KEY,
        ref VARCHAR(50) UNIQUE NOT NULL,
        user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
        service_id INT NOT NULL REFERENCES services(service_id) ON DELETE CASCADE,
        department_id INT NOT NULL REFERENCES departments(department_id) ON DELETE CASCADE,
        timeslot_id INT NOT NULL REFERENCES timeslots(id) ON DELETE CASCADE,
        status VARCHAR(20) NOT NULL CHECK (status IN ('CONFIRMED','CANCELLED')) DEFAULT 'CONFIRMED',
        qr_code_url TEXT,
        created_at TIMESTAMPTZ DEFAULT now()
      );
    `);
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`
      DROP TABLE IF EXISTS appointments;
      DROP TABLE IF EXISTS timeslots;
    `);
  }
}

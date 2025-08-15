import { DataSource } from 'typeorm';
import { ConfigService } from '@nestjs/config';
import * as dotenv from 'dotenv';

dotenv.config();

const configService = new ConfigService();

// Determine if we're in development mode
const isDevelopment = configService.get('NODE_ENV') !== 'production';

export default new DataSource({
  type: 'postgres',
  host: configService.get('DB_HOST', 'localhost'),
  port: configService.get('DB_PORT', 5432),
  username: configService.get('DB_USERNAME', 'postgres'),
  password: configService.get('DB_PASSWORD', 'password'),
  database: configService.get('DB_NAME', 'govconnect'),
  entities: isDevelopment
    ? ['src/**/*.entity{.ts,.js}']
    : ['dist/**/*.entity{.ts,.js}'],
  migrations: isDevelopment
    ? ['src/database/migrations/*{.ts,.js}']
    : ['dist/database/migrations/*{.ts,.js}'],
  migrationsTableName: 'typeorm_migrations',
  synchronize: false,
});

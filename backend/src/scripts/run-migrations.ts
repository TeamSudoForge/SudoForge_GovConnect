import { DataSource } from 'typeorm';
import * as dotenv from 'dotenv';
import * as path from 'path';

// Load environment variables
dotenv.config();

// Create a separate connection for running migrations
const dataSource = new DataSource({
  type: 'postgres',
  host: process.env.DB_HOST || 'localhost',
  port: parseInt(process.env.DB_PORT || '5432'),
  username: process.env.DB_USERNAME || 'postgres',
  password: process.env.DB_PASSWORD || 'password',
  database: process.env.DB_NAME || 'govconnect',
  entities: [path.join(__dirname, '..', 'database', 'entities', '*.entity{.ts,.js}')],
  migrations: [path.join(__dirname, '..', 'database', 'migrations', '*{.ts,.js}')],
  synchronize: false,
  logging: true,
});

async function runMigrations() {
  try {
    console.log('Initializing data source...');
    await dataSource.initialize();
    console.log('Data source initialized');

    console.log('Running migrations...');
    const migrations = await dataSource.runMigrations();
    
    if (migrations.length === 0) {
      console.log('No pending migrations to run');
    } else {
      console.log(`Successfully ran ${migrations.length} migrations:`);
      migrations.forEach(migration => {
        console.log(`- ${migration.name}`);
      });
    }
    
    await dataSource.destroy();
    process.exit(0);
  } catch (error) {
    console.error('Error running migrations:', error);
    if (dataSource.isInitialized) {
      await dataSource.destroy();
    }
    process.exit(1);
  }
}

runMigrations();

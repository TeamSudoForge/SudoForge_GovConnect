import { DataSource } from 'typeorm';
import * as dotenv from 'dotenv';
import * as path from 'path';
import * as fs from 'fs';

dotenv.config();

// Create a connection to the database
const dataSource = new DataSource({
  type: 'postgres',
  host: process.env.DB_HOST || 'localhost',
  port: parseInt(process.env.DB_PORT || '5432'),
  username: process.env.DB_USERNAME || 'postgres',
  password: process.env.DB_PASSWORD || 'password',
  database: process.env.DB_NAME || 'govconnect',
  synchronize: false,
  logging: true,
});

async function initializeMigrationsTable() {
  try {
    // Initialize the connection
    await dataSource.initialize();
    console.log('Connected to database');

    // Check if migrations table exists
    const migrationsTableExists = await dataSource.query(`
      SELECT EXISTS (
        SELECT FROM information_schema.tables 
        WHERE table_schema = 'public' 
        AND table_name = 'migrations'
      );
    `);

    if (!migrationsTableExists[0].exists) {
      console.log('Creating migrations table...');
      
      // Create the migrations table with the structure TypeORM expects
      await dataSource.query(`
        CREATE TABLE "migrations" (
          "id" SERIAL PRIMARY KEY,
          "timestamp" bigint NOT NULL,
          "name" character varying NOT NULL
        );
      `);
      
      console.log('Migrations table created successfully');
    } else {
      console.log('Migrations table already exists');
    }

    // Ensure uuid-ossp extension exists (needed for UUID generation)
    try {
      await dataSource.query(`CREATE EXTENSION IF NOT EXISTS "uuid-ossp"`);
      console.log('Ensured uuid-ossp extension exists');
    } catch (error) {
      console.warn('Could not create uuid-ossp extension:', error.message);
    }

    // Check if we need to run any migrations
    const migrationsDir = path.join(__dirname, '..', 'database', 'migrations');
    if (!fs.existsSync(migrationsDir)) {
      console.log('Migrations directory does not exist:', migrationsDir);
      await dataSource.destroy();
      return;
    }

    const migrationFiles = fs.readdirSync(migrationsDir)
      .filter(file => file.endsWith('.ts') || file.endsWith('.js'))
      .sort();

    if (migrationFiles.length === 0) {
      console.log('No migration files found');
      await dataSource.destroy();
      return;
    }

    // Get applied migrations
    const appliedMigrations = await dataSource.query(`
      SELECT name FROM migrations ORDER BY timestamp ASC
    `);
    
    const appliedMigrationNames = appliedMigrations.map(m => m.name);

    console.log('Found', migrationFiles.length, 'migration files');
    console.log('Applied migrations:', appliedMigrationNames.length);

    await dataSource.destroy();
    console.log('Database connection closed');
    console.log('\nNext steps:');
    console.log('1. Run migrations: npm run migration:run');
    console.log('2. Verify tables were created: npm run db:migration-status');
  } catch (error) {
    console.error('Error initializing migrations table:', error);
    if (dataSource.isInitialized) {
      await dataSource.destroy();
    }
    process.exit(1);
  }
}

// Run the function
initializeMigrationsTable();

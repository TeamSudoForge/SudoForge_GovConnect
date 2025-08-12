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
  logging: false,
});

async function checkMigrationStatus() {
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
      console.log(' Migrations table does not exist - no migrations have been run');
      await dataSource.destroy();
      return;
    }

    const appliedMigrations = await dataSource.query(`
      SELECT name, timestamp FROM migrations ORDER BY timestamp ASC
    `);

    console.log('\n Applied migrations:');
    if (appliedMigrations.length === 0) {
      console.log('   No migrations have been applied yet');
    } else {
      appliedMigrations.forEach(migration => {
        console.log(`   ${migration.name} (${new Date(parseInt(migration.timestamp)).toISOString()})`);
      });
    }

    // Get available migration files
    const migrationsDir = path.join(__dirname, '..', 'database', 'migrations');
    if (!fs.existsSync(migrationsDir)) {
      console.log('\n Migrations directory does not exist:', migrationsDir);
      await dataSource.destroy();
      return;
    }

    const migrationFiles = fs.readdirSync(migrationsDir)
      .filter(file => file.endsWith('.ts') || file.endsWith('.js'))
      .sort();

    console.log('\n Available migration files:');
    if (migrationFiles.length === 0) {
      console.log('   No migration files found');
    } else {
      migrationFiles.forEach(file => {
        const isApplied = appliedMigrations.some(m => m.name === file.replace(/\.(ts|js)$/, ''));
        console.log(`   ${isApplied ? 'ok' : 'error'} ${file}`);
      });
    }

    // Check critical tables
    const criticalTables = ['users', 'auth_sessions', 'passkeys', 'two_factor_codes'];
    console.log('\n Critical tables status:');
    
    for (const table of criticalTables) {
      const tableExists = await dataSource.query(`
        SELECT EXISTS (
          SELECT FROM information_schema.tables 
          WHERE table_schema = 'public' 
          AND table_name = '${table}'
        );
      `);
      
      console.log(`   ${tableExists[0].exists ? 'ok' : 'error'} ${table}`);
    }

    await dataSource.destroy();
    console.log('\nDatabase connection closed');
  } catch (error) {
    console.error('Error checking migration status:', error);
    if (dataSource.isInitialized) {
      await dataSource.destroy();
    }
    process.exit(1);
  }
}

// Run the function
checkMigrationStatus();

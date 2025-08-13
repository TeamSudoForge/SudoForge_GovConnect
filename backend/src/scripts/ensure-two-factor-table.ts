import { DataSource } from 'typeorm';
import * as dotenv from 'dotenv';

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

async function ensureTwoFactorTable() {
  try {
    // Initialize the connection
    await dataSource.initialize();
    console.log('Connected to database');

    // Ensure uuid-ossp extension exists
    try {
      await dataSource.query(`CREATE EXTENSION IF NOT EXISTS "uuid-ossp"`);
      console.log('Ensured uuid-ossp extension exists');
    } catch (error) {
      console.warn('Could not create uuid-ossp extension:', error.message);
    }

    // Check if the table exists
    const tableExists = await dataSource.query(`
      SELECT EXISTS (
        SELECT FROM information_schema.tables 
        WHERE table_schema = 'public' 
        AND table_name = 'two_factor_codes'
      );
    `);

    if (!tableExists[0].exists) {
      console.log('Creating two_factor_codes table...');
      
      // Create the table
      await dataSource.query(`
        CREATE TABLE two_factor_codes (
          id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
          user_id UUID NOT NULL,
          code VARCHAR(6) NOT NULL,
          expires_at TIMESTAMP NOT NULL,
          created_at TIMESTAMP DEFAULT NOW(),
          CONSTRAINT fk_user 
            FOREIGN KEY(user_id) 
            REFERENCES users(id) 
            ON DELETE CASCADE
        );
        
        CREATE INDEX idx_two_factor_codes_user_id ON two_factor_codes(user_id);
        CREATE INDEX idx_two_factor_codes_expires_at ON two_factor_codes(expires_at);
      `);
      
      console.log('two_factor_codes table created successfully');
    } else {
      console.log('two_factor_codes table already exists');
      
      // Check if the table has the correct structure
      const columns = await dataSource.query(`
        SELECT column_name, data_type 
        FROM information_schema.columns 
        WHERE table_schema = 'public' 
        AND table_name = 'two_factor_codes';
      `);
      
      console.log('Current two_factor_codes columns:', columns.map(c => `${c.column_name} (${c.data_type})`).join(', '));
    }

    await dataSource.destroy();
    console.log('Database connection closed');
  } catch (error) {
    console.error('Error ensuring two_factor_codes table:', error);
    if (dataSource.isInitialized) {
      await dataSource.destroy();
    }
    process.exit(1);
  }
}

// Run the function
ensureTwoFactorTable();

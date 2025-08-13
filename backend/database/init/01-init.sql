-- Database initialization script

-- Create the main database if it doesn't exist
SELECT 'CREATE DATABASE govconnect'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'govconnect')\gexec

-- Connect to the govconnect database
\c govconnect;

-- Create extensions if needed
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Create a function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- (The application will create the tables via TypeORM migrations)

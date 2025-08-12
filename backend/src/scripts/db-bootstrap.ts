import { spawn } from 'child_process';
import * as path from 'path';

async function runCommand(command: string, args: string[]): Promise<void> {
  return new Promise((resolve, reject) => {
    console.log(`Running: ${command} ${args.join(' ')}`);
    
    const process = spawn(command, args, { stdio: 'inherit' });
    
    process.on('close', (code) => {
      if (code === 0) {
        resolve();
      } else {
        reject(new Error(`Command failed with exit code ${code}`));
      }
    });
    
    process.on('error', (err) => {
      reject(err);
    });
  });
}

async function bootstrapDatabase() {
  try {
    // Step 1: Initialize migrations table
    console.log('\n Step 1: Initializing migrations table...');
    await runCommand('ts-node', ['-r', 'tsconfig-paths/register', 'src/scripts/initialize-migrations.ts']);
    
    // Step 2: Run migrations
    console.log('\n Step 2: Running migrations...');
    await runCommand('npm', ['run', 'migration:run']);
    
    // Step 3: Ensure two-factor table exists
    console.log('\n Step 3: Ensuring two-factor table exists...');
    await runCommand('ts-node', ['-r', 'tsconfig-paths/register', 'src/scripts/ensure-two-factor-table.ts']);
    
    // Step 4: Check migration status
    console.log('\n Step 4: Checking migration status...');
    await runCommand('ts-node', ['-r', 'tsconfig-paths/register', 'src/scripts/migration-status.ts']);
    
    console.log('\n Database bootstrap complete!');
  } catch (error) {
    console.error('Error bootstrapping database:', error);
    process.exit(1);
  }
}

// Run the function
bootstrapDatabase();

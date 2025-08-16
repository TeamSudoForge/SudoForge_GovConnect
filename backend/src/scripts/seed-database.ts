import { DataSource } from 'typeorm';
import { Department } from '../modules/forms/entities/department.entity';
import typeormConfig from '../config/typeorm.config';

// Departments data with authentication credentials
const departments = [
  { 
    name: 'Business Services', 
    description: 'Business licensing and permits',
    contact_email: 'business@gov.connect',
    contact_phone: '+1-555-0101',
    email: 'business.admin@gov.connect',
    password_hash: '$2b$10$example.hash.for.password123' // This should be properly hashed
  },
  { 
    name: 'Public Works', 
    description: 'Infrastructure and utilities',
    contact_email: 'publicworks@gov.connect',
    contact_phone: '+1-555-0102',
    email: 'publicworks.admin@gov.connect',
    password_hash: '$2b$10$example.hash.for.password123'
  },
  { 
    name: 'Planning & Development', 
    description: 'Zoning and development permits',
    contact_email: 'planning@gov.connect',
    contact_phone: '+1-555-0103',
    email: 'planning.admin@gov.connect',
    password_hash: '$2b$10$example.hash.for.password123'
  },
  { 
    name: 'Health Services', 
    description: 'Public health and safety',
    contact_email: 'health@gov.connect',
    contact_phone: '+1-555-0104',
    email: 'health.admin@gov.connect',
    password_hash: '$2b$10$example.hash.for.password123'
  },
  { 
    name: 'Revenue', 
    description: 'Tax and revenue collection',
    contact_email: 'revenue@gov.connect',
    contact_phone: '+1-555-0105',
    email: 'revenue.admin@gov.connect',
    password_hash: '$2b$10$example.hash.for.password123'
  }
];

async function seedDatabase() {
  const dataSource = new DataSource(typeormConfig.options);
  
  try {
    await dataSource.initialize();
    console.log('Database connected successfully');

    const departmentRepository = dataSource.getRepository(Department);
    
    // Seed Departments
    console.log('Seeding departments...');
    const existingDepartmentsCount = await departmentRepository.count();
    
    if (existingDepartmentsCount === 0) {
      const departmentEntities = departments.map(dept => departmentRepository.create(dept));
      const savedDepartments = await departmentRepository.save(departmentEntities);
      console.log(` Seeded ${departments.length} departments`);
    } else {
      console.log(` ${existingDepartmentsCount} departments already exist. Skipping.`);
    }
    
    // Verify final counts
    const finalDepartmentsCount = await departmentRepository.count();
    
    console.log('\n Final Database State:');
    console.log(`   Departments: ${finalDepartmentsCount}`);
    
  } catch (error) {
    console.error(' Error seeding database:', error);
    throw error;
  } finally {
    await dataSource.destroy();
  }
}

// Run if called directly
if (require.main === module) {
  seedDatabase().catch(console.error);
}

export default seedDatabase;

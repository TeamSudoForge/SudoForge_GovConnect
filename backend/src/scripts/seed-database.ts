import { DataSource } from 'typeorm';
import { FieldType } from '../modules/forms/entities/field-type.entity';
import { Department } from '../modules/forms/entities/department.entity';
import { Service } from '../modules/forms/entities/service.entity';
import typeormConfig from '../config/typeorm.config';

// Field types data
const fieldTypes = [
  { name: 'text', description: 'Text input field' },
  { name: 'number', description: 'Numeric input field' },
  { name: 'email', description: 'Email input field' },
  { name: 'password', description: 'Password input field' },
  { name: 'textarea', description: 'Multi-line text area' },
  { name: 'select', description: 'Dropdown selection' },
  { name: 'radio', description: 'Radio button selection' },
  { name: 'checkbox', description: 'Checkbox input' },
  { name: 'file', description: 'File upload' },
  { name: 'date', description: 'Date picker' },
  { name: 'datetime', description: 'Date and time picker' },
  { name: 'time', description: 'Time picker' },
  { name: 'url', description: 'URL input' },
  { name: 'tel', description: 'Telephone number' },
  { name: 'range', description: 'Range slider' },
  { name: 'hidden', description: 'Hidden field' }
];

// Departments data
const departments = [
  { name: 'Business Services', description: 'Business licensing and permits' },
  { name: 'Public Works', description: 'Infrastructure and utilities' },
  { name: 'Planning & Development', description: 'Zoning and development permits' },
  { name: 'Health Services', description: 'Public health and safety' },
  { name: 'Revenue', description: 'Tax and revenue collection' }
];

// Services data (will use department IDs after departments are created)
const servicesData = [
  { name: 'Business License Application', description: 'Apply for a new business license', departmentName: 'Business Services' },
  { name: 'Building Permit', description: 'Apply for building construction permit', departmentName: 'Planning & Development' },
  { name: 'Water Connection', description: 'Request new water service connection', departmentName: 'Public Works' },
  { name: 'Food Handler Permit', description: 'Apply for food service permit', departmentName: 'Health Services' },
  { name: 'Property Tax Assessment', description: 'Request property tax assessment', departmentName: 'Revenue' }
];

async function seedDatabase() {
  const dataSource = new DataSource(typeormConfig.options);
  
  try {
    await dataSource.initialize();
    console.log('Database connected successfully');

    const fieldTypeRepository = dataSource.getRepository(FieldType);
    const departmentRepository = dataSource.getRepository(Department);
    const serviceRepository = dataSource.getRepository(Service);
    
    // 1. Seed Field Types
    console.log('Seeding field types...');
    const existingFieldTypesCount = await fieldTypeRepository.count();
    
    if (existingFieldTypesCount === 0) {
      const fieldTypeEntities = fieldTypes.map(ft => fieldTypeRepository.create(ft));
      await fieldTypeRepository.save(fieldTypeEntities);
      console.log(` Seeded ${fieldTypes.length} field types`);
    } else {
      console.log(`  ${existingFieldTypesCount} field types already exist. Skipping.`);
    }

    // 2. Seed Departments
    console.log('Seeding departments...');
    const existingDepartmentsCount = await departmentRepository.count();
    
    if (existingDepartmentsCount === 0) {
      const departmentEntities = departments.map(dept => departmentRepository.create(dept));
      const savedDepartments = await departmentRepository.save(departmentEntities);
      console.log(` Seeded ${departments.length} departments`);
      
      // 3. Seed Services (after departments exist)
      console.log('Seeding services...');
      const existingServicesCount = await serviceRepository.count();
      
      if (existingServicesCount === 0) {
        const serviceEntities: Service[] = [];
        
        for (const serviceData of servicesData) {
          const department = savedDepartments.find(d => d.name === serviceData.departmentName);
          if (department) {
            const service = serviceRepository.create({
              name: serviceData.name,
              description: serviceData.description,
              department_id: department.department_id,
              is_active: true
            });
            serviceEntities.push(service);
          }
        }
        
        await serviceRepository.save(serviceEntities);
        console.log(` Seeded ${serviceEntities.length} services`);
      } else {
        console.log(`  ${existingServicesCount} services already exist. Skipping.`);
      }
    } else {
      console.log(`  ${existingDepartmentsCount} departments already exist. Skipping services seed.`);
    }
    
    // Verify final counts
    const finalFieldTypesCount = await fieldTypeRepository.count();
    const finalDepartmentsCount = await departmentRepository.count();
    const finalServicesCount = await serviceRepository.count();
    
    console.log('\n Final Database State:');
    console.log(`   Field Types: ${finalFieldTypesCount}`);
    console.log(`   Departments: ${finalDepartmentsCount}`);
    console.log(`   Services: ${finalServicesCount}`);
    
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

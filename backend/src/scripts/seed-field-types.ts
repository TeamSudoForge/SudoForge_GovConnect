import { DataSource } from 'typeorm';
import { FieldType } from '../modules/forms/entities/field-type.entity';
import typeormConfig from '../config/typeorm.config';

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

async function seedFieldTypes() {
  const dataSource = new DataSource(typeormConfig.options);
  
  try {
    await dataSource.initialize();
    console.log('Database connected successfully');

    const fieldTypeRepository = dataSource.getRepository(FieldType);
    
    // Check if field types already exist
    const existingCount = await fieldTypeRepository.count();
    
    if (existingCount > 0) {
      console.log(`${existingCount} field types already exist. Skipping seed.`);
      return;
    }

    // Insert field types
    const fieldTypeEntities = fieldTypes.map(ft => fieldTypeRepository.create(ft));
    await fieldTypeRepository.save(fieldTypeEntities);
    
    console.log(`Successfully seeded ${fieldTypes.length} field types`);
    
    // Verify the data
    const count = await fieldTypeRepository.count();
    console.log(`Total field types in database: ${count}`);
    
  } catch (error) {
    console.error('Error seeding field types:', error);
  } finally {
    await dataSource.destroy();
  }
}

// Run if called directly
if (require.main === module) {
  seedFieldTypes().catch(console.error);
}

export default seedFieldTypes;

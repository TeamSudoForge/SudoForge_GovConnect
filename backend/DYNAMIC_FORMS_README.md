# GovConnect Dynamic Forms System

This document describes the dynamic forms implementation for the GovConnect backend application, providing a flexible system for government services to create, manage, and collect citizen responses through customizable forms.

## Architecture Overview

The dynamic forms system follows a modular architecture with the following core components:

### Database Tables

#### Core Tables
- `field_types` - Available input field types (text, number, dropdown, etc.)
- `fields` - Reusable field definitions with labels, placeholders, and validation rules
- `field_attributes` - Flexible key-value storage for field-specific configurations
- `departments` - Government departments that own services
- `services` - Individual government services that require forms

#### Form Structure Tables
- `form_fields` - Maps services to required fields with ordering and sections
- `form_responses` - Citizen form submissions with status tracking
- `form_response_values` - Individual field values for each form submission

### Modules (`backend/src/modules/forms/`)

#### Entities (`entities/`)
- `FieldType` - Field type definitions (text, number, dropdown, etc.)
- `Field` - Reusable field definitions
- `FieldAttribute` - Key-value field configurations
- `Department` - Government department entity
- `Service` - Government service entity
- `FormField` - Service-to-field mapping with ordering
- `FormResponse` - Form submission entity
- `FormResponseValue` - Individual field response values

#### DTOs (`dto/`)
- `CreateFormDto` - Form creation payload with service and fields
- `CreateFormResponseDto` - Form submission payload
- `UpdateFormResponseStatusDto` - Status update payload
- `FormAnalyticsResponse` - Analytics response structure
- `DayOfWeekAnalytics` - Weekly analytics interface

#### Services (`services/`)
- `FormsService` - Form creation and management logic
- `FormResponsesService` - Response handling and validation
- `AnalyticsService` - Form submission analytics with weekly breakdowns

#### Controllers (`controllers/`)
- `FormsController` - Form CRUD endpoints
- `FormResponsesController` - Response submission and management
- `AnalyticsController` - Analytics and reporting endpoints

## Features

### 1. Dynamic Field Types
Pre-seeded with 17 field types:
- **text** - Text input field
- **number** - Numeric input field
- **email** - Email input field
- **password** - Password input field
- **textarea** - Multi-line text area
- **select** - Dropdown selection
- **radio** - Radio button selection
- **checkbox** - Checkbox input
- **file** - File upload
- **date** - Date picker
- **datetime** - Date and time picker
- **time** - Time picker
- **url** - URL input
- **tel** - Telephone number
- **range** - Range slider
- **color** - Color picker
- **hidden** - Hidden field

### 2. Flexible Field Configuration
Each field can have custom attributes stored as key-value pairs:
- **Text Fields**: `minLength`, `maxLength`, `regex`, `placeholder`
- **Numeric Fields**: `min`, `max`, `step`, `decimalPlaces`
- **File Upload**: `maxFileSize`, `allowedTypes`, `maxFileCount`
- **Date Fields**: `minDate`, `maxDate`, `format`
- **Select/Radio**: `options`, `defaultValue`

### 3. Form Structure Management
- **Sections**: Group related fields together
- **Ordering**: Control field display order
- **Conditional Logic**: Fields can be shown/hidden based on other field values
- **Validation**: Required field enforcement and custom validation rules

### 4. Response Management
- **Status Tracking**: pending, approved, rejected, processing
- **User Association**: Link responses to authenticated users
- **Audit Trail**: Track submission and update timestamps
- **Data Validation**: Server-side validation of all field values

### 5. Analytics & Reporting
- **Weekly Analytics**: Monday-Sunday response averages for current month
- **Service Performance**: Response counts, completion rates, processing times
- **Status Distribution**: Breakdown of pending/approved/rejected responses
- **Department Insights**: Cross-department analytics and comparisons

## API Endpoints

### Form Management
```http
GET    /api/forms                    # Get all active forms
POST   /api/forms                    # Create new form
GET    /api/forms/field-types        # Get available field types
GET    /api/forms/fields             # Get all reusable fields
GET    /api/forms/:serviceId         # Get specific form structure
PUT    /api/forms/:serviceId         # Update form structure
DELETE /api/forms/:serviceId         # Deactivate form
```

### Form Responses
```http
POST   /api/forms/:serviceId/responses                    # Submit form response
GET    /api/forms/:serviceId/responses                    # Get service responses (admin)
GET    /api/forms/:serviceId/responses/:responseId        # Get specific response
GET    /api/forms/responses/my                            # Get user's responses
PUT    /api/forms/:serviceId/responses/:responseId/status # Update response status
DELETE /api/forms/:serviceId/responses/:responseId        # Delete response
```

### Analytics & Reporting
```http
GET    /api/analytics/forms/:serviceId              # Individual form analytics
GET    /api/analytics/overview                      # System-wide analytics
GET    /api/analytics/departments/:departmentId     # Department analytics
```

## Usage Examples

### 1. Creating a Form

```typescript
const formData = {
  service: {
    name: "Business License Application",
    description: "Apply for a new business license",
    department_id: 1,
    is_active: true
  },
  form_fields: [
    {
      field_id: 1,  // Pre-existing field
      order_index: 1,
      section: "Business Information"
    },
    {
      field_id: 2,
      order_index: 2,
      section: "Business Information"
    }
  ],
  new_fields: [
    {
      ftype_id: 1,  // Text field
      label: "Business Name",
      placeholder: "Enter your business name",
      is_required: true,
      attributes: [
        { attr_key: "minLength", attr_value: "2" },
        { attr_key: "maxLength", attr_value: "100" }
      ]
    }
  ]
};

const response = await fetch('/api/forms', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Authorization': `Bearer ${token}`
  },
  body: JSON.stringify(formData)
});
```

### 2. Submitting a Response

```typescript
const responseData = {
  values: [
    {
      field_id: 1,
      value: "Acme Corporation"
    },
    {
      field_id: 2,
      value: "john@acmecorp.com"
    },
    {
      field_id: 3,
      value: "123-456-7890"
    }
  ]
};

const response = await fetch('/api/forms/1/responses', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Authorization': `Bearer ${token}`
  },
  body: JSON.stringify(responseData)
});
```

### 3. Getting Weekly Analytics

```typescript
const analytics = await fetch('/api/analytics/forms/1', {
  headers: {
    'Authorization': `Bearer ${token}`
  }
});

const data = await analytics.json();
// Returns:
{
  service_id: 1,
  service_name: "Business License Application",
  current_month: {
    year: 2025,
    month: 8,
    total_responses: 45
  },
  weekly_analytics: [
    { day: "Monday", dayNumber: 1, averageResponses: 2.5, totalResponses: 10 },
    { day: "Tuesday", dayNumber: 2, averageResponses: 3.2, totalResponses: 13 },
    // ... other days
  ],
  status_breakdown: {
    pending: 15,
    approved: 25,
    rejected: 5
  }
}
```

## Field Validation Rules

### Built-in Validation
- **Required Fields**: Automatically validated on submission
- **Field Type Validation**: Email format, number ranges, etc.
- **Custom Attributes**: Min/max length, regex patterns, file size limits

### Custom Validation Example
```typescript
// Text field with custom validation
{
  ftype_id: 1,
  label: "Tax ID",
  is_required: true,
  attributes: [
    { attr_key: "regex", attr_value: "^[0-9]{2}-[0-9]{7}$" },
    { attr_key: "errorMessage", attr_value: "Tax ID must be in format XX-XXXXXXX" }
  ]
}
```

## Authentication & Authorization

All endpoints require JWT authentication:
- **Citizens**: Can submit responses and view their own submissions
- **Department Staff**: Can view and manage responses for their department's services
- **System Admin**: Full access to all forms, responses, and analytics

### Required Headers
```typescript
{
  'Authorization': 'Bearer <jwt-token>',
  'Content-Type': 'application/json'
}
```

## Database Schema

### Field Types (Pre-seeded)
```sql
INSERT INTO field_types (name, description) VALUES 
('text', 'Text input field'),
('number', 'Numeric input field'),
('email', 'Email input field'),
-- ... other types
```

### Field Attributes Examples
```sql
-- Text field with length constraints
INSERT INTO field_attributes (field_id, attr_key, attr_value) VALUES
(1, 'minLength', '5'),
(1, 'maxLength', '100'),
(1, 'placeholder', 'Enter full name');

-- Number field with range
INSERT INTO field_attributes (field_id, attr_key, attr_value) VALUES
(2, 'min', '18'),
(2, 'max', '100'),
(2, 'step', '1');
```

## Error Handling

The system provides comprehensive error handling:

### Validation Errors (400 Bad Request)
```json
{
  "message": [
    "Field 'business_name' is required",
    "Email format is invalid"
  ],
  "error": "Bad Request",
  "statusCode": 400
}
```

### Authentication Errors (401 Unauthorized)
```json
{
  "message": "Unauthorized",
  "statusCode": 401
}
```

### Not Found Errors (404 Not Found)
```json
{
  "message": "Service with ID 123 not found",
  "statusCode": 404
}
```

## Configuration

### Environment Variables
```env
DB_HOST=localhost
DB_PORT=5432
DB_USERNAME=postgres
DB_PASSWORD=password
DB_NAME=govconnect
DB_SYNCHRONIZE=true  # Development only
DB_LOGGING=true      # Development only
```

### Docker Development
```bash
# Start development environment
npm run dev:up

# View logs
npm run dev:logs

# Stop environment
npm run dev:down
```

## Migration Management

The system includes comprehensive database migrations:

### Running Migrations
```bash
# Run pending migrations
npm run migration:run

# Create new migration
npm run migration:create src/database/migrations/MigrationName

# Show migration status
npx typeorm-ts-node-commonjs migration:show -d src/config/typeorm.config.ts
```

### Migration Features
- **Automatic Table Creation**: All form-related tables
- **Foreign Key Constraints**: Proper relationships between entities
- **Indexes**: Optimized for query performance
- **Triggers**: Automatic timestamp updates
- **Data Seeding**: Pre-populated field types

## Performance Considerations

### Database Optimization
- **Indexes**: Added on frequently queried columns
- **Foreign Keys**: Proper cascading delete rules
- **Connection Pooling**: TypeORM connection management
- **Query Optimization**: Efficient joins and filtering

### Caching Strategy
```typescript
// Recommended caching for production
// - Field types (rarely change)
// - Form structures (cache until updated)
// - User permissions (short TTL)
```

## Future Enhancements

### Planned Features
1. **Conditional Logic**: Show/hide fields based on other field values
2. **File Storage Integration**: MinIO/S3 integration for file uploads
3. **Form Templates**: Reusable form templates across departments
4. **Workflow Engine**: Multi-step approval processes
5. **Notification System**: Email/SMS notifications for status updates
6. **Form Versioning**: Track form structure changes over time
7. **Export/Import**: Excel/CSV data export capabilities
8. **Real-time Analytics**: Live dashboard updates
9. **API Rate Limiting**: Prevent abuse and ensure fair usage
10. **Audit Logging**: Comprehensive activity tracking

## Troubleshooting

### Common Issues

#### 1. Migration Not Running
```bash
# Check if migration files exist
ls src/database/migrations/

# Verify database connection
docker exec -it govconnect-database-dev psql -U postgres -d govconnect -c "SELECT version();"

# Force migration run
npm run migration:run
```

#### 2. Authentication Errors
- Verify JWT token is included in requests
- Check token expiration
- Ensure user has required permissions

#### 3. Validation Errors
- Verify all required fields are provided
- Check field attribute constraints (min/max length, regex patterns)
- Ensure field types match expected data

#### 4. Performance Issues
```sql
-- Check slow queries
SELECT query, calls, total_time, mean_time
FROM pg_stat_statements
ORDER BY total_time DESC
LIMIT 10;

-- Analyze table statistics
ANALYZE form_responses;
```

## Contributing

### Development Setup
1. Clone the repository
2. Install dependencies: `npm install`
3. Set up environment variables
4. Run development containers: `npm run dev:up`
5. Run migrations: `npm run migration:run`
6. Start development server: `npm run start:dev`

### Testing
```bash
# Run unit tests
npm run test

# Run e2e tests
npm run test:e2e

# Run with coverage
npm run test:cov
```

### Code Standards
- Follow TypeScript best practices
- Use proper error handling
- Include comprehensive JSDoc comments
- Write unit tests for new features
- Validate all inputs and outputs

## License

This project is part of the GovConnect platform and follows the project's licensing terms.

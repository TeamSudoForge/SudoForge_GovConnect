# Dynamic Forms with JSON Configuration

## Overview

The demo form screen now supports complete JSON-driven form configuration, allowing all form data, structure, and UI elements to be defined through JSON instead of being hardcoded.

## Features

### 1. Complete JSON Configuration
- Form metadata (title, description, version)
- Form sections with multiple pages
- Field definitions with validation rules
- UI configuration (labels, colors, text)
- Default form values

### 2. Dynamic Multi-page Support
- Automatically calculates number of form pages from JSON
- Dynamic navigation between pages
- Section-based content rendering

### 3. Flexible Field Types
- All existing field types supported: text, email, phone, dropdown, textarea, date, radio, checkbox, document upload, dependency forms
- Validation rules configurable per field
- Help text and placeholder support

### 4. UI Customization
- Step labels configurable
- Process flow steps from JSON
- Info cards and descriptions
- Department and announcement information

## JSON Structure

### Root Level
```json
{
  "id": "unique-form-id",
  "title": "Form Title",
  "description": "Form description",
  "isActive": true,
  "version": 1,
  "metadata": {
    "department": "Department Name",
    "announcementUrl": "https://example.com/announcement"
  },
  "defaultValues": {
    "field_name": "default_value"
  },
  "sections": [...],
  "ui": {...}
}
```

### Sections
```json
{
  "id": "section-id",
  "title": "Section Title",
  "description": "Section description", 
  "pageNumber": 1,
  "orderIndex": 1,
  "fields": [...]
}
```

### Fields
```json
{
  "id": "field-id",
  "label": "Field Label",
  "fieldName": "field_name",
  "fieldType": "text|email|phone|dropdown|textarea|date|radio|checkbox|documentUpload|dependencyForm",
  "isRequired": true,
  "placeholder": "Placeholder text",
  "helpText": "Help text",
  "orderIndex": 1,
  "validationRules": {
    "minLength": 3,
    "maxLength": 100,
    "pattern": "regex-pattern"
  },
  "options": {
    "options": [
      {"value": "value1", "label": "Label 1"},
      {"value": "value2", "label": "Label 2"}
    ]
  },
  "metadata": {
    "maxLines": 4,
    "maxFiles": 5,
    "formUrl": "/dependency-form-url",
    "isFilled": false
  }
}
```

### UI Configuration
```json
{
  "ui": {
    "overview": {
      "title": "Overview page title",
      "description": "Overview description",
      "infoCards": [
        "Info card text 1",
        "Info card text 2"
      ],
      "processSteps": [
        {
          "stepNumber": 1,
          "title": "Step Title",
          "description": "Step description"
        }
      ]
    },
    "stepLabels": ["Overview", "Form", "Submit"],
    "theme": {
      "primaryColor": "#2196F3",
      "secondaryColor": "#4CAF50"
    }
  }
}
```

## Usage

### 1. With External JSON
```dart
// Load JSON from file or API
final jsonData = await loadJsonFromAssets('assets/form_config.json');

// Pass to demo form
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => DemoFormScreen(jsonFormData: jsonData),
  ),
);
```

### 2. With Default Configuration
```dart
// Uses built-in sample JSON data
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => DemoFormScreen(), // No jsonFormData parameter
  ),
);
```

## Page Number Convention

- Page 1: Overview page with dependency forms
- Page 2, 4, 5, etc.: Form pages (actual form fields)
- Page 3: Submit page with document uploads

The system automatically:
- Counts form pages (excluding overview and submit)
- Handles navigation between multiple form pages
- Shows appropriate page indicators

## Validation

All validation rules are configurable through JSON:
- Required field validation
- Length validation (min/max)
- Pattern validation (regex)
- File type and size validation for uploads
- Custom validation messages

## Testing

Use the `JsonFormTestScreen` to:
- Load and preview JSON configuration
- Test forms with different JSON structures
- View raw JSON data
- Compare default vs custom configurations

## Files

- `demo_form_screen.dart` - Main form screen with JSON support
- `json_form_test_screen.dart` - Testing interface
- `sample_form_config.json` - Example JSON configuration
- `dynamic_form_models.dart` - Data models with JSON parsing

## Benefits

1. **No Code Changes**: Form structure changes without app updates
2. **API Integration**: Forms can be loaded from backend APIs
3. **A/B Testing**: Different form configurations for testing
4. **Localization**: Multiple JSON files for different languages
5. **Dynamic Fields**: Add/remove fields based on business logic
6. **Theme Support**: UI customization through JSON
7. **Validation Control**: Server-side validation rule management

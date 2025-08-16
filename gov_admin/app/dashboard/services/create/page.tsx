'use client';

import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Textarea } from '@/components/ui/textarea';
import { Switch } from '@/components/ui/switch';
import { Checkbox } from '@/components/ui/checkbox';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import { Alert, AlertDescription } from '@/components/ui/alert';
import { Plus, Trash2, Calendar, Edit3, Settings, Loader2, AlertCircle } from 'lucide-react';
import { ServicesService } from '@/lib/services/services.service';
import { DepartmentAuthService } from '@/lib/services/department-auth.service';
import { Department } from '@/lib/services/departments.service';

// Field Type Definitions
interface BaseField {
  id: string;
  type: FieldType;
  label: string;
  placeholder?: string;
  required: boolean;
}

interface TextInputField extends BaseField {
  type: 'text';
  validations: {
    minLength?: number;
    maxLength?: number;
    regex?: string;
    allowNumeric: boolean;
    allowAlpha: boolean;
    allowSpecialChars: boolean;
    allowSpaces: boolean;
  };
}

interface NumericInputField extends BaseField {
  type: 'number';
  validations: {
    min?: number;
    max?: number;
  };
}

interface FileUploadField extends BaseField {
  type: 'file';
  properties: {
    description: string;
  };
  validations: {
    allowedFileTypes: string[];
    maxFileSize?: number;
    maxTotalSize?: number;
    minFileCount?: number;
    maxFileCount?: number;
  };
}

interface DropdownField extends BaseField {
  type: 'dropdown';
  properties: {
    dataSource: 'predefined' | 'custom';
    predefinedType?: 'countries' | 'cities';
    customOptions?: { label: string; value: string }[];
  };
}

interface CurrencyField extends BaseField {
  type: 'currency';
  properties: {
    unit: string;
  };
  validations: {
    min?: number;
    max?: number;
  };
}

interface DateField extends BaseField {
  type: 'date';
  properties: {
    selectableDays?: string[];
  };
  validations: {
    startDate?: string;
    endDate?: string;
  };
}

interface RadioField extends BaseField {
  type: 'radio';
  properties: {
    options: { label: string; value: string }[];
    defaultSelection?: string;
  };
}

interface CheckboxField extends BaseField {
  type: 'checkbox';
  properties: {
    options: { label: string; value: string }[];
  };
}

interface RichTextField extends BaseField {
  type: 'richtext';
  properties: {
    allowBold: boolean;
    allowItalic: boolean;
    allowUnderline: boolean;
    allowLinks: boolean;
    allowImages: boolean;
  };
}

interface AppointmentCardField extends BaseField {
  type: 'appointment_card';
  properties: {
    scheduled: boolean;
    slotDetails?: string;
    bookingInfo?: string;
  };
}

type FormField = TextInputField | NumericInputField | FileUploadField | DropdownField | CurrencyField | DateField | RadioField | CheckboxField | RichTextField | AppointmentCardField;
type FieldType = 'text' | 'number' | 'file' | 'dropdown' | 'currency' | 'date' | 'radio' | 'checkbox' | 'richtext' | 'appointment_card';

const FILE_TYPES = [
  'image/jpeg',
  'image/png', 
  'image/gif',
  'application/pdf',
  'application/msword',
  'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
  'text/plain'
];

export default function CreateServicePage() {
  const router = useRouter();
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [selectedFieldType, setSelectedFieldType] = useState<FieldType>('text');
  
  // Current department state
  const [currentDepartment, setCurrentDepartment] = useState<Department | null>(null);
  
  // Form state  
  const [formData, setFormData] = useState({
    name: '',
    description: '',
    fields: [] as FormField[]
  });

  // Load current department on component mount
  useEffect(() => {
    loadCurrentDepartment();
  }, []);

  const loadCurrentDepartment = async () => {
    try {
      const departmentAuthService = DepartmentAuthService.getInstance();
      const dept = departmentAuthService.getCurrentDepartment();
      
      if (!dept) {
        setError('No department found. Please log in again.');
        router.push('/auth/login');
        return;
      }
      
      setCurrentDepartment(dept);
    } catch (error) {
      console.error('Failed to load current department:', error);
      setError('Failed to load department information');
    }
  };

  // Form functions
  const generateFieldId = () => `field_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;

  const createDefaultField = (type: FieldType): FormField => {
    const baseField = {
      id: generateFieldId(),
      type,
      label: '',
      placeholder: '',
      required: false
    };

    switch (type) {
      case 'text':
        return {
          ...baseField,
          validations: {
            minLength: undefined,
            maxLength: undefined,
            regex: undefined,
            allowNumeric: true,
            allowAlpha: true,
            allowSpecialChars: false,
            allowSpaces: true
          }
        } as TextInputField;
      
      case 'number':
        return {
          ...baseField,
          validations: {
            min: undefined,
            max: undefined
          }
        } as NumericInputField;
      
      case 'file':
        return {
          ...baseField,
          properties: {
            description: ''
          },
          validations: {
            allowedFileTypes: ['image/jpeg', 'image/png', 'application/pdf'],
            maxFileSize: undefined,
            maxTotalSize: undefined,
            minFileCount: undefined,
            maxFileCount: undefined
          }
        } as FileUploadField;
      
      case 'dropdown':
        return {
          ...baseField,
          properties: {
            dataSource: 'custom' as const,
            customOptions: [{ label: '', value: '' }]
          }
        } as DropdownField;
      
      case 'currency':
        return {
          ...baseField,
          properties: {
            unit: 'USD'
          },
          validations: {
            min: undefined,
            max: undefined
          }
        } as CurrencyField;
      
      case 'date':
        return {
          ...baseField,
          properties: {
            selectableDays: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri']
          },
          validations: {
            startDate: undefined,
            endDate: undefined
          }
        } as DateField;
      
      case 'radio':
        return {
          ...baseField,
          properties: {
            options: [{ label: '', value: '' }],
            defaultSelection: undefined
          }
        } as RadioField;
      
      case 'checkbox':
        return {
          ...baseField,
          properties: {
            options: [{ label: '', value: '' }]
          }
        } as CheckboxField;
      
      case 'richtext':
        return {
          ...baseField,
          properties: {
            allowBold: true,
            allowItalic: true,
            allowUnderline: false,
            allowLinks: false,
            allowImages: false
          }
        } as RichTextField;
      
      case 'appointment_card':
        return {
          ...baseField,
          properties: {
            scheduled: false,
            slotDetails: undefined,
            bookingInfo: undefined
          }
        } as AppointmentCardField;
      
      default:
        return baseField as FormField;
    }
  };

  const handleAddField = () => {
    const newField = createDefaultField(selectedFieldType);
    setFormData(prev => ({
      ...prev,
      fields: [...prev.fields, newField]
    }));
  };

  const updateField = (fieldId: string, updates: Partial<FormField>) => {
    setFormData(prev => ({
      ...prev,
      fields: prev.fields.map(field => 
        field.id === fieldId ? { ...field, ...updates } as FormField : field
      )
    }));
  };

  const deleteField = (fieldId: string) => {
    setFormData(prev => ({
      ...prev,
      fields: prev.fields.filter(field => field.id !== fieldId)
    }));
  };

  const handleSaveForm = async () => {
    try {
      setIsLoading(true);
      setError(null);
      
      if (!formData.name.trim()) {
        throw new Error('Form name is required');
      }
      
      if (!currentDepartment) {
        throw new Error('Department information not available');
      }

      // Prepare the service data for the backend
      const serviceData = {
        title: formData.name,
        description: formData.description,
        sections: formData.fields.length > 0 ? [{
          title: 'Form Fields',
          description: 'Main form section',
          pageNumber: 1,
          orderIndex: 1,
          fields: formData.fields.map((field, index) => ({
            label: field.label,
            fieldName: field.label.toLowerCase().replace(/\s+/g, '_'),
            fieldType: field.type,
            isRequired: field.required,
            placeholder: field.placeholder,
            orderIndex: index + 1,
            validationRules: ('validations' in field) ? field.validations : undefined,
            options: ('properties' in field) ? field.properties : undefined,
            metadata: {
              fieldConfig: field
            }
          }))
        }] : []
      };

      const servicesService = ServicesService.getInstance();
      await servicesService.createService(serviceData);
      
      // Navigate back to services list
      router.push('/dashboard/services');
    } catch (error: any) {
      console.error('Failed to save form:', error);
      setError(error.message || 'Failed to save form');
    } finally {
      setIsLoading(false);
    }
  };

  // Field configuration component
  const FieldConfigCard = ({ field, onUpdate, onDelete }: {
    field: FormField;
    onUpdate: (updates: Partial<FormField>) => void;
    onDelete: () => void;
  }) => {
    const [isExpanded, setIsExpanded] = useState(false);

    const renderFieldConfig = () => {
      switch (field.type) {
        case 'text':
          return (
            <TextFieldConfig
              field={field as TextInputField}
              onUpdate={(validations) => onUpdate({ validations })}
            />
          );
        case 'number':
          return (
            <NumberFieldConfig
              field={field as NumericInputField}
              onUpdate={(validations) => onUpdate({ validations })}
            />
          );
        case 'file':
          return (
            <FileUploadFieldConfig
              field={field as FileUploadField}
              onUpdate={onUpdate}
            />
          );
        case 'dropdown':
          return (
            <DropdownFieldConfig
              field={field as DropdownField}
              onUpdate={(properties) => onUpdate({ properties })}
            />
          );
        case 'currency':
          return (
            <CurrencyFieldConfig
              field={field as CurrencyField}
              onUpdate={onUpdate}
            />
          );
        case 'date':
          return (
            <DateFieldConfig
              field={field as DateField}
              onUpdate={onUpdate}
            />
          );
        case 'radio':
          return (
            <RadioFieldConfig
              field={field as RadioField}
              onUpdate={(properties) => onUpdate({ properties })}
            />
          );
        case 'checkbox':
          return (
            <CheckboxFieldConfig
              field={field as CheckboxField}
              onUpdate={(properties) => onUpdate({ properties })}
            />
          );
        case 'richtext':
          return (
            <RichTextFieldConfig
              field={field as RichTextField}
              onUpdate={(properties) => onUpdate({ properties })}
            />
          );
        case 'appointment_card':
          return (
            <AppointmentCardFieldConfig
              field={field as AppointmentCardField}
              onUpdate={(properties) => onUpdate({ properties })}
            />
          );
        default:
          return null;
      }
    };

    return (
      <Card className="border-l-4 border-l-blue-500">
        <CardHeader className="pb-3">
          <div className="flex items-center justify-between">
            <div className="flex items-center space-x-3">
              <div className="p-2 bg-blue-100 rounded-lg">
                <Settings className="h-4 w-4 text-blue-600" />
              </div>
              <div>
                <h4 className="font-medium">{field.label || `${field.type} Field`}</h4>
                <p className="text-sm text-gray-500 capitalize">{field.type} input</p>
              </div>
            </div>
            <div className="flex items-center space-x-2">
              <Button
                variant="ghost"
                size="sm"
                onClick={() => setIsExpanded(!isExpanded)}
              >
                <Edit3 className="h-4 w-4" />
              </Button>
              <Button
                variant="ghost"
                size="sm"
                onClick={onDelete}
                className="text-red-600 hover:text-red-700"
              >
                <Trash2 className="h-4 w-4" />
              </Button>
            </div>
          </div>
        </CardHeader>
        
        {isExpanded && (
          <CardContent className="space-y-4">
            {/* Basic field properties */}
            <div className="grid grid-cols-2 gap-4">
              <div className="space-y-2">
                <Label>Field Label</Label>
                <Input
                  value={field.label}
                  onChange={(e) => onUpdate({ label: e.target.value })}
                  placeholder="Enter field label"
                />
              </div>
              <div className="space-y-2">
                <Label>Placeholder</Label>
                <Input
                  value={field.placeholder || ''}
                  onChange={(e) => onUpdate({ placeholder: e.target.value })}
                  placeholder="Enter placeholder text"
                />
              </div>
            </div>
            
            <div className="flex items-center space-x-2">
              <Switch
                checked={field.required}
                onCheckedChange={(checked) => onUpdate({ required: checked })}
              />
              <Label>Required field</Label>
            </div>

            {/* Field-specific configuration */}
            {renderFieldConfig()}
          </CardContent>
        )}
      </Card>
    );
  };

  // Field-specific configuration components
  const TextFieldConfig = ({ 
    field, 
    onUpdate 
  }: {
    field: TextInputField;
    onUpdate: (validations: TextInputField['validations']) => void;
  }) => (
    <div className="space-y-4 border-t pt-4">
      <h4 className="font-medium text-sm">Text Input Validations</h4>
      <div className="grid grid-cols-2 gap-4">
        <div className="space-y-2">
          <Label>Min Length</Label>
          <Input
            type="number"
            value={field.validations.minLength || ''}
            onChange={(e) => onUpdate({ ...field.validations, minLength: parseInt(e.target.value) || undefined })}
          />
        </div>
        <div className="space-y-2">
          <Label>Max Length</Label>
          <Input
            type="number"
            value={field.validations.maxLength || ''}
            onChange={(e) => onUpdate({ ...field.validations, maxLength: parseInt(e.target.value) || undefined })}
          />
        </div>
      </div>
      <div className="space-y-2">
        <Label>Regex Pattern</Label>
        <Input
          value={field.validations.regex || ''}
          onChange={(e) => onUpdate({ ...field.validations, regex: e.target.value })}
          placeholder="^[a-zA-Z0-9]*$"
        />
      </div>
      <div className="grid grid-cols-2 gap-4">
        <div className="flex items-center space-x-2">
          <Switch
            checked={field.validations.allowNumeric}
            onCheckedChange={(checked) => onUpdate({ ...field.validations, allowNumeric: checked })}
          />
          <Label>Allow Numbers</Label>
        </div>
        <div className="flex items-center space-x-2">
          <Switch
            checked={field.validations.allowAlpha}
            onCheckedChange={(checked) => onUpdate({ ...field.validations, allowAlpha: checked })}
          />
          <Label>Allow Letters</Label>
        </div>
        <div className="flex items-center space-x-2">
          <Switch
            checked={field.validations.allowSpecialChars}
            onCheckedChange={(checked) => onUpdate({ ...field.validations, allowSpecialChars: checked })}
          />
          <Label>Allow Special Characters</Label>
        </div>
        <div className="flex items-center space-x-2">
          <Switch
            checked={field.validations.allowSpaces}
            onCheckedChange={(checked) => onUpdate({ ...field.validations, allowSpaces: checked })}
          />
          <Label>Allow Spaces</Label>
        </div>
      </div>
    </div>
  );

  const NumberFieldConfig = ({ 
    field, 
    onUpdate 
  }: {
    field: NumericInputField;
    onUpdate: (validations: NumericInputField['validations']) => void;
  }) => (
    <div className="space-y-4 border-t pt-4">
      <h4 className="font-medium text-sm">Numeric Validations</h4>
      <div className="grid grid-cols-2 gap-4">
        <div className="space-y-2">
          <Label>Minimum Value</Label>
          <Input
            type="number"
            value={field.validations.min || ''}
            onChange={(e) => onUpdate({ ...field.validations, min: parseInt(e.target.value) || undefined })}
          />
        </div>
        <div className="space-y-2">
          <Label>Maximum Value</Label>
          <Input
            type="number"
            value={field.validations.max || ''}
            onChange={(e) => onUpdate({ ...field.validations, max: parseInt(e.target.value) || undefined })}
          />
        </div>
      </div>
    </div>
  );

  const FileUploadFieldConfig = ({ 
    field, 
    onUpdate 
  }: {
    field: FileUploadField;
    onUpdate: (updates: Partial<FileUploadField>) => void;
  }) => (
    <div className="space-y-4 border-t pt-4">
      <h4 className="font-medium text-sm">File Upload Configuration</h4>
      <div className="space-y-2">
        <Label>Description</Label>
        <Textarea
          value={field.properties.description}
          onChange={(e) => onUpdate({ properties: { ...field.properties, description: e.target.value } })}
          placeholder="Description of what files to upload"
        />
      </div>
      <div className="grid grid-cols-2 gap-4">
        <div className="space-y-2">
          <Label>Min File Count</Label>
          <Input
            type="number"
            value={field.validations.minFileCount || ''}
            onChange={(e) => onUpdate({ 
              validations: { ...field.validations, minFileCount: parseInt(e.target.value) || undefined }
            })}
          />
        </div>
        <div className="space-y-2">
          <Label>Max File Count</Label>
          <Input
            type="number"
            value={field.validations.maxFileCount || ''}
            onChange={(e) => onUpdate({ 
              validations: { ...field.validations, maxFileCount: parseInt(e.target.value) || undefined }
            })}
          />
        </div>
        <div className="space-y-2">
          <Label>Max File Size (MB)</Label>
          <Input
            type="number"
            value={field.validations.maxFileSize || ''}
            onChange={(e) => onUpdate({ 
              validations: { ...field.validations, maxFileSize: parseInt(e.target.value) || undefined }
            })}
          />
        </div>
        <div className="space-y-2">
          <Label>Max Total Size (MB)</Label>
          <Input
            type="number"
            value={field.validations.maxTotalSize || ''}
            onChange={(e) => onUpdate({ 
              validations: { ...field.validations, maxTotalSize: parseInt(e.target.value) || undefined }
            })}
          />
        </div>
      </div>
      <div className="space-y-2">
        <Label>Allowed File Types</Label>
        <div className="grid grid-cols-3 gap-2">
          {FILE_TYPES.map(fileType => (
            <div key={fileType} className="flex items-center space-x-2">
              <Checkbox
                checked={field.validations.allowedFileTypes.includes(fileType)}
                onCheckedChange={(checked) => {
                  const currentTypes = field.validations.allowedFileTypes;
                  const newTypes = checked 
                    ? [...currentTypes, fileType]
                    : currentTypes.filter(t => t !== fileType);
                  onUpdate({ validations: { ...field.validations, allowedFileTypes: newTypes } });
                }}
              />
              <Label className="text-xs">{fileType.split('/')[1] || fileType}</Label>
            </div>
          ))}
        </div>
      </div>
    </div>
  );

  const DropdownFieldConfig = ({ 
    field, 
    onUpdate 
  }: {
    field: DropdownField;
    onUpdate: (properties: DropdownField['properties']) => void;
  }) => (
    <div className="space-y-4 border-t pt-4">
      <h4 className="font-medium text-sm">Dropdown Configuration</h4>
      <div className="space-y-2">
        <Label>Data Source</Label>
        <Select
          value={field.properties.dataSource}
          onValueChange={(value: 'predefined' | 'custom') => 
            onUpdate({ ...field.properties, dataSource: value })
          }
        >
          <SelectTrigger>
            <SelectValue />
          </SelectTrigger>
          <SelectContent>
            <SelectItem value="predefined">Predefined</SelectItem>
            <SelectItem value="custom">Custom</SelectItem>
          </SelectContent>
        </Select>
      </div>
      
      {field.properties.dataSource === 'predefined' && (
        <div className="space-y-2">
          <Label>Predefined Type</Label>
          <Select
            value={field.properties.predefinedType || ''}
            onValueChange={(value: 'countries' | 'cities') => 
              onUpdate({ ...field.properties, predefinedType: value })
            }
          >
            <SelectTrigger>
              <SelectValue />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="countries">Countries</SelectItem>
              <SelectItem value="cities">Cities</SelectItem>
            </SelectContent>
          </Select>
        </div>
      )}

      {field.properties.dataSource === 'custom' && (
        <div className="space-y-2">
          <Label>Custom Options</Label>
          {field.properties.customOptions?.map((option, index) => (
            <div key={index} className="flex space-x-2">
              <Input
                placeholder="Label"
                value={option.label}
                onChange={(e) => {
                  const newOptions = [...(field.properties.customOptions || [])];
                  newOptions[index] = { ...option, label: e.target.value };
                  onUpdate({ ...field.properties, customOptions: newOptions });
                }}
              />
              <Input
                placeholder="Value"
                value={option.value}
                onChange={(e) => {
                  const newOptions = [...(field.properties.customOptions || [])];
                  newOptions[index] = { ...option, value: e.target.value };
                  onUpdate({ ...field.properties, customOptions: newOptions });
                }}
              />
              <Button
                variant="ghost"
                size="sm"
                onClick={() => {
                  const newOptions = field.properties.customOptions?.filter((_, i) => i !== index);
                  onUpdate({ ...field.properties, customOptions: newOptions });
                }}
              >
                <Trash2 className="h-4 w-4" />
              </Button>
            </div>
          ))}
          <Button
            variant="outline"
            size="sm"
            onClick={() => {
              const newOptions = [...(field.properties.customOptions || []), { label: '', value: '' }];
              onUpdate({ ...field.properties, customOptions: newOptions });
            }}
          >
            <Plus className="h-4 w-4 mr-2" />
            Add Option
          </Button>
        </div>
      )}
    </div>
  );

  const CurrencyFieldConfig = ({ 
    field, 
    onUpdate 
  }: {
    field: CurrencyField;
    onUpdate: (updates: Partial<CurrencyField>) => void;
  }) => (
    <div className="space-y-4 border-t pt-4">
      <h4 className="font-medium text-sm">Currency Configuration</h4>
      <div className="grid grid-cols-3 gap-4">
        <div className="space-y-2">
          <Label>Currency Unit</Label>
          <Input
            value={field.properties.unit}
            onChange={(e) => onUpdate({ properties: { ...field.properties, unit: e.target.value } })}
            placeholder="USD"
          />
        </div>
        <div className="space-y-2">
          <Label>Minimum Amount</Label>
          <Input
            type="number"
            value={field.validations.min || ''}
            onChange={(e) => onUpdate({ 
              validations: { ...field.validations, min: parseFloat(e.target.value) || undefined }
            })}
          />
        </div>
        <div className="space-y-2">
          <Label>Maximum Amount</Label>
          <Input
            type="number"
            value={field.validations.max || ''}
            onChange={(e) => onUpdate({ 
              validations: { ...field.validations, max: parseFloat(e.target.value) || undefined }
            })}
          />
        </div>
      </div>
    </div>
  );

  const DateFieldConfig = ({ 
    field, 
    onUpdate 
  }: {
    field: DateField;
    onUpdate: (updates: Partial<DateField>) => void;
  }) => (
    <div className="space-y-4 border-t pt-4">
      <h4 className="font-medium text-sm">Date Configuration</h4>
      <div className="grid grid-cols-2 gap-4">
        <div className="space-y-2">
          <Label>Start Date</Label>
          <Input
            type="date"
            value={field.validations.startDate || ''}
            onChange={(e) => onUpdate({ 
              validations: { ...field.validations, startDate: e.target.value }
            })}
          />
        </div>
        <div className="space-y-2">
          <Label>End Date</Label>
          <Input
            type="date"
            value={field.validations.endDate || ''}
            onChange={(e) => onUpdate({ 
              validations: { ...field.validations, endDate: e.target.value }
            })}
          />
        </div>
      </div>
      <div className="space-y-2">
        <Label>Selectable Days</Label>
        <div className="grid grid-cols-7 gap-2">
          {['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'].map(day => (
            <div key={day} className="flex items-center space-x-1">
              <Checkbox
                checked={field.properties.selectableDays?.includes(day) || false}
                onCheckedChange={(checked) => {
                  const currentDays = field.properties.selectableDays || [];
                  const newDays = checked 
                    ? [...currentDays, day]
                    : currentDays.filter(d => d !== day);
                  onUpdate({ properties: { ...field.properties, selectableDays: newDays } });
                }}
              />
              <Label className="text-xs">{day}</Label>
            </div>
          ))}
        </div>
      </div>
    </div>
  );

  const RadioFieldConfig = ({ 
    field, 
    onUpdate 
  }: {
    field: RadioField;
    onUpdate: (properties: RadioField['properties']) => void;
  }) => (
    <div className="space-y-4 border-t pt-4">
      <h4 className="font-medium text-sm">Radio Configuration</h4>
      <div className="space-y-2">
        <Label>Options</Label>
        {field.properties.options.map((option, index) => (
          <div key={index} className="flex space-x-2">
            <Input
              placeholder="Label"
              value={option.label}
              onChange={(e) => {
                const newOptions = [...field.properties.options];
                newOptions[index] = { ...option, label: e.target.value };
                onUpdate({ ...field.properties, options: newOptions });
              }}
            />
            <Input
              placeholder="Value"
              value={option.value}
              onChange={(e) => {
                const newOptions = [...field.properties.options];
                newOptions[index] = { ...option, value: e.target.value };
                onUpdate({ ...field.properties, options: newOptions });
              }}
            />
            <Button
              variant="ghost"
              size="sm"
              onClick={() => {
                const newOptions = field.properties.options.filter((_, i) => i !== index);
                onUpdate({ ...field.properties, options: newOptions });
              }}
            >
              <Trash2 className="h-4 w-4" />
            </Button>
          </div>
        ))}
        <Button
          variant="outline"
          size="sm"
          onClick={() => {
            const newOptions = [...field.properties.options, { label: '', value: '' }];
            onUpdate({ ...field.properties, options: newOptions });
          }}
        >
          <Plus className="h-4 w-4 mr-2" />
          Add Option
        </Button>
      </div>
      <div className="space-y-2">
        <Label>Default Selection</Label>
        <Select
          value={field.properties.defaultSelection || ''}
          onValueChange={(value) => onUpdate({ ...field.properties, defaultSelection: value })}
        >
          <SelectTrigger>
            <SelectValue placeholder="Select default" />
          </SelectTrigger>
          <SelectContent>
            {field.properties.options.map(option => (
              <SelectItem key={option.value} value={option.value}>
                {option.label}
              </SelectItem>
            ))}
          </SelectContent>
        </Select>
      </div>
    </div>
  );

  const CheckboxFieldConfig = ({ 
    field, 
    onUpdate 
  }: {
    field: CheckboxField;
    onUpdate: (properties: CheckboxField['properties']) => void;
  }) => (
    <div className="space-y-4 border-t pt-4">
      <h4 className="font-medium text-sm">Checkbox Configuration</h4>
      <div className="space-y-2">
        <Label>Options</Label>
        {field.properties.options.map((option, index) => (
          <div key={index} className="flex space-x-2">
            <Input
              placeholder="Label"
              value={option.label}
              onChange={(e) => {
                const newOptions = [...field.properties.options];
                newOptions[index] = { ...option, label: e.target.value };
                onUpdate({ ...field.properties, options: newOptions });
              }}
            />
            <Input
              placeholder="Value"
              value={option.value}
              onChange={(e) => {
                const newOptions = [...field.properties.options];
                newOptions[index] = { ...option, value: e.target.value };
                onUpdate({ ...field.properties, options: newOptions });
              }}
            />
            <Button
              variant="ghost"
              size="sm"
              onClick={() => {
                const newOptions = field.properties.options.filter((_, i) => i !== index);
                onUpdate({ ...field.properties, options: newOptions });
              }}
            >
              <Trash2 className="h-4 w-4" />
            </Button>
          </div>
        ))}
        <Button
          variant="outline"
          size="sm"
          onClick={() => {
            const newOptions = [...field.properties.options, { label: '', value: '' }];
            onUpdate({ ...field.properties, options: newOptions });
          }}
        >
          <Plus className="h-4 w-4 mr-2" />
          Add Option
        </Button>
      </div>
    </div>
  );

  const RichTextFieldConfig = ({ 
    field, 
    onUpdate 
  }: {
    field: RichTextField;
    onUpdate: (properties: RichTextField['properties']) => void;
  }) => (
    <div className="space-y-4 border-t pt-4">
      <h4 className="font-medium text-sm">Rich Text Configuration</h4>
      <div className="grid grid-cols-2 gap-4">
        <div className="flex items-center space-x-2">
          <Switch
            checked={field.properties.allowBold}
            onCheckedChange={(checked) => onUpdate({ ...field.properties, allowBold: checked })}
          />
          <Label>Allow Bold</Label>
        </div>
        <div className="flex items-center space-x-2">
          <Switch
            checked={field.properties.allowItalic}
            onCheckedChange={(checked) => onUpdate({ ...field.properties, allowItalic: checked })}
          />
          <Label>Allow Italic</Label>
        </div>
        <div className="flex items-center space-x-2">
          <Switch
            checked={field.properties.allowUnderline}
            onCheckedChange={(checked) => onUpdate({ ...field.properties, allowUnderline: checked })}
          />
          <Label>Allow Underline</Label>
        </div>
        <div className="flex items-center space-x-2">
          <Switch
            checked={field.properties.allowLinks}
            onCheckedChange={(checked) => onUpdate({ ...field.properties, allowLinks: checked })}
          />
          <Label>Allow Links</Label>
        </div>
        <div className="flex items-center space-x-2">
          <Switch
            checked={field.properties.allowImages}
            onCheckedChange={(checked) => onUpdate({ ...field.properties, allowImages: checked })}
          />
          <Label>Allow Images</Label>
        </div>
      </div>
    </div>
  );

  const AppointmentCardFieldConfig = ({ 
    field, 
    onUpdate 
  }: {
    field: AppointmentCardField;
    onUpdate: (properties: AppointmentCardField['properties']) => void;
  }) => (
    <div className="space-y-4 border-t pt-4">
      <h4 className="font-medium text-sm">Appointment Card Configuration</h4>
      <div className="flex items-center space-x-2">
        <Switch
          checked={field.properties.scheduled}
          onCheckedChange={(checked) => onUpdate({ ...field.properties, scheduled: checked })}
        />
        <Label>Pre-scheduled</Label>
      </div>
      {field.properties.scheduled && (
        <>
          <div className="space-y-2">
            <Label>Slot Details</Label>
            <Input
              value={field.properties.slotDetails || ''}
              onChange={(e) => onUpdate({ ...field.properties, slotDetails: e.target.value })}
              placeholder="Available slots information"
            />
          </div>
          <div className="space-y-2">
            <Label>Booking Information</Label>
            <Textarea
              value={field.properties.bookingInfo || ''}
              onChange={(e) => onUpdate({ ...field.properties, bookingInfo: e.target.value })}
              placeholder="Booking instructions and requirements"
            />
          </div>
        </>
      )}
    </div>
  );

  return (
    <div className="p-6 space-y-6">
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-2xl font-bold">Create Service Form</h1>
          <p className="text-gray-600 mt-1">
            Create a new service for {currentDepartment?.name || 'your department'}
          </p>
        </div>
        <Button 
          onClick={handleSaveForm} 
          disabled={!formData.name || !currentDepartment || isLoading}
        >
          {isLoading ? (
            <>
              <Loader2 className="h-4 w-4 mr-2 animate-spin" />
              Saving...
            </>
          ) : (
            'Save Form'
          )}
        </Button>
      </div>

      {/* Error Alert */}
      {error && (
        <Alert variant="destructive">
          <AlertCircle className="h-4 w-4" />
          <AlertDescription>{error}</AlertDescription>
        </Alert>
      )}

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Form Configuration */}
        <Card>
          <CardHeader>
            <CardTitle>Form Configuration</CardTitle>
          </CardHeader>
          <CardContent className="space-y-4">
            <div className="space-y-2">
              <Label htmlFor="form-name">Form Name</Label>
              <Input
                id="form-name"
                value={formData.name}
                onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                placeholder="Enter form name"
              />
            </div>
            
            <div className="space-y-2">
              <Label htmlFor="form-description">Description</Label>
              <Textarea
                id="form-description"
                value={formData.description}
                onChange={(e) => setFormData({ ...formData, description: e.target.value })}
                placeholder="Enter form description"
              />
            </div>
            
            <div className="space-y-2">
              <Label>Department</Label>
              <div className="p-3 bg-gray-50 rounded-md border">
                <div className="flex items-center space-x-2">
                  <div className="p-1 bg-blue-100 rounded">
                    <Settings className="h-4 w-4 text-blue-600" />
                  </div>
                  <div>
                    <p className="font-medium">{currentDepartment?.name || 'Loading...'}</p>
                    <p className="text-sm text-gray-500">Creating service for your department</p>
                  </div>
                </div>
              </div>
            </div>

            <div className="space-y-2">
              <Label>Field Type to Add</Label>
              <Select
                value={selectedFieldType}
                onValueChange={(value: FieldType) => setSelectedFieldType(value)}
              >
                <SelectTrigger>
                  <SelectValue placeholder="Select field type" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="text">Text Input</SelectItem>
                  <SelectItem value="number">Numeric Input</SelectItem>
                  <SelectItem value="file">File Upload</SelectItem>
                  <SelectItem value="dropdown">Dropdown</SelectItem>
                  <SelectItem value="currency">Currency</SelectItem>
                  <SelectItem value="date">Date/Date Range</SelectItem>
                  <SelectItem value="radio">Radio/Toggle</SelectItem>
                  <SelectItem value="checkbox">Checkbox</SelectItem>
                  <SelectItem value="richtext">Rich Text</SelectItem>
                  <SelectItem value="appointment_card">Appointment Card</SelectItem>
                </SelectContent>
              </Select>
            </div>

            <Button onClick={handleAddField} className="w-full">
              <Plus className="h-4 w-4 mr-2" />
              Add Field
            </Button>
          </CardContent>
        </Card>

        {/* Form Fields */}
        <Card>
          <CardHeader>
            <CardTitle>Form Fields</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="space-y-4">
              {formData.fields.map((field, index) => (
                <FieldConfigCard
                  key={field.id}
                  field={field}
                  onUpdate={(updates) => updateField(field.id, updates)}
                  onDelete={() => deleteField(field.id)}
                />
              ))}
              
              {formData.fields.length === 0 && (
                <div className="text-center py-8 text-gray-500">
                  No fields added yet. Select a field type and click "Add Field" to start building your form.
                </div>
              )}
            </div>
          </CardContent>
        </Card>
      </div>

      {/* Form Preview */}
      {formData.fields.length > 0 && (
        <Card>
          <CardHeader>
            <CardTitle>Form Preview</CardTitle>
            <CardDescription>This is how the form will appear to users</CardDescription>
          </CardHeader>
          <CardContent>
            <div className="bg-gray-50 p-6 rounded-lg">
              <h3 className="text-lg font-semibold mb-4">{formData.name || 'Untitled Form'}</h3>
              {formData.description && (
                <p className="text-gray-600 mb-6">{formData.description}</p>
              )}
              
              <div className="space-y-4">
                {formData.fields.map((field) => (
                  <div key={field.id} className="space-y-2">
                    <Label className="flex items-center">
                      {field.label}
                      {field.required && <span className="text-red-500 ml-1">*</span>}
                    </Label>
                    
                    {/* Field preview based on type */}
                    {field.type === 'text' && (
                      <Input placeholder={field.placeholder} disabled />
                    )}
                    {field.type === 'number' && (
                      <Input type="number" placeholder={field.placeholder} disabled />
                    )}
                    {field.type === 'file' && (
                      <div className="border-2 border-dashed border-gray-300 rounded-lg p-4 text-center text-gray-500">
                        Click to upload files or drag and drop
                      </div>
                    )}
                    {field.type === 'dropdown' && (
                      <Select disabled>
                        <SelectTrigger>
                          <SelectValue placeholder={field.placeholder} />
                        </SelectTrigger>
                      </Select>
                    )}
                    {field.type === 'currency' && (
                      <Input placeholder="$0.00" disabled />
                    )}
                    {field.type === 'date' && (
                      <Input type="date" disabled />
                    )}
                    {field.type === 'radio' && (
                      <div className="space-y-2">
                        {(field as RadioField).properties.options.map((option) => (
                          <div key={option.value} className="flex items-center space-x-2">
                            <input type="radio" disabled />
                            <Label>{option.label}</Label>
                          </div>
                        ))}
                      </div>
                    )}
                    {field.type === 'checkbox' && (
                      <div className="space-y-2">
                        {(field as CheckboxField).properties.options.map((option) => (
                          <div key={option.value} className="flex items-center space-x-2">
                            <input type="checkbox" disabled />
                            <Label>{option.label}</Label>
                          </div>
                        ))}
                      </div>
                    )}
                    {field.type === 'richtext' && (
                      <Textarea placeholder={field.placeholder} disabled className="min-h-[100px]" />
                    )}
                    {field.type === 'appointment_card' && (
                      <Card className="bg-blue-50 border-blue-200">
                        <CardContent className="pt-4">
                          <div className="flex items-center space-x-2 text-blue-700">
                            <Calendar className="h-4 w-4" />
                            <span className="font-medium">Appointment Booking</span>
                          </div>
                          <p className="text-sm text-blue-600 mt-2">
                            Click to schedule your appointment
                          </p>
                        </CardContent>
                      </Card>
                    )}
                  </div>
                ))}
                
                <Button className="w-full mt-6" disabled>
                  Submit Form
                </Button>
              </div>
            </div>
          </CardContent>
        </Card>
      )}
    </div>
  );
}

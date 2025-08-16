"use client"

import { useState } from "react"
import { useRouter } from "next/navigation"
import Link from "next/link"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { Textarea } from "@/components/ui/textarea"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"
import { Switch } from "@/components/ui/switch"
import { Badge } from "@/components/ui/badge"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import { 
  Building2, 
  ArrowLeft, 
  Save, 
  AlertCircle, 
  Plus, 
  Trash2, 
  Edit, 
  GripVertical,
  Eye,
  Settings
} from "lucide-react"
import { ServicesService, CreateServiceRequest } from "@/lib/services/services.service"

// Field types available for form building
const FIELD_TYPES = [
  { value: "text", label: "Text Input" },
  { value: "email", label: "Email" },
  { value: "phone_number", label: "Phone Number" },
  { value: "textarea", label: "Text Area" },
  { value: "number", label: "Number" },
  { value: "date", label: "Date" },
  { value: "dropdown", label: "Dropdown" },
  { value: "radio", label: "Radio Button" },
  { value: "checkbox", label: "Checkbox" },
  { value: "document_upload", label: "Document Upload" }
]

// Auto-fill field options for the first section
const AUTO_FILL_FIELDS = [
  { value: "user_name", label: "User Full Name" },
  { value: "user_email", label: "User Email" },
  { value: "user_phone", label: "User Phone" },
  { value: "user_address", label: "User Address" },
  { value: "user_id", label: "User ID" },
  { value: "submission_date", label: "Submission Date" }
]

interface FormField {
  id?: string
  label: string
  fieldName: string
  fieldType: string
  isRequired: boolean
  placeholder?: string
  helpText?: string
  orderIndex: number
  autoFillSource?: string // For first section fields
  validationRules?: Record<string, any>
  options?: { value: string; label: string }[]
  metadata?: any
}

interface FormSection {
  id?: string
  title: string
  description?: string
  pageNumber: number
  orderIndex: number
  fields: FormField[]
}

interface FormConfig {
  title: string
  description: string
  sections: FormSection[]
}

export default function CreateServicePage() {
  const router = useRouter()
  const [isSubmitting, setIsSubmitting] = useState(false)
  const [error, setError] = useState<string | null>(null)

  const [basicInfo, setBasicInfo] = useState({
    name: "",
    description: "",
  })

  const [formConfig, setFormConfig] = useState<FormConfig>({
    title: "",
    description: "",
    sections: [
      {
        title: "Auto-filled Information",
        description: "This section contains information that will be automatically filled from user profile",
        pageNumber: 1,
        orderIndex: 1,
        fields: []
      }
    ]
  })

  const servicesService = ServicesService.getInstance()

  const handleBasicInfoChange = (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement>) => {
    const { name, value } = e.target
    setBasicInfo(prev => ({ ...prev, [name]: value }))
    
    // Update form config title/description when basic info changes
    if (name === 'name') {
      setFormConfig(prev => ({ ...prev, title: value }))
    } else if (name === 'description') {
      setFormConfig(prev => ({ ...prev, description: value }))
    }
  }

  const addSection = () => {
    const newSection: FormSection = {
      id: Date.now().toString(),
      title: "New Section",
      description: "",
      pageNumber: formConfig.sections.length + 1,
      orderIndex: formConfig.sections.length + 1,
      fields: []
    }
    setFormConfig(prev => ({
      ...prev,
      sections: [...prev.sections, newSection]
    }))
  }

  const updateSection = (sectionIndex: number, updates: Partial<FormSection>) => {
    setFormConfig(prev => ({
      ...prev,
      sections: prev.sections.map((section, index) => 
        index === sectionIndex ? { ...section, ...updates } : section
      )
    }))
  }

  const removeSection = (sectionIndex: number) => {
    if (sectionIndex === 0) return // Can't remove auto-fill section
    setFormConfig(prev => ({
      ...prev,
      sections: prev.sections.filter((_, index) => index !== sectionIndex)
    }))
  }

  const addField = (sectionIndex: number) => {
    const section = formConfig.sections[sectionIndex]
    const newField: FormField = {
      id: Date.now().toString(),
      label: "New Field",
      fieldName: `field_${Date.now()}`,
      fieldType: "text",
      isRequired: false,
      placeholder: "",
      helpText: "",
      orderIndex: section.fields.length + 1,
      ...(sectionIndex === 0 && { autoFillSource: "user_name" }) // Auto-fill for first section
    }
    updateSection(sectionIndex, {
      fields: [...section.fields, newField]
    })
  }

  const updateField = (sectionIndex: number, fieldIndex: number, updates: Partial<FormField>) => {
    const section = formConfig.sections[sectionIndex]
    const updatedFields = section.fields.map((field, index) => 
      index === fieldIndex ? { ...field, ...updates } : field
    )
    updateSection(sectionIndex, { fields: updatedFields })
  }

  const removeField = (sectionIndex: number, fieldIndex: number) => {
    const section = formConfig.sections[sectionIndex]
    const updatedFields = section.fields.filter((_, index) => index !== fieldIndex)
    updateSection(sectionIndex, { fields: updatedFields })
  }

  const addDropdownOption = (sectionIndex: number, fieldIndex: number) => {
    const field = formConfig.sections[sectionIndex].fields[fieldIndex]
    const options = field.options || []
    const newOption = { value: `option_${Date.now()}`, label: "New Option" }
    updateField(sectionIndex, fieldIndex, {
      options: [...options, newOption]
    })
  }

  const updateDropdownOption = (sectionIndex: number, fieldIndex: number, optionIndex: number, updates: Partial<{ value: string; label: string }>) => {
    const field = formConfig.sections[sectionIndex].fields[fieldIndex]
    const options = field.options || []
    const updatedOptions = options.map((option, index) => 
      index === optionIndex ? { ...option, ...updates } : option
    )
    updateField(sectionIndex, fieldIndex, { options: updatedOptions })
  }

  const removeDropdownOption = (sectionIndex: number, fieldIndex: number, optionIndex: number) => {
    const field = formConfig.sections[sectionIndex].fields[fieldIndex]
    const options = field.options || []
    const updatedOptions = options.filter((_, index) => index !== optionIndex)
    updateField(sectionIndex, fieldIndex, { options: updatedOptions })
  }

  const handleSubmit = async () => {
    if (!basicInfo.name.trim()) {
      setError("Service name is required")
      return
    }

    setIsSubmitting(true)
    setError(null)

    try {
      const serviceData: CreateServiceRequest = {
        title: basicInfo.name,
        description: basicInfo.description,
        sections: formConfig.sections.map(section => ({
          title: section.title,
          description: section.description || "",
          pageNumber: section.pageNumber,
          orderIndex: section.orderIndex,
          fields: section.fields.map(field => ({
            label: field.label,
            fieldName: field.fieldName,
            fieldType: field.fieldType,
            isRequired: field.isRequired,
            placeholder: field.placeholder || "",
            helpText: field.helpText || "",
            orderIndex: field.orderIndex,
            validationRules: field.validationRules,
            options: field.options,
            metadata: {
              ...(field.metadata || {}),
              ...(field.autoFillSource && { autoFillSource: field.autoFillSource })
            }
          }))
        }))
      }

      const newService = await servicesService.createService(serviceData)
      router.push(`/dashboard/services/${newService.id}`)
    } catch (err) {
      setError(err instanceof Error ? err.message : "Failed to create service")
    } finally {
      setIsSubmitting(false)
    }
  }

  return (
    <div className="min-h-screen bg-background">
      {/* Header */}
      <header className="border-b border-border bg-card">
        <div className="container mx-auto px-4 py-4">
          <div className="flex items-center justify-between">
            <div className="flex items-center space-x-4">
              <Link href="/dashboard/services">
                <Button variant="ghost" size="sm">
                  <ArrowLeft className="h-4 w-4 mr-2" />
                  Back to Services
                </Button>
              </Link>
              <div>
                <h1 className="text-xl font-bold text-foreground">Create New Service</h1>
                <p className="text-sm text-muted-foreground">Design your service and configure its form structure</p>
              </div>
            </div>
            <Button onClick={handleSubmit} disabled={isSubmitting}>
              <Save className="h-4 w-4 mr-2" />
              {isSubmitting ? "Creating..." : "Create Service"}
            </Button>
          </div>
        </div>
      </header>

      <div className="container mx-auto px-4 py-8">
        {/* Error Message */}
        {error && (
          <div className="mb-6 p-4 bg-red-50 border border-red-200 rounded-md flex items-center">
            <AlertCircle className="h-5 w-5 text-red-600 mr-2" />
            <span className="text-red-700">{error}</span>
          </div>
        )}

        <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
          {/* Form Builder */}
          <div className="lg:col-span-2">
            <Tabs defaultValue="builder" className="w-full">
              <TabsList className="grid w-full grid-cols-2">
                <TabsTrigger value="builder">
                  <Settings className="h-4 w-4 mr-2" />
                  Form Builder
                </TabsTrigger>
                <TabsTrigger value="preview">
                  <Eye className="h-4 w-4 mr-2" />
                  Preview
                </TabsTrigger>
              </TabsList>
              
              <TabsContent value="builder" className="space-y-6">
                {/* Basic Information */}
                <Card>
                  <CardHeader>
                    <CardTitle>Service Information</CardTitle>
                    <CardDescription>
                      Basic details about your service
                    </CardDescription>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    <div>
                      <Label htmlFor="name">Service Name *</Label>
                      <Input
                        id="name"
                        name="name"
                        value={basicInfo.name}
                        onChange={handleBasicInfoChange}
                        placeholder="Enter service name (e.g., 'ID Recovery Application')"
                        required
                      />
                    </div>
                    <div>
                      <Label htmlFor="description">Description</Label>
                      <Textarea
                        id="description"
                        name="description"
                        value={basicInfo.description}
                        onChange={handleBasicInfoChange}
                        placeholder="Describe what this service provides to citizens"
                        rows={3}
                      />
                    </div>
                  </CardContent>
                </Card>

                {/* Form Sections */}
                <Card>
                  <CardHeader>
                    <div className="flex items-center justify-between">
                      <div>
                        <CardTitle>Form Structure</CardTitle>
                        <CardDescription>
                          Design the form that citizens will fill out
                        </CardDescription>
                      </div>
                      <Button onClick={addSection} size="sm">
                        <Plus className="h-4 w-4 mr-2" />
                        Add Section
                      </Button>
                    </div>
                  </CardHeader>
                  <CardContent className="space-y-6">
                    {formConfig.sections.map((section, sectionIndex) => (
                      <div key={sectionIndex} className="border rounded-lg p-4 space-y-4">
                        <div className="flex items-center justify-between">
                          <div className="flex items-center space-x-2">
                            <GripVertical className="h-4 w-4 text-muted-foreground" />
                            <Badge variant={sectionIndex === 0 ? "default" : "secondary"}>
                              Page {section.pageNumber}
                            </Badge>
                            {sectionIndex === 0 && (
                              <Badge variant="outline">Auto-fill Section</Badge>
                            )}
                          </div>
                          {sectionIndex > 0 && (
                            <Button
                              variant="ghost"
                              size="sm"
                              onClick={() => removeSection(sectionIndex)}
                            >
                              <Trash2 className="h-4 w-4" />
                            </Button>
                          )}
                        </div>

                        <div className="grid grid-cols-2 gap-4">
                          <div>
                            <Label htmlFor={`section-title-${sectionIndex}`}>Section Title</Label>
                            <Input
                              id={`section-title-${sectionIndex}`}
                              value={section.title}
                              onChange={(e) => updateSection(sectionIndex, { title: e.target.value })}
                              placeholder="Section title"
                            />
                          </div>
                          <div>
                            <Label htmlFor={`section-description-${sectionIndex}`}>Description (Optional)</Label>
                            <Input
                              id={`section-description-${sectionIndex}`}
                              value={section.description || ""}
                              onChange={(e) => updateSection(sectionIndex, { description: e.target.value })}
                              placeholder="Section description"
                            />
                          </div>
                        </div>

                        {/* Fields */}
                        <div className="space-y-3">
                          <div className="flex items-center justify-between">
                            <Label className="text-sm font-medium">Fields</Label>
                            <Button
                              variant="outline"
                              size="sm"
                              onClick={() => addField(sectionIndex)}
                            >
                              <Plus className="h-4 w-4 mr-2" />
                              Add Field
                            </Button>
                          </div>

                          {section.fields.map((field, fieldIndex) => (
                            <div key={fieldIndex} className="border rounded p-3 space-y-3 bg-muted/30">
                              <div className="flex items-center justify-between">
                                <div className="flex items-center space-x-2">
                                  <GripVertical className="h-3 w-3 text-muted-foreground" />
                                  <span className="text-sm font-medium">Field {fieldIndex + 1}</span>
                                </div>
                                <Button
                                  variant="ghost"
                                  size="sm"
                                  onClick={() => removeField(sectionIndex, fieldIndex)}
                                >
                                  <Trash2 className="h-3 w-3" />
                                </Button>
                              </div>

                              <div className="grid grid-cols-2 gap-3">
                                <div>
                                  <Label htmlFor={`field-label-${sectionIndex}-${fieldIndex}`}>Label</Label>
                                  <Input
                                    id={`field-label-${sectionIndex}-${fieldIndex}`}
                                    value={field.label}
                                    onChange={(e) => updateField(sectionIndex, fieldIndex, { label: e.target.value })}
                                    placeholder="Field label"
                                  />
                                </div>
                                <div>
                                  <Label htmlFor={`field-name-${sectionIndex}-${fieldIndex}`}>Field Name</Label>
                                  <Input
                                    id={`field-name-${sectionIndex}-${fieldIndex}`}
                                    value={field.fieldName}
                                    onChange={(e) => updateField(sectionIndex, fieldIndex, { fieldName: e.target.value })}
                                    placeholder="field_name"
                                  />
                                </div>
                              </div>

                              <div className="grid grid-cols-2 gap-3">
                                <div>
                                  <Label htmlFor={`field-type-${sectionIndex}-${fieldIndex}`}>Field Type</Label>
                                  <Select
                                    value={field.fieldType}
                                    onValueChange={(value) => updateField(sectionIndex, fieldIndex, { fieldType: value })}
                                  >
                                    <SelectTrigger>
                                      <SelectValue placeholder="Select field type" />
                                    </SelectTrigger>
                                    <SelectContent>
                                      {FIELD_TYPES.map((type) => (
                                        <SelectItem key={type.value} value={type.value}>
                                          {type.label}
                                        </SelectItem>
                                      ))}
                                    </SelectContent>
                                  </Select>
                                </div>
                                {sectionIndex === 0 && (
                                  <div>
                                    <Label htmlFor={`auto-fill-${sectionIndex}-${fieldIndex}`}>Auto-fill Source</Label>
                                    <Select
                                      value={field.autoFillSource || "none"}
                                      onValueChange={(value) => updateField(sectionIndex, fieldIndex, { autoFillSource: value === "none" ? undefined : value })}
                                    >
                                      <SelectTrigger>
                                        <SelectValue placeholder="Select auto-fill source" />
                                      </SelectTrigger>
                                      <SelectContent>
                                        <SelectItem value="none">None</SelectItem>
                                        {AUTO_FILL_FIELDS.map((option) => (
                                          <SelectItem key={option.value} value={option.value}>
                                            {option.label}
                                          </SelectItem>
                                        ))}
                                      </SelectContent>
                                    </Select>
                                  </div>
                                )}
                              </div>

                              <div className="grid grid-cols-2 gap-3">
                                <div>
                                  <Label htmlFor={`field-placeholder-${sectionIndex}-${fieldIndex}`}>Placeholder</Label>
                                  <Input
                                    id={`field-placeholder-${sectionIndex}-${fieldIndex}`}
                                    value={field.placeholder || ""}
                                    onChange={(e) => updateField(sectionIndex, fieldIndex, { placeholder: e.target.value })}
                                    placeholder="Enter placeholder text"
                                  />
                                </div>
                                <div>
                                  <Label htmlFor={`field-help-${sectionIndex}-${fieldIndex}`}>Help Text</Label>
                                  <Input
                                    id={`field-help-${sectionIndex}-${fieldIndex}`}
                                    value={field.helpText || ""}
                                    onChange={(e) => updateField(sectionIndex, fieldIndex, { helpText: e.target.value })}
                                    placeholder="Help text"
                                  />
                                </div>
                              </div>

                              <div className="flex items-center space-x-2">
                                <Switch
                                  id={`field-required-${sectionIndex}-${fieldIndex}`}
                                  checked={field.isRequired}
                                  onCheckedChange={(checked) => updateField(sectionIndex, fieldIndex, { isRequired: checked })}
                                />
                                <Label htmlFor={`field-required-${sectionIndex}-${fieldIndex}`}>Required field</Label>
                              </div>

                              {/* Dropdown/Radio/Checkbox Options */}
                              {(field.fieldType === "dropdown" || field.fieldType === "radio" || field.fieldType === "checkbox") && (
                                <div className="space-y-2">
                                  <div className="flex items-center justify-between">
                                    <Label className="text-sm">Options</Label>
                                    <Button
                                      variant="outline"
                                      size="sm"
                                      onClick={() => addDropdownOption(sectionIndex, fieldIndex)}
                                    >
                                      <Plus className="h-3 w-3 mr-1" />
                                      Add Option
                                    </Button>
                                  </div>
                                  {field.options?.map((option, optionIndex) => (
                                    <div key={optionIndex} className="flex items-center space-x-2">
                                      <Input
                                        value={option.label}
                                        onChange={(e) => updateDropdownOption(sectionIndex, fieldIndex, optionIndex, { label: e.target.value })}
                                        placeholder="Option label"
                                        className="flex-1"
                                      />
                                      <Input
                                        value={option.value}
                                        onChange={(e) => updateDropdownOption(sectionIndex, fieldIndex, optionIndex, { value: e.target.value })}
                                        placeholder="Option value"
                                        className="flex-1"
                                      />
                                      <Button
                                        variant="ghost"
                                        size="sm"
                                        onClick={() => removeDropdownOption(sectionIndex, fieldIndex, optionIndex)}
                                      >
                                        <Trash2 className="h-3 w-3" />
                                      </Button>
                                    </div>
                                  ))}
                                </div>
                              )}
                            </div>
                          ))}

                          {section.fields.length === 0 && (
                            <div className="text-center py-8 text-muted-foreground">
                              <Plus className="h-8 w-8 mx-auto mb-2 opacity-50" />
                              <p>No fields added yet</p>
                              <Button
                                variant="outline"
                                size="sm"
                                onClick={() => addField(sectionIndex)}
                                className="mt-2"
                              >
                                Add First Field
                              </Button>
                            </div>
                          )}
                        </div>
                      </div>
                    ))}
                  </CardContent>
                </Card>
              </TabsContent>
              
              <TabsContent value="preview" className="space-y-6">
                <Card>
                  <CardHeader>
                    <CardTitle>{formConfig.title || "Untitled Service"}</CardTitle>
                    <CardDescription>{formConfig.description || "No description provided"}</CardDescription>
                  </CardHeader>
                  <CardContent>
                    <div className="space-y-8">
                      {formConfig.sections.map((section, sectionIndex) => (
                        <div key={sectionIndex} className="space-y-4">
                          <div>
                            <h3 className="text-lg font-semibold">{section.title}</h3>
                            {section.description && (
                              <p className="text-sm text-muted-foreground">{section.description}</p>
                            )}
                          </div>
                          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                            {section.fields.map((field, fieldIndex) => (
                              <div key={fieldIndex} className="space-y-2">
                                <Label htmlFor={`preview-${sectionIndex}-${fieldIndex}`}>
                                  {field.label}
                                  {field.isRequired && <span className="text-red-500 ml-1">*</span>}
                                  {field.autoFillSource && (
                                    <Badge variant="outline" className="ml-2 text-xs">Auto-fill</Badge>
                                  )}
                                </Label>
                                {field.fieldType === "textarea" ? (
                                  <Textarea
                                    id={`preview-${sectionIndex}-${fieldIndex}`}
                                    placeholder={field.placeholder}
                                    disabled
                                  />
                                ) : field.fieldType === "dropdown" ? (
                                  <Select disabled>
                                    <SelectTrigger>
                                      <SelectValue placeholder={field.placeholder || "Select an option"} />
                                    </SelectTrigger>
                                  </Select>
                                ) : (
                                  <Input
                                    id={`preview-${sectionIndex}-${fieldIndex}`}
                                    type={field.fieldType === "email" ? "email" : field.fieldType === "number" ? "number" : field.fieldType === "date" ? "date" : "text"}
                                    placeholder={field.placeholder}
                                    disabled
                                  />
                                )}
                                {field.helpText && (
                                  <p className="text-xs text-muted-foreground">{field.helpText}</p>
                                )}
                              </div>
                            ))}
                          </div>
                        </div>
                      ))}
                    </div>
                  </CardContent>
                </Card>
              </TabsContent>
            </Tabs>
          </div>

          {/* Sidebar */}
          <div className="space-y-6">
            <Card>
              <CardHeader>
                <CardTitle className="text-lg">Quick Actions</CardTitle>
              </CardHeader>
              <CardContent className="space-y-3">
                <Button onClick={handleSubmit} disabled={isSubmitting} className="w-full">
                  <Save className="h-4 w-4 mr-2" />
                  {isSubmitting ? "Creating..." : "Create Service"}
                </Button>
                <Link href="/dashboard/services">
                  <Button variant="outline" className="w-full">
                    Cancel
                  </Button>
                </Link>
              </CardContent>
            </Card>

            <Card>
              <CardHeader>
                <CardTitle className="text-lg">Form Statistics</CardTitle>
              </CardHeader>
              <CardContent className="space-y-3">
                <div className="flex justify-between">
                  <span className="text-sm text-muted-foreground">Sections:</span>
                  <span className="font-medium">{formConfig.sections.length}</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-sm text-muted-foreground">Total Fields:</span>
                  <span className="font-medium">
                    {formConfig.sections.reduce((total, section) => total + section.fields.length, 0)}
                  </span>
                </div>
                <div className="flex justify-between">
                  <span className="text-sm text-muted-foreground">Auto-fill Fields:</span>
                  <span className="font-medium">
                    {formConfig.sections[0]?.fields.filter(field => field.autoFillSource).length || 0}
                  </span>
                </div>
              </CardContent>
            </Card>

            <Card>
              <CardHeader>
                <CardTitle className="text-lg">Tips</CardTitle>
              </CardHeader>
              <CardContent className="space-y-3 text-sm text-muted-foreground">
                <div className="space-y-2">
                  <p>• The first section supports auto-fill from user profiles</p>
                  <p>• Use clear field labels and help text</p>
                  <p>• Mark important fields as required</p>
                  <p>• Preview your form before creating</p>
                </div>
              </CardContent>
            </Card>
          </div>
        </div>
      </div>
    </div>
  )
}

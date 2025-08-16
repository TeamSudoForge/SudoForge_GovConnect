"use client"

import { useState, useEffect } from "react"
import { useParams, useRouter } from "next/navigation"
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
import { ServicesService, Service, UpdateServiceRequest } from "@/lib/services/services.service"

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

export default function EditServicePage() {
  const params = useParams()
  const router = useRouter()
  const [service, setService] = useState<Service | null>(null)
  const [isLoading, setIsLoading] = useState(true)
  const [isSaving, setIsSaving] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const [successMessage, setSuccessMessage] = useState<string | null>(null)

  const [basicInfo, setBasicInfo] = useState({
    name: "",
    description: "",
    isActive: true,
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
  const serviceId = params.id as string

  useEffect(() => {
    if (serviceId) {
      loadService()
    }
  }, [serviceId])

  const loadService = async () => {
    try {
      setIsLoading(true)
      setError(null)
      const data = await servicesService.getServiceById(serviceId)
      setService(data)
      setBasicInfo({
        name: data.title,
        description: data.description || "",
        isActive: data.isActive,
      })
      setFormConfig(prev => ({
        ...prev,
        title: data.title,
        description: data.description || ""
      }))
    } catch (err) {
      setError(err instanceof Error ? err.message : "Failed to load service")
    } finally {
      setIsLoading(false)
    }
  }

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

  const handleSwitchChange = (checked: boolean) => {
    setBasicInfo(prev => ({ ...prev, isActive: checked }))
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
      ...(sectionIndex === 0 && { autoFillSource: "" }) // Add autoFillSource for first section
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

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setIsSaving(true)
    setError(null)
    setSuccessMessage(null)

    try {
      // Update service with form configuration using the correct structure
      const updateData = {
        title: formConfig.title,
        description: formConfig.description,
        isActive: basicInfo.isActive,
        sections: formConfig.sections.map(section => ({
          title: section.title,
          description: section.description,
          pageNumber: section.pageNumber,
          orderIndex: section.orderIndex,
          fields: section.fields.map(field => ({
            label: field.label,
            fieldName: field.fieldName,
            fieldType: field.fieldType,
            isRequired: field.isRequired,
            placeholder: field.placeholder,
            helpText: field.helpText,
            orderIndex: field.orderIndex,
            validationRules: field.validationRules,
            options: field.options,
            metadata: field.metadata
          }))
        }))
      }

      await servicesService.updateService(serviceId, updateData)
      setSuccessMessage("Service and form configuration updated successfully!")
      
      setTimeout(() => {
        router.push(`/dashboard/services/${serviceId}`)
      }, 1500)
    } catch (err) {
      setError(err instanceof Error ? err.message : "Failed to update service")
    } finally {
      setIsSaving(false)
    }
  }

  if (isLoading) {
    return (
      <div className="min-h-screen bg-background flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary mx-auto mb-4"></div>
          <p className="text-muted-foreground">Loading service details...</p>
        </div>
      </div>
    )
  }

  if (error && !service) {
    return (
      <div className="min-h-screen bg-background flex items-center justify-center">
        <div className="text-center">
          <AlertCircle className="h-12 w-12 text-red-500 mx-auto mb-4" />
          <h2 className="text-lg font-medium text-foreground mb-2">Error Loading Service</h2>
          <p className="text-muted-foreground mb-4">{error}</p>
          <div className="space-x-2">
            <Button onClick={loadService}>Try Again</Button>
            <Button variant="outline" onClick={() => router.back()}>Go Back</Button>
          </div>
        </div>
      </div>
    )
  }

  return (
    <div className="min-h-screen bg-background">
      {/* Header */}
      <header className="border-b border-border bg-card">
        <div className="container mx-auto px-4 py-4">
          <div className="flex items-center justify-between">
            <div className="flex items-center space-x-4">
              <Link href={`/dashboard/services/${serviceId}`}>
                <Button variant="ghost" size="sm">
                  <ArrowLeft className="h-4 w-4 mr-2" />
                  Back to Service
                </Button>
              </Link>
              <div>
                <h1 className="text-xl font-bold text-foreground">Form Builder</h1>
                <p className="text-sm text-muted-foreground">{service?.title}</p>
              </div>
            </div>
            <div className="flex items-center space-x-2">
              <Button variant="outline" size="sm">
                <Eye className="h-4 w-4 mr-2" />
                Preview
              </Button>
            </div>
          </div>
        </div>
      </header>

      <div className="container mx-auto px-4 py-8">
        <div className="max-w-4xl mx-auto">
          {/* Success Message */}
          {successMessage && (
            <div className="mb-6 p-4 bg-green-50 border border-green-200 rounded-md">
              <p className="text-green-700">{successMessage}</p>
            </div>
          )}

          {/* Error Message */}
          {error && (
            <div className="mb-6 p-4 bg-red-50 border border-red-200 rounded-md flex items-center">
              <AlertCircle className="h-5 w-5 text-red-600 mr-2" />
              <span className="text-red-700">{error}</span>
            </div>
          )}

          <Tabs defaultValue="basic" className="space-y-6">
            <TabsList className="grid w-full grid-cols-2">
              <TabsTrigger value="basic">Basic Information</TabsTrigger>
              <TabsTrigger value="form">Form Builder</TabsTrigger>
            </TabsList>

            {/* Basic Information Tab */}
            <TabsContent value="basic">
              <Card>
                <CardHeader>
                  <CardTitle className="flex items-center">
                    <Building2 className="h-5 w-5 mr-2" />
                    Service Information
                  </CardTitle>
                  <CardDescription>
                    Update the basic service details
                  </CardDescription>
                </CardHeader>
                <CardContent className="space-y-6">
                  <div>
                    <Label htmlFor="name">Service Name *</Label>
                    <Input
                      id="name"
                      name="name"
                      value={basicInfo.name}
                      onChange={handleBasicInfoChange}
                      placeholder="Enter service name"
                      required
                    />
                  </div>

                  <div>
                    <Label htmlFor="description">Description *</Label>
                    <Textarea
                      id="description"
                      name="description"
                      value={basicInfo.description}
                      onChange={handleBasicInfoChange}
                      placeholder="Enter service description"
                      rows={3}
                      required
                    />
                  </div>

                  <div className="flex items-center space-x-2">
                    <Switch
                      id="isActive"
                      checked={basicInfo.isActive}
                      onCheckedChange={handleSwitchChange}
                    />
                    <Label htmlFor="isActive">
                      Service is active
                    </Label>
                  </div>
                </CardContent>
              </Card>
            </TabsContent>

            {/* Form Builder Tab */}
            <TabsContent value="form">
              <div className="space-y-6">
                {formConfig.sections.map((section, sectionIndex) => (
                  <Card key={section.id || sectionIndex}>
                    <CardHeader>
                      <div className="flex items-center justify-between">
                        <div className="flex items-center space-x-2">
                          <GripVertical className="h-5 w-5 text-muted-foreground" />
                          <div>
                            <CardTitle className="text-lg">
                              {sectionIndex === 0 && (
                                <Badge variant="secondary" className="mr-2">Auto-fill</Badge>
                              )}
                              Page {section.pageNumber}: {section.title}
                            </CardTitle>
                            <CardDescription>{section.description}</CardDescription>
                          </div>
                        </div>
                        <div className="flex items-center space-x-2">
                          <Button
                            variant="outline"
                            size="sm"
                            onClick={() => addField(sectionIndex)}
                          >
                            <Plus className="h-4 w-4 mr-1" />
                            Add Field
                          </Button>
                          {sectionIndex > 0 && (
                            <Button
                              variant="ghost"
                              size="sm"
                              onClick={() => removeSection(sectionIndex)}
                              className="text-red-600 hover:text-red-700"
                            >
                              <Trash2 className="h-4 w-4" />
                            </Button>
                          )}
                        </div>
                      </div>
                    </CardHeader>
                    <CardContent className="space-y-6">
                      {/* Section Settings */}
                      <div className="grid gap-4 md:grid-cols-2">
                        <div>
                          <Label htmlFor={`section-title-${sectionIndex}`}>Section Title</Label>
                          <Input
                            id={`section-title-${sectionIndex}`}
                            value={section.title}
                            onChange={(e) => updateSection(sectionIndex, { title: e.target.value })}
                            disabled={sectionIndex === 0} // Can't edit auto-fill section title
                          />
                        </div>
                        <div>
                          <Label htmlFor={`section-description-${sectionIndex}`}>Description</Label>
                          <Input
                            id={`section-description-${sectionIndex}`}
                            value={section.description || ""}
                            onChange={(e) => updateSection(sectionIndex, { description: e.target.value })}
                            placeholder="Section description"
                          />
                        </div>
                      </div>

                      {/* Fields */}
                      <div className="space-y-4">
                        <h4 className="font-medium">Fields</h4>
                        {section.fields.length === 0 ? (
                          <div className="text-center py-8 bg-muted/30 rounded-lg">
                            <p className="text-muted-foreground">
                              {sectionIndex === 0 
                                ? "Add fields that will be auto-filled from user profile"
                                : "No fields added yet. Click 'Add Field' to get started."
                              }
                            </p>
                          </div>
                        ) : (
                          section.fields.map((field, fieldIndex) => (
                            <Card key={field.id || fieldIndex} className="bg-muted/30">
                              <CardContent className="pt-6">
                                <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
                                  <div>
                                    <Label>Field Label</Label>
                                    <Input
                                      value={field.label}
                                      onChange={(e) => updateField(sectionIndex, fieldIndex, { label: e.target.value })}
                                      placeholder="Field label"
                                    />
                                  </div>
                                  <div>
                                    <Label>Field Name</Label>
                                    <Input
                                      value={field.fieldName}
                                      onChange={(e) => updateField(sectionIndex, fieldIndex, { fieldName: e.target.value })}
                                      placeholder="field_name"
                                    />
                                  </div>
                                  <div>
                                    <Label>Field Type</Label>
                                    <Select
                                      value={field.fieldType}
                                      onValueChange={(value) => updateField(sectionIndex, fieldIndex, { fieldType: value })}
                                    >
                                      <SelectTrigger>
                                        <SelectValue />
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
                                  <div>
                                    <Label>Placeholder</Label>
                                    <Input
                                      value={field.placeholder || ""}
                                      onChange={(e) => updateField(sectionIndex, fieldIndex, { placeholder: e.target.value })}
                                      placeholder="Placeholder text"
                                    />
                                  </div>
                                  <div>
                                    <Label>Help Text</Label>
                                    <Input
                                      value={field.helpText || ""}
                                      onChange={(e) => updateField(sectionIndex, fieldIndex, { helpText: e.target.value })}
                                      placeholder="Help text"
                                    />
                                  </div>
                                  {sectionIndex === 0 && (
                                    <div>
                                      <Label>Auto-fill Source</Label>
                                      <Select
                                        value={field.autoFillSource || ""}
                                        onValueChange={(value) => updateField(sectionIndex, fieldIndex, { autoFillSource: value })}
                                      >
                                        <SelectTrigger>
                                          <SelectValue placeholder="Select source" />
                                        </SelectTrigger>
                                        <SelectContent>
                                          {AUTO_FILL_FIELDS.map((source) => (
                                            <SelectItem key={source.value} value={source.value}>
                                              {source.label}
                                            </SelectItem>
                                          ))}
                                        </SelectContent>
                                      </Select>
                                    </div>
                                  )}
                                  <div className="flex items-center space-x-4">
                                    <div className="flex items-center space-x-2">
                                      <Switch
                                        checked={field.isRequired}
                                        onCheckedChange={(checked) => updateField(sectionIndex, fieldIndex, { isRequired: checked })}
                                      />
                                      <Label>Required</Label>
                                    </div>
                                    <Button
                                      variant="ghost"
                                      size="sm"
                                      onClick={() => removeField(sectionIndex, fieldIndex)}
                                      className="text-red-600 hover:text-red-700"
                                    >
                                      <Trash2 className="h-4 w-4" />
                                    </Button>
                                  </div>
                                </div>
                              </CardContent>
                            </Card>
                          ))
                        )}
                      </div>
                    </CardContent>
                  </Card>
                ))}

                {/* Add Section Button */}
                <Button
                  variant="outline"
                  onClick={addSection}
                  className="w-full"
                >
                  <Plus className="h-4 w-4 mr-2" />
                  Add New Section
                </Button>
              </div>
            </TabsContent>
          </Tabs>

          {/* Submit Button */}
          <div className="flex items-center justify-end space-x-2 pt-6">
            <Link href={`/dashboard/services/${serviceId}`}>
              <Button type="button" variant="outline">
                Cancel
              </Button>
            </Link>
            <Button onClick={handleSubmit} disabled={isSaving}>
              <Save className="h-4 w-4 mr-2" />
              {isSaving ? "Saving..." : "Save Service & Form"}
            </Button>
          </div>
        </div>
      </div>
    </div>
  )
}

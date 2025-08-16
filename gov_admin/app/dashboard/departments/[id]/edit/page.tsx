"use client"

import { useState, useEffect } from "react"
import { useParams, useRouter } from "next/navigation"
import Link from "next/link"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { Textarea } from "@/components/ui/textarea"
import { Switch } from "@/components/ui/switch"
import { Building2, ArrowLeft, Save, AlertCircle } from "lucide-react"
import { DepartmentsService, Department, UpdateDepartmentRequest } from "@/lib/services/departments.service"

export default function EditDepartmentPage() {
  const params = useParams()
  const router = useRouter()
  const [department, setDepartment] = useState<Department | null>(null)
  const [isLoading, setIsLoading] = useState(true)
  const [isSaving, setIsSaving] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const [successMessage, setSuccessMessage] = useState<string | null>(null)

  const [formData, setFormData] = useState({
    name: "",
    description: "",
    contact_email: "",
    contact_phone: "",
    isActive: true,
  })

  const departmentsService = DepartmentsService.getInstance()
  const departmentId = params.id as string

  useEffect(() => {
    if (departmentId) {
      loadDepartment()
    }
  }, [departmentId])

  const loadDepartment = async () => {
    try {
      setIsLoading(true)
      setError(null)
      const data = await departmentsService.getDepartmentById(parseInt(departmentId))
      setDepartment(data)
      setFormData({
        name: data.name,
        description: data.description || "",
        contact_email: data.contact_email || "",
        contact_phone: data.contact_phone || "",
        isActive: data.isActive,
      })
    } catch (err) {
      setError(err instanceof Error ? err.message : "Failed to load department")
    } finally {
      setIsLoading(false)
    }
  }

  const handleInputChange = (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement>) => {
    const { name, value } = e.target
    setFormData(prev => ({ ...prev, [name]: value }))
  }

  const handleSwitchChange = (checked: boolean) => {
    setFormData(prev => ({ ...prev, isActive: checked }))
  }

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setIsSaving(true)
    setError(null)
    setSuccessMessage(null)

    try {
      const updateData: UpdateDepartmentRequest = {
        name: formData.name,
        description: formData.description || undefined,
        contact_email: formData.contact_email || undefined,
        contact_phone: formData.contact_phone || undefined,
        isActive: formData.isActive,
      }

      const updatedDepartment = await departmentsService.updateDepartment(parseInt(departmentId), updateData)
      setDepartment(updatedDepartment)
      setSuccessMessage("Department updated successfully!")
      
      // Redirect after a short delay
      setTimeout(() => {
        router.push(`/dashboard/departments/${departmentId}`)
      }, 1500)
    } catch (err) {
      setError(err instanceof Error ? err.message : "Failed to update department")
    } finally {
      setIsSaving(false)
    }
  }

  if (isLoading) {
    return (
      <div className="min-h-screen bg-background flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary mx-auto mb-4"></div>
          <p className="text-muted-foreground">Loading department details...</p>
        </div>
      </div>
    )
  }

  if (error && !department) {
    return (
      <div className="min-h-screen bg-background flex items-center justify-center">
        <div className="text-center">
          <AlertCircle className="h-12 w-12 text-red-500 mx-auto mb-4" />
          <h2 className="text-lg font-medium text-foreground mb-2">Error Loading Department</h2>
          <p className="text-muted-foreground mb-4">{error}</p>
          <div className="space-x-2">
            <Button onClick={loadDepartment}>Try Again</Button>
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
              <Link href={`/dashboard/departments/${departmentId}`}>
                <Button variant="ghost" size="sm">
                  <ArrowLeft className="h-4 w-4 mr-2" />
                  Back to Details
                </Button>
              </Link>
              <div>
                <h1 className="text-xl font-bold text-foreground">Edit Department</h1>
                <p className="text-sm text-muted-foreground">{department?.name}</p>
              </div>
            </div>
          </div>
        </div>
      </header>

      <div className="container mx-auto px-4 py-8">
        <div className="max-w-2xl mx-auto">
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

          <Card>
            <CardHeader>
              <CardTitle className="flex items-center">
                <Building2 className="h-5 w-5 mr-2" />
                Department Information
              </CardTitle>
              <CardDescription>
                Update the department details below. All changes will be saved to the database.
              </CardDescription>
            </CardHeader>
            <CardContent>
              <form onSubmit={handleSubmit} className="space-y-6">
                {/* Basic Information */}
                <div className="space-y-4">
                  <div>
                    <Label htmlFor="name">Department Name *</Label>
                    <Input
                      id="name"
                      name="name"
                      value={formData.name}
                      onChange={handleInputChange}
                      placeholder="Enter department name"
                      required
                    />
                  </div>

                  <div>
                    <Label htmlFor="description">Description</Label>
                    <Textarea
                      id="description"
                      name="description"
                      value={formData.description}
                      onChange={handleInputChange}
                      placeholder="Enter department description"
                      rows={3}
                    />
                  </div>
                </div>

                {/* Contact Information */}
                <div className="space-y-4">
                  <h3 className="text-lg font-medium">Contact Information</h3>
                  
                  <div>
                    <Label htmlFor="contact_email">Contact Email</Label>
                    <Input
                      id="contact_email"
                      name="contact_email"
                      type="email"
                      value={formData.contact_email}
                      onChange={handleInputChange}
                      placeholder="contact@department.gov"
                    />
                  </div>

                  <div>
                    <Label htmlFor="contact_phone">Contact Phone</Label>
                    <Input
                      id="contact_phone"
                      name="contact_phone"
                      type="tel"
                      value={formData.contact_phone}
                      onChange={handleInputChange}
                      placeholder="+1 (555) 123-4567"
                    />
                  </div>
                </div>

                {/* Status */}
                <div className="space-y-4">
                  <h3 className="text-lg font-medium">Status</h3>
                  
                  <div className="flex items-center space-x-2">
                    <Switch
                      id="isActive"
                      checked={formData.isActive}
                      onCheckedChange={handleSwitchChange}
                    />
                    <Label htmlFor="isActive">
                      Department is active
                    </Label>
                  </div>
                  <p className="text-sm text-muted-foreground">
                    Inactive departments will not be able to access the system
                  </p>
                </div>

                {/* Read-only Information */}
                <div className="space-y-4 pt-4 border-t">
                  <h3 className="text-lg font-medium">Read-only Information</h3>
                  
                  <div className="grid gap-4 md:grid-cols-2">
                    <div>
                      <Label>Department ID</Label>
                      <Input value={department?.department_id || ""} disabled />
                    </div>
                    <div>
                      <Label>Login Email</Label>
                      <Input value={department?.email || ""} disabled />
                    </div>
                  </div>
                </div>

                {/* Submit Button */}
                <div className="flex items-center justify-end space-x-2 pt-6">
                  <Link href={`/dashboard/departments/${departmentId}`}>
                    <Button type="button" variant="outline">
                      Cancel
                    </Button>
                  </Link>
                  <Button type="submit" disabled={isSaving}>
                    <Save className="h-4 w-4 mr-2" />
                    {isSaving ? "Saving..." : "Save Changes"}
                  </Button>
                </div>
              </form>
            </CardContent>
          </Card>
        </div>
      </div>
    </div>
  )
}

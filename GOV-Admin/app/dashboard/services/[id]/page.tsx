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
import { Badge } from "@/components/ui/badge"
import { 
  ArrowLeft, 
  Save, 
  AlertCircle, 
  Cog, 
  Calendar, 
  CheckCircle, 
  XCircle,
  Edit,
  Trash2,
  Settings,
  Eye
} from "lucide-react"
import { ServicesService, Service, UpdateServiceRequest } from "@/lib/services/services.service"

export default function ServiceDetailPage() {
  const params = useParams()
  const router = useRouter()
  const [service, setService] = useState<Service | null>(null)
  const [isLoading, setIsLoading] = useState(true)
  const [isSaving, setIsSaving] = useState(false)
  const [isEditing, setIsEditing] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const [successMessage, setSuccessMessage] = useState<string | null>(null)

  const [formData, setFormData] = useState({
    title: "",
    description: "",
    is_active: true,
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
      setFormData({
        title: data.title,
        description: data.description,
        is_active: data.is_active,
      })
    } catch (err) {
      setError(err instanceof Error ? err.message : "Failed to load service")
    } finally {
      setIsLoading(false)
    }
  }

  const handleInputChange = (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement>) => {
    const { name, value } = e.target
    setFormData(prev => ({ ...prev, [name]: value }))
  }

  const handleSwitchChange = (checked: boolean) => {
    setFormData(prev => ({ ...prev, is_active: checked }))
  }

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setIsSaving(true)
    setError(null)
    setSuccessMessage(null)

    try {
      const updateData: UpdateServiceRequest = {
        title: formData.title,
        description: formData.description,
        is_active: formData.is_active,
      }

      const updatedService = await servicesService.updateService(serviceId, updateData)
      setService(updatedService)
      setSuccessMessage("Service updated successfully!")
      setIsEditing(false)
    } catch (err) {
      setError(err instanceof Error ? err.message : "Failed to update service")
    } finally {
      setIsSaving(false)
    }
  }

  const handleToggleStatus = async () => {
    try {
      const updatedService = await servicesService.toggleServiceStatus(serviceId)
      setService(updatedService)
      setFormData(prev => ({ ...prev, is_active: updatedService.is_active }))
      setSuccessMessage(`Service ${updatedService.is_active ? 'activated' : 'deactivated'} successfully!`)
    } catch (err) {
      setError(err instanceof Error ? err.message : "Failed to toggle service status")
    }
  }

  const handleDelete = async () => {
    if (!confirm("Are you sure you want to delete this service? This action cannot be undone.")) {
      return
    }

    try {
      await servicesService.deleteService(serviceId)
      router.push("/dashboard/services")
    } catch (err) {
      setError(err instanceof Error ? err.message : "Failed to delete service")
    }
  }

  const formatDate = (dateString: string) => {
    return new Date(dateString).toLocaleDateString("en-US", {
      year: "numeric",
      month: "long",
      day: "numeric",
      hour: "2-digit",
      minute: "2-digit",
    })
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
              <Link href="/dashboard/services">
                <Button variant="ghost" size="sm">
                  <ArrowLeft className="h-4 w-4 mr-2" />
                  Back to Services
                </Button>
              </Link>
              <div>
                <h1 className="text-xl font-bold text-foreground">{service?.title}</h1>
                <p className="text-sm text-muted-foreground">Service Details</p>
              </div>
            </div>
            <div className="flex items-center space-x-2">
              {!isEditing && (
                <>
                  <Button variant="outline" size="sm">
                    <Eye className="h-4 w-4 mr-2" />
                    Preview Form
                  </Button>
                  <Link href={`/dashboard/services/${serviceId}/edit`}>
                    <Button variant="outline" size="sm">
                      <Settings className="h-4 w-4 mr-2" />
                      Form Builder
                    </Button>
                  </Link>
                  <Button
                    variant="outline"
                    onClick={handleToggleStatus}
                  >
                    {service?.is_active ? "Deactivate" : "Activate"}
                  </Button>
                  <Button onClick={() => setIsEditing(true)}>
                    <Edit className="h-4 w-4 mr-2" />
                    Edit Service
                  </Button>
                </>
              )}
              {isEditing && (
                <Button
                  variant="outline"
                  onClick={() => {
                    setIsEditing(false)
                    setError(null)
                    setSuccessMessage(null)
                    // Reset form data
                    if (service) {
                      setFormData({
                        title: service.title,
                        description: service.description,
                        is_active: service.is_active,
                      })
                    }
                  }}
                >
                  Cancel
                </Button>
              )}
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

          <div className="grid gap-6 lg:grid-cols-3">
            {/* Main Content */}
            <div className="lg:col-span-2">
              <Card>
                <CardHeader>
                  <CardTitle className="flex items-center justify-between">
                    <div className="flex items-center">
                      <Cog className="h-5 w-5 mr-2" />
                      Service Information
                    </div>
                    <Badge variant={service?.is_active ? "default" : "secondary"}>
                      {service?.is_active ? (
                        <>
                          <CheckCircle className="h-3 w-3 mr-1" />
                          Active
                        </>
                      ) : (
                        <>
                          <XCircle className="h-3 w-3 mr-1" />
                          Inactive
                        </>
                      )}
                    </Badge>
                  </CardTitle>
                  <CardDescription>
                    {isEditing ? "Edit the service details below" : "View and manage service information"}
                  </CardDescription>
                </CardHeader>
                <CardContent>
                  {isEditing ? (
                    <form onSubmit={handleSubmit} className="space-y-6">
                      <div>
                        <Label htmlFor="title">Service Title *</Label>
                        <Input
                          id="title"
                          name="title"
                          value={formData.title}
                          onChange={handleInputChange}
                          placeholder="Enter service title"
                          required
                        />
                      </div>

                      <div>
                        <Label htmlFor="description">Description *</Label>
                        <Textarea
                          id="description"
                          name="description"
                          value={formData.description}
                          onChange={handleInputChange}
                          placeholder="Describe the service"
                          rows={4}
                          required
                        />
                      </div>

                      <div className="flex items-center space-x-2">
                        <Switch
                          id="is_active"
                          checked={formData.is_active}
                          onCheckedChange={handleSwitchChange}
                        />
                        <Label htmlFor="is_active">Service is active</Label>
                      </div>

                      <div className="flex items-center justify-end space-x-2 pt-4">
                        <Button type="submit" disabled={isSaving}>
                          <Save className="h-4 w-4 mr-2" />
                          {isSaving ? "Saving..." : "Save Changes"}
                        </Button>
                      </div>
                    </form>
                  ) : (
                    <div className="space-y-6">
                      <div>
                        <Label className="text-sm font-medium text-muted-foreground">Title</Label>
                        <p className="text-base">{service?.title}</p>
                      </div>

                      <div>
                        <Label className="text-sm font-medium text-muted-foreground">Description</Label>
                        <p className="text-base whitespace-pre-wrap">{service?.description}</p>
                      </div>

                      <div>
                        <Label className="text-sm font-medium text-muted-foreground">Status</Label>
                        <p className="text-base">
                          {service?.is_active ? "Active - Available to citizens" : "Inactive - Not available to citizens"}
                        </p>
                      </div>
                    </div>
                  )}
                </CardContent>
              </Card>

              {/* Form Builder Section */}
              {!isEditing && (
                <Card>
                  <CardHeader>
                    <CardTitle className="flex items-center">
                      <Settings className="h-5 w-5 mr-2" />
                      Form Configuration
                    </CardTitle>
                    <CardDescription>
                      Design the form that citizens will use to apply for this service
                    </CardDescription>
                  </CardHeader>
                  <CardContent>
                    <div className="space-y-4">
                      <p className="text-sm text-muted-foreground">
                        Create a dynamic form with custom fields, sections, and auto-fill capabilities. 
                        The first section will automatically populate with citizen information.
                      </p>
                      <div className="flex space-x-2">
                        <Link href={`/dashboard/services/${serviceId}/edit`} className="flex-1">
                          <Button className="w-full">
                            <Settings className="h-4 w-4 mr-2" />
                            Open Form Builder
                          </Button>
                        </Link>
                        <Button variant="outline">
                          <Eye className="h-4 w-4 mr-2" />
                          Preview
                        </Button>
                      </div>
                    </div>
                  </CardContent>
                </Card>
              )}
            </div>

            {/* Sidebar */}
            <div className="space-y-6">
              {/* Service Stats */}
              <Card>
                <CardHeader>
                  <CardTitle className="text-lg">Service Details</CardTitle>
                </CardHeader>
                <CardContent className="space-y-4">
                  <div>
                    <Label className="text-sm font-medium text-muted-foreground">Service ID</Label>
                    <p className="text-base">{service?.form_id}</p>
                  </div>
                  
                  <div>
                    <Label className="text-sm font-medium text-muted-foreground">Department</Label>
                    <p className="text-base">{service?.department?.name || `Department ${service?.department_id}`}</p>
                  </div>

                  <div>
                    <Label className="text-sm font-medium text-muted-foreground">Created</Label>
                    <div className="flex items-center text-sm text-muted-foreground">
                      <Calendar className="h-4 w-4 mr-2" />
                      {service?.createdAt && formatDate(service.createdAt)}
                    </div>
                  </div>

                  <div>
                    <Label className="text-sm font-medium text-muted-foreground">Last Updated</Label>
                    <div className="flex items-center text-sm text-muted-foreground">
                      <Calendar className="h-4 w-4 mr-2" />
                      {service?.updatedAt && formatDate(service.updatedAt)}
                    </div>
                  </div>
                </CardContent>
              </Card>

              {/* Form Analytics */}
              <Card>
                <CardHeader>
                  <CardTitle className="text-lg">Form Analytics</CardTitle>
                  <CardDescription>
                    Submission statistics for this service
                  </CardDescription>
                </CardHeader>
                <CardContent className="space-y-3">
                  <div className="flex justify-between items-center p-3 bg-muted/30 rounded-lg">
                    <span className="text-sm font-medium">Total Submissions</span>
                    <span className="text-lg font-bold">0</span>
                  </div>
                  <div className="flex justify-between items-center p-3 bg-muted/30 rounded-lg">
                    <span className="text-sm font-medium">Pending Review</span>
                    <span className="text-lg font-bold">0</span>
                  </div>
                  <div className="flex justify-between items-center p-3 bg-muted/30 rounded-lg">
                    <span className="text-sm font-medium">Approved</span>
                    <span className="text-lg font-bold">0</span>
                  </div>
                </CardContent>
              </Card>

              {/* Danger Zone */}
              <Card className="border-red-200">
                <CardHeader>
                  <CardTitle className="text-lg text-red-600">Danger Zone</CardTitle>
                  <CardDescription>
                    Irreversible and destructive actions
                  </CardDescription>
                </CardHeader>
                <CardContent>
                  <Button
                    variant="destructive"
                    onClick={handleDelete}
                    className="w-full"
                  >
                    <Trash2 className="h-4 w-4 mr-2" />
                    Delete Service
                  </Button>
                  <p className="text-xs text-muted-foreground mt-2">
                    This will permanently delete the service and all associated data.
                  </p>
                </CardContent>
              </Card>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}

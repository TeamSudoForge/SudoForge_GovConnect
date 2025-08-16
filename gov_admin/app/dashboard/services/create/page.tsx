"use client"

import { useState } from "react"
import { useRouter } from "next/navigation"
import Link from "next/link"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { Textarea } from "@/components/ui/textarea"
import { ArrowLeft, Save, AlertCircle, Cog } from "lucide-react"
import { ServicesService, CreateServiceRequest } from "@/lib/services/services.service"

export default function CreateServicePage() {
  const router = useRouter()
  const [isLoading, setIsLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const [successMessage, setSuccessMessage] = useState<string | null>(null)

  const [formData, setFormData] = useState<CreateServiceRequest>({
    name: "",
    description: "",
  })

  const servicesService = ServicesService.getInstance()

  const handleInputChange = (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement>) => {
    const { name, value } = e.target
    setFormData(prev => ({ ...prev, [name]: value }))
  }

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setIsLoading(true)
    setError(null)
    setSuccessMessage(null)

    try {
      const newService = await servicesService.createService(formData)
      setSuccessMessage("Service created successfully!")
      
      // Redirect to form builder after creation
      setTimeout(() => {
        router.push(`/dashboard/services/${newService.service_id}/edit`)
      }, 1500)
    } catch (err) {
      setError(err instanceof Error ? err.message : "Failed to create service")
    } finally {
      setIsLoading(false)
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
                <p className="text-sm text-muted-foreground">Add a new service to your department</p>
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
                <Cog className="h-5 w-5 mr-2" />
                Service Information
              </CardTitle>
              <CardDescription>
                Provide basic information about the new service. You'll design the form structure in the next step.
              </CardDescription>
            </CardHeader>
            <CardContent>
              <form onSubmit={handleSubmit} className="space-y-6">
                {/* Basic Information */}
                <div className="space-y-4">
                  <div>
                    <Label htmlFor="name">Service Name *</Label>
                    <Input
                      id="name"
                      name="name"
                      value={formData.name}
                      onChange={handleInputChange}
                      placeholder="Enter service name"
                      required
                    />
                    <p className="text-sm text-muted-foreground mt-1">
                      Choose a clear, descriptive name for your service
                    </p>
                  </div>

                  <div>
                    <Label htmlFor="description">Description *</Label>
                    <Textarea
                      id="description"
                      name="description"
                      value={formData.description}
                      onChange={handleInputChange}
                      placeholder="Describe what this service provides and how citizens can use it"
                      rows={4}
                      required
                    />
                    <p className="text-sm text-muted-foreground mt-1">
                      Provide a detailed description of the service including its purpose and requirements
                    </p>
                  </div>
                </div>

                {/* Information Box */}
                <div className="bg-blue-50 border border-blue-200 rounded-md p-4">
                  <h3 className="font-medium text-blue-900 mb-2">Next Steps</h3>
                  <ul className="text-sm text-blue-700 space-y-1">
                    <li>• After creating the service, you'll design the form structure</li>
                    <li>• Configure field types, validation rules, and auto-fill settings</li>
                    <li>• Set up sections for organizing form fields</li>
                    <li>• Test the form before making it available to citizens</li>
                  </ul>
                </div>

                {/* Submit Button */}
                <div className="flex items-center justify-end space-x-2 pt-6">
                  <Link href="/dashboard/services">
                    <Button type="button" variant="outline">
                      Cancel
                    </Button>
                  </Link>
                  <Button type="submit" disabled={isLoading}>
                    <Save className="h-4 w-4 mr-2" />
                    {isLoading ? "Creating..." : "Create Service & Build Form"}
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

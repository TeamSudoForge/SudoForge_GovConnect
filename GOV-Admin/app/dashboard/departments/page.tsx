"use client"

import { useState, useEffect } from "react"
import Link from "next/link"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Badge } from "@/components/ui/badge"
import { Building2, Search, Users, Edit, Eye, AlertCircle } from "lucide-react"
import { DepartmentsService, Department } from "@/lib/services/departments.service"

export default function DepartmentsPage() {
  const [searchTerm, setSearchTerm] = useState("")
  const [departments, setDepartments] = useState<Department[]>([])
  const [isLoading, setIsLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  const departmentsService = DepartmentsService.getInstance()

  useEffect(() => {
    loadDepartments()
  }, [])

  const loadDepartments = async () => {
    try {
      setIsLoading(true)
      setError(null)
      const data = await departmentsService.getAllDepartments()
      setDepartments(data)
    } catch (err) {
      setError(err instanceof Error ? err.message : "Failed to load departments")
    } finally {
      setIsLoading(false)
    }
  }

  const filteredDepartments = departments.filter(
    (dept) =>
      dept.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
      (dept.contact_email && dept.contact_email.toLowerCase().includes(searchTerm.toLowerCase())) ||
      (dept.description && dept.description.toLowerCase().includes(searchTerm.toLowerCase()))
  )

  const formatDate = (dateString: string) => {
    const date = new Date(dateString)
    const now = new Date()
    const diffTime = Math.abs(now.getTime() - date.getTime())
    const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24))
    
    if (diffDays === 1) return "1 day ago"
    if (diffDays < 7) return `${diffDays} days ago`
    return date.toLocaleDateString()
  }

  return (
    <div className="min-h-screen bg-background">
      {/* Header */}
      <header className="border-b border-border bg-card">
        <div className="container mx-auto px-4 py-4 flex items-center justify-between">
          <div className="flex items-center space-x-4">
            <div className="flex items-center space-x-2">
              <div>
                <h1 className="text-xl font-bold text-foreground">Department Management</h1>
                <p className="text-sm text-muted-foreground">View and manage departments</p>
              </div>
            </div>
          </div>
          <div className="flex items-center space-x-4">
            <Button onClick={loadDepartments} disabled={isLoading}>
              {isLoading ? "Loading..." : "Refresh"}
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
            <Button variant="outline" size="sm" className="ml-auto" onClick={loadDepartments}>
              Retry
            </Button>
          </div>
        )}

        {/* Search and Filters */}
        <div className="flex flex-col sm:flex-row gap-4 mb-6">
          <div className="relative flex-1">
            <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-muted-foreground h-4 w-4" />
            <Input
              placeholder="Search departments by name, email, or description..."
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              className="pl-10"
            />
          </div>
        </div>

        {/* Loading State */}
        {isLoading && (
          <div className="text-center py-12">
            <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary mx-auto mb-4"></div>
            <p className="text-muted-foreground">Loading departments...</p>
          </div>
        )}

        {/* Departments Grid */}
        {!isLoading && (
          <div className="grid gap-6">
            {filteredDepartments.map((department) => (
              <Card key={department.department_id} className="hover:shadow-md transition-shadow">
                <CardHeader>
                  <div className="flex items-start justify-between">
                    <div className="flex-1">
                      <div className="flex items-center space-x-3 mb-2">
                        <CardTitle className="text-lg">{department.name}</CardTitle>
                        <Badge variant={department.isActive ? "default" : "secondary"}>
                          {department.isActive ? "Active" : "Inactive"}
                        </Badge>
                      </div>
                      <CardDescription className="space-y-1">
                        <div className="flex items-center space-x-4 text-sm">
                          <span>
                            <strong>Email:</strong> {department.email}
                          </span>
                          {department.contact_email && (
                            <span>
                              <strong>Contact:</strong> {department.contact_email}
                            </span>
                          )}
                        </div>
                        {department.contact_phone && (
                          <div className="flex items-center space-x-4 text-sm">
                            <span>
                              <strong>Phone:</strong> {department.contact_phone}
                            </span>
                          </div>
                        )}
                        {department.description && (
                          <div className="text-sm mt-2">
                            <strong>Description:</strong> {department.description}
                          </div>
                        )}
                      </CardDescription>
                    </div>
                    <div className="flex items-center space-x-2">
                      <Link href={`/dashboard/departments/${department.department_id}`}>
                        <Button variant="outline" size="sm">
                          <Eye className="h-4 w-4 mr-1" />
                          View
                        </Button>
                      </Link>
                      <Link href={`/dashboard/departments/${department.department_id}/edit`}>
                        <Button variant="outline" size="sm">
                          <Edit className="h-4 w-4 mr-1" />
                          Edit
                        </Button>
                      </Link>
                    </div>
                  </div>
                </CardHeader>
                <CardContent>
                  <div className="flex items-center justify-between text-sm text-muted-foreground">
                    <div className="flex items-center space-x-4">
                      <span className="flex items-center">
                        <Building2 className="h-4 w-4 mr-1" />
                        Department ID: {department.department_id}
                      </span>
                    </div>
                    <span>Last updated: {formatDate(department.updatedAt)}</span>
                  </div>
                </CardContent>
              </Card>
            ))}
          </div>
        )}

        {!isLoading && filteredDepartments.length === 0 && !error && (
          <div className="text-center py-12">
            <Building2 className="h-12 w-12 text-muted-foreground mx-auto mb-4" />
            <h3 className="text-lg font-medium text-foreground mb-2">No departments found</h3>
            <p className="text-muted-foreground mb-4">
              {searchTerm ? "Try adjusting your search terms" : "No departments are available in the system"}
            </p>
          </div>
        )}
      </div>
    </div>
  )
}

"use client"

import { useState, useEffect } from "react"
import Link from "next/link"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Badge } from "@/components/ui/badge"
import { 
  Cog, 
  Plus, 
  Search, 
  Calendar, 
  CheckCircle, 
  XCircle, 
  Edit, 
  Trash2, 
  AlertCircle,
  Building2
} from "lucide-react"
import { ServicesService, Service } from "@/lib/services/services.service"

export default function ServicesPage() {
  // State variables
  const [services, setServices] = useState<Service[]>([])
  const [filteredServices, setFilteredServices] = useState<Service[]>([])
  const [isLoading, setIsLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)
  const [searchTerm, setSearchTerm] = useState("")
  const [filterStatus, setFilterStatus] = useState<"all" | "active" | "inactive">("all")
  
  // Pagination state
  const [currentPage, setCurrentPage] = useState(1)
  const [itemsPerPage] = useState(6) // 6 cards per page (2 rows of 3)
  
  // Pagination calculations
  const totalPages = Math.ceil(filteredServices.length / itemsPerPage)
  const startIndex = (currentPage - 1) * itemsPerPage
  const endIndex = startIndex + itemsPerPage
  const paginatedServices = filteredServices.slice(startIndex, endIndex)

  const servicesService = ServicesService.getInstance()

  useEffect(() => {
    loadServices()
  }, [])

  useEffect(() => {
    filterServices()
    setCurrentPage(1) // Reset to first page when filters change
  }, [services, searchTerm, filterStatus])

  const loadServices = async () => {
    try {
      setIsLoading(true)
      setError(null)
      const data = await servicesService.getAllServices()
      setServices(data)
    } catch (err) {
      setError(err instanceof Error ? err.message : "Failed to load services")
    } finally {
      setIsLoading(false)
    }
  }

  const filterServices = () => {
    let filtered = [...services]

    // Filter by search term
    if (searchTerm) {
      filtered = filtered.filter(service =>
        service.title.toLowerCase().includes(searchTerm.toLowerCase()) ||
        service.description.toLowerCase().includes(searchTerm.toLowerCase())
      )
    }

    // Filter by status
    if (filterStatus !== "all") {
      filtered = filtered.filter(service =>
        filterStatus === "active" ? service.isActive : !service.isActive
      )
    }

    setFilteredServices(filtered)
  }

  const handleToggleStatus = async (serviceId: string) => {
    try {
      await servicesService.toggleServiceStatus(serviceId)
      await loadServices() // Reload to get updated data
    } catch (err) {
      setError(err instanceof Error ? err.message : "Failed to toggle service status")
    }
  }

  const handleDeleteService = async (serviceId: string) => {
    if (!confirm("Are you sure you want to delete this service? This action cannot be undone.")) {
      return
    }

    try {
      await servicesService.deleteService(serviceId)
      await loadServices() // Reload to get updated data
    } catch (err) {
      setError(err instanceof Error ? err.message : "Failed to delete service")
    }
  }

  const formatDate = (dateString: string) => {
    return new Date(dateString).toLocaleDateString("en-US", {
      year: "numeric",
      month: "short",
      day: "numeric",
    })
  }

  if (isLoading) {
    return (
      <div className="min-h-screen bg-background flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary mx-auto mb-4"></div>
          <p className="text-muted-foreground">Loading services...</p>
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
              <Cog className="h-6 w-6 text-primary" />
              <div>
                <h1 className="text-2xl font-bold text-foreground">Services Management</h1>
                <p className="text-muted-foreground">Manage your department's services</p>
              </div>
            </div>
            <Link href="/dashboard/services/new">
              <Button>
                <Plus className="h-4 w-4 mr-2" />
                Create Service
              </Button>
            </Link>
          </div>
        </div>
      </header>

      <div className="container mx-auto px-4 py-8">
        {/* Error Message */}
        {error && (
          <div className="mb-6 p-4 bg-red-50 border border-red-200 rounded-md flex items-center">
            <AlertCircle className="h-5 w-5 text-red-600 mr-2" />
            <span className="text-red-700">{error}</span>
            <Button
              variant="ghost"
              size="sm"
              onClick={() => setError(null)}
              className="ml-auto text-red-600 hover:text-red-700"
            >
              ×
            </Button>
          </div>
        )}

        {/* Statistics */}
        {services.length > 0 && (
          <div className="mb-8 grid gap-4 md:grid-cols-3">
            <Card>
              <CardContent className="pt-6">
                <div className="text-2xl font-bold">{services.length}</div>
                <p className="text-muted-foreground">Total Services</p>
              </CardContent>
            </Card>
            <Card>
              <CardContent className="pt-6">
                <div className="text-2xl font-bold text-green-600">
                  {services.filter(s => s.isActive).length}
                </div>
                <p className="text-muted-foreground">Active Services</p>
              </CardContent>
            </Card>
            <Card>
              <CardContent className="pt-6">
                <div className="text-2xl font-bold text-gray-600">
                  {services.filter(s => !s.isActive).length}
                </div>
                <p className="text-muted-foreground">Inactive Services</p>
              </CardContent>
            </Card>
          </div>
        )}

        {/* Filters */}
        <div className="flex flex-col md:flex-row gap-4 mb-6">
          <div className="relative flex-1">
            <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-muted-foreground h-4 w-4" />
            <Input
              placeholder="Search services..."
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              className="pl-10"
            />
          </div>
          <div className="flex gap-2">
            <Button
              variant={filterStatus === "all" ? "default" : "outline"}
              onClick={() => setFilterStatus("all")}
              size="sm"
            >
              All
            </Button>
            <Button
              variant={filterStatus === "active" ? "default" : "outline"}
              onClick={() => setFilterStatus("active")}
              size="sm"
            >
              Active
            </Button>
            <Button
              variant={filterStatus === "inactive" ? "default" : "outline"}
              onClick={() => setFilterStatus("inactive")}
              size="sm"
            >
              Inactive
            </Button>
          </div>
        </div>

        {/* Services List */}
        <div className="grid gap-6 md:grid-cols-2 lg:grid-cols-3">
          {filteredServices.length === 0 ? (
            <div className="col-span-full text-center py-12">
              <Cog className="h-12 w-12 text-muted-foreground mx-auto mb-4" />
              <h3 className="text-lg font-medium text-foreground mb-2">
                {searchTerm || filterStatus !== "all" ? "No services found" : "No services yet"}
              </h3>
              <p className="text-muted-foreground mb-4">
                {searchTerm || filterStatus !== "all"
                  ? "Try adjusting your search or filters"
                  : "Create your first service to get started"}
              </p>
              {!searchTerm && filterStatus === "all" && (
                <Link href="/dashboard/services/new">
                  <Button>
                    <Plus className="h-4 w-4 mr-2" />
                    Create Service
                  </Button>
                </Link>
              )}
            </div>
          ) : (
            paginatedServices.map((service) => (
              <Card key={service.id} className="hover:shadow-md transition-shadow">
                <CardHeader className="pb-3">
                  <div className="flex items-start justify-between">
                    <div className="flex-1">
                      <CardTitle className="text-lg mb-1">{service.title}</CardTitle>
                      <div className="flex items-center gap-2">
                        <Badge variant={service.isActive ? "default" : "secondary"}>
                          {service.isActive ? (
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
                      </div>
                    </div>
                  </div>
                </CardHeader>
                <CardContent className="pt-0">
                  <CardDescription className="mb-4 line-clamp-2">
                    {service.description}
                  </CardDescription>
                  
                  <div className="flex items-center text-sm text-muted-foreground mb-4">
                    <Calendar className="h-4 w-4 mr-2" />
                    Created: {formatDate(service.createdAt)}
                  </div>

                  <div className="flex items-center justify-between">
                    <div className="flex gap-2">
                      <Link href={`/dashboard/services/${service.id}`}>
                        <Button variant="outline" size="sm">
                          <Edit className="h-4 w-4 mr-1" />
                          Edit
                        </Button>
                      </Link>
                      <Button
                        variant="outline"
                        size="sm"
                        onClick={() => handleToggleStatus(service.id)}
                      >
                        {service.isActive ? "Deactivate" : "Activate"}
                      </Button>
                    </div>
                    <Button
                      variant="ghost"
                      size="sm"
                      onClick={() => handleDeleteService(service.id)}
                      className="text-red-600 hover:text-red-700 hover:bg-red-50"
                    >
                      <Trash2 className="h-4 w-4" />
                    </Button>
                  </div>
                </CardContent>
              </Card>
            ))
          )}
        </div>

        {/* Pagination */}
        {totalPages > 1 && (
          <div className="mt-8 flex items-center justify-between">
            <div className="text-sm text-muted-foreground">
              Showing {startIndex + 1} to {Math.min(endIndex, filteredServices.length)} of {filteredServices.length} services
            </div>
            <div className="flex items-center space-x-2">
              <Button
                variant="outline"
                size="sm"
                onClick={() => setCurrentPage(prev => Math.max(prev - 1, 1))}
                disabled={currentPage === 1}
              >
                Previous
              </Button>
              
              <div className="flex items-center space-x-1">
                {Array.from({ length: totalPages }, (_, i) => i + 1).map((page) => (
                  <Button
                    key={page}
                    variant={currentPage === page ? "default" : "outline"}
                    size="sm"
                    onClick={() => setCurrentPage(page)}
                    className="w-8 h-8"
                  >
                    {page}
                  </Button>
                ))}
              </div>
              
              <Button
                variant="outline"
                size="sm"
                onClick={() => setCurrentPage(prev => Math.min(prev + 1, totalPages))}
                disabled={currentPage === totalPages}
              >
                Next
              </Button>
            </div>
          </div>
        )}
      </div>
    </div>
  )
}

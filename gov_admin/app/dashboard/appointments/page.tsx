"use client"

import { useState } from "react"
import Link from "next/link"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Badge } from "@/components/ui/badge"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"
import { ThemeToggle } from "@/components/theme-toggle"
import { Calendar, Search, Plus, ArrowLeft, Clock, User, MapPin, Phone, Mail } from "lucide-react"

// Mock data for appointments
const appointments = [
  {
    id: 1,
    title: "Health Certificate Consultation",
    service: "Health Certificate Application",
    citizenName: "John Doe",
    citizenEmail: "john.doe@email.com",
    citizenPhone: "+1 (555) 123-4567",
    date: "2024-01-20",
    time: "09:00",
    duration: 30,
    status: "confirmed",
    location: "Room 101, Health Department",
    notes: "Bring valid ID and medical records",
  },
  {
    id: 2,
    title: "Driver's License Renewal",
    service: "Driver's License Renewal",
    citizenName: "Sarah Johnson",
    citizenEmail: "sarah.j@email.com",
    citizenPhone: "+1 (555) 234-5678",
    date: "2024-01-20",
    time: "10:30",
    duration: 45,
    status: "confirmed",
    location: "DMV Office, Counter 3",
    notes: "Eye test required",
  },
  {
    id: 3,
    title: "Business License Meeting",
    service: "Business License Application",
    citizenName: "Mike Chen",
    citizenEmail: "mike.chen@email.com",
    citizenPhone: "+1 (555) 345-6789",
    date: "2024-01-20",
    time: "14:00",
    duration: 60,
    status: "pending",
    location: "Commerce Department, Conference Room A",
    notes: "Business plan review",
  },
  {
    id: 4,
    title: "Tax Assessment Review",
    service: "Property Tax Assessment",
    citizenName: "Lisa Rodriguez",
    citizenEmail: "lisa.r@email.com",
    citizenPhone: "+1 (555) 456-7890",
    date: "2024-01-21",
    time: "11:00",
    duration: 30,
    status: "confirmed",
    location: "Revenue Department, Office 205",
    notes: "Property documents required",
  },
  {
    id: 5,
    title: "Health Screening",
    service: "Health Certificate Application",
    citizenName: "David Wilson",
    citizenEmail: "david.w@email.com",
    citizenPhone: "+1 (555) 567-8901",
    date: "2024-01-21",
    time: "15:30",
    duration: 45,
    status: "cancelled",
    location: "Health Department, Screening Room",
    notes: "Cancelled by citizen",
  },
]

const services = [
  "All Services",
  "Health Certificate Application",
  "Driver's License Renewal",
  "Business License Application",
  "Property Tax Assessment",
]

export default function AppointmentsPage() {
  const [searchTerm, setSearchTerm] = useState("")
  const [selectedService, setSelectedService] = useState("All Services")
  const [statusFilter, setStatusFilter] = useState("all")
  const [dateFilter, setDateFilter] = useState("all")

  const filteredAppointments = appointments.filter((appointment) => {
    const matchesSearch =
      appointment.citizenName.toLowerCase().includes(searchTerm.toLowerCase()) ||
      appointment.citizenEmail.toLowerCase().includes(searchTerm.toLowerCase()) ||
      appointment.title.toLowerCase().includes(searchTerm.toLowerCase())
    const matchesService = selectedService === "All Services" || appointment.service === selectedService
    const matchesStatus = statusFilter === "all" || appointment.status === statusFilter

    return matchesSearch && matchesService && matchesStatus
  })

  const getStatusColor = (status: string) => {
    switch (status) {
      case "confirmed":
        return "bg-green-100 text-green-800"
      case "pending":
        return "bg-yellow-100 text-yellow-800"
      case "cancelled":
        return "bg-red-100 text-red-800"
      case "completed":
        return "bg-blue-100 text-blue-800"
      default:
        return "bg-gray-100 text-gray-800"
    }
  }

  const todayAppointments = 8
  const pendingAppointments = 3
  const confirmedAppointments = 12

  return (
    <div className="min-h-screen bg-background">
      {/* Header */}
      <header className="border-b border-border bg-card">
        <div className="container mx-auto px-4 py-4 flex items-center justify-between">
          <div className="flex items-center space-x-4">
            <div className="flex items-center space-x-2">
              <div>
                <h1 className="text-xl font-bold text-foreground">Appointment Management</h1>
                <p className="text-sm text-muted-foreground">Schedule and manage citizen appointments</p>
              </div>
            </div>
          </div>
          <div className="flex items-center space-x-4">
            <Link href="/dashboard/appointments/calendar">
              <Button variant="outline">
                <Calendar className="h-4 w-4 mr-2" />
                Calendar View
              </Button>
            </Link>
            <Link href="/dashboard/appointments/create">
              <Button>
                <Plus className="h-4 w-4 mr-2" />
                Schedule Appointment
              </Button>
            </Link>
          </div>
        </div>
      </header>

      <div className="container mx-auto px-4 py-8">
        {/* Stats Cards */}
        <div className="grid md:grid-cols-4 gap-4 mb-6">
          <Card>
            <CardContent className="p-4">
              <div className="text-2xl font-bold text-foreground">{todayAppointments}</div>
              <p className="text-sm text-muted-foreground">Today's Appointments</p>
            </CardContent>
          </Card>
          <Card>
            <CardContent className="p-4">
              <div className="text-2xl font-bold text-yellow-600">{pendingAppointments}</div>
              <p className="text-sm text-muted-foreground">Pending Confirmation</p>
            </CardContent>
          </Card>
          <Card>
            <CardContent className="p-4">
              <div className="text-2xl font-bold text-green-600">{confirmedAppointments}</div>
              <p className="text-sm text-muted-foreground">Confirmed</p>
            </CardContent>
          </Card>
          <Card>
            <CardContent className="p-4">
              <div className="text-2xl font-bold text-primary">92%</div>
              <p className="text-sm text-muted-foreground">Attendance Rate</p>
            </CardContent>
          </Card>
        </div>

        {/* Filters */}
        <div className="flex flex-col lg:flex-row gap-4 mb-6">
          <div className="relative flex-1">
            <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-muted-foreground h-4 w-4" />
            <Input
              placeholder="Search appointments..."
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              className="pl-10"
            />
          </div>
          <Select value={selectedService} onValueChange={setSelectedService}>
            <SelectTrigger className="w-full lg:w-64">
              <SelectValue placeholder="Service" />
            </SelectTrigger>
            <SelectContent>
              {services.map((service) => (
                <SelectItem key={service} value={service}>
                  {service}
                </SelectItem>
              ))}
            </SelectContent>
          </Select>
          <Select value={statusFilter} onValueChange={setStatusFilter}>
            <SelectTrigger className="w-full lg:w-40">
              <SelectValue placeholder="Status" />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="all">All Status</SelectItem>
              <SelectItem value="confirmed">Confirmed</SelectItem>
              <SelectItem value="pending">Pending</SelectItem>
              <SelectItem value="cancelled">Cancelled</SelectItem>
              <SelectItem value="completed">Completed</SelectItem>
            </SelectContent>
          </Select>
        </div>

        {/* Appointments List */}
        <div className="space-y-4">
          {filteredAppointments.map((appointment) => (
            <Card key={appointment.id} className="hover:shadow-md transition-shadow">
              <CardHeader>
                <div className="flex items-start justify-between">
                  <div className="flex-1">
                    <div className="flex items-center space-x-3 mb-2">
                      <CardTitle className="text-lg">{appointment.title}</CardTitle>
                      <Badge className={getStatusColor(appointment.status)}>{appointment.status}</Badge>
                    </div>
                    <CardDescription className="mb-3">{appointment.service}</CardDescription>

                    <div className="grid md:grid-cols-2 gap-4 text-sm">
                      <div className="space-y-2">
                        <div className="flex items-center space-x-2 text-muted-foreground">
                          <User className="h-4 w-4" />
                          <span>{appointment.citizenName}</span>
                        </div>
                        <div className="flex items-center space-x-2 text-muted-foreground">
                          <Mail className="h-4 w-4" />
                          <span>{appointment.citizenEmail}</span>
                        </div>
                        <div className="flex items-center space-x-2 text-muted-foreground">
                          <Phone className="h-4 w-4" />
                          <span>{appointment.citizenPhone}</span>
                        </div>
                      </div>
                      <div className="space-y-2">
                        <div className="flex items-center space-x-2 text-muted-foreground">
                          <Calendar className="h-4 w-4" />
                          <span>
                            {appointment.date} at {appointment.time}
                          </span>
                        </div>
                        <div className="flex items-center space-x-2 text-muted-foreground">
                          <Clock className="h-4 w-4" />
                          <span>{appointment.duration} minutes</span>
                        </div>
                        <div className="flex items-center space-x-2 text-muted-foreground">
                          <MapPin className="h-4 w-4" />
                          <span>{appointment.location}</span>
                        </div>
                      </div>
                    </div>
                  </div>
                  <div className="flex items-center space-x-2">
                    <Link href={`/dashboard/appointments/${appointment.id}`}>
                      <Button variant="outline" size="sm">
                        View Details
                      </Button>
                    </Link>
                    <Link href={`/dashboard/appointments/${appointment.id}/edit`}>
                      <Button variant="outline" size="sm">
                        Edit
                      </Button>
                    </Link>
                  </div>
                </div>
              </CardHeader>
              {appointment.notes && (
                <CardContent>
                  <div className="bg-muted/50 p-3 rounded-md">
                    <p className="text-sm">
                      <strong>Notes:</strong> {appointment.notes}
                    </p>
                  </div>
                </CardContent>
              )}
            </Card>
          ))}
        </div>

        {filteredAppointments.length === 0 && (
          <div className="text-center py-12">
            <Calendar className="h-12 w-12 text-muted-foreground mx-auto mb-4" />
            <h3 className="text-lg font-medium text-foreground mb-2">No appointments found</h3>
            <p className="text-muted-foreground mb-4">
              {searchTerm || selectedService !== "All Services" || statusFilter !== "all"
                ? "Try adjusting your search or filters"
                : "Get started by scheduling your first appointment"}
            </p>
            <Link href="/dashboard/appointments/create">
              <Button>
                <Plus className="h-4 w-4 mr-2" />
                Schedule Appointment
              </Button>
            </Link>
          </div>
        )}
      </div>
    </div>
  )
}

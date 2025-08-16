"use client"

import { useState } from "react"
import Link from "next/link"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Badge } from "@/components/ui/badge"
import { ThemeToggle } from "@/components/theme-toggle"
import { Calendar, ArrowLeft, ChevronLeft, ChevronRight, Plus, Clock, User } from "lucide-react"

// Mock calendar data
const calendarData = {
  "2024-01-15": [
    { id: 1, time: "09:00", title: "Health Certificate", citizen: "John Doe", status: "confirmed" },
    { id: 2, time: "14:00", title: "License Renewal", citizen: "Sarah Johnson", status: "pending" },
  ],
  "2024-01-16": [
    { id: 3, time: "10:30", title: "Business License", citizen: "Mike Chen", status: "confirmed" },
    { id: 4, time: "15:00", title: "Tax Assessment", citizen: "Lisa Rodriguez", status: "confirmed" },
  ],
  "2024-01-17": [{ id: 5, time: "11:00", title: "Health Screening", citizen: "David Wilson", status: "pending" }],
  "2024-01-18": [
    { id: 6, time: "09:30", title: "Permit Review", citizen: "Emma Davis", status: "confirmed" },
    { id: 7, time: "13:00", title: "Social Services", citizen: "Robert Brown", status: "confirmed" },
    { id: 8, time: "16:00", title: "Environmental Permit", citizen: "Anna Taylor", status: "pending" },
  ],
}

const daysOfWeek = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
const months = [
  "January",
  "February",
  "March",
  "April",
  "May",
  "June",
  "July",
  "August",
  "September",
  "October",
  "November",
  "December",
]

export default function AppointmentCalendarPage() {
  const [currentDate, setCurrentDate] = useState(new Date(2024, 0, 15)) // January 15, 2024
  const [selectedDate, setSelectedDate] = useState<string | null>("2024-01-15")

  const getDaysInMonth = (date: Date) => {
    return new Date(date.getFullYear(), date.getMonth() + 1, 0).getDate()
  }

  const getFirstDayOfMonth = (date: Date) => {
    return new Date(date.getFullYear(), date.getMonth(), 1).getDay()
  }

  const formatDateKey = (year: number, month: number, day: number) => {
    return `${year}-${String(month + 1).padStart(2, "0")}-${String(day).padStart(2, "0")}`
  }

  const navigateMonth = (direction: "prev" | "next") => {
    setCurrentDate((prev) => {
      const newDate = new Date(prev)
      if (direction === "prev") {
        newDate.setMonth(prev.getMonth() - 1)
      } else {
        newDate.setMonth(prev.getMonth() + 1)
      }
      return newDate
    })
  }

  const renderCalendarDays = () => {
    const daysInMonth = getDaysInMonth(currentDate)
    const firstDay = getFirstDayOfMonth(currentDate)
    const days = []

    // Empty cells for days before the first day of the month
    for (let i = 0; i < firstDay; i++) {
      days.push(<div key={`empty-${i}`} className="h-24 border border-border"></div>)
    }

    // Days of the month
    for (let day = 1; day <= daysInMonth; day++) {
      const dateKey = formatDateKey(currentDate.getFullYear(), currentDate.getMonth(), day)
      const dayAppointments = calendarData[dateKey] || []
      const isSelected = selectedDate === dateKey
      const isToday = dateKey === "2024-01-15" // Mock today

      days.push(
        <div
          key={day}
          className={`h-24 border border-border p-1 cursor-pointer hover:bg-muted/50 transition-colors ${
            isSelected ? "bg-primary/10 border-primary" : ""
          } ${isToday ? "bg-accent" : ""}`}
          onClick={() => setSelectedDate(dateKey)}
        >
          <div className={`text-sm font-medium mb-1 ${isToday ? "text-primary" : ""}`}>{day}</div>
          <div className="space-y-1">
            {dayAppointments.slice(0, 2).map((apt) => (
              <div
                key={apt.id}
                className={`text-xs p-1 rounded truncate ${
                  apt.status === "confirmed" ? "bg-green-100 text-green-800" : "bg-yellow-100 text-yellow-800"
                }`}
              >
                {apt.time} {apt.title}
              </div>
            ))}
            {dayAppointments.length > 2 && (
              <div className="text-xs text-muted-foreground">+{dayAppointments.length - 2} more</div>
            )}
          </div>
        </div>,
      )
    }

    return days
  }

  const selectedDateAppointments = selectedDate ? calendarData[selectedDate] || [] : []

  return (
    <div className="min-h-screen bg-background">
      {/* Header */}
      <header className="border-b border-border bg-card">
        <div className="container mx-auto px-4 py-4 flex items-center justify-between">
          <div className="flex items-center space-x-4">
            <Link
              href="/dashboard/appointments"
              className="flex items-center text-muted-foreground hover:text-foreground"
            >
              <ArrowLeft className="h-4 w-4 mr-1" />
              Appointments
            </Link>
            <div className="flex items-center space-x-2">
              <Calendar className="h-8 w-8 text-primary" />
              <div>
                <h1 className="text-xl font-bold text-foreground">Calendar View</h1>
                <p className="text-sm text-muted-foreground">Monthly appointment overview</p>
              </div>
            </div>
          </div>
          <div className="flex items-center space-x-4">
            <ThemeToggle />
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
        <div className="grid lg:grid-cols-3 gap-6">
          {/* Calendar */}
          <div className="lg:col-span-2">
            <Card>
              <CardHeader>
                <div className="flex items-center justify-between">
                  <CardTitle className="text-2xl">
                    {months[currentDate.getMonth()]} {currentDate.getFullYear()}
                  </CardTitle>
                  <div className="flex items-center space-x-2">
                    <Button variant="outline" size="icon" onClick={() => navigateMonth("prev")}>
                      <ChevronLeft className="h-4 w-4" />
                    </Button>
                    <Button variant="outline" size="icon" onClick={() => navigateMonth("next")}>
                      <ChevronRight className="h-4 w-4" />
                    </Button>
                  </div>
                </div>
              </CardHeader>
              <CardContent>
                {/* Days of week header */}
                <div className="grid grid-cols-7 gap-0 mb-2">
                  {daysOfWeek.map((day) => (
                    <div
                      key={day}
                      className="h-8 flex items-center justify-center text-sm font-medium text-muted-foreground"
                    >
                      {day}
                    </div>
                  ))}
                </div>
                {/* Calendar grid */}
                <div className="grid grid-cols-7 gap-0 border border-border">{renderCalendarDays()}</div>
              </CardContent>
            </Card>
          </div>

          {/* Selected Date Details */}
          <div>
            <Card>
              <CardHeader>
                <CardTitle>
                  {selectedDate
                    ? new Date(selectedDate).toLocaleDateString("en-US", {
                        weekday: "long",
                        year: "numeric",
                        month: "long",
                        day: "numeric",
                      })
                    : "Select a date"}
                </CardTitle>
                <CardDescription>
                  {selectedDateAppointments.length} appointment{selectedDateAppointments.length !== 1 ? "s" : ""}
                </CardDescription>
              </CardHeader>
              <CardContent>
                {selectedDateAppointments.length > 0 ? (
                  <div className="space-y-3">
                    {selectedDateAppointments.map((appointment) => (
                      <div key={appointment.id} className="border border-border rounded-lg p-3">
                        <div className="flex items-start justify-between mb-2">
                          <div className="flex items-center space-x-2">
                            <Clock className="h-4 w-4 text-muted-foreground" />
                            <span className="font-medium">{appointment.time}</span>
                          </div>
                          <Badge
                            className={
                              appointment.status === "confirmed"
                                ? "bg-green-100 text-green-800"
                                : "bg-yellow-100 text-yellow-800"
                            }
                          >
                            {appointment.status}
                          </Badge>
                        </div>
                        <h4 className="font-medium text-sm mb-1">{appointment.title}</h4>
                        <div className="flex items-center space-x-2 text-sm text-muted-foreground">
                          <User className="h-3 w-3" />
                          <span>{appointment.citizen}</span>
                        </div>
                      </div>
                    ))}
                  </div>
                ) : (
                  <div className="text-center py-8">
                    <Calendar className="h-8 w-8 text-muted-foreground mx-auto mb-2" />
                    <p className="text-sm text-muted-foreground">No appointments scheduled</p>
                  </div>
                )}
              </CardContent>
            </Card>

            {/* Quick Stats */}
            <Card className="mt-4">
              <CardHeader>
                <CardTitle className="text-lg">This Month</CardTitle>
              </CardHeader>
              <CardContent className="space-y-3">
                <div className="flex justify-between">
                  <span className="text-sm text-muted-foreground">Total Appointments</span>
                  <span className="font-medium">24</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-sm text-muted-foreground">Confirmed</span>
                  <span className="font-medium text-green-600">18</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-sm text-muted-foreground">Pending</span>
                  <span className="font-medium text-yellow-600">6</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-sm text-muted-foreground">Attendance Rate</span>
                  <span className="font-medium">92%</span>
                </div>
              </CardContent>
            </Card>
          </div>
        </div>
      </div>
    </div>
  )
}

"use client"

import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Building2, Users, Calendar, MessageSquare, FileText, Plus, TrendingUp, Clock, AlertCircle, CheckCircle2, XCircle, UserCheck } from "lucide-react"
import Link from "next/link"
import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"

export default function DashboardPage() {
  // Mock data for Grama Niladhari Division
  const divisionStats = {
    name: "Grama Niladhari Division - Colombo 10",
    gnCode: "563/A",
    todayAppointments: 8,
    pendingDocuments: 12,
    awaitingConfirmation: 3,
    completedToday: 5,
    averageWaitTime: 18,
    citizenMessages: 4,
    totalHouseholds: 1250,
    totalPopulation: 4850
  }

  return (
    <div className="space-y-6">
      {/* Grama Niladhari Division Header */}
      <div className="bg-card p-6 rounded-lg border">
        <div className="flex justify-between items-center">
          <div>
            <h2 className="text-2xl font-bold">{divisionStats.name}</h2>
            <p className="text-muted-foreground">GN Code: {divisionStats.gnCode} | Population: {divisionStats.totalPopulation.toLocaleString()} | Households: {divisionStats.totalHouseholds.toLocaleString()}</p>
            <p className="text-sm text-muted-foreground mt-1">{new Date().toLocaleDateString('en-US', { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' })}</p>
          </div>
          <Badge variant="outline" className="text-green-600 border-green-600">
            <CheckCircle2 className="h-3 w-3 mr-1" />
            On Duty
          </Badge>
        </div>
      </div>

      {/* Quick Stats */}
      <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-6">
        <Card className="border-orange-200 bg-orange-50 dark:bg-orange-950/20">
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Today's Appointments</CardTitle>
            <Calendar className="h-4 w-4 text-orange-600" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-orange-700">{divisionStats.todayAppointments}</div>
            <p className="text-xs text-muted-foreground">
              {divisionStats.awaitingConfirmation} awaiting confirmation
            </p>
          </CardContent>
        </Card>

        <Card className="border-blue-200 bg-blue-50 dark:bg-blue-950/20">
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Certificates to Review</CardTitle>
            <FileText className="h-4 w-4 text-blue-600" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-blue-700">{divisionStats.pendingDocuments}</div>
            <p className="text-xs text-muted-foreground">Character, Income, Residence</p>
          </CardContent>
        </Card>

        <Card className="border-purple-200 bg-purple-50 dark:bg-purple-950/20">
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Citizen Inquiries</CardTitle>
            <MessageSquare className="h-4 w-4 text-purple-600" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-purple-700">{divisionStats.citizenMessages}</div>
            <p className="text-xs text-muted-foreground">Awaiting response</p>
          </CardContent>
        </Card>

        <Card className="border-green-200 bg-green-50 dark:bg-green-950/20">
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Issued Today</CardTitle>
            <UserCheck className="h-4 w-4 text-green-600" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-green-700">{divisionStats.completedToday}</div>
            <p className="text-xs text-muted-foreground">Certificates issued</p>
          </CardContent>
        </Card>
      </div>

      {/* Priority Actions */}
      <div className="grid md:grid-cols-2 gap-6">
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center justify-between">
              <span>Pending Appointments</span>
              <Badge variant="destructive">{divisionStats.awaitingConfirmation} Pending</Badge>
            </CardTitle>
            <CardDescription>Appointments requiring confirmation</CardDescription>
          </CardHeader>
          <CardContent>
            <div className="space-y-3">
              <div className="flex items-center justify-between p-3 rounded-lg bg-muted/50">
                <div>
                  <p className="font-medium">Kamal Perera - Character Certificate</p>
                  <p className="text-sm text-muted-foreground">Today, 10:30 AM</p>
                </div>
                <div className="flex gap-2">
                  <Button size="sm" variant="outline">Review</Button>
                  <Button size="sm">Confirm</Button>
                </div>
              </div>
              <div className="flex items-center justify-between p-3 rounded-lg bg-muted/50">
                <div>
                  <p className="font-medium">Seetha Fernando - Residence Certificate</p>
                  <p className="text-sm text-muted-foreground">Today, 2:00 PM</p>
                </div>
                <div className="flex gap-2">
                  <Button size="sm" variant="outline">Review</Button>
                  <Button size="sm">Confirm</Button>
                </div>
              </div>
              <div className="flex items-center justify-between p-3 rounded-lg bg-muted/50">
                <div>
                  <p className="font-medium">Ranjith Silva - Income Certificate</p>
                  <p className="text-sm text-muted-foreground">Tomorrow, 9:00 AM</p>
                </div>
                <div className="flex gap-2">
                  <Button size="sm" variant="outline">Review</Button>
                  <Button size="sm">Confirm</Button>
                </div>
              </div>
            </div>
            <div className="mt-4">
              <Link href="/dashboard/appointments">
                <Button variant="outline" className="w-full">View All Appointments</Button>
              </Link>
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle className="flex items-center justify-between">
              <span>Documents Pending Review</span>
              <Badge variant="secondary">{divisionStats.pendingDocuments} New</Badge>
            </CardTitle>
            <CardDescription>Pre-submitted documents requiring attention</CardDescription>
          </CardHeader>
          <CardContent>
            <div className="space-y-3">
              <div className="flex items-center justify-between p-3 rounded-lg bg-muted/50">
                <div className="flex-1">
                  <p className="font-medium">Character Certificate Application</p>
                  <p className="text-sm text-muted-foreground">Submitted by Mala Jayawardena</p>
                  <Badge variant="outline" className="mt-1 text-orange-600">Police report missing</Badge>
                </div>
                <Button size="sm" variant="outline">Review</Button>
              </div>
              <div className="flex items-center justify-between p-3 rounded-lg bg-muted/50">
                <div className="flex-1">
                  <p className="font-medium">Income Certificate</p>
                  <p className="text-sm text-muted-foreground">Submitted by Nimal Rajapaksa</p>
                  <Badge variant="outline" className="mt-1 text-green-600">Complete</Badge>
                </div>
                <Button size="sm" variant="outline">Review</Button>
              </div>
              <div className="flex items-center justify-between p-3 rounded-lg bg-muted/50">
                <div className="flex-1">
                  <p className="font-medium">Residence Certificate</p>
                  <p className="text-sm text-muted-foreground">Submitted by Kumari Silva</p>
                  <Badge variant="outline" className="mt-1 text-orange-600">Address proof unclear</Badge>
                </div>
                <Button size="sm" variant="outline">Review</Button>
              </div>
            </div>
            <div className="mt-4">
              <Link href="/dashboard/documents">
                <Button variant="outline" className="w-full">View All Documents</Button>
              </Link>
            </div>
          </CardContent>
        </Card>
      </div>

      {/* Activity and Notifications */}
      <div className="grid lg:grid-cols-2 gap-6">
        <Card>
          <CardHeader>
            <CardTitle>Recent Notifications</CardTitle>
            <CardDescription>System alerts and citizen updates</CardDescription>
          </CardHeader>
          <CardContent>
            <div className="space-y-4">
              <div className="flex items-start space-x-4">
                <div className="w-8 h-8 bg-orange-100 rounded-full flex items-center justify-center flex-shrink-0">
                  <AlertCircle className="h-4 w-4 text-orange-600" />
                </div>
                <div className="flex-1 space-y-1">
                  <p className="text-sm font-medium">Document requires correction</p>
                  <p className="text-xs text-muted-foreground">John Doe's vaccination record is expired</p>
                  <span className="text-xs text-muted-foreground">5 minutes ago</span>
                </div>
              </div>

              <div className="flex items-start space-x-4">
                <div className="w-8 h-8 bg-blue-100 rounded-full flex items-center justify-center flex-shrink-0">
                  <Calendar className="h-4 w-4 text-blue-600" />
                </div>
                <div className="flex-1 space-y-1">
                  <p className="text-sm font-medium">New appointment scheduled</p>
                  <p className="text-xs text-muted-foreground">Health screening - Sarah Johnson - Tomorrow 2:00 PM</p>
                  <span className="text-xs text-muted-foreground">12 minutes ago</span>
                </div>
              </div>

              <div className="flex items-start space-x-4">
                <div className="w-8 h-8 bg-green-100 rounded-full flex items-center justify-center flex-shrink-0">
                  <CheckCircle2 className="h-4 w-4 text-green-600" />
                </div>
                <div className="flex-1 space-y-1">
                  <p className="text-sm font-medium">Document approved</p>
                  <p className="text-xs text-muted-foreground">Medical clearance for Mike Chen</p>
                  <span className="text-xs text-muted-foreground">30 minutes ago</span>
                </div>
              </div>

              <div className="flex items-start space-x-4">
                <div className="w-8 h-8 bg-purple-100 rounded-full flex items-center justify-center flex-shrink-0">
                  <MessageSquare className="h-4 w-4 text-purple-600" />
                </div>
                <div className="flex-1 space-y-1">
                  <p className="text-sm font-medium">New citizen message</p>
                  <p className="text-xs text-muted-foreground">Question about appointment rescheduling</p>
                  <span className="text-xs text-muted-foreground">1 hour ago</span>
                </div>
              </div>
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle>Department Performance</CardTitle>
            <CardDescription>Key metrics for today</CardDescription>
          </CardHeader>
          <CardContent>
            <div className="space-y-4">
              <div>
                <div className="flex items-center justify-between mb-2">
                  <span className="text-sm font-medium">Appointment Completion Rate</span>
                  <span className="text-sm text-muted-foreground">94%</span>
                </div>
                <div className="w-full bg-muted rounded-full h-2">
                  <div className="bg-green-600 h-2 rounded-full" style={{ width: "94%" }}></div>
                </div>
              </div>

              <div>
                <div className="flex items-center justify-between mb-2">
                  <span className="text-sm font-medium">Average Processing Time</span>
                  <span className="text-sm text-muted-foreground">{divisionStats.averageWaitTime} min</span>
                </div>
                <div className="w-full bg-muted rounded-full h-2">
                  <div className="bg-blue-600 h-2 rounded-full" style={{ width: "68%" }}></div>
                </div>
              </div>

              <div>
                <div className="flex items-center justify-between mb-2">
                  <span className="text-sm font-medium">Document Review Progress</span>
                  <span className="text-sm text-muted-foreground">75%</span>
                </div>
                <div className="w-full bg-muted rounded-full h-2">
                  <div className="bg-purple-600 h-2 rounded-full" style={{ width: "75%" }}></div>
                </div>
              </div>

              <div>
                <div className="flex items-center justify-between mb-2">
                  <span className="text-sm font-medium">Citizen Response Rate</span>
                  <span className="text-sm text-muted-foreground">89%</span>
                </div>
                <div className="w-full bg-muted rounded-full h-2">
                  <div className="bg-orange-600 h-2 rounded-full" style={{ width: "89%" }}></div>
                </div>
              </div>

              <div className="mt-4 pt-4 border-t">
                <div className="flex items-center justify-between">
                  <span className="text-sm font-medium">GN Division Efficiency Score</span>
                  <Badge className="bg-green-100 text-green-800">Excellent</Badge>
                </div>
              </div>
            </div>
          </CardContent>
        </Card>
      </div>
    </div>
  )
}

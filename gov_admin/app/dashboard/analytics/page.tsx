"use client"

import { useState } from "react"
import Link from "next/link"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"
import { ThemeToggle } from "@/components/theme-toggle"
import { BarChart3, ArrowLeft, TrendingUp, TrendingDown, Calendar, FileText, Clock } from "lucide-react"
import { ChartContainer, ChartTooltip, ChartTooltipContent } from "@/components/ui/chart"
import {
  Bar,
  BarChart,
  Line,
  LineChart,
  Pie,
  PieChart,
  Cell,
  ResponsiveContainer,
  XAxis,
  YAxis,
  CartesianGrid,
} from "recharts"

// Mock data for analytics
const dailyData = [
  { date: "Mon", appointments: 12, completed: 10, cancelled: 2 },
  { date: "Tue", appointments: 15, completed: 13, cancelled: 2 },
  { date: "Wed", appointments: 8, completed: 7, cancelled: 1 },
  { date: "Thu", appointments: 18, completed: 16, cancelled: 2 },
  { date: "Fri", appointments: 22, completed: 20, cancelled: 2 },
  { date: "Sat", appointments: 6, completed: 5, cancelled: 1 },
  { date: "Sun", appointments: 4, completed: 4, cancelled: 0 },
]

const monthlyData = [
  { month: "Jan", appointments: 245, services: 189, departments: 8 },
  { month: "Feb", appointments: 289, services: 234, departments: 9 },
  { month: "Mar", appointments: 312, services: 267, departments: 10 },
  { month: "Apr", appointments: 278, services: 223, departments: 10 },
  { month: "May", appointments: 334, services: 289, departments: 11 },
  { month: "Jun", appointments: 298, services: 245, departments: 11 },
  { month: "Jul", appointments: 356, services: 312, departments: 12 },
  { month: "Aug", appointments: 389, services: 334, departments: 12 },
  { month: "Sep", appointments: 367, services: 298, departments: 13 },
  { month: "Oct", appointments: 423, services: 378, departments: 13 },
  { month: "Nov", appointments: 445, services: 398, departments: 14 },
  { month: "Dec", appointments: 398, services: 356, departments: 14 },
]

const serviceDistribution = [
  { name: "Health Services", value: 35, color: "#0088FE" },
  { name: "Transportation", value: 25, color: "#00C49F" },
  { name: "Business Licenses", value: 20, color: "#FFBB28" },
  { name: "Tax Services", value: 12, color: "#FF8042" },
  { name: "Social Services", value: 8, color: "#8884D8" },
]

const departmentPerformance = [
  { department: "Health", appointments: 156, satisfaction: 4.8, avgTime: 25 },
  { department: "Transportation", apartments: 134, satisfaction: 4.6, avgTime: 18 },
  { department: "Commerce", appointments: 98, satisfaction: 4.7, avgTime: 35 },
  { department: "Revenue", appointments: 87, satisfaction: 4.5, avgTime: 22 },
  { department: "Social Services", appointments: 76, satisfaction: 4.9, avgTime: 28 },
]

export default function AnalyticsPage() {
  const [timeRange, setTimeRange] = useState("monthly")
  const [selectedMetric, setSelectedMetric] = useState("appointments")

  const chartConfig = {
    appointments: {
      label: "Appointments",
      color: "hsl(var(--chart-1))",
    },
    completed: {
      label: "Completed",
      color: "hsl(var(--chart-2))",
    },
    cancelled: {
      label: "Cancelled",
      color: "hsl(var(--chart-3))",
    },
    services: {
      label: "Services",
      color: "hsl(var(--chart-4))",
    },
    departments: {
      label: "Departments",
      color: "hsl(var(--chart-5))",
    },
  }

  return (
    <div className="min-h-screen bg-background">
      {/* Header */}
      <header className="border-b border-border bg-card">
        <div className="container mx-auto px-4 py-4 flex items-center justify-between">
          <div className="flex items-center space-x-4">
            <div className="flex items-center space-x-2">
              <BarChart3 className="h-8 w-8 text-primary" />
              <div>
                <h1 className="text-xl font-bold text-foreground">Analytics Dashboard</h1>
                <p className="text-sm text-muted-foreground">Track appointments and service performance</p>
              </div>
            </div>
          </div>
          <div className="flex items-center space-x-4">
            <Select value={timeRange} onValueChange={setTimeRange}>
              <SelectTrigger className="w-32">
                <SelectValue />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="daily">Daily</SelectItem>
                <SelectItem value="weekly">Weekly</SelectItem>
                <SelectItem value="monthly">Monthly</SelectItem>
                <SelectItem value="yearly">Yearly</SelectItem>
              </SelectContent>
            </Select>
          </div>
        </div>
      </header>

      <div className="container mx-auto px-4 py-8">
        {/* Key Metrics */}
        <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
          <Card>
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle className="text-sm font-medium">Total Appointments</CardTitle>
              <Calendar className="h-4 w-4 text-muted-foreground" />
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold">4,234</div>
              <div className="flex items-center text-xs text-muted-foreground">
                <TrendingUp className="h-3 w-3 mr-1 text-green-500" />
                +12.5% from last month
              </div>
            </CardContent>
          </Card>

          <Card>
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle className="text-sm font-medium">Completion Rate</CardTitle>
              <Clock className="h-4 w-4 text-muted-foreground" />
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold">87.3%</div>
              <div className="flex items-center text-xs text-muted-foreground">
                <TrendingUp className="h-3 w-3 mr-1 text-green-500" />
                +2.1% from last month
              </div>
            </CardContent>
          </Card>

          <Card>
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle className="text-sm font-medium">Active Services</CardTitle>
              <FileText className="h-4 w-4 text-muted-foreground" />
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold">47</div>
              <div className="flex items-center text-xs text-muted-foreground">
                <TrendingUp className="h-3 w-3 mr-1 text-green-500" />
                +3 new this month
              </div>
            </CardContent>
          </Card>

          <Card>
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle className="text-sm font-medium">Avg. Wait Time</CardTitle>
              <Clock className="h-4 w-4 text-muted-foreground" />
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold">24 min</div>
              <div className="flex items-center text-xs text-muted-foreground">
                <TrendingDown className="h-3 w-3 mr-1 text-green-500" />
                -3.2 min from last month
              </div>
            </CardContent>
          </Card>
        </div>

        <div className="grid lg:grid-cols-2 gap-6 mb-8">
          {/* Appointments Trend */}
          <Card>
            <CardHeader>
              <CardTitle>Appointments Trend</CardTitle>
              <CardDescription>
                {timeRange === "daily" ? "Daily appointments this week" : "Monthly appointments this year"}
              </CardDescription>
            </CardHeader>
            <CardContent>
              <ChartContainer config={chartConfig}>
                <ResponsiveContainer width="100%" height={300}>
                  {timeRange === "daily" ? (
                    <BarChart data={dailyData}>
                      <CartesianGrid strokeDasharray="3 3" />
                      <XAxis dataKey="date" />
                      <YAxis />
                      <ChartTooltip content={<ChartTooltipContent />} />
                      <Bar dataKey="appointments" fill="var(--color-appointments)" />
                      <Bar dataKey="completed" fill="var(--color-completed)" />
                    </BarChart>
                  ) : (
                    <LineChart data={monthlyData}>
                      <CartesianGrid strokeDasharray="3 3" />
                      <XAxis dataKey="month" />
                      <YAxis />
                      <ChartTooltip content={<ChartTooltipContent />} />
                      <Line type="monotone" dataKey="appointments" stroke="var(--color-appointments)" strokeWidth={2} />
                      <Line type="monotone" dataKey="services" stroke="var(--color-services)" strokeWidth={2} />
                    </LineChart>
                  )}
                </ResponsiveContainer>
              </ChartContainer>
            </CardContent>
          </Card>

          {/* Service Distribution */}
          <Card>
            <CardHeader>
              <CardTitle>Service Distribution</CardTitle>
              <CardDescription>Breakdown of appointments by service category</CardDescription>
            </CardHeader>
            <CardContent>
              <ChartContainer config={chartConfig}>
                <ResponsiveContainer width="100%" height={300}>
                  <PieChart>
                    <Pie
                      data={serviceDistribution}
                      cx="50%"
                      cy="50%"
                      outerRadius={80}
                      dataKey="value"
                      label={({ name, percent }) => `${name} ${((percent ?? 0) * 100).toFixed(0)}%`}
                    >
                      {serviceDistribution.map((entry, index) => (
                        <Cell key={`cell-${index}`} fill={entry.color} />
                      ))}
                    </Pie>
                    <ChartTooltip content={<ChartTooltipContent />} />
                  </PieChart>
                </ResponsiveContainer>
              </ChartContainer>
            </CardContent>
          </Card>
        </div>

        {/* Department Performance */}
        <Card className="mb-8">
          <CardHeader>
            <CardTitle>Department Performance</CardTitle>
            <CardDescription>Key metrics by department</CardDescription>
          </CardHeader>
          <CardContent>
            <div className="overflow-x-auto">
              <table className="w-full">
                <thead>
                  <tr className="border-b">
                    <th className="text-left py-3 px-4 font-medium">Department</th>
                    <th className="text-left py-3 px-4 font-medium">Appointments</th>
                    <th className="text-left py-3 px-4 font-medium">Satisfaction</th>
                    <th className="text-left py-3 px-4 font-medium">Avg. Time (min)</th>
                    <th className="text-left py-3 px-4 font-medium">Performance</th>
                  </tr>
                </thead>
                <tbody>
                  {departmentPerformance.map((dept, index) => (
                    <tr key={index} className="border-b">
                      <td className="py-3 px-4 font-medium">{dept.department}</td>
                      <td className="py-3 px-4">{dept.appointments}</td>
                      <td className="py-3 px-4">
                        <div className="flex items-center">
                          <span className="mr-2">{dept.satisfaction}</span>
                          <div className="flex">
                            {[...Array(5)].map((_, i) => (
                              <span
                                key={i}
                                className={`text-xs ${
                                  i < Math.floor(dept.satisfaction) ? "text-yellow-400" : "text-gray-300"
                                }`}
                              >
                                ★
                              </span>
                            ))}
                          </div>
                        </div>
                      </td>
                      <td className="py-3 px-4">{dept.avgTime}</td>
                      <td className="py-3 px-4">
                        <div className="w-full bg-gray-200 rounded-full h-2">
                          <div
                            className="bg-primary h-2 rounded-full"
                            style={{ width: `${(dept.satisfaction / 5) * 100}%` }}
                          ></div>
                        </div>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </CardContent>
        </Card>

        {/* Additional Insights */}
        <div className="grid md:grid-cols-2 gap-6">
          <Card>
            <CardHeader>
              <CardTitle>Peak Hours</CardTitle>
              <CardDescription>Most busy appointment times</CardDescription>
            </CardHeader>
            <CardContent>
              <div className="space-y-4">
                <div className="flex items-center justify-between">
                  <span className="text-sm">10:00 AM - 11:00 AM</span>
                  <div className="flex items-center space-x-2">
                    <div className="w-24 bg-gray-200 rounded-full h-2">
                      <div className="bg-primary h-2 rounded-full" style={{ width: "85%" }}></div>
                    </div>
                    <span className="text-sm text-muted-foreground">85%</span>
                  </div>
                </div>
                <div className="flex items-center justify-between">
                  <span className="text-sm">2:00 PM - 3:00 PM</span>
                  <div className="flex items-center space-x-2">
                    <div className="w-24 bg-gray-200 rounded-full h-2">
                      <div className="bg-primary h-2 rounded-full" style={{ width: "78%" }}></div>
                    </div>
                    <span className="text-sm text-muted-foreground">78%</span>
                  </div>
                </div>
                <div className="flex items-center justify-between">
                  <span className="text-sm">9:00 AM - 10:00 AM</span>
                  <div className="flex items-center space-x-2">
                    <div className="w-24 bg-gray-200 rounded-full h-2">
                      <div className="bg-primary h-2 rounded-full" style={{ width: "72%" }}></div>
                    </div>
                    <span className="text-sm text-muted-foreground">72%</span>
                  </div>
                </div>
                <div className="flex items-center justify-between">
                  <span className="text-sm">11:00 AM - 12:00 PM</span>
                  <div className="flex items-center space-x-2">
                    <div className="w-24 bg-gray-200 rounded-full h-2">
                      <div className="bg-primary h-2 rounded-full" style={{ width: "68%" }}></div>
                    </div>
                    <span className="text-sm text-muted-foreground">68%</span>
                  </div>
                </div>
              </div>
            </CardContent>
          </Card>

          <Card>
            <CardHeader>
              <CardTitle>Recent Trends</CardTitle>
              <CardDescription>Key insights and changes</CardDescription>
            </CardHeader>
            <CardContent>
              <div className="space-y-4">
                <div className="flex items-start space-x-3">
                  <div className="w-2 h-2 bg-green-500 rounded-full mt-2"></div>
                  <div>
                    <p className="text-sm font-medium">Online appointments increased</p>
                    <p className="text-xs text-muted-foreground">65% of appointments now booked online (+15%)</p>
                  </div>
                </div>
                <div className="flex items-start space-x-3">
                  <div className="w-2 h-2 bg-blue-500 rounded-full mt-2"></div>
                  <div>
                    <p className="text-sm font-medium">New service categories added</p>
                    <p className="text-xs text-muted-foreground">Environmental services now available</p>
                  </div>
                </div>
                <div className="flex items-start space-x-3">
                  <div className="w-2 h-2 bg-yellow-500 rounded-full mt-2"></div>
                  <div>
                    <p className="text-sm font-medium">Wait times reduced</p>
                    <p className="text-xs text-muted-foreground">Average wait time down by 13% this month</p>
                  </div>
                </div>
                <div className="flex items-start space-x-3">
                  <div className="w-2 h-2 bg-purple-500 rounded-full mt-2"></div>
                  <div>
                    <p className="text-sm font-medium">Customer satisfaction up</p>
                    <p className="text-xs text-muted-foreground">Overall rating improved to 4.7/5 stars</p>
                  </div>
                </div>
              </div>
            </CardContent>
          </Card>
        </div>
      </div>
    </div>
  )
}

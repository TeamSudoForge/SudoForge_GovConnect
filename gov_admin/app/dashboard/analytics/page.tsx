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
  { date: "Mon", appointments: 7, completed: 6, cancelled: 1 },
  { date: "Tue", appointments: 9, completed: 8, cancelled: 1 },
  { date: "Wed", appointments: 5, completed: 5, cancelled: 0 },
  { date: "Thu", appointments: 11, completed: 10, cancelled: 1 },
  { date: "Fri", appointments: 13, completed: 12, cancelled: 1 },
  { date: "Sat", appointments: 4, completed: 4, cancelled: 0 },
  { date: "Sun", appointments: 2, completed: 2, cancelled: 0 },
]

const monthlyData = [
  { month: "Jan", appointments: 145, certificates: 98, applications: 156 },
  { month: "Feb", appointments: 162, certificates: 112, applications: 178 },
  { month: "Mar", appointments: 134, certificates: 89, applications: 145 },
  { month: "Apr", appointments: 156, certificates: 105, applications: 167 },
  { month: "May", appointments: 189, certificates: 134, applications: 201 },
  { month: "Jun", appointments: 167, certificates: 118, applications: 178 },
  { month: "Jul", appointments: 178, certificates: 125, applications: 189 },
  { month: "Aug", appointments: 203, certificates: 145, applications: 234 },
  { month: "Sep", appointments: 189, certificates: 134, applications: 212 },
  { month: "Oct", appointments: 198, certificates: 142, applications: 223 },
  { month: "Nov", appointments: 212, certificates: 156, applications: 245 },
  { month: "Dec", appointments: 187, certificates: 134, applications: 198 },
]

const certificateDistribution = [
  { name: "Character Certificates", value: 45, color: "#0088FE" },
  { name: "Income Certificates", value: 25, color: "#00C49F" },
  { name: "Residence Certificates", value: 20, color: "#FFBB28" },
  { name: "Birth Certificate Verifications", value: 7, color: "#FF8042" },
  { name: "Other Documents", value: 3, color: "#8884D8" },
]

const weeklyPerformance = [
  { week: "Week 1", certificates: 28, appointments: 32, satisfaction: 4.7, avgTime: 18 },
  { week: "Week 2", certificates: 35, appointments: 38, satisfaction: 4.8, avgTime: 16 },
  { week: "Week 3", certificates: 22, appointments: 29, satisfaction: 4.6, avgTime: 20 },
  { week: "Week 4", certificates: 31, appointments: 35, satisfaction: 4.9, avgTime: 15 },
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
    certificates: {
      label: "Certificates",
      color: "hsl(var(--chart-4))",
    },
    applications: {
      label: "Applications",
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
                <h1 className="text-xl font-bold text-foreground">GN Division Analytics</h1>
                <p className="text-sm text-muted-foreground">Track certificates, appointments and citizen services</p>
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
              <CardTitle className="text-sm font-medium">Total Certificates Issued</CardTitle>
              <Calendar className="h-4 w-4 text-muted-foreground" />
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold">134</div>
              <div className="flex items-center text-xs text-muted-foreground">
                <TrendingUp className="h-3 w-3 mr-1 text-green-500" />
                +8.1% from last month
              </div>
            </CardContent>
          </Card>

          <Card>
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle className="text-sm font-medium">Completion Rate</CardTitle>
              <Clock className="h-4 w-4 text-muted-foreground" />
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold">94.2%</div>
              <div className="flex items-center text-xs text-muted-foreground">
                <TrendingUp className="h-3 w-3 mr-1 text-green-500" />
                +2.3% from last month
              </div>
            </CardContent>
          </Card>

          <Card>
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle className="text-sm font-medium">Pending Applications</CardTitle>
              <FileText className="h-4 w-4 text-muted-foreground" />
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold">12</div>
              <div className="flex items-center text-xs text-muted-foreground">
                <TrendingDown className="h-3 w-3 mr-1 text-green-500" />
                -3 from yesterday
              </div>
            </CardContent>
          </Card>

          <Card>
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle className="text-sm font-medium">Avg. Wait Time</CardTitle>
              <Clock className="h-4 w-4 text-muted-foreground" />
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold">18 min</div>
              <div className="flex items-center text-xs text-muted-foreground">
                <TrendingDown className="h-3 w-3 mr-1 text-green-500" />
                -2.5 min from last month
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
                    <LineChart data={dailyData}>
                      <CartesianGrid strokeDasharray="3 3" />
                      <XAxis dataKey="date" />
                      <YAxis />
                      <Line type="monotone" dataKey="appointments" stroke="#0088FE" strokeWidth={3} />
                      <Line type="monotone" dataKey="completed" stroke="#00C49F" strokeWidth={3} />
                    </LineChart>
                  ) : (
                    <LineChart data={monthlyData}>
                      <CartesianGrid strokeDasharray="3 3" />
                      <XAxis dataKey="month" />
                      <YAxis />
                      <Line type="monotone" dataKey="appointments" stroke="#0088FE" strokeWidth={3} />
                      <Line type="monotone" dataKey="certificates" stroke="#FFBB28" strokeWidth={3} />
                    </LineChart>
                  )}
                </ResponsiveContainer>
              </ChartContainer>
            </CardContent>
          </Card>

          {/* Certificate Distribution */}
          <Card>
            <CardHeader>
              <CardTitle>Certificate Distribution</CardTitle>
              <CardDescription>Breakdown of certificates issued this month</CardDescription>
            </CardHeader>
            <CardContent>
              <ChartContainer config={chartConfig}>
                <ResponsiveContainer width="100%" height={300}>
                  <PieChart>
                    <Pie
                      data={certificateDistribution}
                      cx="50%"
                      cy="50%"
                      outerRadius={80}
                      dataKey="value"
                      label={({ name, percent }) => `${name} ${((percent ?? 0) * 100).toFixed(0)}%`}
                    >
                      {certificateDistribution.map((entry, index) => (
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

        {/* Weekly Performance */}
        <Card className="mb-8">
          <CardHeader>
            <CardTitle>Weekly Performance</CardTitle>
            <CardDescription>GN Division performance over the past month</CardDescription>
          </CardHeader>
          <CardContent>
            <div className="overflow-x-auto">
              <table className="w-full">
                <thead>
                  <tr className="border-b">
                    <th className="text-left py-3 px-4 font-medium">Week</th>
                    <th className="text-left py-3 px-4 font-medium">Certificates Issued</th>
                    <th className="text-left py-3 px-4 font-medium">Appointments</th>
                    <th className="text-left py-3 px-4 font-medium">Satisfaction</th>
                    <th className="text-left py-3 px-4 font-medium">Avg. Time (min)</th>
                  </tr>
                </thead>
                <tbody>
                  {weeklyPerformance.map((week, index) => (
                    <tr key={index} className="border-b">
                      <td className="py-3 px-4 font-medium">{week.week}</td>
                      <td className="py-3 px-4">{week.certificates}</td>
                      <td className="py-3 px-4">{week.appointments}</td>
                      <td className="py-3 px-4">
                        <div className="flex items-center">
                          <span className="mr-2">{week.satisfaction}</span>
                          <div className="flex">
                            {[...Array(5)].map((_, i) => (
                              <span
                                key={i}
                                className={`text-xs ${
                                  i < Math.floor(week.satisfaction) ? "text-yellow-400" : "text-gray-300"
                                }`}
                              >
                                ★
                              </span>
                            ))}
                          </div>
                        </div>
                      </td>
                      <td className="py-3 px-4">{week.avgTime}</td>
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
                    <p className="text-sm font-medium">Digital submissions increased</p>
                    <p className="text-xs text-muted-foreground">78% of applications now submitted online (+23%)</p>
                  </div>
                </div>
                <div className="flex items-start space-x-3">
                  <div className="w-2 h-2 bg-blue-500 rounded-full mt-2"></div>
                  <div>
                    <p className="text-sm font-medium">Character certificates most requested</p>
                    <p className="text-xs text-muted-foreground">45% of all certificate requests</p>
                  </div>
                </div>
                <div className="flex items-start space-x-3">
                  <div className="w-2 h-2 bg-yellow-500 rounded-full mt-2"></div>
                  <div>
                    <p className="text-sm font-medium">Processing time improved</p>
                    <p className="text-xs text-muted-foreground">Average processing time down to 24 hours</p>
                  </div>
                </div>
                <div className="flex items-start space-x-3">
                  <div className="w-2 h-2 bg-purple-500 rounded-full mt-2"></div>
                  <div>
                    <p className="text-sm font-medium">Citizen satisfaction high</p>
                    <p className="text-xs text-muted-foreground">4.8/5 average rating for GN services</p>
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

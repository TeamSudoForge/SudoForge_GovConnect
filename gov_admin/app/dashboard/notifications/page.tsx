"use client"

import { useState } from "react"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Textarea } from "@/components/ui/textarea"
import { Badge } from "@/components/ui/badge"
import { Label } from "@/components/ui/label"
import { Switch } from "@/components/ui/switch"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import { Checkbox } from "@/components/ui/checkbox"
import {
  Bell,
  Mail,
  MessageSquare,
  Send,
  Clock,
  CheckCircle2,
  AlertCircle,
  User,
  Users,
  Calendar,
  Filter,
  Search,
  Settings,
  Smartphone,
  Plus
} from "lucide-react"

// Mock data
const notificationTemplates = [
  {
    id: 1,
    name: "Certificate Ready",
    type: "email",
    subject: "Your {{certificateType}} is Ready for Collection",
    content: "Dear {{citizenName}}, Your {{certificateType}} has been approved and is ready for collection. Please visit the Grama Niladhari office during working hours (9 AM - 5 PM) with your NIC."
  },
  {
    id: 2,
    name: "Document Issue",
    type: "sms",
    subject: "Document Correction Required",
    content: "Your {{documentType}} submission requires correction. Issue: {{issue}}. Please check your email for details. - GN Colombo 10"
  },
  {
    id: 3,
    name: "Appointment Reminder",
    type: "both",
    subject: "Appointment Reminder - Tomorrow {{time}}",
    content: "Dear {{citizenName}}, This is a reminder of your appointment tomorrow at {{time}} for {{service}}. Please bring all required documents."
  }
]

const recentNotifications = [
  {
    id: 1,
    recipient: "Kamal Perera",
    type: "email",
    template: "Certificate Ready",
    status: "delivered",
    timestamp: "10 min ago",
    channel: "email"
  },
  {
    id: 2,
    recipient: "Seetha Fernando",
    type: "sms",
    template: "Document Issue",
    status: "pending",
    timestamp: "30 min ago",
    channel: "sms"
  },
  {
    id: 3,
    recipient: "Multiple (15)",
    type: "broadcast",
    template: "Office Hours Change",
    status: "delivered",
    timestamp: "2 hours ago",
    channel: "both"
  }
]

export default function NotificationsPage() {
  const [selectedTemplate, setSelectedTemplate] = useState(notificationTemplates[0])
  const [notificationType, setNotificationType] = useState("individual")
  const [selectedChannel, setSelectedChannel] = useState("email")
  const [customMessage, setCustomMessage] = useState("")
  const [selectedCitizens, setSelectedCitizens] = useState<string[]>([])

  return (
    <div className="min-h-screen bg-background">
      {/* Header */}
      <header className="border-b border-border bg-card">
        <div className="container mx-auto px-4 py-4">
          <div className="flex items-center justify-between">
            <div>
              <h1 className="text-xl font-bold text-foreground">Notification Management</h1>
              <p className="text-sm text-muted-foreground">Send email and SMS notifications to citizens</p>
            </div>
            <div className="flex items-center gap-2">
              <Badge variant="outline" className="bg-green-50 text-green-700 border-green-200">
                <CheckCircle2 className="h-3 w-3 mr-1" />
                245 Sent Today
              </Badge>
              <Badge variant="outline" className="bg-orange-50 text-orange-700 border-orange-200">
                <Clock className="h-3 w-3 mr-1" />
                3 Scheduled
              </Badge>
            </div>
          </div>
        </div>
      </header>

      <div className="container mx-auto px-4 py-6">
        <Tabs defaultValue="send" className="space-y-6">
          <TabsList className="grid w-full grid-cols-3 max-w-xl">
            <TabsTrigger value="send">Send Notification</TabsTrigger>
            <TabsTrigger value="templates">Templates</TabsTrigger>
            <TabsTrigger value="history">History</TabsTrigger>
          </TabsList>

          <TabsContent value="send" className="space-y-6">
            <div className="grid lg:grid-cols-3 gap-6">
              {/* Notification Setup */}
              <div className="lg:col-span-2 space-y-6">
                <Card>
                  <CardHeader>
                    <CardTitle>Create Notification</CardTitle>
                    <CardDescription>Send notifications to citizens via email or SMS</CardDescription>
                  </CardHeader>
                  <CardContent className="space-y-6">
                    {/* Notification Type */}
                    <div className="space-y-3">
                      <Label>Notification Type</Label>
                      <div className="grid grid-cols-3 gap-3">
                        <Button
                          variant={notificationType === "individual" ? "default" : "outline"}
                          onClick={() => setNotificationType("individual")}
                          className="justify-start"
                        >
                          <User className="h-4 w-4 mr-2" />
                          Individual
                        </Button>
                        <Button
                          variant={notificationType === "group" ? "default" : "outline"}
                          onClick={() => setNotificationType("group")}
                          className="justify-start"
                        >
                          <Users className="h-4 w-4 mr-2" />
                          Group
                        </Button>
                        <Button
                          variant={notificationType === "broadcast" ? "default" : "outline"}
                          onClick={() => setNotificationType("broadcast")}
                          className="justify-start"
                        >
                          <Bell className="h-4 w-4 mr-2" />
                          Broadcast
                        </Button>
                      </div>
                    </div>

                    {/* Recipients */}
                    {notificationType === "individual" && (
                      <div className="space-y-3">
                        <Label>Recipient</Label>
                        <Select>
                          <SelectTrigger>
                            <SelectValue placeholder="Search citizen by name or NIC" />
                          </SelectTrigger>
                          <SelectContent>
                            <SelectItem value="891234567V">Kamal Perera - 891234567V</SelectItem>
                            <SelectItem value="925678901V">Seetha Fernando - 925678901V</SelectItem>
                            <SelectItem value="783456789V">Ranjith Silva - 783456789V</SelectItem>
                          </SelectContent>
                        </Select>
                      </div>
                    )}

                    {notificationType === "group" && (
                      <div className="space-y-3">
                        <Label>Select Group</Label>
                        <Select>
                          <SelectTrigger>
                            <SelectValue placeholder="Choose a group" />
                          </SelectTrigger>
                          <SelectContent>
                            <SelectItem value="pending-docs">Pending Document Submissions</SelectItem>
                            <SelectItem value="tomorrow-appointments">Tomorrow's Appointments</SelectItem>
                            <SelectItem value="certificate-ready">Certificates Ready for Collection</SelectItem>
                          </SelectContent>
                        </Select>
                      </div>
                    )}

                    {/* Channel Selection */}
                    <div className="space-y-3">
                      <Label>Notification Channel</Label>
                      <div className="grid grid-cols-3 gap-3">
                        <Button
                          variant={selectedChannel === "email" ? "default" : "outline"}
                          onClick={() => setSelectedChannel("email")}
                          className="justify-start"
                        >
                          <Mail className="h-4 w-4 mr-2" />
                          Email
                        </Button>
                        <Button
                          variant={selectedChannel === "sms" ? "default" : "outline"}
                          onClick={() => setSelectedChannel("sms")}
                          className="justify-start"
                        >
                          <Smartphone className="h-4 w-4 mr-2" />
                          SMS
                        </Button>
                        <Button
                          variant={selectedChannel === "both" ? "default" : "outline"}
                          onClick={() => setSelectedChannel("both")}
                          className="justify-start"
                        >
                          <MessageSquare className="h-4 w-4 mr-2" />
                          Both
                        </Button>
                      </div>
                    </div>

                    {/* Template Selection */}
                    <div className="space-y-3">
                      <Label>Message Template</Label>
                      <Select
                        value={selectedTemplate.id.toString()}
                        onValueChange={(value) => {
                          const template = notificationTemplates.find(t => t.id.toString() === value)
                          if (template) setSelectedTemplate(template)
                        }}
                      >
                        <SelectTrigger>
                          <SelectValue />
                        </SelectTrigger>
                        <SelectContent>
                          {notificationTemplates.map((template) => (
                            <SelectItem key={template.id} value={template.id.toString()}>
                              {template.name}
                            </SelectItem>
                          ))}
                        </SelectContent>
                      </Select>
                    </div>

                    {/* Message Preview */}
                    <div className="space-y-3">
                      <Label>Message Content</Label>
                      {selectedChannel !== "sms" && (
                        <Input
                          placeholder="Subject"
                          defaultValue={selectedTemplate.subject}
                          className="mb-3"
                        />
                      )}
                      <Textarea
                        placeholder="Message content"
                        defaultValue={selectedTemplate.content}
                        className="min-h-[120px]"
                      />
                      <p className="text-xs text-muted-foreground">
                        Variables: {`{{citizenName}}, {{certificateType}}, {{time}}, etc.`}
                      </p>
                    </div>

                    {/* Schedule Option */}
                    <div className="flex items-center justify-between p-4 border rounded-lg">
                      <div className="space-y-1">
                        <Label>Schedule for later</Label>
                        <p className="text-sm text-muted-foreground">Send this notification at a specific time</p>
                      </div>
                      <Switch />
                    </div>
                  </CardContent>
                </Card>
              </div>

              {/* Preview Panel */}
              <div className="lg:col-span-1">
                <Card>
                  <CardHeader>
                    <CardTitle>Preview</CardTitle>
                    <CardDescription>See how your notification will appear</CardDescription>
                  </CardHeader>
                  <CardContent>
                    {selectedChannel === "email" || selectedChannel === "both" ? (
                      <div className="space-y-3">
                        <div className="p-4 border rounded-lg bg-muted/20">
                          <p className="text-xs text-muted-foreground mb-2">EMAIL PREVIEW</p>
                          <div className="space-y-2">
                            <p className="font-medium text-sm">Subject: Your Character Certificate is Ready for Collection</p>
                            <div className="text-sm space-y-2">
                              <p>Dear Kamal Perera,</p>
                              <p>Your Character Certificate has been approved and is ready for collection. Please visit the Grama Niladhari office during working hours (9 AM - 5 PM) with your NIC.</p>
                              <p className="text-muted-foreground">GN Division - Colombo 10</p>
                            </div>
                          </div>
                        </div>
                      </div>
                    ) : null}

                    {selectedChannel === "sms" || selectedChannel === "both" ? (
                      <div className="space-y-3 mt-4">
                        <div className="p-4 border rounded-lg bg-muted/20">
                          <p className="text-xs text-muted-foreground mb-2">SMS PREVIEW</p>
                          <div className="text-sm">
                            <p>Your Character Certificate is ready for collection. Visit GN office (9AM-5PM) with NIC. - GN Colombo 10</p>
                            <p className="text-xs text-muted-foreground mt-2">Characters: 98/160</p>
                          </div>
                        </div>
                      </div>
                    ) : null}

                    <div className="mt-6 space-y-3">
                      <Button className="w-full">
                        <Send className="h-4 w-4 mr-2" />
                        Send Notification
                      </Button>
                      <Button variant="outline" className="w-full">
                        Save as Draft
                      </Button>
                    </div>
                  </CardContent>
                </Card>
              </div>
            </div>
          </TabsContent>

          <TabsContent value="templates" className="space-y-6">
            <Card>
              <CardHeader>
                <div className="flex items-center justify-between">
                  <div>
                    <CardTitle>Notification Templates</CardTitle>
                    <CardDescription>Manage reusable notification templates</CardDescription>
                  </div>
                  <Button>
                    <Plus className="h-4 w-4 mr-2" />
                    New Template
                  </Button>
                </div>
              </CardHeader>
              <CardContent>
                <div className="space-y-4">
                  {notificationTemplates.map((template) => (
                    <div key={template.id} className="p-4 border rounded-lg space-y-3">
                      <div className="flex items-start justify-between">
                        <div>
                          <h4 className="font-medium">{template.name}</h4>
                          <p className="text-sm text-muted-foreground">{template.subject}</p>
                        </div>
                        <div className="flex items-center gap-2">
                          <Badge variant="outline">
                            {template.type === "email" && <Mail className="h-3 w-3 mr-1" />}
                            {template.type === "sms" && <Smartphone className="h-3 w-3 mr-1" />}
                            {template.type === "both" && <MessageSquare className="h-3 w-3 mr-1" />}
                            {template.type}
                          </Badge>
                          <Button variant="outline" size="sm">Edit</Button>
                        </div>
                      </div>
                      <p className="text-sm text-muted-foreground">{template.content}</p>
                    </div>
                  ))}
                </div>
              </CardContent>
            </Card>
          </TabsContent>

          <TabsContent value="history" className="space-y-6">
            <Card>
              <CardHeader>
                <div className="flex items-center justify-between">
                  <div>
                    <CardTitle>Notification History</CardTitle>
                    <CardDescription>Track sent notifications and their status</CardDescription>
                  </div>
                  <div className="flex gap-2">
                    <Button variant="outline" size="sm">
                      <Filter className="h-4 w-4 mr-1" />
                      Filter
                    </Button>
                    <Button variant="outline" size="sm">
                      Export
                    </Button>
                  </div>
                </div>
              </CardHeader>
              <CardContent>
                <div className="space-y-4">
                  {recentNotifications.map((notif) => (
                    <div key={notif.id} className="flex items-center justify-between p-4 border rounded-lg">
                      <div className="flex items-center gap-4">
                        <div className={`w-10 h-10 rounded-full flex items-center justify-center ${
                          notif.channel === "email" ? "bg-blue-100" : "bg-green-100"
                        }`}>
                          {notif.channel === "email" ? (
                            <Mail className="h-5 w-5 text-blue-600" />
                          ) : notif.channel === "sms" ? (
                            <Smartphone className="h-5 w-5 text-green-600" />
                          ) : (
                            <MessageSquare className="h-5 w-5 text-purple-600" />
                          )}
                        </div>
                        <div>
                          <p className="font-medium">{notif.recipient}</p>
                          <p className="text-sm text-muted-foreground">{notif.template}</p>
                        </div>
                      </div>
                      <div className="flex items-center gap-3">
                        <Badge variant={notif.status === "delivered" ? "default" : "secondary"}>
                          {notif.status === "delivered" ? (
                            <CheckCircle2 className="h-3 w-3 mr-1" />
                          ) : (
                            <Clock className="h-3 w-3 mr-1" />
                          )}
                          {notif.status}
                        </Badge>
                        <span className="text-sm text-muted-foreground">{notif.timestamp}</span>
                      </div>
                    </div>
                  ))}
                </div>
              </CardContent>
            </Card>
          </TabsContent>
        </Tabs>
      </div>
    </div>
  )
}
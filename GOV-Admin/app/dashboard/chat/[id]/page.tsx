"use client"

import type React from "react"

import { useState, useRef, useEffect } from "react"
import Link from "next/link"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Textarea } from "@/components/ui/textarea"
import { Badge } from "@/components/ui/badge"
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"
import { ThemeToggle } from "@/components/theme-toggle"
import { ArrowLeft, Send, Paperclip, Phone, Mail, User, Calendar, FileText } from "lucide-react"
import { useParams } from "next/navigation"

// Mock data for individual conversation
const conversationData = {
  id: 1,
  citizenName: "John Doe",
  citizenEmail: "john.doe@email.com",
  citizenPhone: "+1 (555) 123-4567",
  service: "Health Certificate Application",
  status: "active",
  avatar: "/generic-person.png",
  appointmentDate: "2024-01-25",
  applicationId: "HC-2024-001234",
}

const messages = [
  {
    id: 1,
    sender: "citizen",
    message:
      "Hello, I submitted my health certificate application last week. Could you please provide an update on the status?",
    timestamp: "2024-01-20 09:15",
    type: "text",
  },
  {
    id: 2,
    sender: "officer",
    message:
      "Hello John! Thank you for reaching out. I've reviewed your application HC-2024-001234. Your documents have been processed and are currently under medical review.",
    timestamp: "2024-01-20 10:30",
    type: "text",
  },
  {
    id: 3,
    sender: "officer",
    message:
      "The estimated processing time is 3-5 business days from the medical review date. You should receive your certificate by January 25th.",
    timestamp: "2024-01-20 10:32",
    type: "text",
  },
  {
    id: 4,
    sender: "citizen",
    message:
      "That's great! I have an appointment scheduled for January 25th. Will I be able to pick up the certificate during that appointment?",
    timestamp: "2024-01-20 14:20",
    type: "text",
  },
  {
    id: 5,
    sender: "officer",
    message:
      "Yes, absolutely! Your certificate will be ready for pickup during your appointment on January 25th at 2:00 PM. Please bring a valid ID for verification.",
    timestamp: "2024-01-20 15:45",
    type: "text",
  },
  {
    id: 6,
    sender: "citizen",
    message: "Perfect! One more question - do I need to bring any additional documents for the pickup?",
    timestamp: "2024-01-22 11:10",
    type: "text",
  },
  {
    id: 7,
    sender: "citizen",
    message: "Thank you for the update. When can I expect the certificate?",
    timestamp: "2024-01-22 16:30",
    type: "text",
  },
]

export default function ChatConversationPage() {
  const params = useParams()
  const [newMessage, setNewMessage] = useState("")
  const [chatMessages, setChatMessages] = useState(messages)
  const messagesEndRef = useRef<HTMLDivElement>(null)

  const scrollToBottom = () => {
    messagesEndRef.current?.scrollIntoView({ behavior: "smooth" })
  }

  useEffect(() => {
    scrollToBottom()
  }, [chatMessages])

  const handleSendMessage = (e: React.FormEvent) => {
    e.preventDefault()
    if (newMessage.trim()) {
      const message = {
        id: chatMessages.length + 1,
        sender: "officer" as const,
        message: newMessage,
        timestamp: new Date().toLocaleString(),
        type: "text" as const,
      }
      setChatMessages([...chatMessages, message])
      setNewMessage("")
    }
  }

  const getStatusColor = (status: string) => {
    switch (status) {
      case "active":
        return "bg-green-100 text-green-800"
      case "pending":
        return "bg-yellow-100 text-yellow-800"
      case "resolved":
        return "bg-blue-100 text-blue-800"
      default:
        return "bg-gray-100 text-gray-800"
    }
  }

  return (
    <div className="min-h-screen bg-background flex flex-col">
      {/* Header */}
      <header className="border-b border-border bg-card">
        <div className="container mx-auto px-4 py-4 flex items-center justify-between">
          <div className="flex items-center space-x-4">
            <Link href="/dashboard/chat" className="flex items-center text-muted-foreground hover:text-foreground">
              <ArrowLeft className="h-4 w-4 mr-1" />
              Chat
            </Link>
            <div className="flex items-center space-x-3">
              <Avatar className="h-10 w-10">
                <AvatarImage src={conversationData.avatar || "/placeholder.svg"} alt={conversationData.citizenName} />
                <AvatarFallback>
                  {conversationData.citizenName
                    .split(" ")
                    .map((n) => n[0])
                    .join("")}
                </AvatarFallback>
              </Avatar>
              <div>
                <h1 className="text-xl font-bold text-foreground">{conversationData.citizenName}</h1>
                <p className="text-sm text-muted-foreground">{conversationData.service}</p>
              </div>
              <Badge className={getStatusColor(conversationData.status)}>{conversationData.status}</Badge>
            </div>
          </div>
          <div className="flex items-center space-x-4">
            <Button variant="outline" size="sm">
              <Phone className="h-4 w-4 mr-2" />
              Call
            </Button>
          </div>
        </div>
      </header>

      <div className="flex-1 container mx-auto px-4 py-6 grid lg:grid-cols-4 gap-6">
        {/* Chat Messages */}
        <div className="lg:col-span-3 flex flex-col">
          <Card className="flex-1 flex flex-col">
            <CardHeader>
              <CardTitle className="text-lg">Conversation</CardTitle>
            </CardHeader>
            <CardContent className="flex-1 flex flex-col">
              {/* Messages Container */}
              <div className="flex-1 overflow-y-auto space-y-4 mb-4 max-h-96">
                {chatMessages.map((msg) => (
                  <div key={msg.id} className={`flex ${msg.sender === "officer" ? "justify-end" : "justify-start"}`}>
                    <div
                      className={`max-w-xs lg:max-w-md px-4 py-2 rounded-lg ${
                        msg.sender === "officer"
                          ? "bg-primary text-primary-foreground"
                          : "bg-muted text-muted-foreground"
                      }`}
                    >
                      <p className="text-sm">{msg.message}</p>
                      <p
                        className={`text-xs mt-1 ${
                          msg.sender === "officer" ? "text-primary-foreground/70" : "text-muted-foreground/70"
                        }`}
                      >
                        {msg.timestamp}
                      </p>
                    </div>
                  </div>
                ))}
                <div ref={messagesEndRef} />
              </div>

              {/* Message Input */}
              <form onSubmit={handleSendMessage} className="flex space-x-2">
                <Textarea
                  placeholder="Type your message..."
                  value={newMessage}
                  onChange={(e) => setNewMessage(e.target.value)}
                  className="flex-1 min-h-[60px] resize-none"
                  onKeyDown={(e) => {
                    if (e.key === "Enter" && !e.shiftKey) {
                      e.preventDefault()
                      handleSendMessage(e)
                    }
                  }}
                />
                <div className="flex flex-col space-y-2">
                  <Button type="button" variant="outline" size="icon">
                    <Paperclip className="h-4 w-4" />
                  </Button>
                  <Button type="submit" size="icon">
                    <Send className="h-4 w-4" />
                  </Button>
                </div>
              </form>
            </CardContent>
          </Card>
        </div>

        {/* Citizen Information Sidebar */}
        <div className="space-y-6">
          {/* Contact Information */}
          <Card>
            <CardHeader>
              <CardTitle className="text-lg">Contact Information</CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="flex items-center space-x-3">
                <User className="h-4 w-4 text-muted-foreground" />
                <div>
                  <p className="font-medium">{conversationData.citizenName}</p>
                  <p className="text-sm text-muted-foreground">Citizen</p>
                </div>
              </div>

              <div className="flex items-center space-x-3">
                <Mail className="h-4 w-4 text-muted-foreground" />
                <div>
                  <p className="text-sm">{conversationData.citizenEmail}</p>
                </div>
              </div>

              <div className="flex items-center space-x-3">
                <Phone className="h-4 w-4 text-muted-foreground" />
                <div>
                  <p className="text-sm">{conversationData.citizenPhone}</p>
                </div>
              </div>
            </CardContent>
          </Card>

          {/* Service Information */}
          <Card>
            <CardHeader>
              <CardTitle className="text-lg">Service Details</CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="flex items-center space-x-3">
                <FileText className="h-4 w-4 text-muted-foreground" />
                <div>
                  <p className="font-medium">{conversationData.service}</p>
                  <p className="text-sm text-muted-foreground">Application ID: {conversationData.applicationId}</p>
                </div>
              </div>

              <div className="flex items-center space-x-3">
                <Calendar className="h-4 w-4 text-muted-foreground" />
                <div>
                  <p className="text-sm">Appointment: {conversationData.appointmentDate}</p>
                  <p className="text-sm text-muted-foreground">2:00 PM</p>
                </div>
              </div>
            </CardContent>
          </Card>

          {/* Quick Actions */}
          <Card>
            <CardHeader>
              <CardTitle className="text-lg">Quick Actions</CardTitle>
            </CardHeader>
            <CardContent className="space-y-2">
              <Button variant="outline" className="w-full justify-start bg-transparent">
                <Calendar className="h-4 w-4 mr-2" />
                Schedule Appointment
              </Button>
              <Button variant="outline" className="w-full justify-start bg-transparent">
                <FileText className="h-4 w-4 mr-2" />
                View Application
              </Button>
              <Button variant="outline" className="w-full justify-start bg-transparent">
                <Phone className="h-4 w-4 mr-2" />
                Make Call
              </Button>
            </CardContent>
          </Card>

          {/* Conversation Status */}
          <Card>
            <CardHeader>
              <CardTitle className="text-lg">Status</CardTitle>
            </CardHeader>
            <CardContent>
              <div className="space-y-3">
                <div className="flex justify-between items-center">
                  <span className="text-sm">Current Status</span>
                  <Badge className={getStatusColor(conversationData.status)}>{conversationData.status}</Badge>
                </div>
                <div className="space-y-2">
                  <Button variant="outline" size="sm" className="w-full bg-transparent">
                    Mark as Resolved
                  </Button>
                  <Button variant="outline" size="sm" className="w-full bg-transparent">
                    Transfer to Supervisor
                  </Button>
                </div>
              </div>
            </CardContent>
          </Card>
        </div>
      </div>
    </div>
  )
}

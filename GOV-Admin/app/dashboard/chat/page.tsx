"use client"

import { useState } from "react"
import Link from "next/link"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Badge } from "@/components/ui/badge"
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"
import { ThemeToggle } from "@/components/theme-toggle"
import { MessageSquare, ArrowLeft, Search, Plus, Clock, Phone, Mail } from "lucide-react"

// Mock data for chat conversations
const conversations = [
  {
    id: 1,
    citizenName: "John Doe",
    citizenEmail: "john.doe@email.com",
    citizenPhone: "+1 (555) 123-4567",
    service: "Health Certificate Application",
    lastMessage: "Thank you for the update. When can I expect the certificate?",
    timestamp: "2 min ago",
    unreadCount: 2,
    status: "active",
    avatar: "/generic-person.png",
  },
  {
    id: 2,
    citizenName: "Sarah Johnson",
    citizenEmail: "sarah.j@email.com",
    citizenPhone: "+1 (555) 234-5678",
    service: "Driver's License Renewal",
    lastMessage: "I have uploaded the required documents as requested.",
    timestamp: "15 min ago",
    unreadCount: 0,
    status: "active",
    avatar: "/generic-person.png",
  },
  {
    id: 3,
    citizenName: "Mike Chen",
    citizenEmail: "mike.chen@email.com",
    citizenPhone: "+1 (555) 345-6789",
    service: "Business License Application",
    lastMessage: "Could you please clarify the zoning requirements?",
    timestamp: "1 hour ago",
    unreadCount: 1,
    status: "pending",
    avatar: "/mike-chen-portrait.png",
  },
  {
    id: 4,
    citizenName: "Lisa Rodriguez",
    citizenEmail: "lisa.r@email.com",
    citizenPhone: "+1 (555) 456-7890",
    service: "Property Tax Assessment",
    lastMessage: "Perfect! Thank you for your assistance.",
    timestamp: "2 hours ago",
    unreadCount: 0,
    status: "resolved",
    avatar: "/portrait-woman.png",
  },
  {
    id: 5,
    citizenName: "David Wilson",
    citizenEmail: "david.w@email.com",
    citizenPhone: "+1 (555) 567-8901",
    service: "Health Certificate Application",
    lastMessage: "I need to reschedule my appointment for next week.",
    timestamp: "3 hours ago",
    unreadCount: 3,
    status: "active",
    avatar: "/abstract-figure.png",
  },
]

export default function ChatPage() {
  const [searchTerm, setSearchTerm] = useState("")
  const [statusFilter, setStatusFilter] = useState("all")

  const filteredConversations = conversations.filter((conv) => {
    const matchesSearch =
      conv.citizenName.toLowerCase().includes(searchTerm.toLowerCase()) ||
      conv.service.toLowerCase().includes(searchTerm.toLowerCase()) ||
      conv.citizenEmail.toLowerCase().includes(searchTerm.toLowerCase())
    const matchesStatus = statusFilter === "all" || conv.status === statusFilter

    return matchesSearch && matchesStatus
  })

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

  const totalUnread = conversations.reduce((sum, conv) => sum + conv.unreadCount, 0)
  const activeChats = conversations.filter((conv) => conv.status === "active").length
  const pendingChats = conversations.filter((conv) => conv.status === "pending").length

  return (
    <div className="min-h-screen bg-background">
      {/* Header */}
      <header className="border-b border-border bg-card">
        <div className="container mx-auto px-4 py-4 flex items-center justify-between">
          <div className="flex items-center space-x-4">
            <div className="flex items-center space-x-2">
              <MessageSquare className="h-8 w-8 text-primary" />
              <div>
                <h1 className="text-xl font-bold text-foreground">Chat & Communication</h1>
                <p className="text-sm text-muted-foreground">Communicate with citizens and applicants</p>
              </div>
            </div>
          </div>
          <div className="flex items-center space-x-4">
            <Button>
              <Plus className="h-4 w-4 mr-2" />
              New Chat
            </Button>
          </div>
        </div>
      </header>

      <div className="container mx-auto px-4 py-8">
        {/* Stats Cards */}
        <div className="grid md:grid-cols-4 gap-4 mb-6">
          <Card>
            <CardContent className="p-4">
              <div className="text-2xl font-bold text-foreground">{totalUnread}</div>
              <p className="text-sm text-muted-foreground">Unread Messages</p>
            </CardContent>
          </Card>
          <Card>
            <CardContent className="p-4">
              <div className="text-2xl font-bold text-green-600">{activeChats}</div>
              <p className="text-sm text-muted-foreground">Active Conversations</p>
            </CardContent>
          </Card>
          <Card>
            <CardContent className="p-4">
              <div className="text-2xl font-bold text-yellow-600">{pendingChats}</div>
              <p className="text-sm text-muted-foreground">Pending Response</p>
            </CardContent>
          </Card>
          <Card>
            <CardContent className="p-4">
              <div className="text-2xl font-bold text-primary">4.8</div>
              <p className="text-sm text-muted-foreground">Avg Response Time (hrs)</p>
            </CardContent>
          </Card>
        </div>

        {/* Search and Filters */}
        <div className="flex flex-col sm:flex-row gap-4 mb-6">
          <div className="relative flex-1">
            <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-muted-foreground h-4 w-4" />
            <Input
              placeholder="Search conversations..."
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              className="pl-10"
            />
          </div>
          <div className="flex gap-2">
            <Button
              variant={statusFilter === "all" ? "default" : "outline"}
              size="sm"
              onClick={() => setStatusFilter("all")}
            >
              All
            </Button>
            <Button
              variant={statusFilter === "active" ? "default" : "outline"}
              size="sm"
              onClick={() => setStatusFilter("active")}
            >
              Active
            </Button>
            <Button
              variant={statusFilter === "pending" ? "default" : "outline"}
              size="sm"
              onClick={() => setStatusFilter("pending")}
            >
              Pending
            </Button>
            <Button
              variant={statusFilter === "resolved" ? "default" : "outline"}
              size="sm"
              onClick={() => setStatusFilter("resolved")}
            >
              Resolved
            </Button>
          </div>
        </div>

        {/* Conversations List */}
        <div className="space-y-4">
          {filteredConversations.map((conversation) => (
            <Link key={conversation.id} href={`/dashboard/chat/${conversation.id}`}>
              <Card className="hover:shadow-md transition-shadow cursor-pointer">
                <CardHeader>
                  <div className="flex items-start space-x-4">
                    <Avatar className="h-12 w-12">
                      <AvatarImage src={conversation.avatar || "/placeholder.svg"} alt={conversation.citizenName} />
                      <AvatarFallback>
                        {conversation.citizenName
                          .split(" ")
                          .map((n) => n[0])
                          .join("")}
                      </AvatarFallback>
                    </Avatar>

                    <div className="flex-1 min-w-0">
                      <div className="flex items-center justify-between mb-1">
                        <div className="flex items-center space-x-3">
                          <CardTitle className="text-lg truncate">{conversation.citizenName}</CardTitle>
                          <Badge className={getStatusColor(conversation.status)}>{conversation.status}</Badge>
                          {conversation.unreadCount > 0 && (
                            <Badge variant="destructive" className="text-xs">
                              {conversation.unreadCount}
                            </Badge>
                          )}
                        </div>
                        <div className="flex items-center text-sm text-muted-foreground">
                          <Clock className="h-4 w-4 mr-1" />
                          {conversation.timestamp}
                        </div>
                      </div>

                      <CardDescription className="mb-3">
                        <strong>Service:</strong> {conversation.service}
                      </CardDescription>

                      <div className="grid md:grid-cols-2 gap-4 text-sm text-muted-foreground mb-3">
                        <div className="flex items-center space-x-2">
                          <Mail className="h-4 w-4" />
                          <span className="truncate">{conversation.citizenEmail}</span>
                        </div>
                        <div className="flex items-center space-x-2">
                          <Phone className="h-4 w-4" />
                          <span>{conversation.citizenPhone}</span>
                        </div>
                      </div>

                      <div className="bg-muted/50 p-3 rounded-md">
                        <p className="text-sm text-foreground">
                          <strong>Last message:</strong> {conversation.lastMessage}
                        </p>
                      </div>
                    </div>
                  </div>
                </CardHeader>
              </Card>
            </Link>
          ))}
        </div>

        {filteredConversations.length === 0 && (
          <div className="text-center py-12">
            <MessageSquare className="h-12 w-12 text-muted-foreground mx-auto mb-4" />
            <h3 className="text-lg font-medium text-foreground mb-2">No conversations found</h3>
            <p className="text-muted-foreground mb-4">
              {searchTerm || statusFilter !== "all"
                ? "Try adjusting your search or filters"
                : "Start communicating with citizens about their services"}
            </p>
            <Button>
              <Plus className="h-4 w-4 mr-2" />
              Start New Chat
            </Button>
          </div>
        )}
      </div>
    </div>
  )
}

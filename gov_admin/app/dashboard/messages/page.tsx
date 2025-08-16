"use client"

import { useState } from "react"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Textarea } from "@/components/ui/textarea"
import { Badge } from "@/components/ui/badge"
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import {
  Send,
  Search,
  Paperclip,
  Phone,
  Mail,
  MessageSquare,
  User,
  Clock,
  CheckCircle2,
  AlertCircle,
  Archive,
  Star,
  MoreVertical
} from "lucide-react"

// Mock data for messages
const conversations = [
  {
    id: 1,
    citizenName: "Kamal Perera",
    citizenNIC: "891234567V",
    lastMessage: "Thank you for the update on my character certificate",
    timestamp: "10 min ago",
    unread: 2,
    status: "active",
    category: "certificates",
    phone: "+94 77 123 4567"
  },
  {
    id: 2,
    citizenName: "Seetha Fernando",
    citizenNIC: "925678901V",
    lastMessage: "I have uploaded the new address proof document",
    timestamp: "1 hour ago",
    unread: 0,
    status: "active",
    category: "documents",
    phone: "+94 71 234 5678"
  },
  {
    id: 3,
    citizenName: "Ranjith Silva",
    citizenNIC: "783456789V",
    lastMessage: "When can I collect my income certificate?",
    timestamp: "2 hours ago",
    unread: 1,
    status: "active",
    category: "inquiry",
    phone: "+94 70 345 6789"
  },
  {
    id: 4,
    citizenName: "Mala Jayawardena",
    citizenNIC: "956789012V",
    lastMessage: "Application submitted successfully",
    timestamp: "Yesterday",
    unread: 0,
    status: "resolved",
    category: "general",
    phone: "+94 76 456 7890"
  }
]

const messages = [
  {
    id: 1,
    sender: "citizen",
    content: "Good morning, I submitted my character certificate application yesterday. Can you please check the status?",
    timestamp: "9:30 AM",
    status: "read"
  },
  {
    id: 2,
    sender: "gn",
    content: "Good morning! I've checked your application. Your police report is missing from the submission. Please upload it to proceed.",
    timestamp: "9:45 AM",
    status: "read"
  },
  {
    id: 3,
    sender: "citizen",
    content: "Oh, I see. I will get it from the police station today. How long do I have to submit it?",
    timestamp: "10:00 AM",
    status: "read"
  },
  {
    id: 4,
    sender: "gn",
    content: "You have 3 working days to submit the police report. Once received, I can process your certificate within 24 hours.",
    timestamp: "10:15 AM",
    status: "read"
  },
  {
    id: 5,
    sender: "citizen",
    content: "Thank you for the update on my character certificate",
    timestamp: "10:20 AM",
    status: "read"
  }
]

export default function MessagesPage() {
  const [selectedConversation, setSelectedConversation] = useState(conversations[0])
  const [messageText, setMessageText] = useState("")
  const [searchTerm, setSearchTerm] = useState("")
  const [filterCategory, setFilterCategory] = useState("all")

  const filteredConversations = conversations.filter((conv) => {
    const matchesSearch = 
      conv.citizenName.toLowerCase().includes(searchTerm.toLowerCase()) ||
      conv.citizenNIC.toLowerCase().includes(searchTerm.toLowerCase())
    const matchesCategory = filterCategory === "all" || conv.category === filterCategory
    return matchesSearch && matchesCategory
  })

  const sendMessage = () => {
    if (messageText.trim()) {
      // Handle send message
      setMessageText("")
    }
  }

  return (
    <div className="min-h-screen bg-background">
      {/* Header */}
      <header className="border-b border-border bg-card">
        <div className="container mx-auto px-4 py-4">
          <div className="flex items-center justify-between">
            <div>
              <h1 className="text-xl font-bold text-foreground">Citizen Communications</h1>
              <p className="text-sm text-muted-foreground">Manage messages and inquiries from citizens</p>
            </div>
            <div className="flex items-center gap-2">
              <Badge variant="outline" className="bg-green-50 text-green-700 border-green-200">
                <MessageSquare className="h-3 w-3 mr-1" />
                3 Active Chats
              </Badge>
              <Badge variant="outline" className="bg-orange-50 text-orange-700 border-orange-200">
                <AlertCircle className="h-3 w-3 mr-1" />
                3 Unread
              </Badge>
            </div>
          </div>
        </div>
      </header>

      <div className="container mx-auto px-4 py-6">
        <div className="grid lg:grid-cols-3 gap-6 h-[calc(100vh-200px)]">
          {/* Conversations List */}
          <div className="lg:col-span-1">
            <Card className="h-full">
              <CardHeader>
                <CardTitle>Conversations</CardTitle>
                <div className="space-y-3 mt-4">
                  <div className="relative">
                    <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-muted-foreground h-4 w-4" />
                    <Input
                      placeholder="Search citizens..."
                      value={searchTerm}
                      onChange={(e) => setSearchTerm(e.target.value)}
                      className="pl-10"
                    />
                  </div>
                  <Select value={filterCategory} onValueChange={setFilterCategory}>
                    <SelectTrigger>
                      <SelectValue placeholder="Filter by category" />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="all">All Categories</SelectItem>
                      <SelectItem value="certificates">Certificates</SelectItem>
                      <SelectItem value="documents">Documents</SelectItem>
                      <SelectItem value="inquiry">Inquiries</SelectItem>
                      <SelectItem value="general">General</SelectItem>
                    </SelectContent>
                  </Select>
                </div>
              </CardHeader>
              <CardContent className="overflow-y-auto">
                <div className="space-y-2">
                  {filteredConversations.map((conv) => (
                    <div
                      key={conv.id}
                      className={`p-3 rounded-lg cursor-pointer transition-colors ${
                        selectedConversation?.id === conv.id
                          ? "bg-primary/10 border border-primary"
                          : "hover:bg-muted/50"
                      }`}
                      onClick={() => setSelectedConversation(conv)}
                    >
                      <div className="flex items-start justify-between mb-1">
                        <div className="flex items-center gap-3">
                          <Avatar className="h-10 w-10">
                            <AvatarFallback>{conv.citizenName.split(' ').map(n => n[0]).join('')}</AvatarFallback>
                          </Avatar>
                          <div>
                            <p className="font-medium text-sm">{conv.citizenName}</p>
                            <p className="text-xs text-muted-foreground">{conv.citizenNIC}</p>
                          </div>
                        </div>
                        {conv.unread > 0 && (
                          <Badge className="bg-primary text-primary-foreground text-xs px-2 py-0">
                            {conv.unread}
                          </Badge>
                        )}
                      </div>
                      <p className="text-sm text-muted-foreground truncate mb-1">{conv.lastMessage}</p>
                      <div className="flex items-center justify-between">
                        <span className="text-xs text-muted-foreground">{conv.timestamp}</span>
                        <Badge variant="outline" className="text-xs">
                          {conv.category}
                        </Badge>
                      </div>
                    </div>
                  ))}
                </div>
              </CardContent>
            </Card>
          </div>

          {/* Message Thread */}
          <div className="lg:col-span-2">
            {selectedConversation ? (
              <Card className="h-full flex flex-col">
                <CardHeader className="border-b">
                  <div className="flex items-center justify-between">
                    <div className="flex items-center gap-3">
                      <Avatar className="h-10 w-10">
                        <AvatarFallback>
                          {selectedConversation.citizenName.split(' ').map(n => n[0]).join('')}
                        </AvatarFallback>
                      </Avatar>
                      <div>
                        <h3 className="font-semibold">{selectedConversation.citizenName}</h3>
                        <div className="flex items-center gap-3 text-sm text-muted-foreground">
                          <span>{selectedConversation.citizenNIC}</span>
                          <span className="flex items-center">
                            <Phone className="h-3 w-3 mr-1" />
                            {selectedConversation.phone}
                          </span>
                        </div>
                      </div>
                    </div>
                    <div className="flex items-center gap-2">
                      <Button variant="outline" size="sm">
                        <Phone className="h-4 w-4 mr-1" />
                        Call
                      </Button>
                      <Button variant="outline" size="sm">
                        <Mail className="h-4 w-4 mr-1" />
                        Email
                      </Button>
                      <Button variant="ghost" size="sm">
                        <MoreVertical className="h-4 w-4" />
                      </Button>
                    </div>
                  </div>
                </CardHeader>

                <CardContent className="flex-1 overflow-y-auto p-4">
                  <div className="space-y-4">
                    {messages.map((msg) => (
                      <div
                        key={msg.id}
                        className={`flex ${msg.sender === 'gn' ? 'justify-end' : 'justify-start'}`}
                      >
                        <div
                          className={`max-w-[70%] p-3 rounded-lg ${
                            msg.sender === 'gn'
                              ? 'bg-primary text-primary-foreground'
                              : 'bg-muted'
                          }`}
                        >
                          <p className="text-sm">{msg.content}</p>
                          <div className="flex items-center gap-2 mt-1">
                            <span className="text-xs opacity-70">{msg.timestamp}</span>
                            {msg.sender === 'gn' && msg.status === 'read' && (
                              <CheckCircle2 className="h-3 w-3" />
                            )}
                          </div>
                        </div>
                      </div>
                    ))}
                  </div>
                </CardContent>

                <div className="p-4 border-t">
                  <div className="flex gap-2">
                    <Button variant="outline" size="icon">
                      <Paperclip className="h-4 w-4" />
                    </Button>
                    <Textarea
                      placeholder="Type your message..."
                      value={messageText}
                      onChange={(e) => setMessageText(e.target.value)}
                      className="flex-1 min-h-[60px] resize-none"
                      onKeyDown={(e) => {
                        if (e.key === 'Enter' && !e.shiftKey) {
                          e.preventDefault()
                          sendMessage()
                        }
                      }}
                    />
                    <Button onClick={sendMessage}>
                      <Send className="h-4 w-4 mr-1" />
                      Send
                    </Button>
                  </div>
                  <div className="flex gap-2 mt-2">
                    <Button variant="outline" size="sm" className="text-xs">
                      Request Documents
                    </Button>
                    <Button variant="outline" size="sm" className="text-xs">
                      Send Status Update
                    </Button>
                    <Button variant="outline" size="sm" className="text-xs">
                      Schedule Appointment
                    </Button>
                  </div>
                </div>
              </Card>
            ) : (
              <Card className="h-full flex items-center justify-center">
                <div className="text-center">
                  <MessageSquare className="h-12 w-12 text-muted-foreground mx-auto mb-4" />
                  <p className="text-muted-foreground">Select a conversation to view messages</p>
                </div>
              </Card>
            )}
          </div>
        </div>
      </div>
    </div>
  )
}
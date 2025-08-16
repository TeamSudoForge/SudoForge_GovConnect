"use client"

import { useState } from "react"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Badge } from "@/components/ui/badge"
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import { 
  Search, 
  User, 
  Phone, 
  Mail, 
  MapPin, 
  Calendar, 
  FileText, 
  Eye, 
  MessageSquare,
  Plus,
  Filter,
  Download,
  Edit,
  Home,
  Users,
  IdCard,
  Activity
} from "lucide-react"

// Mock data for citizens
const citizens = [
  {
    id: 1,
    name: "Kamal Perera",
    nic: "891234567V",
    phone: "+94 77 123 4567",
    email: "kamal.perera@email.com",
    address: "45/2, Temple Road, Colombo 10",
    dateOfBirth: "1989-05-15",
    gender: "Male",
    occupation: "Teacher",
    registrationDate: "2020-03-15",
    status: "active",
    certificatesIssued: 3,
    lastVisit: "2024-01-18",
    householdMembers: 4,
    familyHead: true
  },
  {
    id: 2,
    name: "Seetha Fernando",
    nic: "925678901V",
    phone: "+94 71 234 5678",
    email: "seetha.fernando@email.com",
    address: "12A, Flower Lane, Colombo 10",
    dateOfBirth: "1992-08-22",
    gender: "Female",
    occupation: "Nurse",
    registrationDate: "2018-07-20",
    status: "active",
    certificatesIssued: 2,
    lastVisit: "2024-01-17",
    householdMembers: 2,
    familyHead: false
  },
  {
    id: 3,
    name: "Ranjith Silva",
    nic: "783456789V",
    phone: "+94 70 345 6789",
    email: "ranjith.silva@email.com",
    address: "78, Main Street, Colombo 10",
    dateOfBirth: "1978-12-10",
    gender: "Male",
    occupation: "Engineer",
    registrationDate: "2015-11-08",
    status: "active",
    certificatesIssued: 5,
    lastVisit: "2024-01-16",
    householdMembers: 3,
    familyHead: true
  },
  {
    id: 4,
    name: "Mala Jayawardena",
    nic: "956789012V",
    phone: "+94 76 456 7890",
    email: "mala.jayawardena@email.com",
    address: "23/1, School Lane, Colombo 10",
    dateOfBirth: "1995-03-18",
    gender: "Female",
    occupation: "Student",
    registrationDate: "2023-01-12",
    status: "active",
    certificatesIssued: 1,
    lastVisit: "2024-01-18",
    householdMembers: 5,
    familyHead: false
  },
  {
    id: 5,
    name: "Nimal Rajapaksa",
    nic: "872345678V",
    phone: "+94 75 567 8901",
    email: "nimal.rajapaksa@email.com",
    address: "90, Temple Road, Colombo 10",
    dateOfBirth: "1987-09-05",
    gender: "Male",
    occupation: "Business Owner",
    registrationDate: "2019-05-30",
    status: "active",
    certificatesIssued: 4,
    lastVisit: "2024-01-19",
    householdMembers: 6,
    familyHead: true
  }
]

// Mock recent activities
const recentActivities = [
  {
    id: 1,
    citizenName: "Kamal Perera",
    action: "Character Certificate Application",
    date: "2024-01-18",
    status: "pending"
  },
  {
    id: 2,
    citizenName: "Seetha Fernando",
    action: "Document Correction Submitted",
    date: "2024-01-17",
    status: "completed"
  },
  {
    id: 3,
    citizenName: "Ranjith Silva",
    action: "Income Certificate Issued",
    date: "2024-01-16",
    status: "completed"
  }
]

export default function CitizensPage() {
  const [searchTerm, setSearchTerm] = useState("")
  const [statusFilter, setStatusFilter] = useState("all")
  const [selectedCitizen, setSelectedCitizen] = useState(citizens[0])

  const filteredCitizens = citizens.filter((citizen) => {
    const matchesSearch = 
      citizen.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
      citizen.nic.toLowerCase().includes(searchTerm.toLowerCase()) ||
      citizen.address.toLowerCase().includes(searchTerm.toLowerCase())
    const matchesStatus = statusFilter === "all" || citizen.status === statusFilter
    return matchesSearch && matchesStatus
  })

  const getStatusBadge = (status: string) => {
    switch (status) {
      case "active":
        return <Badge className="bg-green-100 text-green-800">Active</Badge>
      case "inactive":
        return <Badge variant="secondary">Inactive</Badge>
      case "moved":
        return <Badge className="bg-orange-100 text-orange-800">Moved</Badge>
      default:
        return <Badge>{status}</Badge>
    }
  }

  return (
    <div className="min-h-screen bg-background">
      {/* Header */}
      <header className="border-b border-border bg-card">
        <div className="container mx-auto px-4 py-4">
          <div className="flex items-center justify-between">
            <div>
              <h1 className="text-xl font-bold text-foreground">Citizen Registry</h1>
              <p className="text-sm text-muted-foreground">Manage citizen records and household information</p>
            </div>
            <div className="flex items-center gap-2">
              <Badge variant="outline" className="bg-blue-50 text-blue-700 border-blue-200">
                <Users className="h-3 w-3 mr-1" />
                {filteredCitizens.length} Citizens
              </Badge>
              <Badge variant="outline" className="bg-green-50 text-green-700 border-green-200">
                <Home className="h-3 w-3 mr-1" />
                1,250 Households
              </Badge>
              <Button>
                <Plus className="h-4 w-4 mr-2" />
                Add Citizen
              </Button>
            </div>
          </div>
        </div>
      </header>

      <div className="container mx-auto px-4 py-6">
        <div className="grid lg:grid-cols-3 gap-6">
          {/* Citizens List */}
          <div className="lg:col-span-1">
            <Card>
              <CardHeader>
                <CardTitle>Citizens Directory</CardTitle>
                <CardDescription>Browse and search citizen records</CardDescription>
              </CardHeader>
              <CardContent>
                {/* Search and Filter */}
                <div className="space-y-4 mb-4">
                  <div className="relative">
                    <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-muted-foreground h-4 w-4" />
                    <Input
                      placeholder="Search by name, NIC, or address..."
                      value={searchTerm}
                      onChange={(e) => setSearchTerm(e.target.value)}
                      className="pl-10"
                    />
                  </div>
                  <div className="flex gap-2">
                    <Select value={statusFilter} onValueChange={setStatusFilter}>
                      <SelectTrigger className="flex-1">
                        <SelectValue placeholder="Filter by status" />
                      </SelectTrigger>
                      <SelectContent>
                        <SelectItem value="all">All Status</SelectItem>
                        <SelectItem value="active">Active</SelectItem>
                        <SelectItem value="inactive">Inactive</SelectItem>
                        <SelectItem value="moved">Moved</SelectItem>
                      </SelectContent>
                    </Select>
                    <Button variant="outline" size="icon">
                      <Filter className="h-4 w-4" />
                    </Button>
                  </div>
                </div>

                {/* Citizens List */}
                <div className="space-y-3 max-h-[600px] overflow-y-auto">
                  {filteredCitizens.map((citizen) => (
                    <div
                      key={citizen.id}
                      className={`p-3 rounded-lg border cursor-pointer transition-colors ${
                        selectedCitizen?.id === citizen.id 
                          ? "border-primary bg-primary/5" 
                          : "border-border hover:border-primary/50"
                      }`}
                      onClick={() => setSelectedCitizen(citizen)}
                    >
                      <div className="flex items-start justify-between mb-2">
                        <div className="flex items-center gap-3">
                          <Avatar className="h-10 w-10">
                            <AvatarFallback>{citizen.name.split(' ').map(n => n[0]).join('')}</AvatarFallback>
                          </Avatar>
                          <div>
                            <p className="font-medium text-sm">{citizen.name}</p>
                            <p className="text-xs text-muted-foreground">{citizen.nic}</p>
                          </div>
                        </div>
                        {getStatusBadge(citizen.status)}
                      </div>
                      <div className="text-xs text-muted-foreground">
                        <p className="flex items-center mb-1">
                          <MapPin className="h-3 w-3 mr-1" />
                          {citizen.address}
                        </p>
                        <p>Household: {citizen.householdMembers} members</p>
                      </div>
                    </div>
                  ))}
                </div>

                {filteredCitizens.length === 0 && (
                  <div className="text-center py-8">
                    <User className="h-8 w-8 text-muted-foreground mx-auto mb-2" />
                    <p className="text-sm text-muted-foreground">No citizens found</p>
                  </div>
                )}
              </CardContent>
            </Card>
          </div>

          {/* Citizen Details */}
          <div className="lg:col-span-2">
            {selectedCitizen ? (
              <div className="space-y-6">
                {/* Basic Information */}
                <Card>
                  <CardHeader>
                    <div className="flex items-start justify-between">
                      <div className="flex items-center gap-4">
                        <Avatar className="h-16 w-16">
                          <AvatarFallback className="text-lg">
                            {selectedCitizen.name.split(' ').map(n => n[0]).join('')}
                          </AvatarFallback>
                        </Avatar>
                        <div>
                          <CardTitle className="text-xl">{selectedCitizen.name}</CardTitle>
                          <CardDescription>NIC: {selectedCitizen.nic}</CardDescription>
                          <div className="flex items-center gap-2 mt-2">
                            {getStatusBadge(selectedCitizen.status)}
                            {selectedCitizen.familyHead && (
                              <Badge variant="outline" className="bg-blue-50 text-blue-700">
                                <Home className="h-3 w-3 mr-1" />
                                Family Head
                              </Badge>
                            )}
                          </div>
                        </div>
                      </div>
                      <div className="flex gap-2">
                        <Button variant="outline" size="sm">
                          <Edit className="h-4 w-4 mr-1" />
                          Edit
                        </Button>
                        <Button variant="outline" size="sm">
                          <MessageSquare className="h-4 w-4 mr-1" />
                          Message
                        </Button>
                      </div>
                    </div>
                  </CardHeader>
                  <CardContent>
                    <Tabs defaultValue="personal" className="w-full">
                      <TabsList className="grid w-full grid-cols-4">
                        <TabsTrigger value="personal">Personal</TabsTrigger>
                        <TabsTrigger value="contact">Contact</TabsTrigger>
                        <TabsTrigger value="documents">Documents</TabsTrigger>
                        <TabsTrigger value="history">History</TabsTrigger>
                      </TabsList>

                      <TabsContent value="personal" className="space-y-4 mt-4">
                        <div className="grid md:grid-cols-2 gap-6">
                          <div className="space-y-4">
                            <div>
                              <label className="text-sm font-medium text-muted-foreground">Date of Birth</label>
                              <p className="font-medium">{new Date(selectedCitizen.dateOfBirth).toLocaleDateString()}</p>
                            </div>
                            <div>
                              <label className="text-sm font-medium text-muted-foreground">Gender</label>
                              <p className="font-medium">{selectedCitizen.gender}</p>
                            </div>
                            <div>
                              <label className="text-sm font-medium text-muted-foreground">Occupation</label>
                              <p className="font-medium">{selectedCitizen.occupation}</p>
                            </div>
                          </div>
                          <div className="space-y-4">
                            <div>
                              <label className="text-sm font-medium text-muted-foreground">Registration Date</label>
                              <p className="font-medium">{new Date(selectedCitizen.registrationDate).toLocaleDateString()}</p>
                            </div>
                            <div>
                              <label className="text-sm font-medium text-muted-foreground">Household Members</label>
                              <p className="font-medium">{selectedCitizen.householdMembers} members</p>
                            </div>
                            <div>
                              <label className="text-sm font-medium text-muted-foreground">Last Visit</label>
                              <p className="font-medium">{new Date(selectedCitizen.lastVisit).toLocaleDateString()}</p>
                            </div>
                          </div>
                        </div>
                      </TabsContent>

                      <TabsContent value="contact" className="space-y-4 mt-4">
                        <div className="space-y-4">
                          <div>
                            <label className="text-sm font-medium text-muted-foreground">Phone Number</label>
                            <div className="flex items-center gap-2 mt-1">
                              <Phone className="h-4 w-4 text-muted-foreground" />
                              <p className="font-medium">{selectedCitizen.phone}</p>
                              <Button variant="outline" size="sm">Call</Button>
                            </div>
                          </div>
                          <div>
                            <label className="text-sm font-medium text-muted-foreground">Email Address</label>
                            <div className="flex items-center gap-2 mt-1">
                              <Mail className="h-4 w-4 text-muted-foreground" />
                              <p className="font-medium">{selectedCitizen.email}</p>
                              <Button variant="outline" size="sm">Email</Button>
                            </div>
                          </div>
                          <div>
                            <label className="text-sm font-medium text-muted-foreground">Address</label>
                            <div className="flex items-start gap-2 mt-1">
                              <MapPin className="h-4 w-4 text-muted-foreground mt-1" />
                              <p className="font-medium">{selectedCitizen.address}</p>
                            </div>
                          </div>
                        </div>
                      </TabsContent>

                      <TabsContent value="documents" className="space-y-4 mt-4">
                        <div className="space-y-3">
                          <div className="flex items-center justify-between p-4 border rounded-lg">
                            <div className="flex items-center gap-3">
                              <FileText className="h-5 w-5 text-muted-foreground" />
                              <div>
                                <p className="font-medium">Character Certificate</p>
                                <p className="text-sm text-muted-foreground">Issued: Jan 15, 2024</p>
                              </div>
                            </div>
                            <div className="flex gap-2">
                              <Button variant="outline" size="sm">
                                <Eye className="h-4 w-4 mr-1" />
                                View
                              </Button>
                              <Button variant="outline" size="sm">
                                <Download className="h-4 w-4 mr-1" />
                                Download
                              </Button>
                            </div>
                          </div>
                          <div className="flex items-center justify-between p-4 border rounded-lg">
                            <div className="flex items-center gap-3">
                              <FileText className="h-5 w-5 text-muted-foreground" />
                              <div>
                                <p className="font-medium">Income Certificate</p>
                                <p className="text-sm text-muted-foreground">Issued: Dec 20, 2023</p>
                              </div>
                            </div>
                            <div className="flex gap-2">
                              <Button variant="outline" size="sm">
                                <Eye className="h-4 w-4 mr-1" />
                                View
                              </Button>
                              <Button variant="outline" size="sm">
                                <Download className="h-4 w-4 mr-1" />
                                Download
                              </Button>
                            </div>
                          </div>
                        </div>
                        <div className="pt-4 border-t">
                          <p className="text-sm text-muted-foreground mb-2">Summary</p>
                          <p className="font-medium">{selectedCitizen.certificatesIssued} certificates issued to date</p>
                        </div>
                      </TabsContent>

                      <TabsContent value="history" className="space-y-4 mt-4">
                        <div className="space-y-3">
                          {recentActivities
                            .filter(activity => activity.citizenName === selectedCitizen.name)
                            .map((activity) => (
                            <div key={activity.id} className="flex items-start gap-3 p-3 border rounded-lg">
                              <div className="w-8 h-8 bg-blue-100 rounded-full flex items-center justify-center flex-shrink-0">
                                <Activity className="h-4 w-4 text-blue-600" />
                              </div>
                              <div className="flex-1">
                                <p className="font-medium text-sm">{activity.action}</p>
                                <p className="text-xs text-muted-foreground">{activity.date}</p>
                              </div>
                              <Badge variant={activity.status === "completed" ? "default" : "secondary"}>
                                {activity.status}
                              </Badge>
                            </div>
                          ))}
                          {recentActivities.filter(activity => activity.citizenName === selectedCitizen.name).length === 0 && (
                            <p className="text-sm text-muted-foreground text-center py-4">No recent activities</p>
                          )}
                        </div>
                      </TabsContent>
                    </Tabs>
                  </CardContent>
                </Card>
              </div>
            ) : (
              <Card>
                <CardContent className="flex items-center justify-center h-96">
                  <div className="text-center">
                    <User className="h-12 w-12 text-muted-foreground mx-auto mb-4" />
                    <p className="text-muted-foreground">Select a citizen to view details</p>
                  </div>
                </CardContent>
              </Card>
            )}
          </div>
        </div>
      </div>
    </div>
  )
}
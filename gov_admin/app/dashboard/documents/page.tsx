"use client"

import { useState } from "react"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Badge } from "@/components/ui/badge"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import { Textarea } from "@/components/ui/textarea"
import { Label } from "@/components/ui/label"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"
import { 
  FileText, 
  Search, 
  Download, 
  Eye, 
  MessageSquare, 
  CheckCircle2, 
  AlertCircle, 
  XCircle,
  Clock,
  Send,
  Paperclip,
  User,
  Calendar,
  Home,
  MapPin
} from "lucide-react"

// Mock data for documents
const documents = [
  {
    id: 1,
    type: "Character Certificate",
    citizenName: "Kamal Perera",
    citizenNIC: "891234567V",
    submittedDate: "2024-01-18",
    status: "pending",
    address: "45/2, Temple Road, Colombo 10",
    phone: "+94 77 123 4567",
    issues: [],
    documents: ["NIC Copy", "Police Report", "Application Form"]
  },
  {
    id: 2,
    type: "Residence Certificate",
    citizenName: "Seetha Fernando",
    citizenNIC: "925678901V",
    submittedDate: "2024-01-17",
    status: "requires_correction",
    address: "12A, Flower Lane, Colombo 10",
    phone: "+94 71 234 5678",
    issues: ["Address proof document is not clear", "NIC copy is expired"],
    documents: ["NIC Copy", "Utility Bill", "Application Form"]
  },
  {
    id: 3,
    type: "Income Certificate",
    citizenName: "Ranjith Silva",
    citizenNIC: "783456789V",
    submittedDate: "2024-01-16",
    status: "approved",
    address: "78, Main Street, Colombo 10",
    phone: "+94 70 345 6789",
    issues: [],
    documents: ["NIC Copy", "Salary Slips", "Bank Statements", "Application Form"]
  },
  {
    id: 4,
    type: "Character Certificate",
    citizenName: "Mala Jayawardena",
    citizenNIC: "956789012V",
    submittedDate: "2024-01-18",
    status: "pending",
    address: "23/1, School Lane, Colombo 10",
    phone: "+94 76 456 7890",
    issues: [],
    documents: ["NIC Copy", "Application Form"]
  },
  {
    id: 5,
    type: "Birth Certificate Verification",
    citizenName: "Nimal Rajapaksa",
    citizenNIC: "872345678V",
    submittedDate: "2024-01-19",
    status: "pending",
    address: "90, Temple Road, Colombo 10",
    phone: "+94 75 567 8901",
    issues: [],
    documents: ["Birth Certificate", "Parent's NIC", "Application Form"]
  }
]

export default function DocumentsPage() {
  const [searchTerm, setSearchTerm] = useState("")
  const [statusFilter, setStatusFilter] = useState("all")
  const [selectedDocument, setSelectedDocument] = useState(documents[0])
  const [communicationMessage, setCommunicationMessage] = useState("")

  const filteredDocuments = documents.filter((doc) => {
    const matchesSearch = 
      doc.citizenName.toLowerCase().includes(searchTerm.toLowerCase()) ||
      doc.citizenNIC.toLowerCase().includes(searchTerm.toLowerCase()) ||
      doc.type.toLowerCase().includes(searchTerm.toLowerCase())
    const matchesStatus = statusFilter === "all" || doc.status === statusFilter
    return matchesSearch && matchesStatus
  })

  const getStatusBadge = (status: string) => {
    switch (status) {
      case "pending":
        return <Badge variant="secondary" className="bg-yellow-100 text-yellow-800"><Clock className="h-3 w-3 mr-1" />Pending Review</Badge>
      case "requires_correction":
        return <Badge variant="destructive"><AlertCircle className="h-3 w-3 mr-1" />Requires Correction</Badge>
      case "approved":
        return <Badge variant="default" className="bg-green-100 text-green-800"><CheckCircle2 className="h-3 w-3 mr-1" />Approved</Badge>
      case "rejected":
        return <Badge variant="destructive"><XCircle className="h-3 w-3 mr-1" />Rejected</Badge>
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
              <h1 className="text-xl font-bold text-foreground">Document Review</h1>
              <p className="text-sm text-muted-foreground">Review and process citizen document submissions</p>
            </div>
            <Badge variant="outline" className="text-blue-600 border-blue-600">
              <Home className="h-3 w-3 mr-1" />
              Grama Niladhari - Colombo 10
            </Badge>
          </div>
        </div>
      </header>

      <div className="container mx-auto px-4 py-6">
        <div className="grid lg:grid-cols-3 gap-6">
          {/* Document List */}
          <div className="lg:col-span-1">
            <Card>
              <CardHeader>
                <CardTitle>Document Queue</CardTitle>
                <CardDescription>Documents awaiting review</CardDescription>
              </CardHeader>
              <CardContent>
                {/* Search and Filter */}
                <div className="space-y-4 mb-4">
                  <div className="relative">
                    <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-muted-foreground h-4 w-4" />
                    <Input
                      placeholder="Search by name or NIC..."
                      value={searchTerm}
                      onChange={(e) => setSearchTerm(e.target.value)}
                      className="pl-10"
                    />
                  </div>
                  <Select value={statusFilter} onValueChange={setStatusFilter}>
                    <SelectTrigger>
                      <SelectValue placeholder="Filter by status" />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="all">All Status</SelectItem>
                      <SelectItem value="pending">Pending</SelectItem>
                      <SelectItem value="requires_correction">Requires Correction</SelectItem>
                      <SelectItem value="approved">Approved</SelectItem>
                      <SelectItem value="rejected">Rejected</SelectItem>
                    </SelectContent>
                  </Select>
                </div>

                {/* Document List */}
                <div className="space-y-3">
                  {filteredDocuments.map((doc) => (
                    <div
                      key={doc.id}
                      className={`p-3 rounded-lg border cursor-pointer transition-colors ${
                        selectedDocument?.id === doc.id 
                          ? "border-primary bg-primary/5" 
                          : "border-border hover:border-primary/50"
                      }`}
                      onClick={() => setSelectedDocument(doc)}
                    >
                      <div className="flex items-start justify-between mb-2">
                        <div className="flex-1">
                          <p className="font-medium text-sm">{doc.type}</p>
                          <p className="text-xs text-muted-foreground">{doc.citizenName}</p>
                        </div>
                        {getStatusBadge(doc.status)}
                      </div>
                      <div className="flex items-center text-xs text-muted-foreground">
                        <Calendar className="h-3 w-3 mr-1" />
                        {doc.submittedDate}
                      </div>
                    </div>
                  ))}
                </div>

                {filteredDocuments.length === 0 && (
                  <div className="text-center py-8">
                    <FileText className="h-8 w-8 text-muted-foreground mx-auto mb-2" />
                    <p className="text-sm text-muted-foreground">No documents found</p>
                  </div>
                )}
              </CardContent>
            </Card>
          </div>

          {/* Document Details */}
          <div className="lg:col-span-2">
            {selectedDocument ? (
              <Card>
                <CardHeader>
                  <div className="flex items-start justify-between">
                    <div>
                      <CardTitle>{selectedDocument.type}</CardTitle>
                      <CardDescription>Application ID: #GN10-{selectedDocument.id.toString().padStart(6, '0')}</CardDescription>
                    </div>
                    {getStatusBadge(selectedDocument.status)}
                  </div>
                </CardHeader>
                <CardContent>
                  <Tabs defaultValue="details" className="w-full">
                    <TabsList className="grid w-full grid-cols-3">
                      <TabsTrigger value="details">Details</TabsTrigger>
                      <TabsTrigger value="documents">Documents</TabsTrigger>
                      <TabsTrigger value="communication">Communication</TabsTrigger>
                    </TabsList>

                    <TabsContent value="details" className="space-y-4">
                      {/* Citizen Information */}
                      <div className="space-y-4">
                        <h3 className="font-semibold">Citizen Information</h3>
                        <div className="grid md:grid-cols-2 gap-4">
                          <div>
                            <Label className="text-muted-foreground">Full Name</Label>
                            <p className="font-medium">{selectedDocument.citizenName}</p>
                          </div>
                          <div>
                            <Label className="text-muted-foreground">NIC Number</Label>
                            <p className="font-medium">{selectedDocument.citizenNIC}</p>
                          </div>
                          <div>
                            <Label className="text-muted-foreground">Contact Number</Label>
                            <p className="font-medium">{selectedDocument.phone}</p>
                          </div>
                          <div>
                            <Label className="text-muted-foreground">Submission Date</Label>
                            <p className="font-medium">{selectedDocument.submittedDate}</p>
                          </div>
                          <div className="md:col-span-2">
                            <Label className="text-muted-foreground">Address</Label>
                            <p className="font-medium flex items-start">
                              <MapPin className="h-4 w-4 mr-1 mt-0.5 text-muted-foreground" />
                              {selectedDocument.address}
                            </p>
                          </div>
                        </div>
                      </div>

                      {/* Issues */}
                      {selectedDocument.issues.length > 0 && (
                        <div className="space-y-3">
                          <h3 className="font-semibold text-red-600">Issues Found</h3>
                          <div className="space-y-2">
                            {selectedDocument.issues.map((issue, index) => (
                              <div key={index} className="flex items-start space-x-2 text-sm">
                                <AlertCircle className="h-4 w-4 text-red-500 mt-0.5" />
                                <span>{issue}</span>
                              </div>
                            ))}
                          </div>
                        </div>
                      )}

                      {/* Action Buttons */}
                      <div className="flex gap-3 pt-4">
                        <Button className="flex-1" disabled={selectedDocument.status === "approved"}>
                          <CheckCircle2 className="h-4 w-4 mr-2" />
                          Approve
                        </Button>
                        <Button variant="outline" className="flex-1">
                          <AlertCircle className="h-4 w-4 mr-2" />
                          Request Correction
                        </Button>
                        <Button variant="destructive" className="flex-1">
                          <XCircle className="h-4 w-4 mr-2" />
                          Reject
                        </Button>
                      </div>
                    </TabsContent>

                    <TabsContent value="documents" className="space-y-4">
                      <h3 className="font-semibold">Submitted Documents</h3>
                      <div className="space-y-3">
                        {selectedDocument.documents.map((doc, index) => (
                          <div key={index} className="flex items-center justify-between p-3 border rounded-lg">
                            <div className="flex items-center space-x-3">
                              <FileText className="h-5 w-5 text-muted-foreground" />
                              <span className="font-medium">{doc}</span>
                            </div>
                            <div className="flex gap-2">
                              <Button size="sm" variant="outline">
                                <Eye className="h-4 w-4 mr-1" />
                                View
                              </Button>
                              <Button size="sm" variant="outline">
                                <Download className="h-4 w-4 mr-1" />
                                Download
                              </Button>
                            </div>
                          </div>
                        ))}
                      </div>
                    </TabsContent>

                    <TabsContent value="communication" className="space-y-4">
                      <h3 className="font-semibold">Communication with Citizen</h3>
                      
                      {/* Message History */}
                      <div className="space-y-3 max-h-64 overflow-y-auto p-4 bg-muted/20 rounded-lg">
                        <div className="flex items-start space-x-3">
                          <div className="w-8 h-8 bg-blue-100 rounded-full flex items-center justify-center">
                            <User className="h-4 w-4 text-blue-600" />
                          </div>
                          <div className="flex-1">
                            <p className="text-sm font-medium">Citizen</p>
                            <p className="text-sm">I have submitted all required documents for the character certificate.</p>
                            <p className="text-xs text-muted-foreground mt-1">2 hours ago</p>
                          </div>
                        </div>
                        
                        {selectedDocument.status === "requires_correction" && (
                          <div className="flex items-start space-x-3">
                            <div className="w-8 h-8 bg-green-100 rounded-full flex items-center justify-center">
                              <Home className="h-4 w-4 text-green-600" />
                            </div>
                            <div className="flex-1">
                              <p className="text-sm font-medium">Grama Niladhari</p>
                              <p className="text-sm">Please provide a clearer copy of your address proof document. The current one is not readable.</p>
                              <p className="text-xs text-muted-foreground mt-1">1 hour ago</p>
                            </div>
                          </div>
                        )}
                      </div>

                      {/* Send Message */}
                      <div className="space-y-3">
                        <Textarea
                          placeholder="Type your message to the citizen..."
                          value={communicationMessage}
                          onChange={(e) => setCommunicationMessage(e.target.value)}
                          className="min-h-[100px]"
                        />
                        <div className="flex justify-between">
                          <Button variant="outline" size="sm">
                            <Paperclip className="h-4 w-4 mr-1" />
                            Attach File
                          </Button>
                          <Button>
                            <Send className="h-4 w-4 mr-1" />
                            Send Message
                          </Button>
                        </div>
                      </div>
                    </TabsContent>
                  </Tabs>
                </CardContent>
              </Card>
            ) : (
              <Card>
                <CardContent className="flex items-center justify-center h-96">
                  <div className="text-center">
                    <FileText className="h-12 w-12 text-muted-foreground mx-auto mb-4" />
                    <p className="text-muted-foreground">Select a document to review</p>
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
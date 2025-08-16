"use client"

import type React from "react"

import { useState } from "react"
import Link from "next/link"
import { Button } from "@/components/ui/button"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { Textarea } from "@/components/ui/textarea"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"
import { ThemeToggle } from "@/components/theme-toggle"
import { Building2, ArrowLeft, Save } from "lucide-react"
import { useRouter } from "next/navigation"

export default function RegisterDepartmentPage() {
  const [formData, setFormData] = useState({
    departmentName: "",
    departmentType: "",
    email: "",
    contactPerson: "",
    phone: "",
    address: "",
    description: "",
    website: "",
    establishedYear: "",
  })
  const [isLoading, setIsLoading] = useState(false)
  const router = useRouter()

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setIsLoading(true)

    // Simulate registration
    setTimeout(() => {
      setIsLoading(false)
      router.push("/dashboard/departments")
    }, 1000)
  }

  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement>) => {
    setFormData((prev) => ({
      ...prev,
      [e.target.name]: e.target.value,
    }))
  }

  return (
    <div className="min-h-screen bg-background">
      {/* Header */}
      <header className="border-b border-border bg-card">
        <div className="container mx-auto px-4 py-4 flex items-center justify-between">
          <div className="flex items-center space-x-4">
            <Link
              href="/dashboard/departments"
              className="flex items-center text-muted-foreground hover:text-foreground"
            >
              <ArrowLeft className="h-4 w-4 mr-1" />
              Departments
            </Link>
            <div className="flex items-center space-x-2">
              <Building2 className="h-8 w-8 text-primary" />
              <div>
                <h1 className="text-xl font-bold text-foreground">Register New Department</h1>
                <p className="text-sm text-muted-foreground">Add a new government department</p>
              </div>
            </div>
          </div>
          <ThemeToggle />
        </div>
      </header>

      <div className="container mx-auto px-4 py-8 max-w-4xl">
        <Card>
          <CardHeader>
            <CardTitle>Department Information</CardTitle>
            <CardDescription>Fill in the details to register a new government department</CardDescription>
          </CardHeader>
          <CardContent>
            <form onSubmit={handleSubmit} className="space-y-6">
              {/* Basic Information */}
              <div className="space-y-4">
                <h3 className="text-lg font-medium">Basic Information</h3>
                <div className="grid md:grid-cols-2 gap-4">
                  <div className="space-y-2">
                    <Label htmlFor="departmentName">Department Name *</Label>
                    <Input
                      id="departmentName"
                      name="departmentName"
                      placeholder="Department of Health"
                      value={formData.departmentName}
                      onChange={handleChange}
                      required
                    />
                  </div>
                  <div className="space-y-2">
                    <Label htmlFor="departmentType">Department Type *</Label>
                    <Select onValueChange={(value) => setFormData((prev) => ({ ...prev, departmentType: value }))}>
                      <SelectTrigger>
                        <SelectValue placeholder="Select department type" />
                      </SelectTrigger>
                      <SelectContent>
                        <SelectItem value="health">Health & Medical</SelectItem>
                        <SelectItem value="education">Education</SelectItem>
                        <SelectItem value="transportation">Transportation</SelectItem>
                        <SelectItem value="finance">Finance & Revenue</SelectItem>
                        <SelectItem value="social">Social Services</SelectItem>
                        <SelectItem value="environment">Environment</SelectItem>
                        <SelectItem value="public-safety">Public Safety</SelectItem>
                        <SelectItem value="other">Other</SelectItem>
                      </SelectContent>
                    </Select>
                  </div>
                </div>

                <div className="space-y-2">
                  <Label htmlFor="description">Department Description</Label>
                  <Textarea
                    id="description"
                    name="description"
                    placeholder="Brief description of the department's mission and services"
                    value={formData.description}
                    onChange={handleChange}
                    rows={3}
                  />
                </div>
              </div>

              {/* Contact Information */}
              <div className="space-y-4">
                <h3 className="text-lg font-medium">Contact Information</h3>
                <div className="grid md:grid-cols-2 gap-4">
                  <div className="space-y-2">
                    <Label htmlFor="contactPerson">Contact Person *</Label>
                    <Input
                      id="contactPerson"
                      name="contactPerson"
                      placeholder="John Doe"
                      value={formData.contactPerson}
                      onChange={handleChange}
                      required
                    />
                  </div>
                  <div className="space-y-2">
                    <Label htmlFor="email">Official Email *</Label>
                    <Input
                      id="email"
                      name="email"
                      type="email"
                      placeholder="department@gov.example"
                      value={formData.email}
                      onChange={handleChange}
                      required
                    />
                  </div>
                </div>

                <div className="grid md:grid-cols-2 gap-4">
                  <div className="space-y-2">
                    <Label htmlFor="phone">Phone Number *</Label>
                    <Input
                      id="phone"
                      name="phone"
                      type="tel"
                      placeholder="+1 (555) 123-4567"
                      value={formData.phone}
                      onChange={handleChange}
                      required
                    />
                  </div>
                  <div className="space-y-2">
                    <Label htmlFor="website">Website (Optional)</Label>
                    <Input
                      id="website"
                      name="website"
                      type="url"
                      placeholder="https://department.gov.example"
                      value={formData.website}
                      onChange={handleChange}
                    />
                  </div>
                </div>

                <div className="space-y-2">
                  <Label htmlFor="address">Physical Address *</Label>
                  <Input
                    id="address"
                    name="address"
                    placeholder="123 Government St, City, State 12345"
                    value={formData.address}
                    onChange={handleChange}
                    required
                  />
                </div>
              </div>

              {/* Additional Information */}
              <div className="space-y-4">
                <h3 className="text-lg font-medium">Additional Information</h3>
                <div className="space-y-2">
                  <Label htmlFor="establishedYear">Established Year (Optional)</Label>
                  <Input
                    id="establishedYear"
                    name="establishedYear"
                    type="number"
                    placeholder="1995"
                    value={formData.establishedYear}
                    onChange={handleChange}
                    min="1800"
                    max="2024"
                  />
                </div>
              </div>

              <div className="flex justify-end space-x-4 pt-6">
                <Link href="/dashboard/departments">
                  <Button variant="outline">Cancel</Button>
                </Link>
                <Button type="submit" disabled={isLoading}>
                  {isLoading ? (
                    "Registering..."
                  ) : (
                    <>
                      <Save className="h-4 w-4 mr-2" />
                      Register Department
                    </>
                  )}
                </Button>
              </div>
            </form>
          </CardContent>
        </Card>
      </div>
    </div>
  )
}

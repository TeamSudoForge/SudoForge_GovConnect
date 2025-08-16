"use client"

import type React from "react"

import { useState } from "react"
import Link from "next/link"
import { Button } from "@/components/ui/button"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { Textarea } from "@/components/ui/textarea"
import { Building2, ArrowLeft } from "lucide-react"
import { useRouter } from "next/navigation"
import { OfficialsAuthService } from "@/lib/services/officials-auth.service"
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select"

// Predefined divisions for Grama Niladhari
const DIVISIONS = [
  "Colombo North",
  "Colombo South",
  "Colombo East",
  "Colombo West",
  "Dehiwala",
  "Mount Lavinia",
  "Moratuwa",
  "Kotte",
  "Kaduwela",
  "Homagama",
  "Maharagama",
  "Kesbewa",
  "Boralesgamuwa",
  "Nugegoda",
  "Piliyandala",
  "Ratmalana",
  "Pannipitiya",
  "Kottawa",
  "Malabe",
  "Battaramulla",
]

// Predefined departments
const DEPARTMENTS = [
  "District Secretariat",
  "Divisional Secretariat",
  "Grama Niladhari Division",
  "Municipal Council",
  "Urban Council",
  "Pradeshiya Sabha",
  "Ministry of Home Affairs",
  "Ministry of Public Administration",
  "Land Registry",
  "Social Services Department",
]

export default function RegisterPage() {
  const [formData, setFormData] = useState({
    nameWithInitials: "",
    email: "",
    password: "",
    confirmPassword: "",
    role: "",
    department: "",
    division: "",
    contact_phone: "",
  })
  const [isLoading, setIsLoading] = useState(false)
  const [error, setError] = useState("")
  const router = useRouter()

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setIsLoading(true)
    setError("")

    if (formData.password !== formData.confirmPassword) {
      setError("Passwords do not match")
      setIsLoading(false)
      return
    }

    try {
      const authService = OfficialsAuthService.getInstance()
      await authService.register({
        name: formData.nameWithInitials,
        email: formData.email,
        password: formData.password,
        designation: formData.role || undefined,
        department: formData.department || undefined,
        division: formData.division || undefined,
        contact_phone: formData.contact_phone || undefined,
      })
      
      // Redirect to dashboard on successful registration
      router.push("/dashboard")
    } catch (err) {
      setError(err instanceof Error ? err.message : "Registration failed")
    } finally {
      setIsLoading(false)
    }
  }

  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement>) => {
    setFormData((prev) => ({
      ...prev,
      [e.target.name]: e.target.value,
    }))
  }

  const handleSelectChange = (name: string, value: string) => {
    setFormData((prev) => ({
      ...prev,
      [name]: value,
    }))
  }

  return (
    <div className="min-h-screen bg-background py-8 px-4">
      <div className="container mx-auto max-w-2xl">
        <div className="flex items-center justify-center mb-8">
          <Building2 className="h-12 w-12 text-primary mr-3" />
          <h1 className="text-2xl font-bold text-foreground">Government Portal</h1>
        </div>

        <Card>
          <CardHeader className="space-y-1">
            <CardTitle className="text-2xl text-center">Register Official</CardTitle>
            <CardDescription className="text-center">
              Register as a government official to access the portal
            </CardDescription>
          </CardHeader>
          <CardContent>
            <form onSubmit={handleSubmit} className="space-y-4">
              {error && (
                <div className="p-3 text-sm text-red-600 bg-red-50 border border-red-200 rounded-md">
                  {error}
                </div>
              )}
              
              <div className="space-y-2">
                <Label htmlFor="nameWithInitials">Name with Initials</Label>
                <Input
                  id="nameWithInitials"
                  name="nameWithInitials"
                  placeholder="J. K. Perera"
                  value={formData.nameWithInitials}
                  onChange={handleChange}
                  required
                />
                <p className="text-xs text-muted-foreground">Enter your name with initials (e.g., J. K. Perera)</p>
              </div>

              <div className="grid md:grid-cols-2 gap-4">
                <div className="space-y-2">
                  <Label htmlFor="email">Official Email</Label>
                  <Input
                    id="email"
                    name="email"
                    type="email"
                    placeholder="john.doe@gov.example"
                    value={formData.email}
                    onChange={handleChange}
                    required
                  />
                </div>
                <div className="space-y-2">
                  <Label htmlFor="contact_phone">Contact Phone</Label>
                  <Input
                    id="contact_phone"
                    name="contact_phone"
                    type="tel"
                    placeholder="+1 (555) 123-4567"
                    value={formData.contact_phone}
                    onChange={handleChange}
                  />
                </div>
              </div>

              <div className="grid md:grid-cols-2 gap-4">
                <div className="space-y-2">
                  <Label htmlFor="role">Role</Label>
                  <Select value={formData.role} onValueChange={(value) => handleSelectChange("role", value)}>
                    <SelectTrigger id="role">
                      <SelectValue placeholder="Select your role" />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="grama_niladhari">Grama Niladhari</SelectItem>
                    </SelectContent>
                  </Select>
                </div>
                <div className="space-y-2">
                  <Label htmlFor="department">Department</Label>
                  <Select value={formData.department} onValueChange={(value) => handleSelectChange("department", value)}>
                    <SelectTrigger id="department">
                      <SelectValue placeholder="Select your department" />
                    </SelectTrigger>
                    <SelectContent>
                      {DEPARTMENTS.map((dept) => (
                        <SelectItem key={dept} value={dept.toLowerCase().replace(/\s+/g, '_')}>
                          {dept}
                        </SelectItem>
                      ))}
                    </SelectContent>
                  </Select>
                </div>
              </div>

              <div className="space-y-2">
                <Label htmlFor="division">Division</Label>
                <Select value={formData.division} onValueChange={(value) => handleSelectChange("division", value)}>
                  <SelectTrigger id="division">
                    <SelectValue placeholder="Select your division" />
                  </SelectTrigger>
                  <SelectContent>
                    {DIVISIONS.map((division) => (
                      <SelectItem key={division} value={division.toLowerCase().replace(/\s+/g, '_')}>
                        {division}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </div>

              <div className="grid md:grid-cols-2 gap-4">
                <div className="space-y-2">
                  <Label htmlFor="password">Password</Label>
                  <Input
                    id="password"
                    name="password"
                    type="password"
                    value={formData.password}
                    onChange={handleChange}
                    required
                  />
                </div>
                <div className="space-y-2">
                  <Label htmlFor="confirmPassword">Confirm Password</Label>
                  <Input
                    id="confirmPassword"
                    name="confirmPassword"
                    type="password"
                    value={formData.confirmPassword}
                    onChange={handleChange}
                    required
                  />
                </div>
              </div>

              <Button type="submit" className="w-full" disabled={isLoading}>
                {isLoading ? "Registering..." : "Register Official"}
              </Button>
            </form>

            <div className="mt-6 text-center text-sm">
              <span className="text-muted-foreground">Already have an account? </span>
              <Link href="/auth/login" className="text-primary hover:underline">
                Sign in here
              </Link>
            </div>
          </CardContent>
        </Card>

        <div className="mt-6 text-center">
          <Link href="/" className="inline-flex items-center text-sm text-muted-foreground hover:text-foreground">
            <ArrowLeft className="h-4 w-4 mr-1" />
            Back to home
          </Link>
        </div>
      </div>
    </div>
  )
}

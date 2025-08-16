"use client"

import { useState } from "react"
import Link from "next/link"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { Badge } from "@/components/ui/badge"
import { ThemeToggle } from "@/components/theme-toggle"
import { Settings, ArrowLeft, Plus, Edit, Trash2, Save } from "lucide-react"

// Mock data for categories
const initialCategories = [
  {
    id: 1,
    name: "Health & Medical",
    description: "Health services and medical certificates",
    serviceCount: 8,
    color: "bg-red-100 text-red-800",
  },
  {
    id: 2,
    name: "Transportation",
    description: "Vehicle registration, licenses, and permits",
    serviceCount: 5,
    color: "bg-blue-100 text-blue-800",
  },
  {
    id: 3,
    name: "Business & Commerce",
    description: "Business licenses and commercial permits",
    serviceCount: 12,
    color: "bg-green-100 text-green-800",
  },
  {
    id: 4,
    name: "Finance & Revenue",
    description: "Tax services and financial documentation",
    serviceCount: 6,
    color: "bg-yellow-100 text-yellow-800",
  },
  {
    id: 5,
    name: "Education",
    description: "Educational services and certifications",
    serviceCount: 4,
    color: "bg-purple-100 text-purple-800",
  },
  {
    id: 6,
    name: "Social Services",
    description: "Social welfare and community services",
    serviceCount: 7,
    color: "bg-pink-100 text-pink-800",
  },
]

export default function ServiceCategoriesPage() {
  const [categories, setCategories] = useState(initialCategories)
  const [isAddingNew, setIsAddingNew] = useState(false)
  const [editingId, setEditingId] = useState<number | null>(null)
  const [newCategory, setNewCategory] = useState({ name: "", description: "" })

  const handleAddCategory = () => {
    if (newCategory.name.trim()) {
      const newId = Math.max(...categories.map((c) => c.id)) + 1
      setCategories([
        ...categories,
        {
          id: newId,
          name: newCategory.name,
          description: newCategory.description,
          serviceCount: 0,
          color: "bg-gray-100 text-gray-800",
        },
      ])
      setNewCategory({ name: "", description: "" })
      setIsAddingNew(false)
    }
  }

  const handleDeleteCategory = (id: number) => {
    setCategories(categories.filter((c) => c.id !== id))
  }

  return (
    <div className="min-h-screen bg-background">
      {/* Header */}
      <header className="border-b border-border bg-card">
        <div className="container mx-auto px-4 py-4 flex items-center justify-between">
          <div className="flex items-center space-x-4">
            <div className="flex items-center space-x-2">
              <div>
                <h1 className="text-xl font-bold text-foreground">Service Categories</h1>
                <p className="text-sm text-muted-foreground">Manage service categories and organization</p>
              </div>
            </div>
          </div>
          <div className="flex items-center space-x-4">
            <Button onClick={() => setIsAddingNew(true)}>
              <Plus className="h-4 w-4 mr-2" />
              Add Category
            </Button>
          </div>
        </div>
      </header>

      <div className="container mx-auto px-4 py-8">
        {/* Add New Category */}
        {isAddingNew && (
          <Card className="mb-6">
            <CardHeader>
              <CardTitle>Add New Category</CardTitle>
              <CardDescription>Create a new service category</CardDescription>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="grid md:grid-cols-2 gap-4">
                <div className="space-y-2">
                  <Label htmlFor="categoryName">Category Name</Label>
                  <Input
                    id="categoryName"
                    placeholder="Environment & Sustainability"
                    value={newCategory.name}
                    onChange={(e) => setNewCategory((prev) => ({ ...prev, name: e.target.value }))}
                  />
                </div>
                <div className="space-y-2">
                  <Label htmlFor="categoryDescription">Description</Label>
                  <Input
                    id="categoryDescription"
                    placeholder="Environmental services and permits"
                    value={newCategory.description}
                    onChange={(e) => setNewCategory((prev) => ({ ...prev, description: e.target.value }))}
                  />
                </div>
              </div>
              <div className="flex justify-end space-x-2">
                <Button variant="outline" onClick={() => setIsAddingNew(false)}>
                  Cancel
                </Button>
                <Button onClick={handleAddCategory}>
                  <Save className="h-4 w-4 mr-2" />
                  Add Category
                </Button>
              </div>
            </CardContent>
          </Card>
        )}

        {/* Categories Grid */}
        <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-6">
          {categories.map((category) => (
            <Card key={category.id} className="hover:shadow-md transition-shadow">
              <CardHeader>
                <div className="flex items-start justify-between">
                  <div className="flex-1">
                    <div className="flex items-center space-x-2 mb-2">
                      <CardTitle className="text-lg">{category.name}</CardTitle>
                      <Badge className={category.color}>{category.serviceCount} services</Badge>
                    </div>
                    <CardDescription>{category.description}</CardDescription>
                  </div>
                  <div className="flex items-center space-x-1">
                    <Button variant="ghost" size="icon" onClick={() => setEditingId(category.id)}>
                      <Edit className="h-4 w-4" />
                    </Button>
                    <Button
                      variant="ghost"
                      size="icon"
                      onClick={() => handleDeleteCategory(category.id)}
                      className="text-destructive hover:text-destructive"
                    >
                      <Trash2 className="h-4 w-4" />
                    </Button>
                  </div>
                </div>
              </CardHeader>
              <CardContent>
                <div className="text-sm text-muted-foreground">Used by {category.serviceCount} services</div>
              </CardContent>
            </Card>
          ))}
        </div>

        {categories.length === 0 && (
          <div className="text-center py-12">
            <Settings className="h-12 w-12 text-muted-foreground mx-auto mb-4" />
            <h3 className="text-lg font-medium text-foreground mb-2">No categories found</h3>
            <p className="text-muted-foreground mb-4">Create your first service category to organize your services</p>
            <Button onClick={() => setIsAddingNew(true)}>
              <Plus className="h-4 w-4 mr-2" />
              Add Category
            </Button>
          </div>
        )}
      </div>
    </div>
  )
}

"use client"

import type React from "react"

import { useState } from "react"
import { Button } from "@/components/ui/button"
import { ThemeToggle } from "@/components/theme-toggle"
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"
import { Badge } from "@/components/ui/badge"
import {
  Building2,
  Calendar,
  BarChart3,
  Settings,
  MessageSquare,
  FileText,
  Menu,
  X,
  Bell,
  LogOut,
  Home,
} from "lucide-react"
import Link from "next/link"
import { usePathname } from "next/navigation"
import { cn } from "@/lib/utils"

const navigation = [
  { name: "Dashboard", href: "/dashboard", icon: Home },
  { name: "Departments", href: "/dashboard/departments", icon: Building2 },
  { name: "Services", href: "/dashboard/services", icon: FileText },
  { name: "Appointments", href: "/dashboard/appointments", icon: Calendar },
  { name: "Analytics", href: "/dashboard/analytics", icon: BarChart3 },
  { name: "Chat", href: "/dashboard/chat", icon: MessageSquare },
]

export default function DashboardLayout({
  children,
}: {
  children: React.ReactNode
}) {
  const [sidebarOpen, setSidebarOpen] = useState(false)
  const [sidebarCollapsed, setSidebarCollapsed] = useState(false)
  const pathname = usePathname()

  return (
    <div className="min-h-screen bg-background">
      {/* Mobile sidebar overlay */}
      {sidebarOpen && (
        <div className="fixed inset-0 z-40 bg-black/50 lg:hidden" onClick={() => setSidebarOpen(false)} />
      )}

      {/* Sidebar */}
      <div
        className={cn(
          "fixed inset-y-0 left-0 z-50 border-r border-border transform transition-transform duration-200 ease-in-out lg:translate-x-0",
          "bg-card dark:bg-[#070C14]",
          sidebarOpen ? "translate-x-0" : "-translate-x-full",
          sidebarCollapsed ? "w-20" : "w-64"
        )}
      >
        <div className="flex flex-col h-full">
          {/* Sidebar Header: Logo + Toggle + Close */}
          <div className="flex items-center h-16 border-b border-border px-4">
            {/* Logo */}
            {!sidebarCollapsed && (
              <div className="flex items-center space-x-2">
                <Building2 className="h-8 w-8 text-primary" />
                <div>
                  <h1 className="text-lg font-bold text-foreground">Gov Services</h1>
                  <p className="text-xs text-muted-foreground">Management Portal</p>
                </div>
              </div>
            )}
            {/* Toggle Button */}
            <Button
              variant="ghost"
              size="icon"
              className={sidebarCollapsed ? "mx-auto" : "ml-2"}
              title="Expand sidebar"
              onClick={() => setSidebarCollapsed((prev) => !prev)}
            >
              <Menu className="h-5 w-5" />
            </Button>
            {/* Mobile Close Button */}
            <Button variant="ghost" size="sm" className="lg:hidden" onClick={() => setSidebarOpen(false)}>
              <X className="h-4 w-4" />
            </Button>
          </div>

          {/* Navigation */}
          <nav className="flex-1 p-4 space-y-2">
            {navigation.map((item) => {
              // Special logic: Dashboard button is only active on exact /dashboard
              let isActive = pathname === item.href;
              // Make 'Services' active for /dashboard/services and its subpages
              if (item.name === "Services" && pathname.startsWith("/dashboard/services/")) {
                isActive = true;
              }
              return (
                <Link
                  key={item.name}
                  href={item.href}
                  className={cn(
                    "flex items-center px-3 py-2 rounded-lg text-sm font-medium transition-colors",
                    sidebarCollapsed ? "justify-center" : "space-x-3",
                    isActive
                      ? "bg-primary text-primary-foreground"
                      : "text-muted-foreground hover:text-foreground hover:bg-muted",
                  )}
                  onClick={() => setSidebarOpen(false)}
                >
                  <item.icon className="h-5 w-5" />
                  {!sidebarCollapsed && <span>{item.name}</span>}
                </Link>
              )
            })}
          </nav>


          {/* Centered Logout Button at Bottom */}
          <div className="mt-auto flex justify-center pb-6">
            <Button
              variant="ghost"
              className={cn(
                "flex items-center transition-colors",
                sidebarCollapsed ? "justify-center" : "space-x-2",
                "hover:bg-red-100 hover:text-red-600"
              )}
              title="Logout"
            >
              <LogOut className="h-5 w-5" />
              {!sidebarCollapsed && <span className="text-base">Logout</span>}
            </Button>
          </div>

          {/* ...user profile section removed... */}
        </div>
      </div>

      {/* Main content */}
      <div
        className={cn(
          sidebarCollapsed ? "lg:pl-20" : "lg:pl-64"
        )}
      >
        {/* Top header */}
        <header
          className={cn(
            "border-b border-border fixed top-0 left-0 right-0 z-30",
            "bg-card dark:bg-[#070C14]",
            sidebarCollapsed ? "lg:pl-20" : "lg:pl-64"
          )}
        >
          <div className="flex items-center h-16 justify-between px-4">
            <div className="flex items-center space-x-4">
              <Button variant="ghost" size="sm" className="lg:hidden" onClick={() => setSidebarOpen(true)}>
                <Menu className="h-5 w-5" />
              </Button>
              <div>
                {pathname === "/dashboard" ? (
                  <>
                    <h2 className="text-lg font-semibold text-foreground">Dashboard</h2>
                    <p className="text-sm text-muted-foreground">Manage your government services efficiently</p>
                  </>
                ) : (
                  <>
                    <h2 className="text-lg font-semibold text-foreground">
                      {pathname.replace("/dashboard/", "").split("/")[0].replace(/-/g, " ").replace(/\b\w/g, c => c.toUpperCase())}
                    </h2>
                    <p className="text-sm text-muted-foreground">
                      {
                        {
                          services: "View and manage all government services.",
                          departments: "Browse and configure departments.",
                          appointments: "Schedule and review appointments.",
                          analytics: "Analyze service and appointment data.",
                          chat: "Communicate with other users and departments."
                        }[pathname.replace("/dashboard/", "").split("/")[0]] || "View details for this section."
                      }
                    </p>
                  </>
                )}
              </div>
            </div>

            <div className="flex items-center space-x-4">
              <Button variant="ghost" size="sm" className="relative">
                <Bell className="h-5 w-5" />
                <Badge className="absolute -top-1 -right-1 h-5 w-5 flex items-center justify-center p-0 text-xs">
                  3
                </Badge>
              </Button>
              <ThemeToggle />
              {/* User Profile Top Right */}
              <div className="flex items-center space-x-3 pl-4 border-l border-border">
                <Avatar className="h-8 w-8">
                  <AvatarImage src="/placeholder.svg?height=32&width=32" />
                  <AvatarFallback>JD</AvatarFallback>
                </Avatar>
                <div className="flex flex-col min-w-0">
                  <span className="text-sm font-medium text-foreground leading-tight truncate">John Doe</span>
                  <span className="text-xs text-muted-foreground truncate">Department of Health</span>
                </div>
                
              </div>
            </div>
          </div>
        </header>

  {/* Page content */}
  <main className="p-6 pt-[72px]">{children}</main>
      </div>
    </div>
  )
}

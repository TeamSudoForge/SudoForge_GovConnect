// API Configuration
const API_BASE_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3000';

export interface Department {
  department_id: number;
  name: string;
  email: string;
  description?: string;
  contact_email?: string;
  contact_phone?: string;
  isActive: boolean;
  role: string;
  createdAt: string;
  updatedAt: string;
}

export interface UpdateDepartmentRequest {
  name?: string;
  description?: string;
  contact_email?: string;
  contact_phone?: string;
  isActive?: boolean;
}

export class DepartmentsService {
  private static instance: DepartmentsService;

  private constructor() {}

  public static getInstance(): DepartmentsService {
    if (!DepartmentsService.instance) {
      DepartmentsService.instance = new DepartmentsService();
    }
    return DepartmentsService.instance;
  }

  private getAuthHeaders(): HeadersInit {
    const token = typeof window !== 'undefined' ? localStorage.getItem('dept_access_token') : null;
    return {
      'Content-Type': 'application/json',
      ...(token && { Authorization: `Bearer ${token}` }),
    };
  }

  async getAllDepartments(): Promise<Department[]> {
    const response = await fetch(`${API_BASE_URL}/departments`, {
      method: 'GET',
      headers: this.getAuthHeaders(),
    });

    if (!response.ok) {
      if (response.status === 401) {
        throw new Error('Unauthorized: Please log in again');
      }
      throw new Error('Failed to fetch departments');
    }

    return await response.json();
  }

  async getDepartmentById(id: number): Promise<Department> {
    const response = await fetch(`${API_BASE_URL}/departments/${id}`, {
      method: 'GET',
      headers: this.getAuthHeaders(),
    });

    if (!response.ok) {
      if (response.status === 401) {
        throw new Error('Unauthorized: Please log in again');
      }
      if (response.status === 404) {
        throw new Error('Department not found');
      }
      throw new Error('Failed to fetch department');
    }

    return await response.json();
  }

  async updateDepartment(id: number, data: UpdateDepartmentRequest): Promise<Department> {
    const response = await fetch(`${API_BASE_URL}/departments/${id}`, {
      method: 'PATCH',
      headers: this.getAuthHeaders(),
      body: JSON.stringify(data),
    });

    if (!response.ok) {
      if (response.status === 401) {
        throw new Error('Unauthorized: Please log in again');
      }
      if (response.status === 404) {
        throw new Error('Department not found');
      }
      const error = await response.json().catch(() => ({ message: 'Update failed' }));
      throw new Error(error.message || 'Failed to update department');
    }

    return await response.json();
  }

  async deleteDepartment(id: number): Promise<void> {
    const response = await fetch(`${API_BASE_URL}/departments/${id}`, {
      method: 'DELETE',
      headers: this.getAuthHeaders(),
    });

    if (!response.ok) {
      if (response.status === 401) {
        throw new Error('Unauthorized: Please log in again');
      }
      if (response.status === 404) {
        throw new Error('Department not found');
      }
      throw new Error('Failed to delete department');
    }
  }
}

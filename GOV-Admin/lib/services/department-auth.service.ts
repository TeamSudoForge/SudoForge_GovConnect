// API Configuration
const API_BASE_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3000';

export interface DepartmentLoginRequest {
  email: string;
  password: string;
}

export interface DepartmentRegisterRequest {
  name: string;
  email: string;
  password: string;
  description?: string;
  contact_email?: string;
  contact_phone?: string;
}

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

export interface DepartmentAuthResponse {
  department: Department;
  accessToken: string;
  refreshToken: string;
  expiresIn: number;
}

export class DepartmentAuthService {
  private static instance: DepartmentAuthService;
  private accessToken: string | null = null;
  private refreshToken: string | null = null;

  private constructor() {
    // Load tokens from localStorage if available
    if (typeof window !== 'undefined') {
      this.accessToken = localStorage.getItem('dept_access_token');
      this.refreshToken = localStorage.getItem('dept_refresh_token');
    }
  }

  public static getInstance(): DepartmentAuthService {
    if (!DepartmentAuthService.instance) {
      DepartmentAuthService.instance = new DepartmentAuthService();
    }
    return DepartmentAuthService.instance;
  }

  async login(credentials: DepartmentLoginRequest): Promise<DepartmentAuthResponse> {
    const response = await fetch(`${API_BASE_URL}/auth/department/login`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(credentials),
    });

    if (!response.ok) {
      const error = await response.json().catch(() => ({ message: 'Login failed' }));
      throw new Error(error.message || 'Login failed');
    }

    const data: DepartmentAuthResponse = await response.json();
    
    // Store tokens
    this.accessToken = data.accessToken;
    this.refreshToken = data.refreshToken;
    
    if (typeof window !== 'undefined') {
      localStorage.setItem('dept_access_token', data.accessToken);
      localStorage.setItem('dept_refresh_token', data.refreshToken);
      localStorage.setItem('department', JSON.stringify(data.department));
    }

    return data;
  }

  async register(data: DepartmentRegisterRequest): Promise<DepartmentAuthResponse> {
    const response = await fetch(`${API_BASE_URL}/auth/department/register`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(data),
    });

    if (!response.ok) {
      const error = await response.json().catch(() => ({ message: 'Registration failed' }));
      throw new Error(error.message || 'Registration failed');
    }

    const result: DepartmentAuthResponse = await response.json();
    
    // Store tokens
    this.accessToken = result.accessToken;
    this.refreshToken = result.refreshToken;
    
    if (typeof window !== 'undefined') {
      localStorage.setItem('dept_access_token', result.accessToken);
      localStorage.setItem('dept_refresh_token', result.refreshToken);
      localStorage.setItem('department', JSON.stringify(result.department));
    }

    return result;
  }

  async getProfile(): Promise<Department> {
    if (!this.accessToken) {
      throw new Error('No access token available');
    }

    const response = await fetch(`${API_BASE_URL}/auth/department/profile`, {
      headers: {
        'Authorization': `Bearer ${this.accessToken}`,
        'Content-Type': 'application/json',
      },
    });

    if (!response.ok) {
      if (response.status === 401) {
        // Token expired, clear storage
        this.logout();
        throw new Error('Session expired');
      }
      throw new Error('Failed to fetch profile');
    }

    return await response.json();
  }

  logout(): void {
    this.accessToken = null;
    this.refreshToken = null;
    
    if (typeof window !== 'undefined') {
      localStorage.removeItem('dept_access_token');
      localStorage.removeItem('dept_refresh_token');
      localStorage.removeItem('department');
    }
  }

  isAuthenticated(): boolean {
    return !!this.accessToken;
  }

  getCurrentDepartment(): Department | null {
    if (typeof window !== 'undefined') {
      const deptData = localStorage.getItem('department');
      return deptData ? JSON.parse(deptData) : null;
    }
    return null;
  }

  getAccessToken(): string | null {
    return this.accessToken;
  }
}

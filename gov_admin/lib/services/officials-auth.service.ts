// API Configuration
const API_BASE_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3000';

export interface OfficialsLoginRequest {
  email: string;
  password: string;
}

export interface OfficialsRegisterRequest {
  name: string;
  email: string;
  password: string;
  designation?: string;
  department?: string;
  division?: string;
  contact_phone?: string;
}

export interface Official {
  official_id: number;
  name: string;
  email: string;
  designation?: string;
  department?: string;
  division?: string;
  contact_phone?: string;
  isActive: boolean;
  role: string;
  createdAt: string;
  updatedAt: string;
}

export interface OfficialsAuthResponse {
  official: Official;
  accessToken: string;
  refreshToken: string;
  expiresIn: number;
}

export class OfficialsAuthService {
  private static instance: OfficialsAuthService;
  private accessToken: string | null = null;
  private refreshToken: string | null = null;

  private constructor() {
    // Load tokens from localStorage if available
    if (typeof window !== 'undefined') {
      this.accessToken = localStorage.getItem('official_access_token');
      this.refreshToken = localStorage.getItem('official_refresh_token');
    }
  }

  public static getInstance(): OfficialsAuthService {
    if (!OfficialsAuthService.instance) {
      OfficialsAuthService.instance = new OfficialsAuthService();
    }
    return OfficialsAuthService.instance;
  }

  async login(credentials: OfficialsLoginRequest): Promise<OfficialsAuthResponse> {
    const response = await fetch(`${API_BASE_URL}/auth/officials/login`, {
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

    const data: OfficialsAuthResponse = await response.json();
    
    // Store tokens
    this.accessToken = data.accessToken;
    this.refreshToken = data.refreshToken;
    
    if (typeof window !== 'undefined') {
      localStorage.setItem('official_access_token', data.accessToken);
      localStorage.setItem('official_refresh_token', data.refreshToken);
      localStorage.setItem('official', JSON.stringify(data.official));
    }

    return data;
  }

  async register(data: OfficialsRegisterRequest): Promise<OfficialsAuthResponse> {
    const response = await fetch(`${API_BASE_URL}/auth/officials/register`, {
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

    const result: OfficialsAuthResponse = await response.json();
    
    // Store tokens
    this.accessToken = result.accessToken;
    this.refreshToken = result.refreshToken;
    
    if (typeof window !== 'undefined') {
      localStorage.setItem('official_access_token', result.accessToken);
      localStorage.setItem('official_refresh_token', result.refreshToken);
      localStorage.setItem('official', JSON.stringify(result.official));
    }

    return result;
  }

  async getProfile(): Promise<Official> {
    if (!this.accessToken) {
      throw new Error('No access token available');
    }

    const response = await fetch(`${API_BASE_URL}/auth/officials/profile`, {
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
      localStorage.removeItem('official_access_token');
      localStorage.removeItem('official_refresh_token');
      localStorage.removeItem('official');
    }
  }

  isAuthenticated(): boolean {
    return !!this.accessToken;
  }

  getCurrentOfficial(): Official | null {
    if (typeof window !== 'undefined') {
      const officialData = localStorage.getItem('official');
      return officialData ? JSON.parse(officialData) : null;
    }
    return null;
  }

  getAccessToken(): string | null {
    return this.accessToken;
  }
}
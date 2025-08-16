export interface Service {
  id: string;
  title: string;
  description: string;
  isActive: boolean; 
  version: number;
  metadata: any;
  createdAt: string;
  updatedAt: string;
  sections?: FormSection[];
}

export interface FormSection {
  id: string; 
  title: string;
  description: string;
  pageNumber: number;
  orderIndex: number;
  formId: string;
  fields: FormField[];
  createdAt: string;
  updatedAt: string;
}

export interface FormField {
  id: string;
  label: string;
  fieldName: string;
  fieldType: string;
  isRequired: boolean;
  placeholder?: string;
  helpText?: string;
  orderIndex: number;
  validationRules?: any;
  options?: any;
  metadata?: any;
  sectionId: string;
  createdAt: string;
  updatedAt: string;
}

export interface CreateServiceRequest {
  title: string;
  description: string;
  sections?: CreateFormSection[];
}

export interface CreateFormSection {
  title: string;
  description?: string;
  pageNumber: number;
  orderIndex: number;
  fields: CreateFormField[];
}

export interface CreateFormField {
  label: string;
  fieldName: string;
  fieldType: string;
  isRequired: boolean;
  placeholder?: string;
  helpText?: string;
  orderIndex: number;
  validationRules?: any;
  options?: any;
  metadata?: any;
}

export interface UpdateServiceRequest {
  title?: string;
  description?: string;
  isActive?: boolean;
  sections?: CreateFormSection[];
}

export class ServicesService {
  private static instance: ServicesService;
  private baseUrl = 'http://localhost:3000/dynamic-forms';
  private departmentsUrl = 'http://localhost:3000/departments';

  private constructor() {}

  static getInstance(): ServicesService {
    if (!ServicesService.instance) {
      ServicesService.instance = new ServicesService();
    }
    return ServicesService.instance;
  }

  private getAuthHeaders(): HeadersInit {
    const token = localStorage.getItem('token');
    return {
      'Content-Type': 'application/json',
      ...(token && { Authorization: `Bearer ${token}` }),
    };
  }

  async getAllServices(active?: boolean): Promise<Service[]> {
    try {
      // Get all dynamic forms which represent our services
      const response = await fetch(this.baseUrl, {
        method: 'GET',
        headers: this.getAuthHeaders(),
      });

      if (!response.ok) {
        const errorData = await response.json().catch(() => ({}));
        throw new Error(errorData.message || `HTTP error! status: ${response.status}`);
      }

      const forms = await response.json();
      
      // Transform dynamic forms to services format - no transformation needed since structure matches
      return forms;
    } catch (error) {
      console.error('Error fetching services:', error);
      throw error;
    }
  }

  async getServiceById(serviceId: string): Promise<Service> {
    try {
      const response = await fetch(`${this.baseUrl}/${serviceId}`, {
        method: 'GET',
        headers: this.getAuthHeaders(),
      });

      if (!response.ok) {
        const errorData = await response.json().catch(() => ({}));
        throw new Error(errorData.message || `HTTP error! status: ${response.status}`);
      }

      const form = await response.json();
      
      // No transformation needed since structure matches
      return form;
    } catch (error) {
      console.error('Error fetching service:', error);
      throw error;
    }
  }

  async createService(serviceData: CreateServiceRequest): Promise<Service> {
    try {
      const response = await fetch(this.baseUrl, {
        method: 'POST',
        headers: this.getAuthHeaders(),
        body: JSON.stringify(serviceData),
      });

      if (!response.ok) {
        const errorData = await response.json().catch(() => ({}));
        throw new Error(errorData.message || `HTTP error! status: ${response.status}`);
      }

      const form = await response.json();
      
      // No transformation needed since structure matches
      return form;
    } catch (error) {
      console.error('Error creating service:', error);
      throw error;
    }
  }

  async updateService(serviceId: string, updateData: UpdateServiceRequest): Promise<Service> {
    try {
      const response = await fetch(`${this.baseUrl}/${serviceId}`, {
        method: 'PUT',
        headers: this.getAuthHeaders(),
        body: JSON.stringify(updateData),
      });

      if (!response.ok) {
        const errorData = await response.json().catch(() => ({}));
        throw new Error(errorData.message || `HTTP error! status: ${response.status}`);
      }

      const form = await response.json();
      
      // No transformation needed since structure matches
      return form;
    } catch (error) {
      console.error('Error updating service:', error);
      throw error;
    }
  }

  async deleteService(serviceId: string): Promise<void> {
    try {
      const response = await fetch(`${this.baseUrl}/${serviceId}`, {
        method: 'DELETE',
        headers: this.getAuthHeaders(),
      });

      if (!response.ok) {
        const errorData = await response.json().catch(() => ({}));
        throw new Error(errorData.message || `HTTP error! status: ${response.status}`);
      }
    } catch (error) {
      console.error('Error deleting service:', error);
      throw error;
    }
  }

  async toggleServiceStatus(serviceId: string): Promise<Service> {
    try {
      // First get the current service
      const currentService = await this.getServiceById(serviceId);
      
      // Update with toggled status
      return await this.updateService(serviceId, {
        isActive: !currentService.isActive
      });
    } catch (error) {
      console.error('Error toggling service status:', error);
      throw error;
    }
  }
}

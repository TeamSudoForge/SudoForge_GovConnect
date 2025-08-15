export interface DayOfWeekAnalytics {
  day: string;
  dayNumber: number;
  averageResponses: number;
  totalResponses: number;
}

export interface FormAnalyticsResponse {
  service_id: number;
  service_name: string;
  current_month: {
    year: number;
    month: number;
    total_responses: number;
  };
  weekly_analytics: DayOfWeekAnalytics[];
  status_breakdown: {
    pending: number;
    approved: number;
    rejected: number;
    [key: string]: number;
  };
}

export interface OverallAnalyticsResponse {
  total_services: number;
  total_responses: number;
  total_departments: number;
  most_popular_services: {
    service_id: number;
    service_name: string;
    response_count: number;
  }[];
}

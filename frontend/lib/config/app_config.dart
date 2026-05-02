class AppConfig {
  static const String apiBaseUrl = '/api';
  
  // Environment-specific configurations can be added here
  // For now, we use relative URLs since the backend serves the frontend
  // This works for both development and production (Railway)
  
  // API endpoints
  static const String authEndpoint = '$apiBaseUrl/auth';
  static const String projectsEndpoint = '$apiBaseUrl/projects';
  static const String tasksEndpoint = '$apiBaseUrl/tasks';
  static const String dashboardEndpoint = '$apiBaseUrl/dashboard';
  static const String usersEndpoint = '$apiBaseUrl/users';
  static const String healthEndpoint = '$apiBaseUrl/health';
}

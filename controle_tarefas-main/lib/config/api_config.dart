class ApiConfig {
  static const String baseUrl = 'https://tarefas-api-1-83wo.onrender.com';

  static const _urlsPlaceholder = {
    'https://tarefas-api.onrender.com',
    'https://SUA-API.onrender.com',
    'https://sua-api.onrender.com',
  };

  static bool get configurada => !_urlsPlaceholder.contains(baseUrl);
}

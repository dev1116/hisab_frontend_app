class ApiEndpoints {
  // Auth
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String me = '/auth/me';

  // Business
  static const String createBusiness = '/business';
  static const String myBusinesses = '/business/my';
  static String businessByCode(String code) => '/business/$code';
  static String businessTypes() => '/business/types';

  // Customers
  static String addCustomer(int bId) => '/business/$bId/customers';
  static String listCustomers(int bId) => '/business/$bId/customers';
  static String getCustomer(int bId, int cId) =>
      '/business/$bId/customers/$cId';

  // Quotations
  static String quotations(int bId) => '/business/$bId/quotations';
  static String quotationById(int bId, int id) =>
      '/business/$bId/quotations/$id';
  static String quotationStatus(int bId, int id) =>
      '/business/$bId/quotations/$id/status';
  static String quotationRevise(int bId, int id) =>
      '/business/$bId/quotations/$id/revise';

  // Utils
  static String pincode(String pin) => '/utils/pincode/$pin';

  // Base URL for files
  static const String baseUrl = 'http://13.201.66.37:8082';
  // static const String baseUrl =
  // "https://wisconsin-noted-represented-merge.trycloudflare.com/";
  static String fileUrl(String path) => '$baseUrl$path';
}

class ApiConstants {
  static const String serverUrl = 'https://agriconnect-api-q5rw.onrender.com';

  static const String baseUrl = '$serverUrl/api';

  // Auth
  static const String login = '/auth/login';
  static const String refresh = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String registerBuyer = '/auth/register/buyer';
  static const String registerFarmer = '/auth/register/farmer';
  static const String registerDeliverer = '/auth/register/deliverer';

  // Users
  static const String me = '/users/me';
  static const String farmers = '/users/farmers';

  // Products
  static const String products = '/products';
  static const String myProducts = '/products/my';

  // Cart
  static const String cart = '/cart';
  static const String cartItems = '/cart/items';

  // Orders
  static const String orders = '/orders';

  // Deliveries
  static const String deliveriesAvailable = '/deliveries/available';
  static const String deliveriesCurrent = '/deliveries/current';

  // Geo
  static const String wilayas = '/geo/wilayas';

  // Categories
  static const String categories = '/categories';

  // Reviews
  static const String reviews = '/reviews';
}

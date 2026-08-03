class ApiEndpoints {
  const ApiEndpoints._();

  static const String login = "login";
  static const String register = "register";
  static const String logout = "logout";
  static const String emailVerify = "email/verify";
  static const String emailResend = "email/resend";
  static const String passwordForgot = "password/forgot";
  static const String passwordReset = "password/reset";
  static const String passwordChange = "password/change";

  static const String profile = "profile";

  static const String banners = "banners";
  static const String categories = "categories";
  static const String products = "products";
  static const String productsDeals = "products/deals";
  static String product(Object id) => "products/$id";
  static String productRelated(Object id) => "products/$id/related";
  static String productReviews(Object id) => "products/$id/reviews";
  static String userProfile(Object id) => "users/$id/profile";

  static const String cart = "cart";
  static String cartItem(Object id) => "cart/$id";

  static const String wishlist = "wishlist";
  static String wishlistItem(Object id) => "wishlist/$id";

  static const String addresses = "addresses";
  static String address(Object id) => "addresses/$id";

  static const String orders = "orders";
  static String order(Object id) => "orders/$id";
  static String orderPay(Object id) => "orders/$id/pay";
  static String orderCancel(Object id) => "orders/$id/cancel";
  static const String couponsApply = "coupons/apply";

  static const String genieChat = "genie/chat";

  static const String notifications = "notifications";
  static const String notificationsReadAll = "notifications/read-all";
  static String notificationRead(Object id) => "notifications/$id/read";
  static const String deviceTokens = "device-tokens";

  static const String adminStats = "admin/stats";
  static const String adminOrders = "admin/orders";
  static String adminOrderStatus(Object id) => "admin/orders/$id/status";
  static const String adminProducts = "admin/products";
  static String adminProduct(Object id) => "admin/products/$id";
  static const String adminCategories = "admin/categories";
  static String adminCategory(Object id) => "admin/categories/$id";
  static const String adminCoupons = "admin/coupons";
  static String adminCoupon(Object id) => "admin/coupons/$id";
  static const String adminUsers = "admin/users";
  static String adminUserRole(Object id) => "admin/users/$id/role";
  static String adminUser(Object id) => "admin/users/$id";
  static const String adminBanners = "admin/banners";
  static String adminBanner(Object id) => "admin/banners/$id";
}

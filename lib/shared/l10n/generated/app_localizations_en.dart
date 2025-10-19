// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Backstage Cinema';

  @override
  String get common_ok => 'OK';

  @override
  String get common_cancel => 'Cancel';

  @override
  String get common_save => 'Save';

  @override
  String get common_delete => 'Delete';

  @override
  String get common_edit => 'Edit';

  @override
  String get common_back => 'Back';

  @override
  String get common_next => 'Next';

  @override
  String get common_search => 'Search';

  @override
  String get common_filter => 'Filter';

  @override
  String get common_loading => 'Loading...';

  @override
  String get common_error => 'Error';

  @override
  String get common_success => 'Success';

  @override
  String get common_confirm => 'Confirm';

  @override
  String get login_title => 'Welcome to Backstage';

  @override
  String get login_subtitle => 'Cinema management system';

  @override
  String get login_cpf_label => 'CPF';

  @override
  String get login_cpf_hint => 'Enter your CPF';

  @override
  String get login_password_label => 'Password';

  @override
  String get login_password_hint => 'Enter your password';

  @override
  String get login_button => 'Sign In';

  @override
  String get login_forgot_password => 'Forgot your password?';

  @override
  String get login_error_invalid_credentials => 'Invalid CPF or password';

  @override
  String get login_error_empty_cpf => 'Please enter your CPF';

  @override
  String get login_error_empty_password => 'Please enter your password';

  @override
  String get login_error_invalid_cpf => 'Invalid CPF';

  @override
  String get features_carousel_pos_title => 'Point of Sale';

  @override
  String get features_carousel_pos_description =>
      'Quick and intuitive ticket and product sales';

  @override
  String get features_carousel_sessions_title => 'Session Management';

  @override
  String get features_carousel_sessions_description =>
      'Complete control of sessions and cinema rooms';

  @override
  String get features_carousel_inventory_title => 'Inventory Control';

  @override
  String get features_carousel_inventory_description =>
      'Efficient management of products and supplies';

  @override
  String get features_carousel_reports_title => 'Reports and Analytics';

  @override
  String get features_carousel_reports_description =>
      'Real-time data for better decision making';

  @override
  String get splash_loading => 'Loading...';

  @override
  String get dashboard_title => 'Dashboard';

  @override
  String dashboard_greeting(String name) {
    return 'Hello, $name!';
  }

  @override
  String get dashboard_sales_today => 'Sales Today';

  @override
  String get dashboard_tickets_sold => 'Tickets Sold';

  @override
  String get dashboard_sessions_active => 'Active Sessions';

  @override
  String get dashboard_occupancy_rate => 'Occupancy Rate';

  @override
  String get pos_title => 'Point of Sale';

  @override
  String get pos_select_session => 'Select Session';

  @override
  String get pos_select_products => 'Add Products';

  @override
  String get pos_cart_title => 'Cart';

  @override
  String get pos_cart_empty => 'Empty cart';

  @override
  String get pos_total => 'Total';

  @override
  String get pos_finalize_sale => 'Finalize Sale';

  @override
  String get pos_payment_method => 'Payment Method';

  @override
  String get pos_payment_cash => 'Cash';

  @override
  String get pos_payment_card => 'Card';

  @override
  String get pos_payment_pix => 'PIX';

  @override
  String get pos_sale_success => 'Sale completed successfully!';

  @override
  String get pos_sale_error => 'Error processing sale';

  @override
  String get sessions_title => 'Sessions';

  @override
  String get sessions_scheduled => 'Scheduled';

  @override
  String get sessions_in_progress => 'In Progress';

  @override
  String get sessions_completed => 'Completed';

  @override
  String sessions_room(String number) {
    return 'Room $number';
  }

  @override
  String get sessions_occupancy => 'Occupancy';

  @override
  String get sessions_create => 'New Session';

  @override
  String get sessions_edit => 'Edit Session';

  @override
  String get sessions_delete_confirm =>
      'Do you really want to delete this session?';

  @override
  String get inventory_title => 'Inventory';

  @override
  String get inventory_products => 'Products';

  @override
  String get inventory_low_stock => 'Low Stock';

  @override
  String get inventory_out_of_stock => 'Out of Stock';

  @override
  String get inventory_add_product => 'Add Product';

  @override
  String get inventory_edit_product => 'Edit Product';

  @override
  String get inventory_product_name => 'Product Name';

  @override
  String get inventory_product_quantity => 'Quantity';

  @override
  String get inventory_product_price => 'Price';

  @override
  String get inventory_product_category => 'Category';

  @override
  String get inventory_save_success => 'Product saved successfully';

  @override
  String get inventory_save_error => 'Error saving product';

  @override
  String get reports_title => 'Reports';

  @override
  String get reports_sales => 'Sales';

  @override
  String get reports_sessions => 'Sessions';

  @override
  String get reports_inventory => 'Inventory';

  @override
  String get reports_period => 'Period';

  @override
  String get reports_today => 'Today';

  @override
  String get reports_week => 'Week';

  @override
  String get reports_month => 'Month';

  @override
  String get reports_custom => 'Custom';

  @override
  String get reports_export => 'Export';

  @override
  String get reports_generate => 'Generate Report';

  @override
  String get profile_title => 'Profile';

  @override
  String get profile_name => 'Name';

  @override
  String get profile_cpf => 'CPF';

  @override
  String get profile_role => 'Role';

  @override
  String get profile_cinema => 'Cinema';

  @override
  String get profile_change_password => 'Change Password';

  @override
  String get profile_logout => 'Logout';

  @override
  String get profile_logout_confirm => 'Do you really want to logout?';

  @override
  String get settings_title => 'Settings';

  @override
  String get settings_general => 'General';

  @override
  String get settings_notifications => 'Notifications';

  @override
  String get settings_appearance => 'Appearance';

  @override
  String get settings_language => 'Language';

  @override
  String get settings_about => 'About';

  @override
  String get error_network => 'Connection error. Check your internet.';

  @override
  String get error_server => 'Server error. Try again later.';

  @override
  String get error_unknown => 'Unknown error. Try again.';

  @override
  String get error_timeout => 'Timeout exceeded. Try again.';

  @override
  String get validation_required => 'Required field';

  @override
  String get validation_invalid_email => 'Invalid email';

  @override
  String get validation_invalid_cpf => 'Invalid CPF';

  @override
  String validation_min_length(int count) {
    return 'Minimum $count characters';
  }

  @override
  String validation_max_length(int count) {
    return 'Maximum $count characters';
  }
}

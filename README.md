# Naseej Admin - Egyptian Handmade Carpets Admin Panel

<div align="center">

![Naseej Admin Logo](assets/images/icon3.png)

A comprehensive administrative dashboard for managing Egyptian handmade carpet e-commerce operations

</div>

---

## 📱 About The Project

Naseej Admin is a powerful Flutter-based administration panel designed specifically for managing carpet and rug e-commerce operations. Built with GetX state management and a focus on efficiency, this app provides complete control over products, orders, customers, delivery operations, and store management.

### 🎯 Key Highlights

- **Complete Admin Control**: Manage all aspects of the e-commerce platform
- **Real-Time Updates**: Live order tracking and inventory management
- **Advanced Analytics**: Comprehensive dashboard with sales insights
- **Multi-Role Support**: Admin and Manager role management
- **Offline Capability**: Internet connectivity detection with auto-reconnection
- **PDF Reporting**: Export dashboard reports for analysis

---

## ✨ Features

### 📊 Dashboard & Analytics

#### Performance Metrics
- Total revenue and monthly sales tracking
- Revenue growth percentage calculations
- Order statistics (total, pending, delivered)
- Customer analytics (total, new customers)
- Visual charts (weekly and monthly sales trends)

#### Top Performers
- Best-selling products with revenue tracking
- Top customers by order count and spending
- Leading delivery personnel by ratings
- Most successful stores by revenue
- Top-performing categories

#### PDF Export
- Generate comprehensive dashboard reports
- Include all statistics and charts
- Downloadable and shareable format
- Timestamp and admin attribution

### 🛍️ Product Management

#### Product Catalog
- Grid and list view displays
- Advanced search and filtering
- Category-based organization
- Stock level monitoring
- Low stock and out-of-stock alerts

#### Product Operations
- Add new products with multiple images
- Edit product details and pricing
- Toggle product active/inactive status
- Delete products with confirmation
- View detailed product information
- Manage product categories

#### Inventory Control
- Real-time stock tracking
- Price and discount management
- Product status indicators
- Image gallery management

### 📦 Order Management

#### Order Processing
- View all orders with status filters
- Real-time order status updates
- Order details with customer information
- Delivery tracking and assignment
- Order history and analytics

#### Status Management
- Pending orders queue
- Confirmed order processing
- Shipping coordination
- Delivery confirmation
- Cancellation handling

#### Order Tracking
- Customer details and contact info
- Payment status monitoring
- Delivery person assignment
- Order timeline visualization
- Reorder functionality

### 👥 Customer Management

#### Customer Database
- Complete customer profiles
- Order history per customer
- Contact information management
- Customer status (active/inactive)
- Total spending analytics

#### Customer Analytics
- Top customers by revenue
- Order frequency tracking
- Last order date tracking
- Customer lifetime value
- Profile image management

### 🚚 Delivery Management

#### Delivery Personnel
- Add and manage delivery staff
- Track deliveries in real-time
- Monitor delivery ratings
- Manage vehicle information
- Status tracking (available/busy/offline)

#### Delivery Operations
- Assign orders to delivery personnel
- Track delivery performance
- View delivery history
- Manage delivery schedules
- Contact information management

### 🏪 Store Management

#### Physical Store Network
- Add and edit store locations
- Manage store operating hours
- Store-specific order processing
- Manager assignment
- Store status management (open/closed)

#### Store Operations
- Store address and contact details
- Opening/closing hours configuration
- Store image uploads
- Active/inactive status toggle
- Location-based filtering

### 🗂️ Category Management

#### Category Organization
- Create and edit categories
- Category image uploads
- Reorder categories via drag-and-drop
- Product count per category
- Active/inactive category status

#### Category Features
- Category-based product filtering
- Category descriptions
- Visual category representation
- Delete categories with warnings

### 👨‍💼 Admin Management

#### Admin Users
- Add new admin accounts
- Edit admin profiles
- Role assignment (admin/manager)
- Admin status management
- Password management for admins

#### Admin Operations
- View admin details
- Change admin passwords
- Activate/deactivate admin accounts
- Delete admin accounts
- Profile image management

### 🔐 Authentication & Security

#### Login System
- Secure email/password authentication
- Token-based session management
- Auto-logout on password change
- Internet connectivity checking

#### Profile Management
- Update personal information
- Profile image upload
- Change password functionality
- Email (read-only)
- Phone number updates

### 🔔 Notifications

#### Notification System
- Real-time notification delivery
- Unread count badges
- Mark as read functionality
- Notification filtering (all/unread/read)
- Delete notifications
- Clear all notifications

#### Notification Types
- Order notifications
- Delivery updates
- System alerts
- Product updates
- Customer activities

### ⚙️ Settings & Preferences

#### App Settings
- Theme selection
- Language preferences (if implemented)
- Notification settings
- Profile management
- About app information

#### Account Management
- Change password
- Update profile information
- Logout functionality
- Account security

---

## 🏗️ Architecture

### Project Structure

```
lib/
├── config/
│   ├── routes.dart                 # App routing configuration
│   ├── app_colors.dart            # Color scheme constants
│   └── app_theme.dart             # Theme configuration
│
├── controllers/                    # GetX Controllers
│   ├── auth_controller.dart       # Authentication logic
│   ├── profile_controller.dart    # Profile management
│   ├── DashboardController.dart   # Dashboard analytics
│   ├── product_controller.dart    # Product operations
│   ├── category_controller.dart   # Category management
│   ├── order_controller.dart      # Order processing
│   ├── customer_controller.dart   # Customer management
│   ├── delivery_controller.dart   # Delivery operations
│   ├── store_controller.dart      # Store management
│   ├── admin_controller.dart      # Admin user management
│   └── notification_controller.dart # Notifications
│
├── models/                         # Data Models
│   ├── product.dart
│   ├── category.dart
│   ├── order.dart
│   ├── customer.dart
│   ├── delivery_man.dart
│   ├── store.dart
│   ├── admin_user.dart
│   └── notification_model.dart
│
├── screens/                        # UI Screens
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── change_password_screen.dart
│   │
│   ├── dashboard/
│   │   └── dashboard_screen.dart
│   │
│   ├── products/
│   │   ├── products_screen.dart
│   │   ├── product_details_screen.dart
│   │   ├── add_product_screen.dart
│   │   └── edit_product_screen.dart
│   │
│   ├── categories/
│   │   ├── categories_screen.dart
│   │   └── category_form_screen.dart
│   │
│   ├── orders/
│   │   ├── orders_screen.dart
│   │   └── order_details_screen.dart
│   │
│   ├── customers/
│   │   ├── customers_screen.dart
│   │   └── customer_details_screen.dart
│   │
│   ├── delivery/
│   │   ├── delivery_screen.dart
│   │   └── delivery_form_screen.dart
│   │
│   ├── stores/
│   │   ├── stores_screen.dart
│   │   ├── store_form_screen.dart
│   │   └── store_details_screen.dart
│   │
│   ├── admin/
│   │   ├── admins_screen.dart
│   │   ├── admin_details_screen.dart
│   │   ├── add_admin_screen.dart
│   │   └── change_admin_password_screen.dart
│   │
│   ├── profile/
│   │   └── profile_screen.dart
│   │
│   ├── notifications/
│   │   └── notifications_screen.dart
│   │
│   └── about/
│       └── about_screen.dart
│
├── services/                       # Business Logic Services
│   ├── api_service.dart           # API communication
│   └── auth_service.dart          # Authentication service
│
├── widgets/                        # Reusable Widgets
│   ├── sidebar_menu.dart          # Navigation drawer
│   ├── custom_button.dart         # Custom button widget
│   ├── custom_text_field.dart     # Custom input field
│   ├── stat_card.dart             # Statistics card
│   └── internet_checker_widget.dart
│
├── utils/                          # Utility Classes
│   ├── validators.dart            # Form validators
│   ├── internet_checker.dart      # Connectivity check
│   ├── internet_middleware.dart   # Internet middleware
│   └── alterexitapp.dart          # Exit confirmation
│
└── main.dart                       # App entry point
```

### Design Patterns

- **GetX Pattern**: State management with GetX controllers
- **Service Layer Pattern**: Separation of business logic from UI
- **Repository Pattern**: Data access abstraction via services
- **Singleton Pattern**: Permanent controllers and services
- **Factory Pattern**: Model creation from JSON responses
- **Observer Pattern**: Reactive state management with Obx

### State Management

- **GetX Controllers**: Reactive state management
- **Persistent Controllers**: `permanent: true` for core features
- **Reactive Variables**: `.obs` for observable state
- **Dependency Injection**: `Get.put()` and `Get.find()`

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (>=3.0.0)
- Dart SDK (>=3.0.0)
- Android Studio / VS Code with Flutter extension
- iOS Simulator / Android Emulator
- Git
- Backend API server running

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/naseej-admin-app.git
   cd naseej-admin-app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure API endpoints**
   
   Update `lib/services/api_service.dart` with your backend URL:
   ```dart
   class ApiService {
     static const String baseUrl = "https://your-backend-url.com/api";
     // ... rest of configuration
   }
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

### Environment Setup

The app automatically initializes all required controllers in `main.dart`:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services
  Get.put(ApiService(), permanent: true);
  Get.put(AuthService(), permanent: true);
  
  // Initialize controllers
  Get.put(AuthController(), permanent: true);
  Get.put(ProfileController(), permanent: true);
  // ... other controllers
  
  runApp(const NaseejAdminApp());
}
```

---

## 📦 Dependencies

### Core Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  get: ^4.6.6
  
  # Network & API
  http: ^1.1.0
  
  # UI Components
  cached_network_image: ^3.3.0
  
  # Image Handling
  image_picker: ^1.0.5
  
  # PDF Generation
  pdf: ^3.10.7
  printing: ^5.11.1
  
  # Utilities
  intl: ^0.18.1
  connectivity_plus: ^5.0.1
```

### Development Dependencies

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
```

---

## 🔌 API Documentation

### Base URL
```
https://your-backend-url.com/api/admin
```

### Authentication Endpoints

#### Admin Login
```http
POST /auth/login
Content-Type: application/json

{
  "email": "admin@example.com",
  "password": "password123"
}

Response:
{
  "status": "success",
  "data": {
    "admin": {
      "id": "string",
      "name": "string",
      "email": "string",
      "role": "admin|manager",
      "profile_image": "string|null"
    },
    "token": "Bearer token"
  }
}
```

#### Change Password
```http
POST /auth/change-password
Authorization: Bearer {token}
Content-Type: application/json

{
  "current_password": "string",
  "new_password": "string",
  "confirm_password": "string"
}
```

### Dashboard Endpoints

#### Get Dashboard Stats
```http
GET /dashboard/stats
Authorization: Bearer {token}

Response:
{
  "total_revenue": number,
  "month_sales": number,
  "revenue_growth": number,
  "total_orders": number,
  "pending_orders": number,
  "total_customers": number,
  "new_customers_week": number
}
```

#### Get Sales Charts
```http
GET /dashboard/charts
Authorization: Bearer {token}

Response:
{
  "weekly_labels": ["Mon", "Tue", ...],
  "weekly_revenue": [100, 200, ...],
  "monthly_labels": ["Jan", "Feb", ...],
  "monthly_revenue": [1000, 2000, ...]
}
```

### Product Endpoints

#### Get All Products
```http
GET /products
Authorization: Bearer {token}

Query Parameters:
- category_id (optional)
- search (optional)
- active (optional)
```

#### Create Product
```http
POST /products/create
Authorization: Bearer {token}
Content-Type: multipart/form-data

{
  "name": "string",
  "description": "string",
  "price": number,
  "discount_price": number|null,
  "stock": number,
  "category_id": "string",
  "images[]": [File, File, ...],
  "is_active": boolean
}
```

#### Update Product
```http
POST /products/update/{id}
Authorization: Bearer {token}
Content-Type: multipart/form-data

{
  "name": "string",
  "description": "string",
  "price": number,
  "stock": number,
  // ... other fields
}
```

#### Delete Product
```http
DELETE /products/delete/{id}
Authorization: Bearer {token}
```

### Order Endpoints

#### Get All Orders
```http
GET /orders
Authorization: Bearer {token}

Query Parameters:
- status (optional): pending|confirmed|processing|shipped|delivered|cancelled
- search (optional)
```

#### Update Order Status
```http
POST /orders/update-status/{id}
Authorization: Bearer {token}
Content-Type: application/json

{
  "status": "confirmed|processing|shipped|delivered|cancelled"
}
```

#### Assign Delivery Person
```http
POST /orders/assign-delivery/{id}
Authorization: Bearer {token}
Content-Type: application/json

{
  "delivery_man_id": "string"
}
```

### Customer Endpoints

#### Get All Customers
```http
GET /customers
Authorization: Bearer {token}

Query Parameters:
- search (optional)
- is_active (optional)
```

#### Toggle Customer Status
```http
POST /customers/toggle-status/{id}
Authorization: Bearer {token}
Content-Type: application/json

{
  "is_active": boolean
}
```

### Delivery Endpoints

#### Get All Delivery Personnel
```http
GET /delivery-men
Authorization: Bearer {token}
```

#### Create Delivery Person
```http
POST /delivery-men/create
Authorization: Bearer {token}
Content-Type: multipart/form-data

{
  "name": "string",
  "email": "string",
  "phone": "string",
  "vehicle_type": "string",
  "vehicle_number": "string",
  "profile_image": File|null
}
```

#### Update Delivery Status
```http
POST /delivery-men/update-status/{id}
Authorization: Bearer {token}
Content-Type: application/json

{
  "status": "available|busy|offline"
}
```

### Store Endpoints

#### Get All Stores
```http
GET /stores
Authorization: Bearer {token}
```

#### Create Store
```http
POST /stores/create
Authorization: Bearer {token}
Content-Type: multipart/form-data

{
  "name": "string",
  "address": "string",
  "city": "string",
  "region": "string",
  "manager_name": "string",
  "phone": "string",
  "opening_time": "HH:mm",
  "closing_time": "HH:mm",
  "image": File|null
}
```

### Notification Endpoints

#### Get Notifications
```http
GET /notifications
Authorization: Bearer {token}

Query Parameters:
- is_read (optional): true|false
```

#### Mark as Read
```http
POST /notifications/mark-read/{id}
Authorization: Bearer {token}
```

#### Clear All
```http
DELETE /notifications/clear-all
Authorization: Bearer {token}
```

---

## 🎨 Theme & Styling

### Color Palette

```dart
class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF8B3C3C);
  static const Color accent = Color(0xFFD4A574);
  
  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);
  
  // Neutral Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey = Color(0xFF9E9E9E);
  static const Color lightGrey = Color(0xFFF5F5F5);
  static const Color background = Color(0xFFFAFAFA);
  
  // Text Colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  
  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, accent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
```

### Typography

- **Headers**: System Bold (24-32px)
- **Body**: System Regular (14-16px)
- **Captions**: System Regular (12px)

---

## 📱 Screenshots

### Dashboard
- Sales analytics with charts
- Quick statistics cards
- Recent orders preview
- Top performers lists

### Product Management
- Product grid/list view
- Product details with images
- Add/Edit product forms
- Category filtering

### Order Management
- Order list with status filters
- Order details view
- Status update workflow
- Delivery assignment

### User Management
- Customer list
- Admin list
- Delivery personnel list
- Store locations

---

## 🧪 Testing

### Running Tests

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage
```

### Test Structure

```
test/
├── unit/
│   ├── controllers/
│   ├── services/
│   └── models/
├── widget/
│   └── screens/
└── integration/
    └── flows/
```

---

## 📱 Building for Production

### Android

```bash
# Build APK
flutter build apk --release

# Build App Bundle
flutter build appbundle --release
```

### iOS

```bash
# Build IPA
flutter build ios --release
```

### Version Management

Update in `pubspec.yaml`:
```yaml
version: 1.0.0+1
```

---

## 🔒 Security Considerations

### Best Practices Implemented

1. **Token-Based Authentication**: Secure JWT tokens
2. **Auto Logout**: On password change for security
3. **Input Validation**: Server-side and client-side
4. **Secure Storage**: Encrypted token storage
5. **HTTPS Only**: All API calls over HTTPS
6. **Role-Based Access**: Admin and Manager roles

### Recommendations

- Use environment variables for sensitive data
- Implement certificate pinning for production
- Enable ProGuard/R8 for Android builds
- Use secure storage packages for tokens

---

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Code Style

- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart)
- Use GetX patterns for state management
- Write meaningful commit messages
- Add comments for complex logic
- Run `flutter analyze` before committing

---


## 📋 Changelog

### Version 1.0.0 (Current)
- Initial release
- Complete admin dashboard
- Product, order, and customer management
- Delivery and store management
- Notification system
- PDF report generation

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 📧 Contact

**Project Maintainer**: Naseej Team
- Email: admin@naseej.com
- Phone: +966 123 456 789
- Website: www.naseej.com

**Technical Support**: support@naseej.com

---

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- GetX community for excellent state management
- Egyptian artisan community for inspiration
- All contributors to this project

---

## 📚 Additional Resources

### Documentation
- [Flutter Documentation](https://flutter.dev/docs)
- [GetX Documentation](https://pub.dev/packages/get)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)

### Tutorials
- [Flutter Best Practices](https://flutter.dev/docs/development/best-practices)
- [GetX State Management](https://github.com/jonataslaw/getx/blob/master/README.md)

---

## 🔄 Version Compatibility

### Tested With
- **Flutter**: 3.10.0+
- **Dart**: 3.0.0+
- **Android**: API 21+ (Android 5.0+)
- **iOS**: iOS 12.0+

### Backend Compatibility
- Compatible with Naseej User App v1.0.0
- Requires Backend API v1.0.0+



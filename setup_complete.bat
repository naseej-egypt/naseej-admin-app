@echo off
chcp 65001 >nul
color 0A
echo.
echo ╔════════════════════════════════════════════════════════════╗
echo ║         NASEEJ ADMIN PANEL - PROJECT SETUP                 ║
echo ║         Complete Structure Creator                         ║
echo ╚════════════════════════════════════════════════════════════╝
echo.

:: Check if Flutter is installed
flutter --version >nul 2>&1
if errorlevel 1 (
    color 0C
    echo [ERROR] Flutter is not installed or not in PATH!
    echo Please install Flutter from: https://flutter.dev/docs/get-started/install
    pause
    exit /b 1
)

echo [✓] Flutter is installed
echo.

:: Ask for project location
set "PROJECT_PATH=%cd%\naseej_admin"
echo Default project location: %PROJECT_PATH%
set /p "CUSTOM_PATH=Enter custom path or press Enter to use default: "
if not "%CUSTOM_PATH%"=="" set "PROJECT_PATH=%CUSTOM_PATH%"

echo.
echo Creating project at: %PROJECT_PATH%
echo.

:: Create project directory
if exist "%PROJECT_PATH%" (
    echo [WARNING] Directory already exists!
    set /p "CONTINUE=Do you want to continue? (y/n): "
    if /i not "%CONTINUE%"=="y" exit /b 0
)

mkdir "%PROJECT_PATH%" 2>nul
cd /d "%PROJECT_PATH%"

:: Create Flutter project
echo.
echo ═══════════════════════════════════════
echo Step 1: Creating Flutter Project
echo ═══════════════════════════════════════
call flutter create . --org com.naseej --platforms=android,ios,web --project-name naseej_admin
if errorlevel 1 (
    color 0C
    echo [ERROR] Failed to create Flutter project!
    pause
    exit /b 1
)
echo [✓] Flutter project created
echo.

:: Create directory structure
echo ═══════════════════════════════════════
echo Step 2: Creating Directory Structure
echo ═══════════════════════════════════════

mkdir lib\config 2>nul
mkdir lib\models 2>nul
mkdir lib\services 2>nul
mkdir lib\controllers 2>nul
mkdir lib\screens\auth 2>nul
mkdir lib\screens\dashboard 2>nul
mkdir lib\screens\products 2>nul
mkdir lib\screens\categories 2>nul
mkdir lib\screens\orders 2>nul
mkdir lib\screens\customers 2>nul
mkdir lib\screens\delivery 2>nul
mkdir lib\widgets 2>nul
mkdir lib\utils 2>nul
mkdir assets\images 2>nul
mkdir web\icons 2>nul

echo [✓] Directory structure created
echo.

:: Create placeholder files
echo ═══════════════════════════════════════
echo Step 3: Creating Placeholder Files
echo ═══════════════════════════════════════

:: Config files
echo // TODO: Add app_colors implementation > lib\config\app_colors.dart
echo // TODO: Add app_theme implementation > lib\config\app_theme.dart
echo // TODO: Add routes implementation > lib\config\routes.dart

:: Model files
echo // TODO: Add admin_user model > lib\models\admin_user.dart
echo // TODO: Add product model > lib\models\product.dart
echo // TODO: Add category model > lib\models\category.dart
echo // TODO: Add order model > lib\models\order.dart
echo // TODO: Add customer model > lib\models\customer.dart
echo // TODO: Add delivery_man model > lib\models\delivery_man.dart

:: Service files
echo // TODO: Add auth_service > lib\services\auth_service.dart
echo // TODO: Add product_service > lib\services\product_service.dart
echo // TODO: Add category_service > lib\services\category_service.dart
echo // TODO: Add order_service > lib\services\order_service.dart
echo // TODO: Add customer_service > lib\services\customer_service.dart
echo // TODO: Add delivery_service > lib\services\delivery_service.dart
echo // TODO: Add dashboard_service > lib\services\dashboard_service.dart

:: Controller files
echo // TODO: Add auth_controller > lib\controllers\auth_controller.dart
echo // TODO: Add product_controller > lib\controllers\product_controller.dart
echo // TODO: Add category_controller > lib\controllers\category_controller.dart
echo // TODO: Add order_controller > lib\controllers\order_controller.dart
echo // TODO: Add customer_controller > lib\controllers\customer_controller.dart
echo // TODO: Add delivery_controller > lib\controllers\delivery_controller.dart

:: Screen files
echo // TODO: Add login_screen > lib\screens\auth\login_screen.dart
echo // TODO: Add dashboard_screen > lib\screens\dashboard\dashboard_screen.dart
echo // TODO: Add products_screen > lib\screens\products\products_screen.dart
echo // TODO: Add add_product_screen > lib\screens\products\add_product_screen.dart
echo // TODO: Add edit_product_screen > lib\screens\products\edit_product_screen.dart
echo // TODO: Add categories_screen > lib\screens\categories\categories_screen.dart
echo // TODO: Add category_form_screen > lib\screens\categories\category_form_screen.dart
echo // TODO: Add orders_screen > lib\screens\orders\orders_screen.dart
echo // TODO: Add order_details_screen > lib\screens\orders\order_details_screen.dart
echo // TODO: Add customers_screen > lib\screens\customers\customers_screen.dart
echo // TODO: Add customer_details_screen > lib\screens\customers\customer_details_screen.dart
echo // TODO: Add delivery_screen > lib\screens\delivery\delivery_screen.dart
echo // TODO: Add delivery_form_screen > lib\screens\delivery\delivery_form_screen.dart

:: Widget files
echo // TODO: Add custom_button > lib\widgets\custom_button.dart
echo // TODO: Add custom_text_field > lib\widgets\custom_text_field.dart
echo // TODO: Add stat_card > lib\widgets\stat_card.dart
echo // TODO: Add data_table_widget > lib\widgets\data_table_widget.dart
echo // TODO: Add sidebar_menu > lib\widgets\sidebar_menu.dart

:: Utils files
echo // TODO: Add constants > lib\utils\constants.dart
echo // TODO: Add validators > lib\utils\validators.dart

echo [✓] Placeholder files created
echo.

:: Create SETUP_GUIDE.md
echo ═══════════════════════════════════════
echo Step 4: Creating Setup Guide
echo ═══════════════════════════════════════

(
echo # 🚀 Naseej Admin Panel - Setup Guide
echo.
echo ## ✅ Project Structure Created Successfully!
echo.
echo ### 📁 Directory Structure:
echo ```
echo naseej_admin/
echo ├── lib/
echo │   ├── config/          # Configuration files
echo │   ├── models/          # Data models
echo │   ├── services/        # Business logic
echo │   ├── controllers/     # State management
echo │   ├── screens/         # UI screens
echo │   ├── widgets/         # Reusable widgets
echo │   └── utils/           # Utilities
echo ├── assets/
echo │   └── images/
echo ├── web/
echo └── pubspec.yaml
echo ```
echo.
echo ### 📝 Next Steps:
echo.
echo #### 1. Copy the provided code files
echo Copy all Dart code from the chat into their respective files:
echo - Replace `lib/config/*.dart` files
echo - Replace `lib/models/*.dart` files
echo - Replace `lib/services/*.dart` files
echo - Replace `lib/controllers/*.dart` files
echo - Replace `lib/screens/**/*.dart` files
echo - Replace `lib/widgets/*.dart` files
echo - Replace `lib/utils/*.dart` files
echo.
echo #### 2. Update pubspec.yaml
echo Replace the content of `pubspec.yaml` with the provided version that includes:
echo - get: ^4.6.6
echo - firebase_core: ^2.24.2
echo - firebase_auth: ^4.16.0
echo - cloud_firestore: ^4.14.0
echo - And all other dependencies
echo.
echo #### 3. Install dependencies
echo ```bash
echo flutter pub get
echo ```
echo.
echo #### 4. Configure Firebase
echo ```bash
echo # Install FlutterFire CLI
echo dart pub global activate flutterfire_cli
echo.
echo # Configure Firebase for your project
echo flutterfire configure
echo ```
echo.
echo #### 5. Run the application
echo ```bash
echo # For web
echo flutter run -d chrome
echo.
echo # For Android
echo flutter run -d android
echo.
echo # For iOS
echo flutter run -d ios
echo ```
echo.
echo ### 🎨 Theme Colors:
echo - Primary: Deep Burgundy/Maroon ^(#8B3C3C^)
echo - Background: Warm Beige/Cream ^(#F1E9DB^)
echo - Accent: Warm Gold ^(#D4A574^)
echo.
echo ### 🔥 Features:
echo - ✅ Authentication System
echo - ✅ Dashboard with Statistics
echo - ✅ Product Management ^(CRUD^)
echo - ✅ Category Management
echo - ✅ Order Management
echo - ✅ Customer Management
echo - ✅ Delivery Personnel Management
echo - ✅ Image Upload
echo - ✅ Search ^& Filter
echo - ✅ Responsive Design
echo.
echo ### 📚 File Checklist:
echo Use this checklist to ensure all files are properly copied:
echo.
echo #### Config ^(3 files^):
echo - [ ] lib/config/app_colors.dart
echo - [ ] lib/config/app_theme.dart
echo - [ ] lib/config/routes.dart
echo.
echo #### Models ^(6 files^):
echo - [ ] lib/models/admin_user.dart
echo - [ ] lib/models/product.dart
echo - [ ] lib/models/category.dart
echo - [ ] lib/models/order.dart
echo - [ ] lib/models/customer.dart
echo - [ ] lib/models/delivery_man.dart
echo.
echo #### Services ^(7 files^):
echo - [ ] lib/services/auth_service.dart
echo - [ ] lib/services/product_service.dart
echo - [ ] lib/services/category_service.dart
echo - [ ] lib/services/order_service.dart
echo - [ ] lib/services/customer_service.dart
echo - [ ] lib/services/delivery_service.dart
echo - [ ] lib/services/dashboard_service.dart
echo.
echo #### Controllers ^(6 files^):
echo - [ ] lib/controllers/auth_controller.dart
echo - [ ] lib/controllers/product_controller.dart
echo - [ ] lib/controllers/category_controller.dart
echo - [ ] lib/controllers/order_controller.dart
echo - [ ] lib/controllers/customer_controller.dart
echo - [ ] lib/controllers/delivery_controller.dart
echo.
echo #### Screens ^(13 files^):
echo - [ ] lib/screens/auth/login_screen.dart
echo - [ ] lib/screens/dashboard/dashboard_screen.dart
echo - [ ] lib/screens/products/products_screen.dart
echo - [ ] lib/screens/products/add_product_screen.dart
echo - [ ] lib/screens/products/edit_product_screen.dart
echo - [ ] lib/screens/categories/categories_screen.dart
echo - [ ] lib/screens/categories/category_form_screen.dart
echo - [ ] lib/screens/orders/orders_screen.dart
echo - [ ] lib/screens/orders/order_details_screen.dart
echo - [ ] lib/screens/customers/customers_screen.dart
echo - [ ] lib/screens/customers/customer_details_screen.dart
echo - [ ] lib/screens/delivery/delivery_screen.dart
echo - [ ] lib/screens/delivery/delivery_form_screen.dart
echo.
echo #### Widgets ^(5 files^):
echo - [ ] lib/widgets/custom_button.dart
echo - [ ] lib/widgets/custom_text_field.dart
echo - [ ] lib/widgets/stat_card.dart
echo - [ ] lib/widgets/data_table_widget.dart
echo - [ ] lib/widgets/sidebar_menu.dart
echo.
echo #### Utils ^(2 files^):
echo - [ ] lib/utils/constants.dart
echo - [ ] lib/utils/validators.dart
echo.
echo #### Root Files:
echo - [ ] lib/main.dart
echo - [ ] pubspec.yaml
echo.
echo ### 🆘 Troubleshooting:
echo.
echo **Issue: Flutter not found**
echo - Install Flutter: https://flutter.dev/docs/get-started/install
echo - Add Flutter to PATH
echo.
echo **Issue: Firebase configuration fails**
echo - Ensure Firebase CLI is installed: `npm install -g firebase-tools`
echo - Login to Firebase: `firebase login`
echo - Make sure you have a Firebase project created
echo.
echo **Issue: Dependencies not installing**
echo - Run: `flutter clean`
echo - Run: `flutter pub get`
echo - Check internet connection
echo.
echo ### 📞 Support:
echo For issues or questions, refer to:
echo - Flutter Documentation: https://flutter.dev/docs
echo - Firebase Documentation: https://firebase.google.com/docs
echo - GetX Documentation: https://pub.dev/packages/get
echo.
echo ---
echo Created by Naseej Admin Setup Script
echo Generated on: %date% %time%
) > SETUP_GUIDE.md

echo [✓] Setup guide created
echo.

:: Create file checklist
echo ═══════════════════════════════════════
echo Step 5: Creating File Checklist
echo ═══════════════════════════════════════

(
echo # File Implementation Checklist
echo.
echo Copy this file and mark each item as you implement it.
echo.
echo ## Config Files
echo [ ] lib/config/app_colors.dart
echo [ ] lib/config/app_theme.dart
echo [ ] lib/config/routes.dart
echo.
echo ## Model Files
echo [ ] lib/models/admin_user.dart
echo [ ] lib/models/product.dart
echo [ ] lib/models/category.dart
echo [ ] lib/models/order.dart
echo [ ] lib/models/customer.dart
echo [ ] lib/models/delivery_man.dart
echo.
echo ## Service Files
echo [ ] lib/services/auth_service.dart
echo [ ] lib/services/product_service.dart
echo [ ] lib/services/category_service.dart
echo [ ] lib/services/order_service.dart
echo [ ] lib/services/customer_service.dart
echo [ ] lib/services/delivery_service.dart
echo [ ] lib/services/dashboard_service.dart
echo.
echo ## Controller Files
echo [ ] lib/controllers/auth_controller.dart
echo [ ] lib/controllers/product_controller.dart
echo [ ] lib/controllers/category_controller.dart
echo [ ] lib/controllers/order_controller.dart
echo [ ] lib/controllers/customer_controller.dart
echo [ ] lib/controllers/delivery_controller.dart
echo.
echo ## Screen Files
echo [ ] lib/screens/auth/login_screen.dart
echo [ ] lib/screens/dashboard/dashboard_screen.dart
echo [ ] lib/screens/products/products_screen.dart
echo [ ] lib/screens/products/add_product_screen.dart
echo [ ] lib/screens/products/edit_product_screen.dart
echo [ ] lib/screens/categories/categories_screen.dart
echo [ ] lib/screens/categories/category_form_screen.dart
echo [ ] lib/screens/orders/orders_screen.dart
echo [ ] lib/screens/orders/order_details_screen.dart
echo [ ] lib/screens/customers/customers_screen.dart
echo [ ] lib/screens/customers/customer_details_screen.dart
echo [ ] lib/screens/delivery/delivery_screen.dart
echo [ ] lib/screens/delivery/delivery_form_screen.dart
echo.
echo ## Widget Files
echo [ ] lib/widgets/custom_button.dart
echo [ ] lib/widgets/custom_text_field.dart
echo [ ] lib/widgets/stat_card.dart
echo [ ] lib/widgets/data_table_widget.dart
echo [ ] lib/widgets/sidebar_menu.dart
echo.
echo ## Util Files
echo [ ] lib/utils/constants.dart
echo [ ] lib/utils/validators.dart
echo.
echo ## Root Files
echo [ ] lib/main.dart
echo [ ] pubspec.yaml
echo.
echo ## Setup Tasks
echo [ ] Run: flutter pub get
echo [ ] Configure Firebase: flutterfire configure
echo [ ] Test run: flutter run -d chrome
) > FILE_CHECKLIST.md

echo [✓] File checklist created
echo.

:: Display success message
color 0A
echo.
echo ╔════════════════════════════════════════════════════════════╗
echo ║              ✅ SETUP COMPLETED SUCCESSFULLY!              ║
echo ╚════════════════════════════════════════════════════════════╝
echo.
echo 📁 Project Location: %PROJECT_PATH%
echo.
echo 📋 What was created:
echo    - Flutter project structure
echo    - All required directories
echo    - Placeholder Dart files
echo    - SETUP_GUIDE.md (detailed instructions)
echo    - FILE_CHECKLIST.md (implementation tracker)
echo.
echo 🎯 Next Steps:
echo    1. Open SETUP_GUIDE.md for detailed instructions
echo    2. Copy all provided Dart code into respective files
echo    3. Update pubspec.yaml with provided dependencies
echo    4. Run: flutter pub get
echo    5. Configure Firebase: flutterfire configure
echo.
echo 💡 Quick Commands:
echo    - Open in VS Code: code .
echo    - Open in Android Studio: studio .
echo    - View structure: tree /F
echo.
echo ═══════════════════════════════════════════════════════════════
echo.

:: Ask if user wants to open in editor
set /p "OPEN_EDITOR=Open project in VS Code now? (y/n): "
if /i "%OPEN_EDITOR%"=="y" (
    echo Opening in VS Code...
    code .
)

echo.
echo Press any key to view the project structure...
pause >nul

tree /F /A

echo.
echo ═══════════════════════════════════════════════════════════════
echo Setup Complete! Happy Coding! 🚀
echo ═══════════════════════════════════════════════════════════════
echo.
pause

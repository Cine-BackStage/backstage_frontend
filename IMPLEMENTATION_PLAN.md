# Backstage Cinema - Flutter Frontend Implementation Plan

## 📋 Executive Summary

This document outlines the comprehensive implementation plan for the Backstage Cinema Flutter frontend application. The architecture follows **Clean Architecture** principles with **Feature-Module Architecture**, using a **multi-package monorepo** structure managed by **Melos**, inspired by InfinitePay Dashboard's enterprise-grade patterns.

**Project Type**: Cinema Management System (Admin Dashboard + POS + Inventory Management + Session Management)

**Architecture Style**: Clean Architecture + Feature-Module + Monorepo

**State Management**: BLoC (Business Logic Component)

**Navigation**: Sophisticated named routing with guards and stack protection

**Testing Strategy**: Robot Pattern for UI tests, comprehensive unit tests

---

## 🎯 Project Structure Overview

```
backstage_cine/
├── backstage_frontend/               # Main Flutter monorepo
│   ├── app/                         # Main application entry
│   ├── packages/                    # Modular packages ecosystem
│   │   ├── core/                    # Core framework
│   │   ├── adapters/               # External service abstractions
│   │   ├── features/               # Business features (modules)
│   │   ├── shared/                 # Shared utilities
│   │   └── design_system/          # UI components & theme
│   └── melos.yaml                  # Monorepo configuration
└── backstage-cinema/                # Reference Next.js implementation
```

---

## 📐 Architecture Layers

### **1. Domain Layer** (Business Logic - Pure Dart)
- **Entities**: Core business objects
- **Repositories**: Abstract data contracts
- **Use Cases**: Business operations
- **Errors**: Domain-specific exceptions

### **2. Data Layer** (Data Access)
- **Models (DTOs)**: Data transfer objects
- **Repositories**: Repository implementations
- **Data Sources**: Remote (API) and Local (Cache/DB)
- **Mappers**: DTO ↔ Entity conversion

### **3. Infrastructure Layer** (External Services - Mocked for now)
- **API Clients**: HTTP communication (mocked responses)
- **Storage Services**: Local persistence (mocked)
- **Analytics**: Event tracking (mocked)
- **Notifications**: Push notifications (mocked)

### **4. Presentation Layer** (UI)
- **BLoC/Cubit**: State management
- **Pages**: Full-screen views
- **Widgets**: Reusable UI components
- **Utils**: UI helpers and extensions

---

## 🎨 UI/UX Analysis from Prototypes

### **Screens Identified**:

1. **Splash Screen** (`splash_pt1-3.png`)
   - App initialization/loading screen
   - Backstage Cinema logo (centered)
   - Tagline: "No Drama" below logo
   - Loading indicator (circular spinner with Golden Reel color)
   - Cinematic Black background
   - Smooth fade-in animation

2. **Login Screen** (`login.png`)
   - **Features Carousel** (NEW):
     - Horizontal scrollable carousel above login form
     - Feature cards showcasing app capabilities:
       - "Dashboard Analytics" card
       - "POS System" card
       - "Session Management" card
       - "Inventory Control" card
     - Auto-scroll with page indicators (Golden Reel dots)
     - Each card: icon + title + brief description
   - **Login Form**:
     - CPF input with mask (000.000.000-00)
     - Password field with show/hide toggle
     - "Forgot password?" link (Orange Spotlight)
     - Sign In button (Orange Spotlight background)
   - Logo at top (Golden Reel on Cinematic Black)
   - No demo credentials display (removed for production-ready feel)

3. **Admin Dashboard** (`admin_dash_pt1-7.png`)
   - Total Revenue card with percentage change
   - Active Employees counter (12/15 currently on duty)
   - Inventory Value with alerts (3 items need attention)
   - Today's Sessions counter (8 sessions, 156 tickets sold)
   - Navigation: Cinema Management Overview

4. **POS (Point of Sale)** (`pos_pt1-4.png`)
   - Movie Tickets / Concessions tabs
   - Movie session list (The Dark Knight 19:00 • 2D - $25.00)
   - "Add Ticket" buttons
   - Customer Info section (CPF Optional)
   - Shopping cart/checkout functionality

5. **Session Management** (`session_management_pt1-2.png`)
   - Filter Sessions dropdown (All Sessions)
   - Movie session cards with:
     - Movie title (The Dark Knight)
     - Theater + format (Theater 1 • 2D)
     - Time range (16:00 - 18:30)
     - Date (15/01/2024)
     - Ticket Price ($25.00)
     - Available Seats (85/120)
     - Seat Availability progress bar (71%)
     - "View Seat Map" button
     - Status badge (Scheduled)

6. **Inventory Management** (`inventory_management_pt1-3.png`)
   - Alert banners:
     - 1 items out of stock (red)
     - 2 items running low (orange)
     - 3 items expired (red)
   - Inventory Items / Stock Adjustments tabs
   - Filters & Search section:
     - Search by name or SKU input
     - Category dropdown (All Categories)
     - Stock Status dropdown (All Items)
     - Refresh button

7. **Reset Password** (`reset_password.png`)
   - Password reset flow

---

## 🎨 Design System (Based on Official Style Guide)

### **Color Palette**:
```dart
// Primary Colors
- Cinematic Black: #0D0D0D (primary background, dark theme base)
- Spotlight White: #F5F5F5 (text, light elements)

// Accent Colors
- Golden Reel: #FFD700 (premium accent, elevated features, headings)
- Popcorn Yellow: #FFD64D (playful secondary accent, notifications)
- Orange Spotlight: #FF8C42 (standout CTAs, primary actions, alerts)

// Support Colors
- Gray Curtain: #2E2E2E (panels, dividers, card backgrounds)
- Ticket Stub Beige: #F2E6D0 (subtle highlights, UI hints)

// Alert Colors (Additional)
- Alert Red: #FF4444 (critical errors, out of stock)
- Success Green: #22C55E (success states, confirmations)
```

### **Color Usage Guidelines**:
```dart
// Backgrounds
- Primary Background: Cinematic Black (#0D0D0D)
- Card Background: Gray Curtain (#2E2E2E)
- Subtle Highlights: Ticket Stub Beige (#F2E6D0)

// Text
- Base Text: Spotlight White (#F5F5F5)
- Headings: Golden Reel (#FFD700) - premium feel
- Subheadings: Spotlight White (#F5F5F5)
- Muted Text: Gray Curtain (#2E2E2E) on light backgrounds

// Buttons & CTAs
- Primary Action: Orange Spotlight (#FF8C42) - buy, sell, confirm
- Secondary/Premium: Golden Reel (#FFD700) - special features, VIP
- Playful/Light: Popcorn Yellow (#FFD64D) - fun elements, reminders

// Icons & Highlights
- Premium Icons: Golden Reel (#FFD700)
- Active States: Orange Spotlight (#FF8C42)
- Info/Light Alerts: Popcorn Yellow (#FFD64D)
```

### **Typography**:
```dart
// Font Family: Bold sans-serif for cinematic presence
// Recommended: Inter, Montserrat, or Poppins

// Headings
- H1: Bold, 32px, Golden Reel (#FFD700) - main titles
- H2: Bold, 24px, Spotlight White (#F5F5F5) - section headers
- H3: SemiBold, 20px, Spotlight White (#F5F5F5) - card titles

// Body
- Body Regular: 16px minimum, Spotlight White (#F5F5F5)
- Body Small: 14px, Spotlight White (#F5F5F5) or Gray Curtain
- Caption: 12px, Gray Curtain (#2E2E2E)

// Special
- Tagline: Italic, 14px, Spotlight White - "No Drama"
- Emphasis: Golden Reel (#FFD700) for premium highlights
- Urgent: Orange Spotlight (#FF8C42) for urgent CTAs
- Playful: Popcorn Yellow (#FFD64D) for fun notes
```

### **Logo Guidelines**:
```dart
// Logo Composition
- Text: "Backstage Cinema" in bold sans-serif
- Tagline: "No Drama" underneath in smaller, italic font
- Primary Version: Spotlight White or Golden Reel on Cinematic Black
- Inverted Version: Cinematic Black on Spotlight White or Ticket Stub Beige
```

### **Components Needed**:
1. **Cards**:
   - Metric cards (Gray Curtain background, rounded corners)
   - Feature cards (for login carousel)
   - Session cards, Inventory cards
2. **Input Fields**:
   - Dark Gray Curtain background with Spotlight White text
   - Golden Reel focus border
3. **Buttons**:
   - Primary (Orange Spotlight background) - main CTAs
   - Secondary (Golden Reel background) - premium actions
   - Ghost (transparent with Golden Reel border)
4. **Progress Bars**:
   - Seat availability (Golden Reel fill)
5. **Status Badges**:
   - Scheduled (Popcorn Yellow)
   - In Progress (Orange Spotlight)
   - Completed (Success Green)
6. **Alert Banners**:
   - Critical (Alert Red background)
   - Warning (Orange Spotlight background)
   - Info (Popcorn Yellow background)
7. **Tabs**:
   - Movie Tickets / Concessions style
   - Active tab: Golden Reel underline
8. **Dropdown Selects**:
   - Gray Curtain background
   - Golden Reel highlight on hover
9. **List Items**:
   - Movie session cards, inventory items
   - Gray Curtain background
10. **Carousel**:
    - Horizontal scrollable feature showcase
    - Page indicators (Golden Reel dots)
11. **Loading Indicators**:
    - Circular spinner (Golden Reel color)
    - Linear progress (Golden Reel fill)

---

## 📦 Feature Modules Breakdown

### **Phase 1: Foundation & Core Infrastructure** (Week 1-2)

#### **1.1 Core Package Setup**
```
packages/core/
├── lib/
│   ├── navigator/           # Navigation management
│   ├── permissions/         # Permission handling
│   ├── connectivity/        # Network state
│   ├── analytics/          # Event tracking (mocked)
│   └── diagnostics/        # Error reporting (mocked)
```

**Deliverables**:
- Navigation Manager with stack protection
- Route guards (authentication)
- Permission handler service (mocked)
- Connectivity checker (mocked - always online)
- Analytics tracker (mocked - console logs)

#### **1.2 Design System Package**
```
packages/design_system/
├── lib/
│   ├── theme/
│   │   ├── app_colors.dart
│   │   ├── app_text_styles.dart
│   │   ├── app_theme.dart
│   │   └── app_dimensions.dart
│   ├── widgets/
│   │   ├── buttons/
│   │   │   ├── primary_button.dart
│   │   │   ├── secondary_button.dart
│   │   │   └── ghost_button.dart
│   │   ├── cards/
│   │   │   ├── metric_card.dart
│   │   │   ├── session_card.dart
│   │   │   └── inventory_card.dart
│   │   ├── inputs/
│   │   │   ├── text_field.dart
│   │   │   ├── password_field.dart
│   │   │   ├── cpf_field.dart
│   │   │   └── search_field.dart
│   │   ├── indicators/
│   │   │   ├── progress_bar.dart
│   │   │   ├── loading_spinner.dart
│   │   │   └── status_badge.dart
│   │   ├── alerts/
│   │   │   ├── alert_banner.dart
│   │   │   └── snackbar.dart
│   │   ├── navigation/
│   │   │   ├── app_bar.dart
│   │   │   ├── bottom_nav.dart
│   │   │   └── drawer.dart
│   │   └── layout/
│   │       ├── page_scaffold.dart
│   │       └── responsive_layout.dart
│   └── assets/
│       └── images/
│           └── cinema_logo.png
```

**Deliverables**:
- Complete theme configuration (colors, typography, dimensions)
- 20+ reusable UI components matching prototypes
- Responsive layout helpers
- Loading states & error views

#### **1.3 Shared Packages**
```
packages/shared/
├── routing/
│   ├── app_routes.dart
│   ├── route_guards.dart
│   └── navigation_helpers.dart
├── l10n/                        # Internationalization (NEW)
│   ├── lib/
│   │   ├── l10n.dart
│   │   └── arb/
│   │       ├── app_pt_BR.arb    # Brazilian Portuguese (primary)
│   │       └── app_en.arb       # English (fallback)
│   └── pubspec.yaml
├── utils/
│   ├── formatters/
│   │   ├── cpf_formatter.dart
│   │   ├── currency_formatter.dart
│   │   └── date_formatter.dart
│   ├── validators/
│   │   ├── cpf_validator.dart
│   │   └── form_validators.dart
│   └── extensions/
│       ├── string_extensions.dart
│       ├── date_extensions.dart
│       └── num_extensions.dart
└── entities/
    ├── error/
    │   ├── app_exception.dart
    │   └── failure.dart
    └── result/
        └── either.dart
```

**Deliverables**:
- CPF formatter and validator
- Currency formatters (BRL)
- Date/time utilities
- Common extensions
- Error handling framework
- **Internationalization (intl) package setup**:
  - Centralized pt_BR translations (primary language)
  - English translations (fallback)
  - All UI strings externalized to ARB files
  - Type-safe translation access via generated code

#### **1.4 Adapters Package**
```
packages/adapters/
├── http_client/
│   ├── http_client.dart           # Abstract interface
│   ├── http_client_impl.dart      # Dio implementation (mocked)
│   ├── http_interceptors.dart     # Auth, logging interceptors
│   └── http_exception.dart        # HTTP error handling
├── storage/
│   ├── storage_client.dart        # Abstract interface
│   └── storage_client_impl.dart   # SharedPreferences (mocked)
├── connectivity/
│   ├── connectivity_client.dart
│   └── connectivity_client_impl.dart (mocked - always connected)
└── analytics/
    ├── analytics_client.dart
    └── analytics_client_impl.dart (mocked - console logs)
```

**Deliverables**:
- HTTP client with interceptors (mocked responses)
- Local storage abstraction (mocked)
- Connectivity monitoring (mocked)
- Analytics tracking (mocked)

---

### **Phase 2: Authentication Feature** (Week 2)

#### **2.1 Authentication Module**
```
packages/features/authentication/
├── lib/
│   ├── domain/
│   │   ├── entities/
│   │   │   ├── user.dart
│   │   │   ├── credentials.dart
│   │   │   ├── auth_token.dart
│   │   │   └── feature_info.dart          # NEW: for carousel
│   │   ├── repositories/
│   │   │   └── auth_repository.dart
│   │   ├── usecases/
│   │   │   ├── login_usecase.dart
│   │   │   ├── logout_usecase.dart
│   │   │   ├── reset_password_usecase.dart
│   │   │   ├── check_auth_status_usecase.dart
│   │   │   └── get_features_usecase.dart  # NEW: get carousel features
│   │   └── errors/
│   │       └── auth_exceptions.dart
│   ├── data/
│   │   ├── models/
│   │   │   ├── user_dto.dart
│   │   │   ├── login_response_dto.dart
│   │   │   └── feature_info_dto.dart      # NEW
│   │   ├── repositories/
│   │   │   └── auth_repository_impl.dart
│   │   └── datasources/
│   │       ├── auth_remote_datasource.dart (mocked)
│   │       └── auth_local_datasource.dart (mocked)
│   ├── presentation/
│   │   ├── bloc/
│   │   │   ├── auth_bloc.dart
│   │   │   ├── auth_event.dart
│   │   │   └── auth_state.dart
│   │   ├── pages/
│   │   │   ├── login_page.dart            # UPDATED: with carousel
│   │   │   ├── forgot_password_page.dart
│   │   │   └── splash_page.dart           # UPDATED: loading indicator
│   │   └── widgets/
│   │       ├── login_form.dart
│   │       ├── features_carousel.dart     # NEW
│   │       ├── feature_card.dart          # NEW
│   │       └── splash_loading.dart        # NEW
│   └── authentication.dart (public API)
└── test/
    ├── domain/
    ├── data/
    └── presentation/
```

**User Roles** (from prototype demo credentials):
```dart
enum UserRole {
  admin,     // CPF: 123.456.789-01, Password: admin123
  employee   // CPF: 987.654.321-00, Password: employee123
}
```

**Mocked Login Logic**:
```dart
// Hardcoded users for initial phase
final mockUsers = [
  User(
    cpf: '12345678901',
    role: UserRole.admin,
    name: 'Admin User',
    password: 'admin123',
  ),
  User(
    cpf: '98765432100',
    role: UserRole.employee,
    name: 'Employee User',
    password: 'employee123',
  ),
];
```

**Mocked Feature Cards Data**:
```dart
final mockFeatures = [
  FeatureInfo(
    id: '1',
    title: 'Dashboard Analytics', // translatable key: 'feature_dashboard_title'
    description: 'Monitor revenue, employees, and operations in real-time',
    icon: Icons.bar_chart,
    color: AppColors.goldenReel,
  ),
  FeatureInfo(
    id: '2',
    title: 'POS System',
    description: 'Fast ticket sales and concession management',
    icon: Icons.point_of_sale,
    color: AppColors.orangeSpotlight,
  ),
  FeatureInfo(
    id: '3',
    title: 'Session Management',
    description: 'Control movie sessions, seats, and schedules',
    icon: Icons.movie,
    color: AppColors.popcornYellow,
  ),
  FeatureInfo(
    id: '4',
    title: 'Inventory Control',
    description: 'Track stock, alerts, and concession items',
    icon: Icons.inventory,
    color: AppColors.goldenReel,
  ),
];
```

**Deliverables**:
- **Splash Screen**:
  - Cinematic Black background
  - Backstage Cinema logo (centered, Golden Reel color)
  - "No Drama" tagline (Spotlight White, italic)
  - Circular loading indicator (Golden Reel color)
  - Smooth fade-in animation (300ms)
  - Initialize app dependencies during display (min 2 seconds)
- **Login Screen**:
  - **Features Carousel** (above login form):
    - Horizontal scrollable PageView
    - 4 feature cards with icons, titles, descriptions
    - Auto-scroll every 3 seconds
    - Page indicators (Golden Reel dots)
    - Smooth transitions
  - **Login Form**:
    - CPF validation and formatting
    - Password field with show/hide toggle
    - "Forgot password?" link (Orange Spotlight color)
    - Sign In button (Orange Spotlight background)
    - **NO demo credentials display** (removed)
  - Logo at top (Golden Reel on Cinematic Black)
  - All text strings in pt_BR via intl package
- Role-based navigation (admin → dashboard, employee → POS)
- Auth state management (BLoC)
- Token persistence (mocked)

---

### **Phase 3: Admin Dashboard Feature** (Week 3)

#### **3.1 Dashboard Module**
```
packages/features/dashboard/
├── lib/
│   ├── domain/
│   │   ├── entities/
│   │   │   ├── dashboard_metrics.dart
│   │   │   ├── revenue_data.dart
│   │   │   ├── employee_status.dart
│   │   │   ├── inventory_summary.dart
│   │   │   └── session_summary.dart
│   │   ├── repositories/
│   │   │   └── dashboard_repository.dart
│   │   └── usecases/
│   │       ├── get_dashboard_metrics_usecase.dart
│   │       ├── get_revenue_data_usecase.dart
│   │       └── get_today_summary_usecase.dart
│   ├── data/
│   │   ├── models/
│   │   │   ├── dashboard_metrics_dto.dart
│   │   │   └── revenue_data_dto.dart
│   │   ├── repositories/
│   │   │   └── dashboard_repository_impl.dart
│   │   └── datasources/
│   │       └── dashboard_remote_datasource.dart (mocked)
│   ├── presentation/
│   │   ├── bloc/
│   │   │   ├── dashboard_bloc.dart
│   │   │   ├── dashboard_event.dart
│   │   │   └── dashboard_state.dart
│   │   ├── pages/
│   │   │   └── dashboard_page.dart
│   │   └── widgets/
│   │       ├── revenue_card.dart
│   │       ├── employee_status_card.dart
│   │       ├── inventory_alert_card.dart
│   │       └── session_summary_card.dart
│   └── dashboard.dart
```

**Mocked Data**:
```dart
final mockDashboardMetrics = DashboardMetrics(
  totalRevenue: 45280.50,
  revenueChangePercent: 12.5,
  activeEmployees: 12,
  totalEmployees: 15,
  inventoryValue: 8450.00,
  inventoryAlertsCount: 3,
  todaySessionsCount: 8,
  todayTicketsSold: 156,
);
```

**Deliverables**:
- Dashboard page with 4 metric cards
- Revenue card with percentage indicator
- Active employees counter
- Inventory value with alert badge
- Today's sessions summary
- Top navigation bar (admin role badge, logout)
- Pull-to-refresh functionality
- Loading and error states

---

### **Phase 4: POS (Point of Sale) Feature** (Week 4)

#### **4.1 POS Module**
```
packages/features/pos/
├── lib/
│   ├── domain/
│   │   ├── entities/
│   │   │   ├── movie_session.dart
│   │   │   ├── ticket.dart
│   │   │   ├── concession_item.dart
│   │   │   ├── cart.dart
│   │   │   └── transaction.dart
│   │   ├── repositories/
│   │   │   ├── sessions_repository.dart
│   │   │   ├── concessions_repository.dart
│   │   │   └── transactions_repository.dart
│   │   └── usecases/
│   │       ├── get_available_sessions_usecase.dart
│   │       ├── get_concessions_usecase.dart
│   │       ├── add_ticket_to_cart_usecase.dart
│   │       ├── add_concession_to_cart_usecase.dart
│   │       └── process_transaction_usecase.dart
│   ├── data/
│   │   ├── models/
│   │   │   ├── movie_session_dto.dart
│   │   │   ├── ticket_dto.dart
│   │   │   └── concession_item_dto.dart
│   │   ├── repositories/
│   │   │   ├── sessions_repository_impl.dart
│   │   │   └── concessions_repository_impl.dart
│   │   └── datasources/
│   │       ├── pos_remote_datasource.dart (mocked)
│   │       └── pos_local_datasource.dart (mocked)
│   ├── presentation/
│   │   ├── bloc/
│   │   │   ├── pos_bloc.dart
│   │   │   ├── pos_event.dart
│   │   │   ├── pos_state.dart
│   │   │   ├── cart_cubit.dart
│   │   │   └── cart_state.dart
│   │   ├── pages/
│   │   │   ├── pos_page.dart
│   │   │   └── checkout_page.dart
│   │   └── widgets/
│   │       ├── session_list_view.dart
│   │       ├── session_card.dart
│   │       ├── concessions_list_view.dart
│   │       ├── cart_widget.dart
│   │       ├── customer_info_form.dart
│   │       └── payment_summary.dart
│   └── pos.dart
```

**Mocked Sessions**:
```dart
final mockSessions = [
  MovieSession(
    id: '1',
    movieTitle: 'The Dark Knight',
    time: '19:00',
    format: '2D',
    price: 25.00,
    availableSeats: 85,
    totalSeats: 120,
  ),
  MovieSession(
    id: '2',
    movieTitle: 'Inception',
    time: '21:30',
    format: 'IMAX',
    price: 35.00,
    availableSeats: 45,
    totalSeats: 100,
  ),
  MovieSession(
    id: '3',
    movieTitle: 'Interstellar',
    time: '16:00',
    format: '3D',
    price: 30.00,
    availableSeats: 92,
    totalSeats: 120,
  ),
];
```

**Deliverables**:
- POS page with tabs (Movie Tickets / Concessions)
- Movie sessions list with "Add Ticket" buttons
- Concessions list (future phase)
- Shopping cart widget
- Customer Info section (optional CPF)
- Checkout flow (mocked payment)
- Cart state management
- Transaction confirmation

---

### **Phase 5: Session Management Feature** (Week 5)

#### **5.1 Sessions Module**
```
packages/features/sessions/
├── lib/
│   ├── domain/
│   │   ├── entities/
│   │   │   ├── session.dart
│   │   │   ├── theater.dart
│   │   │   ├── movie.dart
│   │   │   ├── seat.dart
│   │   │   └── seat_map.dart
│   │   ├── repositories/
│   │   │   ├── sessions_repository.dart
│   │   │   └── theaters_repository.dart
│   │   └── usecases/
│   │       ├── get_sessions_usecase.dart
│   │       ├── filter_sessions_usecase.dart
│   │       ├── get_seat_map_usecase.dart
│   │       ├── create_session_usecase.dart
│   │       └── update_session_usecase.dart
│   ├── data/
│   │   ├── models/
│   │   │   ├── session_dto.dart
│   │   │   ├── theater_dto.dart
│   │   │   └── seat_map_dto.dart
│   │   ├── repositories/
│   │   │   └── sessions_repository_impl.dart
│   │   └── datasources/
│   │       └── sessions_remote_datasource.dart (mocked)
│   ├── presentation/
│   │   ├── bloc/
│   │   │   ├── sessions_list_bloc.dart
│   │   │   ├── sessions_list_event.dart
│   │   │   ├── sessions_list_state.dart
│   │   │   ├── seat_map_cubit.dart
│   │   │   └── seat_map_state.dart
│   │   ├── pages/
│   │   │   ├── sessions_page.dart
│   │   │   ├── seat_map_page.dart
│   │   │   └── create_session_page.dart
│   │   └── widgets/
│   │       ├── session_card.dart
│   │       ├── session_filter.dart
│   │       ├── seat_availability_bar.dart
│   │       ├── seat_map_grid.dart
│   │       └── status_badge.dart
│   └── sessions.dart
```

**Mocked Session Data**:
```dart
final mockSessionDetails = [
  Session(
    id: '1',
    movieTitle: 'The Dark Knight',
    theater: 'Theater 1',
    format: '2D',
    startTime: DateTime(2024, 1, 15, 16, 0),
    endTime: DateTime(2024, 1, 15, 18, 30),
    ticketPrice: 25.00,
    availableSeats: 85,
    totalSeats: 120,
    status: SessionStatus.scheduled,
    seatAvailabilityPercent: 71,
  ),
  // ... more sessions
];
```

**Deliverables**:
- Sessions list page
- Filter dropdown (All Sessions / By Date / By Movie)
- Session cards with all details
- Seat availability progress bar
- Status badges (Scheduled, In Progress, Completed)
- "View Seat Map" modal/page
- Visual seat map grid (future phase - basic version)

---

### **Phase 6: Inventory Management Feature** (Week 6)

#### **6.1 Inventory Module**
```
packages/features/inventory/
├── lib/
│   ├── domain/
│   │   ├── entities/
│   │   │   ├── inventory_item.dart
│   │   │   ├── stock_adjustment.dart
│   │   │   ├── category.dart
│   │   │   └── inventory_alert.dart
│   │   ├── repositories/
│   │   │   └── inventory_repository.dart
│   │   └── usecases/
│   │       ├── get_inventory_items_usecase.dart
│   │       ├── search_items_usecase.dart
│   │       ├── filter_items_usecase.dart
│   │       ├── adjust_stock_usecase.dart
│   │       └── get_inventory_alerts_usecase.dart
│   ├── data/
│   │   ├── models/
│   │   │   ├── inventory_item_dto.dart
│   │   │   └── stock_adjustment_dto.dart
│   │   ├── repositories/
│   │   │   └── inventory_repository_impl.dart
│   │   └── datasources/
│   │       └── inventory_remote_datasource.dart (mocked)
│   ├── presentation/
│   │   ├── bloc/
│   │   │   ├── inventory_list_bloc.dart
│   │   │   ├── inventory_list_event.dart
│   │   │   ├── inventory_list_state.dart
│   │   │   ├── inventory_filter_cubit.dart
│   │   │   └── stock_adjustment_cubit.dart
│   │   ├── pages/
│   │   │   ├── inventory_page.dart
│   │   │   └── stock_adjustment_page.dart
│   │   └── widgets/
│   │       ├── inventory_alert_banners.dart
│   │       ├── inventory_filter_section.dart
│   │       ├── inventory_item_card.dart
│   │       └── stock_adjustment_form.dart
│   └── inventory.dart
```

**Mocked Inventory Data**:
```dart
final mockInventoryAlerts = [
  InventoryAlert(
    type: AlertType.outOfStock,
    message: '1 items are out of stock: Cinema T-Shirt Medium',
    itemsCount: 1,
  ),
  InventoryAlert(
    type: AlertType.runningLow,
    message: '2 items are running low: Large Soda, Movie Theater Candy',
    itemsCount: 2,
  ),
  InventoryAlert(
    type: AlertType.expired,
    message: '3 items have expired: Large Popcorn, Large Soda, Movie Theater Candy',
    itemsCount: 3,
  ),
];

final mockInventoryItems = [
  InventoryItem(
    id: '1',
    name: 'Large Popcorn',
    sku: 'POPCORN-L-001',
    category: 'Concessions',
    currentStock: 5,
    minStock: 20,
    maxStock: 100,
    unitPrice: 8.00,
    status: StockStatus.low,
    expiryDate: DateTime(2024, 1, 10), // expired
  ),
  // ... more items
];
```

**Deliverables**:
- Inventory page with alert banners
- Tabs: Inventory Items / Stock Adjustments
- Search field (by name or SKU)
- Category filter dropdown
- Stock Status filter dropdown
- Inventory items list/grid
- Alert-based color coding
- Refresh functionality
- Stock adjustment form (basic)

---

## 🧪 Testing Strategy

### **Unit Tests** (Per Feature)
```dart
// Example: packages/features/authentication/test/domain/usecases/login_usecase_test.dart
void main() {
  late LoginUseCase useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = LoginUseCase(mockRepository);
  });

  group('LoginUseCase', () {
    test('should return User when credentials are valid', () async {
      // Arrange
      when(() => mockRepository.login(any(), any()))
          .thenAnswer((_) async => Right(mockUser));

      // Act
      final result = await useCase(Credentials(cpf: '12345678901', password: 'admin123'));

      // Assert
      expect(result, Right(mockUser));
      verify(() => mockRepository.login(any(), any())).called(1);
    });

    test('should return AuthFailure when credentials are invalid', () async {
      // Arrange
      when(() => mockRepository.login(any(), any()))
          .thenAnswer((_) async => Left(AuthFailure.invalidCredentials()));

      // Act
      final result = await useCase(Credentials(cpf: 'invalid', password: 'wrong'));

      // Assert
      expect(result.isLeft(), true);
    });
  });
}
```

### **Widget Tests (Robot Pattern)**
```dart
// Example: packages/features/authentication/test/presentation/robot/login_page_robot_test.dart
void main() {
  late LoginPageRobot robot;
  late LoginPageScenario scenario;

  setUp(() async {
    scenario = LoginPageScenario();
    robot = LoginPageRobot(tester);
    await robot.configure(scenario: scenario);
  });

  testWidgets('should navigate to dashboard when admin logs in', (tester) async {
    // Given - on login page
    robot.assertLoginFormVisible();

    // When - enters admin credentials and submits
    await robot.enterCpf('123.456.789-01');
    await robot.enterPassword('admin123');
    await robot.tapSignInButton();

    // Then - should navigate to dashboard
    robot.assertNavigatedTo('/dashboard');
  });

  testWidgets('should show error when credentials are invalid', (tester) async {
    // Given - on login page
    robot.assertLoginFormVisible();

    // When - enters invalid credentials
    await robot.enterCpf('111.111.111-11');
    await robot.enterPassword('wrongpassword');
    await robot.tapSignInButton();

    // Then - should display error message
    robot.assertErrorShown('Invalid credentials');
  });
}
```

---

## 📁 Package Dependencies Configuration

### **Root `melos.yaml`**
```yaml
name: backstage_cinema
repository: https://github.com/your-org/backstage_cine

packages:
  - app
  - packages/**

command:
  bootstrap:
    runPubGetInParallel: true

scripts:
  analyze:
    run: dart analyze --fatal-infos
    exec:
      concurrency: 5

  test:
    run: flutter test --coverage
    exec:
      concurrency: 3

  generate:
    run: dart run build_runner build --delete-conflicting-outputs
    exec:
      concurrency: 1
```

### **Internationalization (intl) Package Configuration**

#### **Shared L10n Package `pubspec.yaml`**
```yaml
name: l10n
version: 0.0.1
publish_to: none

environment:
  sdk: ">=3.6.0 <4.0.0"
  flutter: ">=3.27.4"

dependencies:
  flutter:
    sdk: flutter
  intl: ^0.19.0

dev_dependencies:
  flutter_test:
    sdk: flutter

flutter:
  generate: true
```

#### **Shared L10n Package `l10n.yaml`**
```yaml
arb-dir: lib/arb
template-arb-file: app_pt_BR.arb
output-localization-file: app_localizations.dart
output-class: AppLocalizations
```

#### **Example ARB Files**

**`packages/shared/l10n/lib/arb/app_pt_BR.arb`** (Primary - Brazilian Portuguese):
```json
{
  "@@locale": "pt_BR",

  "appTitle": "Backstage Cinema",
  "@appTitle": {
    "description": "Application title"
  },

  "appTagline": "No Drama",
  "@appTagline": {
    "description": "Application tagline"
  },

  "loginTitle": "Login do Funcionário",
  "loginCpfLabel": "CPF",
  "loginCpfHint": "000.000.000-00",
  "loginPasswordLabel": "Senha",
  "loginPasswordHint": "Digite sua senha",
  "loginButton": "Entrar",
  "loginForgotPassword": "Esqueceu sua senha?",

  "featureDashboardTitle": "Dashboard Analytics",
  "featureDashboardDesc": "Monitore receita, funcionários e operações em tempo real",
  "featurePosTitle": "Sistema POS",
  "featurePosDesc": "Vendas rápidas de ingressos e gerenciamento de concessões",
  "featureSessionsTitle": "Gerenciamento de Sessões",
  "featureSessionsDesc": "Controle sessões de filmes, assentos e horários",
  "featureInventoryTitle": "Controle de Estoque",
  "featureInventoryDesc": "Rastreie estoque, alertas e itens de concessão",

  "dashboardTitle": "Painel Administrativo",
  "dashboardRevenueCard": "Receita Total",
  "dashboardEmployeesCard": "Funcionários Ativos",
  "dashboardInventoryCard": "Valor do Estoque",
  "dashboardSessionsCard": "Sessões de Hoje",
  "dashboardOnDuty": "em serviço",
  "dashboardItemsNeedAttention": "itens precisam de atenção",
  "dashboardTicketsSold": "ingressos vendidos",

  "posTitle": "Backstage Cinema POS",
  "posSubtitle": "Sistema de Ponto de Venda",
  "posMovieTicketsTab": "Ingressos de Filme",
  "posConcessionsTab": "Concessões",
  "posAddTicket": "Adicionar Ingresso",
  "posCustomerInfo": "Informações do Cliente",
  "posCustomerCpf": "CPF (Opcional)",

  "sessionsTitle": "Gerenciamento de Sessões",
  "sessionsSubtitle": "Sessões de Filmes e Reservas de Assentos",
  "sessionsFilterAll": "Todas as Sessões",
  "sessionsScheduled": "Agendado",
  "sessionsInProgress": "Em Andamento",
  "sessionsCompleted": "Concluído",
  "sessionsViewSeatMap": "Ver Mapa de Assentos",
  "sessionsAvailableSeats": "Assentos Disponíveis",
  "sessionsTicketPrice": "Preço do Ingresso",

  "inventoryTitle": "Gerenciamento de Estoque",
  "inventorySubtitle": "Controle de Estoque e Rastreamento",
  "inventoryItemsTab": "Itens de Estoque",
  "inventoryAdjustmentsTab": "Ajustes de Estoque",
  "inventorySearchHint": "Buscar por nome ou SKU...",
  "inventoryRefresh": "Atualizar",
  "inventoryAllCategories": "Todas as Categorias",
  "inventoryAllItems": "Todos os Itens",
  "inventoryOutOfStock": "{count} {count, plural, =1{item está} other{itens estão}} fora de estoque: {items}",
  "inventoryRunningLow": "{count} {count, plural, =1{item está} other{itens estão}} acabando: {items}",
  "inventoryExpired": "{count} {count, plural, =1{item expirou} other{itens expiraram}}: {items}",

  "errorInvalidCredentials": "Credenciais inválidas. Verifique seu CPF e senha.",
  "errorNetworkError": "Erro de rede. Verifique sua conexão.",
  "errorGeneric": "Ocorreu um erro. Tente novamente.",

  "loading": "Carregando...",
  "logout": "Sair"
}
```

**`packages/shared/l10n/lib/arb/app_en.arb`** (Fallback - English):
```json
{
  "@@locale": "en",

  "appTitle": "Backstage Cinema",
  "appTagline": "No Drama",

  "loginTitle": "Employee Login",
  "loginCpfLabel": "CPF",
  "loginCpfHint": "000.000.000-00",
  "loginPasswordLabel": "Password",
  "loginPasswordHint": "Enter your password",
  "loginButton": "Sign In",
  "loginForgotPassword": "Forgot your password?",

  "featureDashboardTitle": "Dashboard Analytics",
  "featureDashboardDesc": "Monitor revenue, employees, and operations in real-time",
  "featurePosTitle": "POS System",
  "featurePosDesc": "Fast ticket sales and concession management",
  "featureSessionsTitle": "Session Management",
  "featureSessionsDesc": "Control movie sessions, seats, and schedules",
  "featureInventoryTitle": "Inventory Control",
  "featureInventoryDesc": "Track stock, alerts, and concession items",

  "dashboardTitle": "Admin Dashboard",
  "dashboardRevenueCard": "Total Revenue",
  "dashboardEmployeesCard": "Active Employees",
  "dashboardInventoryCard": "Inventory Value",
  "dashboardSessionsCard": "Today's Sessions",
  "dashboardOnDuty": "on duty",
  "dashboardItemsNeedAttention": "items need attention",
  "dashboardTicketsSold": "tickets sold",

  "posTitle": "Backstage Cinema POS",
  "posSubtitle": "Point of Sale System",
  "posMovieTicketsTab": "Movie Tickets",
  "posConcessionsTab": "Concessions",
  "posAddTicket": "Add Ticket",
  "posCustomerInfo": "Customer Info",
  "posCustomerCpf": "CPF (Optional)",

  "sessionsTitle": "Session Management",
  "sessionsSubtitle": "Movie Sessions & Seat Reservations",
  "sessionsFilterAll": "All Sessions",
  "sessionsScheduled": "Scheduled",
  "sessionsInProgress": "In Progress",
  "sessionsCompleted": "Completed",
  "sessionsViewSeatMap": "View Seat Map",
  "sessionsAvailableSeats": "Available Seats",
  "sessionsTicketPrice": "Ticket Price",

  "inventoryTitle": "Inventory Management",
  "inventorySubtitle": "Stock Control & Tracking",
  "inventoryItemsTab": "Inventory Items",
  "inventoryAdjustmentsTab": "Stock Adjustments",
  "inventorySearchHint": "Search by name or SKU...",
  "inventoryRefresh": "Refresh",
  "inventoryAllCategories": "All Categories",
  "inventoryAllItems": "All Items",
  "inventoryOutOfStock": "{count} {count, plural, =1{item is} other{items are}} out of stock: {items}",
  "inventoryRunningLow": "{count} {count, plural, =1{item is} other{items are}} running low: {items}",
  "inventoryExpired": "{count} {count, plural, =1{item has} other{items have}} expired: {items}",

  "errorInvalidCredentials": "Invalid credentials. Check your CPF and password.",
  "errorNetworkError": "Network error. Check your connection.",
  "errorGeneric": "An error occurred. Please try again.",

  "loading": "Loading...",
  "logout": "Logout"
}
```

#### **Using Translations in Code**:
```dart
import 'package:l10n/l10n.dart';

// In widgets
Widget build(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;

  return Text(l10n.appTitle); // "Backstage Cinema"
  return Text(l10n.loginButton); // "Entrar" (pt_BR) or "Sign In" (en)
  return Text(l10n.dashboardTitle); // "Painel Administrativo"

  // With parameters
  return Text(l10n.inventoryOutOfStock(
    count: 1,
    items: 'Cinema T-Shirt Medium',
  )); // "1 item está fora de estoque: Cinema T-Shirt Medium"
}
```

### **Feature Module `pubspec.yaml` Template**
```yaml
name: authentication
version: 0.0.1
publish_to: none

environment:
  sdk: ">=3.6.0 <4.0.0"
  flutter: ">=3.27.4"

dependencies:
  flutter:
    sdk: flutter

  # State Management
  flutter_bloc: ^8.1.6
  bloc: ^8.1.4
  equatable: ^2.0.7

  # Functional Programming
  dartz: ^0.10.1

  # Core dependencies
  core:
    path: ../../core
  design_system:
    path: ../../design_system
  shared:
    path: ../../shared

  # Internationalization
  l10n:
    path: ../../shared/l10n

  # Adapters
  http_client:
    path: ../../adapters/http_client
  storage:
    path: ../../adapters/storage

dev_dependencies:
  flutter_test:
    sdk: flutter
  mocktail: ^1.0.4
  bloc_test: ^9.1.7
```

---

## 🗓️ Implementation Timeline

### **Week 1-2: Foundation**
- ✅ Setup monorepo with Melos
- ✅ Create core package (navigation, connectivity, analytics)
- ✅ Build design system (theme, 20+ widgets)
- ✅ Setup adapters (HTTP, storage, all mocked)
- ✅ Shared utilities (formatters, validators, extensions)

### **Week 2: Authentication**
- ✅ Domain layer (User entity, Auth repository contract, Login use case)
- ✅ Data layer (User DTO, Auth repository impl with mocked data source)
- ✅ Presentation layer (Auth BLoC, Login page, Splash page)
- ✅ Unit tests + Robot tests
- ✅ CPF validation & formatting

### **Week 3: Admin Dashboard**
- ✅ Domain layer (Dashboard metrics entities, use cases)
- ✅ Data layer (Mocked dashboard data source)
- ✅ Presentation layer (Dashboard BLoC, Dashboard page with 4 cards)
- ✅ Metric cards (Revenue, Employees, Inventory, Sessions)
- ✅ Navigation bar with role badge
- ✅ Tests

### **Week 4: POS Feature**
- ✅ Domain layer (Session, Ticket, Cart entities, use cases)
- ✅ Data layer (Mocked sessions & concessions data)
- ✅ Presentation layer (POS BLoC, Cart Cubit, POS page)
- ✅ Tabs (Movie Tickets / Concessions)
- ✅ Session list with "Add Ticket" functionality
- ✅ Shopping cart & checkout flow
- ✅ Tests

### **Week 5: Session Management**
- ✅ Domain layer (Session, Theater, Seat entities, use cases)
- ✅ Data layer (Mocked sessions data with detailed info)
- ✅ Presentation layer (Sessions BLoC, Seat Map Cubit)
- ✅ Sessions list with filters
- ✅ Session cards (all details, availability bar, status)
- ✅ Basic seat map view
- ✅ Tests

### **Week 6: Inventory Management**
- ✅ Domain layer (Inventory item, Stock adjustment entities, use cases)
- ✅ Data layer (Mocked inventory data with alerts)
- ✅ Presentation layer (Inventory BLoC, Filter Cubit)
- ✅ Alert banners (out of stock, low, expired)
- ✅ Filters & search
- ✅ Inventory items list
- ✅ Stock adjustment form
- ✅ Tests

### **Week 7: Integration & Polish**
- ✅ Navigation flow testing (all routes)
- ✅ Role-based access control verification
- ✅ Error handling & edge cases
- ✅ Loading states polish
- ✅ Responsive layout adjustments
- ✅ Performance optimization
- ✅ Documentation updates

---

## 🎯 Success Criteria

### **Phase 1 Complete When**:
- [ ] All screens from prototypes are implemented
- [ ] Navigation flows work correctly (admin → dashboard, employee → POS)
- [ ] All mocked data displays properly
- [ ] Design system matches prototypes (colors, typography, components)
- [ ] CPF formatting and validation works
- [ ] Role-based routing functions correctly
- [ ] 80%+ unit test coverage
- [ ] Robot tests for all main flows pass
- [ ] App runs on iOS and Android without errors

### **Quality Gates**:
- [ ] `melos analyze` passes with no errors
- [ ] `melos test` achieves 80%+ coverage
- [ ] No navigation black screens or stack errors
- [ ] All forms validate properly
- [ ] Error states display correctly
- [ ] Loading states are smooth

---

## 📚 Key Implementation Notes

### **Mocked Data Strategy**:
All infrastructure layer services return mocked data for Phase 1:
- **Auth API**: Hardcoded users (admin, employee)
- **Dashboard API**: Static metrics
- **Sessions API**: 10-15 sample sessions
- **Inventory API**: 20-30 sample items with alerts
- **Connectivity**: Always returns "connected"
- **Analytics**: Console logs only

### **Navigation Rules**:
```dart
Role.admin → Routes:
  - /dashboard (default)
  - /sessions
  - /inventory
  - /pos
  - /settings

Role.employee → Routes:
  - /pos (default)
  - /sessions (read-only)
```

### **State Persistence**:
- Auth token stored in mocked storage
- Cart state persisted during session
- Last viewed screen restored on app restart

### **Error Handling**:
```dart
sealed class AppException implements Exception {
  const AppException(this.message);
  final String message;
}

class NetworkException extends AppException {
  const NetworkException(super.message);
}

class AuthException extends AppException {
  const AuthException(super.message);
}

class ValidationException extends AppException {
  const ValidationException(super.message);
}
```

---

## 🔄 Phase 2: Real API Integration (Future)

Once Phase 1 is complete and approved, Phase 2 will involve:

1. **Replace Mocked Data Sources** with real API calls
2. **Implement Real Authentication** with JWT tokens
3. **Add Real-time Updates** (WebSocket for sessions, inventory)
4. **Connect to Backstage Backend** services
5. **Add Offline Support** with local database (Hive/Drift)
6. **Implement Real Analytics** (Firebase, Mixpanel)
7. **Add Push Notifications**
8. **Performance Monitoring** (Firebase Performance)

---

## 📞 Contact & Support

For questions or clarifications during implementation:
- Architecture decisions: Refer to `how_to_implement_flutter.md`
- Design reference: Check `backstage_documentation/assets/prototype/v1/`
- Backend APIs: See `backstage_backend` documentation
- Next.js reference: Check `backstage-cinema` for UI patterns

---

## ✅ Implementation Checklist

### **Phase 0: Pre-Setup**
- [ ] Review implementation plan
- [ ] Approve architecture decisions
- [ ] Install Flutter 3.27.4
- [ ] Install Dart SDK 3.6.0+
- [ ] Install Melos globally (`dart pub global activate melos`)
- [ ] Setup IDE (VS Code with Flutter extensions)

### **Phase 1: Foundation & Core Infrastructure** (Week 1-2)

#### **1.1 Monorepo Setup**
- [ ] Create melos.yaml configuration
- [ ] Setup project structure (app/, packages/)
- [ ] Configure melos scripts (bootstrap, analyze, test, generate)
- [ ] Run `melos bootstrap` successfully

#### **1.2 Core Package**
- [ ] Create packages/core package
- [ ] Implement NavigationManager with stack protection
- [ ] Implement RouteGuards (authentication)
- [ ] Create PermissionHandler service (mocked)
- [ ] Create ConnectivityChecker (mocked)
- [ ] Create AnalyticsTracker (mocked)
- [ ] Write unit tests for core services

#### **1.3 Design System Package**
- [ ] Create packages/design_system package
- [ ] Define AppColors (all style guide colors)
- [ ] Define AppTextStyles (typography)
- [ ] Define AppTheme (light/dark themes)
- [ ] Define AppDimensions (spacing, sizing)
- [ ] Create PrimaryButton widget
- [ ] Create SecondaryButton widget
- [ ] Create GhostButton widget
- [ ] Create MetricCard widget
- [ ] Create SessionCard widget
- [ ] Create InventoryCard widget
- [ ] Create FeatureCard widget (for carousel)
- [ ] Create CineTextField widget
- [ ] Create CinePasswordField widget
- [ ] Create CpfField widget
- [ ] Create SearchField widget
- [ ] Create ProgressBar widget
- [ ] Create LoadingSpinner widget
- [ ] Create StatusBadge widget
- [ ] Create AlertBanner widget
- [ ] Create CineSnackbar widget
- [ ] Create CineAppBar widget
- [ ] Create CineTabs widget
- [ ] Create CineDropdown widget
- [ ] Create PageScaffold widget
- [ ] Create ResponsiveLayout widget
- [ ] Create FeaturesCarousel widget
- [ ] Create SplashLoading widget
- [ ] Add cinema logo asset
- [ ] Write widget tests for all components

#### **1.4 Shared L10n Package**
- [ ] Create packages/shared/l10n package
- [ ] Setup l10n.yaml configuration
- [ ] Create app_pt_BR.arb (Brazilian Portuguese)
- [ ] Create app_en.arb (English fallback)
- [ ] Add all translation strings (80+ keys)
- [ ] Generate localization code
- [ ] Test translations in sample widget

#### **1.5 Shared Utils Package**
- [ ] Create packages/shared/utils package
- [ ] Create CpfFormatter
- [ ] Create CpfValidator
- [ ] Create CurrencyFormatter (BRL)
- [ ] Create DateFormatter
- [ ] Create StringExtensions
- [ ] Create DateExtensions
- [ ] Create NumExtensions
- [ ] Create AppException classes
- [ ] Create Failure classes
- [ ] Create Either/Result implementation
- [ ] Write unit tests for all utilities

#### **1.6 Shared Routing Package**
- [ ] Create packages/shared/routing package
- [ ] Define AppRoutes constants
- [ ] Implement RouteGuards
- [ ] Create NavigationHelpers
- [ ] Write navigation tests

#### **1.7 Adapters Package**
- [ ] Create packages/adapters/http_client package
- [ ] Define HttpClient interface
- [ ] Implement HttpClientImpl (Dio-based, mocked)
- [ ] Create AuthInterceptor
- [ ] Create LoggerInterceptor
- [ ] Create HttpException classes
- [ ] Create packages/adapters/storage package
- [ ] Define StorageClient interface
- [ ] Implement StorageClientImpl (SharedPreferences, mocked)
- [ ] Create packages/adapters/connectivity package
- [ ] Define ConnectivityClient interface
- [ ] Implement ConnectivityClientImpl (mocked - always connected)
- [ ] Create packages/adapters/analytics package
- [ ] Define AnalyticsClient interface
- [ ] Implement AnalyticsClientImpl (console logs)
- [ ] Write tests for all adapters

#### **1.8 Main App Setup**
- [ ] Create app/ package
- [ ] Setup main.dart with MaterialApp
- [ ] Configure theme (use design_system)
- [ ] Setup localization delegates
- [ ] Configure navigation
- [ ] Setup dependency injection (GetIt)
- [ ] Create initial routes
- [ ] Test app launches successfully

### **Phase 2: Authentication Feature** (Week 2)
- [ ] Create packages/features/authentication package
- [ ] Implement domain layer (User, Credentials, AuthToken entities)
- [ ] Implement repositories (AuthRepository)
- [ ] Implement use cases (Login, Logout, CheckAuthStatus, GetFeatures)
- [ ] Implement data layer (DTOs, datasources - mocked)
- [ ] Implement AuthBloc
- [ ] Create SplashPage with loading indicator
- [ ] Create FeaturesCarousel widget
- [ ] Create LoginPage with carousel
- [ ] Create LoginForm widget
- [ ] Create ForgotPasswordPage
- [ ] Implement role-based navigation
- [ ] Write unit tests
- [ ] Write widget tests (Robot pattern)

### **Phase 3: Admin Dashboard** (Week 3)
- [ ] Create packages/features/dashboard package
- [ ] Implement domain layer
- [ ] Implement data layer (mocked)
- [ ] Implement DashboardBloc
- [ ] Create DashboardPage
- [ ] Create RevenueCard widget
- [ ] Create EmployeeStatusCard widget
- [ ] Create InventoryAlertCard widget
- [ ] Create SessionSummaryCard widget
- [ ] Implement pull-to-refresh
- [ ] Write tests

### **Phase 4: POS Feature** (Week 4)
- [ ] Create packages/features/pos package
- [ ] Implement domain layer
- [ ] Implement data layer (mocked)
- [ ] Implement PosBloc and CartCubit
- [ ] Create PosPage with tabs
- [ ] Create SessionListView
- [ ] Create SessionCard
- [ ] Create CartWidget
- [ ] Create CustomerInfoForm
- [ ] Create CheckoutPage
- [ ] Write tests

### **Phase 5: Session Management** (Week 5)
- [ ] Create packages/features/sessions package
- [ ] Implement domain layer
- [ ] Implement data layer (mocked)
- [ ] Implement SessionsBloc
- [ ] Create SessionsPage
- [ ] Create SessionFilter
- [ ] Create SessionCard with availability
- [ ] Create basic SeatMapPage
- [ ] Write tests

### **Phase 6: Inventory Management** (Week 6)
- [ ] Create packages/features/inventory package
- [ ] Implement domain layer
- [ ] Implement data layer (mocked)
- [ ] Implement InventoryBloc
- [ ] Create InventoryPage
- [ ] Create InventoryAlertBanners
- [ ] Create InventoryFilterSection
- [ ] Create InventoryItemCard
- [ ] Create StockAdjustmentForm
- [ ] Write tests

### **Phase 7: Integration & Polish** (Week 7)
- [ ] Test all navigation flows
- [ ] Verify role-based access control
- [ ] Test error handling
- [ ] Polish loading states
- [ ] Test responsive layouts
- [ ] Performance optimization
- [ ] Update documentation
- [ ] Final QA pass

---

## ✅ Next Steps

1. **Review this plan** with the team
2. **Approve architecture** and design decisions
3. **Setup development environment** (Flutter 3.27.4, Melos)
4. **Initialize monorepo structure**
5. **Begin Phase 1: Foundation** (Week 1-2)

---

**Document Version**: 1.1
**Last Updated**: 2025-01-19
**Author**: AI Architecture Assistant
**Status**: Ready for Review

---

## 📝 Version History

**v1.1** (2025-01-19):
- ✅ Updated design system colors based on official style guide
- ✅ Added comprehensive color usage guidelines
- ✅ Updated typography with official font recommendations
- ✅ Added internationalization (intl) package setup
- ✅ Created example ARB files for pt_BR and English
- ✅ Removed demo credentials from login screen
- ✅ Corrected splash screen definition (loading screen with indicator)
- ✅ Added features carousel to login screen
- ✅ Added new widgets: FeaturesCarousel, FeatureCard, SplashLoading
- ✅ Updated all color references to match style guide

**v1.0** (2025-01-19):
- Initial implementation plan created

# DrinkTime 🍻

A Flutter mobile application for purchasing, sharing, and redeeming drink tokens/coupons with friends. Built with a wallet-first approach using Supabase backend for real-time data synchronization.

## 🌟 Features

### 💰 Digital Wallet
- **Token Management**: View all your purchased and received drink tokens
- **Smart Filtering**: Separate tabs for Available, Used, and All tokens
- **Real-time Updates**: Instant synchronization across devices
- **Token Value Tracking**: See total wallet value at a glance

### 🛒 Marketplace
- **Browse Bars**: Discover participating bars and their drink offerings
- **Purchase Tokens**: Buy drink tokens for yourself or as gifts
- **Menu Integration**: View full drink menus with prices
- **Secure Transactions**: Safe payment processing through Supabase

### 🤝 Social Sharing
- **Share Tokens**: Send drink tokens to friends by username
- **QR Code Redemption**: Generate and scan QR codes for easy redemption
- **Gift System**: Purchase tokens as gifts for others
- **Invite Friends**: Share tokens with users not yet on the platform

### 📱 User Experience
- **Wallet-First Navigation**: Quick access to your tokens on app launch
- **Material Design 3**: Modern, intuitive interface
- **Cross-Platform**: Works on iOS, Android, Web, and Desktop
- **Offline Capability**: Basic functionality works without internet

## 🏗️ Technical Architecture

### Frontend
- **Framework**: Flutter (Dart SDK 3.8.1+)
- **State Management**: Riverpod for reactive state handling
- **Navigation**: GoRouter with bottom tab navigation
- **UI Library**: Material Design 3 with custom theming
- **QR Codes**: qr_flutter for QR code generation and scanning

### Backend
- **Database**: Supabase (PostgreSQL)
- **Authentication**: Supabase Auth with email/password
- **Real-time**: Supabase real-time subscriptions
- **Storage**: Supabase Storage for assets
- **Security**: Row Level Security (RLS) policies

### Architecture Pattern
- **Feature-First**: Organized by business features
- **Clean Architecture**: Separation of data, domain, and presentation layers
- **Repository Pattern**: Abstracted data access layer
- **Provider-Based**: Dependency injection with Riverpod

## 📁 Project Structure

```
lib/
├── features/
│   ├── auth/                    # Authentication
│   │   ├── data/               # Auth repository
│   │   └── presentation/       # Login/Signup screens
│   ├── marketplace/            # Bar browsing & discovery
│   │   ├── data/               # Marketplace repository
│   │   ├── domain/             # Bar models
│   │   └── presentation/       # Home screen & controllers
│   ├── menu/                   # Drink menu & purchasing
│   │   ├── data/               # Menu repository
│   │   ├── domain/             # Menu item models
│   │   └── presentation/       # Menu screen & controllers
│   └── wallet/                 # Token management
│       ├── data/               # Wallet repository
│       └── presentation/       # Wallet screen & controllers
├── main_scaffold.dart          # Bottom navigation
├── router.dart                 # App routing configuration
└── main.dart                   # App entry point
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.8.1 or higher
- Dart SDK 3.0.0 or higher
- Android Studio / VS Code with Flutter extensions
- Git for version control

### Installation

1. **Clone the repository**
   ```bash
   git clone git@github.com:mbruner63/drink_time.git
   cd drink_time
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Supabase**
   - Create a new project at [Supabase](https://supabase.com)
   - Copy your project URL and anon key
   - Update `lib/main.dart` with your credentials:
   ```dart
   await Supabase.initialize(
     url: 'YOUR_SUPABASE_URL',
     anonKey: 'YOUR_SUPABASE_ANON_KEY',
   );
   ```

4. **Set up database schema**
   - Run the SQL migrations in your Supabase dashboard
   - Set up Row Level Security policies
   - Create the required tables: `profiles`, `bars`, `menu_items`, `coupons`

5. **Run the application**
   ```bash
   flutter run
   ```

### Database Schema

The app requires the following key tables:

- **profiles**: User information and authentication
- **bars**: Participating establishments
- **menu_items**: Drink offerings per bar
- **coupons**: Token/coupon records with status tracking

See the SQL migrations in the Supabase dashboard for complete schema.

## 🧪 Testing

Run the test suite:
```bash
flutter test
```

For integration tests:
```bash
flutter drive --target=test_driver/app.dart
```

## 📱 Platform Support

- ✅ **Android** (API 21+)
- ✅ **iOS** (iOS 12.0+)
- ✅ **Web** (Modern browsers)
- ✅ **Windows** (Windows 10+)
- ✅ **macOS** (macOS 10.14+)
- ✅ **Linux** (Recent distributions)

## 🔧 Development Commands

### Code Generation
```bash
flutter packages pub run build_runner build
```

### Icon Generation
```bash
dart run tool/generate_icon.dart
```

### Build Commands
```bash
# Debug build
flutter build apk --debug

# Release build
flutter build apk --release

# iOS build
flutter build ios --release

# Web build
flutter build web --release
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Code Style
- Follow Flutter/Dart conventions
- Use meaningful variable and function names
- Add comments for complex logic
- Write tests for new features

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **Flutter Team** for the amazing cross-platform framework
- **Supabase** for the powerful backend-as-a-service
- **Material Design** for the UI component system
- **Font Awesome** for the icon library

## 📞 Support

For support, email support@drinktime.app or open an issue in this repository.

## 🗺️ Roadmap

- [ ] Push notifications for token sharing
- [ ] Apple Pay / Google Pay integration
- [ ] Location-based bar discovery
- [ ] Social features and friend connections
- [ ] Analytics dashboard for bar owners
- [ ] Loyalty programs and rewards

---

**Built with ❤️ using Flutter and Supabase**
# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build Commands

This is a Flutter project using Dart SDK 3.8.1+. Common development commands:

- **Development**: `flutter run` - Run the app in debug mode with hot reload
- **Build for release**: `flutter build apk` (Android) or `flutter build ios` (iOS)
- **Install dependencies**: `flutter pub get`
- **Upgrade dependencies**: `flutter pub upgrade`
- **Run tests**: `flutter test`
- **Analyze code**: `flutter analyze`
- **Format code**: `dart format .`

### Platform-specific builds:
- **Android**: `flutter build apk --release` or `flutter build appbundle`
- **iOS**: `flutter build ios --release`
- **Web**: `flutter build web`
- **Windows**: `flutter build windows`
- **macOS**: `flutter build macos`
- **Linux**: `flutter build linux`

## Architecture Overview

This is a **drink tracking mobile application** built with Flutter. Based on the dependencies, it appears to be designed for tracking drinks with QR code functionality and cloud synchronization.

### Key Dependencies and Architecture Patterns

1. **State Management**: Uses **Riverpod** (`flutter_riverpod ^2.5.1`) - the recommended state management solution for clean architecture in Flutter

2. **Navigation**: Implements **GoRouter** (`go_router ^14.0.0`) for declarative routing and deep linking support

3. **Backend/Database**: Integrates with **Supabase** (`supabase_flutter ^2.0.0`) for real-time database, authentication, and backend services

4. **QR Code Features**:
   - `qr_flutter ^4.1.0` - Generate QR codes
   - `mobile_scanner ^5.0.0` - Scan QR codes with camera
   - These suggest the app likely uses QR codes for drink identification or sharing

5. **UI/Typography**:
   - `google_fonts ^6.1.0` - Custom typography
   - `font_awesome_flutter ^10.7.0` - Icon library

### Current State

The project is currently in its initial state with the default Flutter counter app template in `lib/main.dart`. The sophisticated dependencies suggest this is planned to be a full-featured drink tracking application.

### Development Notes

- The project uses `flutter_lints ^5.0.0` for code quality enforcement
- Analysis options are configured in `analysis_options.yaml` with standard Flutter lints
- The app supports all major platforms (Android, iOS, Web, Windows, macOS, Linux)
- Private package (not published to pub.dev)

### Expected Architecture Pattern

Based on the Riverpod dependency, the app should follow clean architecture principles:
- **Providers**: State management with Riverpod providers
- **Models**: Data models for drinks, users, etc.
- **Services**: API calls to Supabase backend
- **Views**: Widget screens and components
- **Router**: GoRouter configuration for navigation

### QR Code Integration

The dual QR code dependencies suggest the app will:
- Generate QR codes for drinks or user profiles
- Scan QR codes to add drinks or connect with other users
- Potentially share drink information via QR codes
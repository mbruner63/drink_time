import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Main scaffold with bottom navigation bar for the authenticated app
class MainScaffold extends StatelessWidget {
  final Widget child;

  const MainScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _calculateSelectedIndex(context),
        onTap: (index) => _onItemTapped(index, context),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF1E3A8A), // Dark blue
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        elevation: 8,
        items: const [
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.wallet),
            label: 'My Wallet',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.store),
            label: 'Buy Drinks',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.user),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  /// Calculate the selected index based on the current route
  static int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).fullPath ?? '';

    if (location.startsWith('/wallet')) {
      return 0;
    }
    if (location.startsWith('/marketplace')) {
      return 1;
    }
    if (location.startsWith('/profile')) {
      return 2;
    }
    return 0; // Default to wallet
  }

  /// Handle bottom navigation bar item taps
  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        GoRouter.of(context).go('/wallet');
        break;
      case 1:
        GoRouter.of(context).go('/marketplace');
        break;
      case 2:
        GoRouter.of(context).go('/profile');
        break;
    }
  }
}
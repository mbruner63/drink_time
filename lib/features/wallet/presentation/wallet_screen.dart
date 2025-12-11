import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'wallet_controller.dart';
import '../../auth/presentation/auth_controller.dart';

class WalletScreen extends ConsumerStatefulWidget {
  const WalletScreen({super.key});

  @override
  ConsumerState<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends ConsumerState<WalletScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Add listener to refresh filtered providers when switching tabs
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        print('🔄 Tab switching to index: ${_tabController.index}');
        final currentUser = ref.read(currentUserProvider);
        if (currentUser != null) {
          // Force refresh the filtered providers when switching tabs
          if (_tabController.index == 1) { // Available tab
            print('   📊 Refreshing Available tab data');
            ref.invalidate(couponsByStatusProvider(CouponStatusQuery(userId: currentUser.id, status: 'purchased')));
          } else if (_tabController.index == 2) { // Used tab
            print('   📊 Refreshing Used tab data');
            ref.invalidate(couponsByStatusProvider(CouponStatusQuery(userId: currentUser.id, status: 'redeemed')));
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showQrCodeDialog(Map<String, dynamic> coupon) {
    final qrSecret = CouponHelper.getQrSecret(coupon);
    final drinkName = CouponHelper.getDrinkName(coupon);
    final barName = CouponHelper.getBarName(coupon);
    final price = CouponHelper.getFormattedPrice(coupon);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            drinkName,
                            style: GoogleFonts.fredoka(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF4682B4),
                            ),
                          ),
                          Text(
                            'at $barName',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          Text(
                            price,
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF4682B4),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // QR Code
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: QrImageView(
                    data: qrSecret,
                    size: 200,
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                  ),
                ),

                const SizedBox(height: 20),

                // Instructions
                Text(
                  'Show this QR code at the bar to redeem your drink',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 20),

                // Maps button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _openMapForBar(coupon),
                    icon: const Icon(FontAwesomeIcons.locationDot),
                    label: Text('View $barName on Map'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF4682B4),
                      side: const BorderSide(color: Color(0xFF4682B4)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Actions
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // TODO: Implement share functionality
                          Navigator.of(context).pop();
                          _showShareDialog(coupon);
                        },
                        icon: const Icon(FontAwesomeIcons.share),
                        label: const Text('Share'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF4682B4),
                          side: const BorderSide(color: Color(0xFF4682B4)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _markAsRedeemed(coupon);
                        },
                        icon: const Icon(FontAwesomeIcons.check),
                        label: const Text('Mark as Used'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4682B4),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showShareDialog(Map<String, dynamic> coupon) {
    final TextEditingController usernameController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Share Coupon',
            style: GoogleFonts.fredoka(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF4682B4),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Enter the username of the person you want to share this coupon with:',
                style: GoogleFonts.inter(fontSize: 14),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(FontAwesomeIcons.user, size: 16),
                ),
                keyboardType: TextInputType.text,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (usernameController.text.isNotEmpty) {
                  Navigator.of(context).pop();
                  _shareCoupon(coupon['id'], usernameController.text);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4682B4),
                foregroundColor: Colors.white,
              ),
              child: const Text('Share'),
            ),
          ],
        );
      },
    );
  }

  void _shareCoupon(String couponId, String username) async {
    print('🖱️ UI: Share button pressed');
    print('   🎫 Coupon ID: $couponId');
    print('   👤 Username: $username');

    try {
      await ref.read(walletActionsControllerProvider.notifier).shareCoupon(
        couponId: couponId,
        recipientEmail: username,
      );

      final state = ref.read(walletActionsControllerProvider);
      print('🔍 UI: Checking final state...');
      print('   Has error: ${state.hasError}');
      print('   Error: ${state.error}');
      print('   Has action: ${state.hasAction}');
      print('   Last action: ${state.lastAction}');

      if (!mounted) {
        print('⚠️ UI: Widget not mounted, skipping UI updates');
        return;
      }

      if (state.hasError) {
        print('❌ UI: Showing error snackbar');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to share: ${state.error}'),
            backgroundColor: Colors.red.shade600,
          ),
        );
      } else if (state.hasAction) {
        print('✅ UI: Showing success snackbar');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.lastAction!),
            backgroundColor: Colors.green.shade600,
          ),
        );
        // Refresh coupons
        final currentUser = ref.read(currentUserProvider);
        if (currentUser != null) {
          print('🔄 UI: Refreshing coupon list for user: ${currentUser.id}');
          ref.invalidate(myCouponsProvider(currentUser.id));
          // Also refresh the filtered providers
          ref.invalidate(couponsByStatusProvider(CouponStatusQuery(userId: currentUser.id, status: 'purchased')));
          ref.invalidate(couponsByStatusProvider(CouponStatusQuery(userId: currentUser.id, status: 'shared')));
          ref.invalidate(couponsByStatusProvider(CouponStatusQuery(userId: currentUser.id, status: 'redeemed')));
          ref.invalidate(purchasedCouponsProvider(currentUser.id));
          ref.invalidate(receivedCouponsProvider(currentUser.id));
        }
      } else {
        print('🤷 UI: No error or action detected - this might be the issue!');
      }
    } catch (e) {
      print('💥 UI: Exception caught in _shareCoupon: $e');
    }
  }

  void _openMapForBar(Map<String, dynamic> coupon) async {
    final barName = CouponHelper.getBarName(coupon);
    var coordinates = CouponHelper.getBarCoordinates(coupon);

    print('📍 Opening map for bar: $barName');
    print('   📊 Available coordinates from coupon: $coordinates');
    print('   🗃️ Full coupon data structure: ${coupon.toString()}');

    // If coordinates aren't in coupon data, try to fetch from bars table
    if (coordinates == null) {
      final barId = CouponHelper.getBarId(coupon);
      print('   🔍 No coordinates in coupon, trying to fetch for barId: $barId');

      if (barId != null) {
        try {
          final repository = ref.read(walletRepositoryProvider);
          coordinates = await repository.getBarCoordinates(barId);
          print('   📊 Fetched coordinates: $coordinates');
        } catch (e) {
          print('   💥 Error fetching coordinates: $e');
        }
      }
    }

    // List of URL formats to try in order of preference
    final List<String> mapUrls = [];

    // 1. Try coordinates if available (most accurate)
    if (coordinates != null) {
      final lat = coordinates['latitude']!;
      final lng = coordinates['longitude']!;
      mapUrls.addAll([
        'geo:$lat,$lng?q=$lat,$lng($barName)', // Android geo intent
        'https://www.google.com/maps/search/?api=1&query=$lat,$lng', // Google Maps web
        'https://maps.google.com/?q=$lat,$lng', // Alternative Google Maps
        'https://maps.apple.com/?ll=$lat,$lng&q=$barName', // Apple Maps
      ]);
    }

    // 2. Fallback to bar name search
    final encodedBarName = Uri.encodeComponent(barName);
    mapUrls.addAll([
      'geo:0,0?q=$encodedBarName', // Android geo search
      'https://www.google.com/maps/search/?api=1&query=$encodedBarName', // Google Maps search
      'https://maps.google.com/?q=$encodedBarName', // Alternative Google Maps
      'https://maps.apple.com/?q=$encodedBarName', // Apple Maps search
    ]);

    // Try each URL until one works
    bool mapOpened = false;
    for (int i = 0; i < mapUrls.length && !mapOpened; i++) {
      final url = mapUrls[i];
      print('   🔗 Trying URL ${i + 1}: $url');

      try {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          print('   ✅ Maps opened successfully with URL ${i + 1}');
          mapOpened = true;
        } else {
          print('   ❌ Cannot launch URL ${i + 1}');
        }
      } catch (e) {
        print('   💥 Error with URL ${i + 1}: $e');
      }
    }

    if (!mapOpened) {
      print('💥 All map URLs failed');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open maps for $barName. Please search for "$barName" manually in your maps app.'),
            backgroundColor: Colors.red.shade600,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  void _markAsRedeemed(Map<String, dynamic> coupon) async {
    print('🖱️ UI: Mark as redeemed button pressed');
    print('   🎫 Coupon ID: ${coupon['id']}');
    print('   📊 Coupon status: ${coupon['status']}');
    print('   🍺 Drink: ${CouponHelper.getDrinkName(coupon)}');

    try {
      await ref.read(walletActionsControllerProvider.notifier).redeemCoupon(coupon['id']);

      final state = ref.read(walletActionsControllerProvider);
      print('🔍 UI: Checking final redeem state...');
      print('   Has error: ${state.hasError}');
      print('   Error: ${state.error}');
      print('   Has action: ${state.hasAction}');
      print('   Last action: ${state.lastAction}');

      if (!mounted) {
        print('⚠️ UI: Widget not mounted, skipping UI updates');
        return;
      }

      if (state.hasError) {
        print('❌ UI: Showing redeem error snackbar');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to mark as redeemed: ${state.error}'),
            backgroundColor: Colors.red.shade600,
          ),
        );
      } else if (state.hasAction) {
        print('✅ UI: Showing redeem success snackbar');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.lastAction!),
            backgroundColor: Colors.green.shade600,
          ),
        );
        // Refresh coupons
        final currentUser = ref.read(currentUserProvider);
        if (currentUser != null) {
          print('🔄 UI: Refreshing coupon list after redemption');
          ref.invalidate(myCouponsProvider(currentUser.id));
          // Also refresh the filtered providers
          ref.invalidate(couponsByStatusProvider(CouponStatusQuery(userId: currentUser.id, status: 'purchased')));
          ref.invalidate(couponsByStatusProvider(CouponStatusQuery(userId: currentUser.id, status: 'shared')));
          ref.invalidate(couponsByStatusProvider(CouponStatusQuery(userId: currentUser.id, status: 'redeemed')));
          ref.invalidate(purchasedCouponsProvider(currentUser.id));
          ref.invalidate(receivedCouponsProvider(currentUser.id));
        }
      } else {
        print('🤷 UI: No error or action detected after redemption - this might be the issue!');
      }
    } catch (e) {
      print('💥 UI: Exception caught in _markAsRedeemed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);

    if (currentUser == null) {
      return const Scaffold(
        body: Center(
          child: Text('Please log in to view your wallet'),
        ),
      );
    }

    final allCouponsAsync = ref.watch(myCouponsProvider(currentUser.id));
    final totalValueAsync = ref.watch(totalCouponValueProvider(currentUser.id));

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF87CEEB),
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'My Wallet',
              style: GoogleFonts.fredoka(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            totalValueAsync.when(
              loading: () => const SizedBox(),
              error: (_, __) => const SizedBox(),
              data: (totalValue) => Text(
                'Total Value: \$${totalValue.toStringAsFixed(2)}',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              print('🔄 Manual refresh triggered');
              ref.invalidate(myCouponsProvider(currentUser.id));
              // Also refresh all filtered providers
              ref.invalidate(couponsByStatusProvider(CouponStatusQuery(userId: currentUser.id, status: 'purchased')));
              ref.invalidate(couponsByStatusProvider(CouponStatusQuery(userId: currentUser.id, status: 'shared')));
              ref.invalidate(couponsByStatusProvider(CouponStatusQuery(userId: currentUser.id, status: 'redeemed')));
              ref.invalidate(purchasedCouponsProvider(currentUser.id));
              ref.invalidate(receivedCouponsProvider(currentUser.id));
              ref.invalidate(totalCouponValueProvider(currentUser.id));
            },
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.7),
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Available'),
            Tab(text: 'Used'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAllCouponsTab(currentUser.id),
          _buildAvailableCouponsTab(currentUser.id),
          _buildUsedCouponsTab(currentUser.id),
        ],
      ),
    );
  }

  Widget _buildAllCouponsTab(String userId) {
    final couponsAsync = ref.watch(myCouponsProvider(userId));
    return _buildCouponsList(couponsAsync);
  }

  Widget _buildAvailableCouponsTab(String userId) {
    final couponsAsync = ref.watch(couponsByStatusProvider(
      CouponStatusQuery(userId: userId, status: 'purchased'),
    ));
    return _buildCouponsList(couponsAsync);
  }

  Widget _buildUsedCouponsTab(String userId) {
    final couponsAsync = ref.watch(couponsByStatusProvider(
      CouponStatusQuery(userId: userId, status: 'redeemed'),
    ));
    return _buildCouponsList(couponsAsync);
  }

  Widget _buildCouponsList(AsyncValue<List<Map<String, dynamic>>> couponsAsync) {
    return couponsAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4682B4)),
        ),
      ),
      error: (error, stack) => _buildErrorWidget(error.toString()),
      data: (coupons) {
        if (coupons.isEmpty) {
          return _buildEmptyState();
        }
        return _buildCouponsListView(coupons);
      },
    );
  }

  Widget _buildCouponsListView(List<Map<String, dynamic>> coupons) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: coupons.length,
      itemBuilder: (context, index) {
        final coupon = coupons[index];
        return _buildCouponCard(coupon);
      },
    );
  }

  Widget _buildCouponCard(Map<String, dynamic> coupon) {
    final drinkName = CouponHelper.getDrinkName(coupon);
    final barName = CouponHelper.getBarName(coupon);
    final price = CouponHelper.getFormattedPrice(coupon);
    final status = CouponHelper.getStatusDisplay(coupon);
    final date = CouponHelper.getFormattedDate(coupon);
    final canUse = CouponHelper.canRedeem(coupon);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: canUse ? () => _showQrCodeDialog(coupon) : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Drink icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: canUse
                        ? [const Color(0xFF87CEEB), const Color(0xFF4682B4)]
                        : [Colors.grey.shade400, Colors.grey.shade600],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  FontAwesomeIcons.wineGlass,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),

              // Coupon details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$drinkName at $barName',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: canUse ? Colors.grey.shade800 : Colors.grey.shade500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Purchased $date',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: canUse
                                ? const Color(0xFF87CEEB).withOpacity(0.1)
                                : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            price,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: canUse ? const Color(0xFF4682B4) : Colors.grey.shade600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getStatusColor(coupon['status']).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            status,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: _getStatusColor(coupon['status']),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Action buttons
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Maps button
                  IconButton(
                    onPressed: () => _openMapForBar(coupon),
                    icon: Icon(
                      FontAwesomeIcons.locationDot,
                      color: const Color(0xFF4682B4),
                      size: 18,
                    ),
                    tooltip: 'View on Map',
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                  ),
                  // QR code indicator
                  if (canUse)
                    Icon(
                      FontAwesomeIcons.qrcode,
                      color: Colors.grey.shade400,
                      size: 20,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'purchased':
        return Colors.green;
      case 'shared':
        return Colors.blue;
      case 'redeemed':
        return Colors.grey;
      default:
        return Colors.orange;
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            FontAwesomeIcons.wallet,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No coupons yet',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Purchase drinks to add coupons to your wallet',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              FontAwesomeIcons.triangleExclamation,
              size: 64,
              color: Colors.red.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load coupons',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                final currentUser = ref.read(currentUserProvider);
                if (currentUser != null) {
                  ref.invalidate(myCouponsProvider(currentUser.id));
                }
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4682B4),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
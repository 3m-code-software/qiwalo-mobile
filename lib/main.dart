import 'package:flutter/material.dart';
import 'api/booking_repository.dart';
import 'owner_driver_data.dart';
import 'screens/account.dart';
import 'screens/auth.dart';
import 'screens/booking.dart';
import 'screens/design_index.dart';
import 'screens/discover.dart';
import 'screens/owner_driver.dart';
import 'screens/role_login.dart';
import 'role_data_gate.dart';
import 'theme.dart';

void main() => runApp(const QiwaloApp());

class QiwaloApp extends StatelessWidget {
  const QiwaloApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'قيوالو',
      debugShowCheckedModeBanner: false,
      theme: qiwaloTheme(),
      builder: (context, child) => Directionality(
        textDirection: TextDirection.rtl,
        child: child!,
      ),
      initialRoute: '/design',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/unit':
            return MaterialPageRoute<dynamic>(
              settings: settings,
              builder: (_) => UnitScreen(
                slug: settings.arguments is String
                    ? settings.arguments as String
                    : null,
              ),
            );
          case '/gallery':
            final images = settings.arguments;
            return MaterialPageRoute<dynamic>(
              settings: settings,
              builder: (_) => GalleryScreen(
                images: images is List<String> ? images : null,
              ),
            );
          case '/checkout':
            final draft = settings.arguments;
            return MaterialPageRoute<dynamic>(
              settings: settings,
              builder: (_) => CheckoutScreen(
                draft: draft is BookingDraft
                    ? draft
                    : const BookingDraft(
                        slug: 'nile-view-dar-al-madina',
                        unitName: 'دار المدينة بإطلالة على النيل',
                        cityAr: 'الأقصر',
                        checkIn: '2026-11-30',
                        checkOut: '2026-12-03',
                      ),
              ),
            );
          case '/success':
            final booking = settings.arguments;
            return MaterialPageRoute<dynamic>(
              settings: settings,
              builder: (_) => BookingSuccessScreen(
                booking: booking is MobileBooking
                    ? booking
                    : MobileBooking.preview(
                        'CASH',
                        BookingQuote.preview.grandTotal,
                      ),
              ),
            );
          case '/bookings':
            return MaterialPageRoute<dynamic>(
              settings: settings,
              builder: (_) => BookingsScreen(
                initialReference: settings.arguments is String
                    ? settings.arguments as String
                    : null,
              ),
            );
          case '/driver-trip-detail':
            final trip = settings.arguments;
            return MaterialPageRoute<dynamic>(
              settings: settings,
              builder: (_) => DriverTripDetailScreen(
                trip: trip is DriverTrip ? trip : driverTrips.first,
              ),
            );
          case '/owner-unit-form':
            final unitId = settings.arguments;
            return MaterialPageRoute<dynamic>(
              settings: settings,
              builder: (_) => RoleDataGate(
                role: 'OWNER',
                title: 'إضافة / تعديل وحدة',
                builder: (context, snapshot) => OwnerUnitFormScreen(
                  snapshot: snapshot,
                  unitId: unitId is String ? unitId : null,
                ),
              ),
            );
          case '/role-login':
            return MaterialPageRoute<dynamic>(
              settings: settings,
              builder: (_) => RoleLoginScreen(
                role: settings.arguments is String ? settings.arguments as String : 'OWNER',
              ),
            );
          default:
            return null;
        }
      },
      routes: {
        '/design': (_) => const DesignIndexScreen(),
        '/onboarding': (_) => const OnboardingScreen(),
        '/login': (_) => const LoginScreen(),
        '/signup': (_) => const SignupScreen(),
        '/telegram': (_) => const TelegramScreen(),
        '/recovery': (_) => const RecoveryScreen(),
        '/home': (_) => const HomeScreen(),
        '/filters': (_) => const SheetPreview(title: 'ورقة الفلاتر', sheet: FilterSheet()),
        '/calendar': (_) => const SheetPreview(title: 'ورقة التوافر', sheet: CalendarSheet()),
        '/payment': (_) => const PaymentScreen(),
        '/booking-detail': (_) => const BookingDetailScreen(),
        '/favorites': (_) => const FavoritesScreen(),
        '/profile': (_) => const ProfileScreen(),
        '/help': (_) => const HelpScreen(),
        '/owner-dashboard': (_) => RoleDataGate(
              role: 'OWNER',
              title: 'لوحة المالك',
              builder: (_, snapshot) => OwnerDashboardScreen(snapshot: snapshot),
            ),
        '/owner-units': (_) => RoleDataGate(
              role: 'OWNER',
              title: 'وحداتي',
              builder: (_, snapshot) => OwnerUnitsScreen(snapshot: snapshot),
            ),
        '/owner-bookings': (_) => RoleDataGate(
              role: 'OWNER',
              title: 'طلبات الحجز',
              builder: (_, snapshot) => OwnerBookingsScreen(snapshot: snapshot),
            ),
        '/driver-dashboard': (_) => RoleDataGate(
              role: 'DRIVER',
              title: 'لوحة السائق',
              builder: (_, snapshot) => DriverDashboardScreen(snapshot: snapshot),
            ),
        '/driver-trips': (_) => RoleDataGate(
              role: 'DRIVER',
              title: 'الرحلات المتاحة',
              builder: (_, snapshot) => DriverTripsScreen(snapshot: snapshot),
            ),
        '/driver-vehicle': (_) => RoleDataGate(
              role: 'DRIVER',
              title: 'المركبة والملف',
              builder: (_, snapshot) => DriverVehicleScreen(snapshot: snapshot),
            ),
      },
    );
  }
}

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// Constrains the whole app to a comfortable reading width and centers it on
/// large (desktop/web) viewports, so the phone-first UI no longer stretches
/// edge-to-edge. Phones and tablets are left untouched.
class ResponsiveShell extends StatelessWidget {
  final Widget child;
  const ResponsiveShell({super.key, required this.child});

  /// Above this width the app is centered inside a fixed-width column.
  static const double maxContentWidth = 980;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width <= maxContentWidth) return child;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    // A slightly darker/lighter backdrop makes the centered app read as an
    // intentional frame rather than a stranded column.
    final backdrop = isDark ? const Color(0xFF050505) : const Color(0xFFE7E9EE);

    return ColoredBox(
      color: backdrop,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: maxContentWidth),
          child: DecoratedBox(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.5 : 0.12),
                  blurRadius: 40,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Lets the user drag-scroll with a mouse/trackpad on web & desktop, and keeps
/// scrollbars visible — Flutter otherwise disables mouse drag scrolling.
class AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
      };
}

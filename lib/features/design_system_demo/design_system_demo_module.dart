import '../../core/modules/infinite_module.dart';
import 'presentation/pages/demo_home_page.dart';
import 'presentation/pages/buttons_demo_page.dart';
import 'presentation/pages/inputs_demo_page.dart';
import 'presentation/pages/cards_demo_page.dart';
import 'presentation/pages/indicators_demo_page.dart';
import 'presentation/pages/alerts_demo_page.dart';
import 'presentation/pages/colors_demo_page.dart';
import 'presentation/pages/typography_demo_page.dart';

/// Design System Demo Module
/// Self-contained module with its own navigation for showcasing design system components
class DesignSystemDemoModule extends InfiniteModule {
  DesignSystemDemoModule({
    super.key,
    super.navigatorKey,
    super.observers,
    super.initialRoute = '/demo',
  });

  @override
  List<InfiniteChildRoute> get routes => [
        // Home - Component categories
        InfiniteRoute(
          routeName: '/demo',
          builder: (context, args) => const DemoHomePage(),
        ),

        // Colors
        InfiniteRoute(
          routeName: '/demo/colors',
          builder: (context, args) => const ColorsDemoPage(),
        ),

        // Typography
        InfiniteRoute(
          routeName: '/demo/typography',
          builder: (context, args) => const TypographyDemoPage(),
        ),

        // Buttons
        InfiniteRoute(
          routeName: '/demo/buttons',
          builder: (context, args) => const ButtonsDemoPage(),
        ),

        // Inputs
        InfiniteRoute(
          routeName: '/demo/inputs',
          builder: (context, args) => const InputsDemoPage(),
        ),

        // Cards
        InfiniteRoute(
          routeName: '/demo/cards',
          builder: (context, args) => const CardsDemoPage(),
        ),

        // Indicators
        InfiniteRoute(
          routeName: '/demo/indicators',
          builder: (context, args) => const IndicatorsDemoPage(),
        ),

        // Alerts
        InfiniteRoute(
          routeName: '/demo/alerts',
          builder: (context, args) => const AlertsDemoPage(),
        ),
      ];

  @override
  List<InjectionContainer> get dependencies => [
        // No dependencies needed for demo module
      ];
}

import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';

/// Base route for infinite module navigation
abstract class InfiniteChildRoute {
  String get routeName;
  Widget Function(BuildContext context, Object? args) get builder;
}

/// Standard child route implementation
class InfiniteRoute implements InfiniteChildRoute {
  @override
  final String routeName;

  @override
  final Widget Function(BuildContext context, Object? args) builder;

  const InfiniteRoute({
    required this.routeName,
    required this.builder,
  });
}

/// Module route that contains another InfiniteModule
class InfiniteModuleRoute implements InfiniteChildRoute {
  @override
  final String routeName;

  final InfiniteModule module;

  const InfiniteModuleRoute({
    required this.routeName,
    required this.module,
  });

  @override
  Widget Function(BuildContext context, Object? args) get builder {
    return (context, args) => module;
  }
}

/// Dependency injection container function
typedef InjectionContainer = FutureOr<void> Function();

/// Base module class for Backstage Cinema
abstract class InfiniteModule extends StatefulWidget {
  InfiniteModule({
    super.key,
    GlobalKey<NavigatorState>? navigatorKey,
    this.observers = const <NavigatorObserver>[],
    this.initialRoute,
  }) : navigatorKey = navigatorKey ?? GlobalKey<NavigatorState>();

  final GlobalKey<NavigatorState> navigatorKey;
  final List<NavigatorObserver> observers;
  final String? initialRoute;

  /// Define routes for this module
  List<InfiniteChildRoute> get routes;

  /// Define dependency injection containers
  List<InjectionContainer> get dependencies => [];

  /// Initialize the module
  @mustCallSuper
  FutureOr<void> start() async {
    log('Starting module: $runtimeType', name: 'InfiniteModule');

    // Initialize all dependency containers
    for (final dependency in dependencies) {
      await dependency();
    }

    // Start nested modules recursively
    for (final route in routes) {
      if (route is InfiniteModuleRoute) {
        await route.module.start();
      }
    }
  }

  /// Dispose module resources
  void dispose() {
    log('Disposing module: $runtimeType', name: 'InfiniteModule');
  }

  String get _initialRoute => initialRoute ?? routes.first.routeName;

  @override
  State<InfiniteModule> createState() => _InfiniteModuleState();
}

class _InfiniteModuleState extends State<InfiniteModule> {
  @override
  void initState() {
    super.initState();
    log('_InfiniteModuleState.initState() for ${widget.runtimeType} with navigatorKey: ${widget.navigatorKey}', name: 'InfiniteModule');
    widget.start();
  }

  @override
  Widget build(BuildContext context) {
    log('_InfiniteModuleState.build() for ${widget.runtimeType} with navigatorKey: ${widget.navigatorKey}', name: 'InfiniteModule');
    return PopScope(
      canPop: !(widget.navigatorKey.currentState?.canPop() ?? false),
      onPopInvokedWithResult: (didPop, result) {
        // Handle back button for nested navigation
        if (!didPop && (widget.navigatorKey.currentState?.canPop() ?? false)) {
          widget.navigatorKey.currentState?.pop();
        }
      },
      child: Navigator(
        key: widget.navigatorKey,
        initialRoute: widget._initialRoute,
        observers: widget.observers,
        onGenerateRoute: (settings) {
          log('Navigator.onGenerateRoute() for ${widget.runtimeType} with route: ${settings.name}', name: 'InfiniteModule');
          final routeName = settings.name ?? widget._initialRoute;
          final args = settings.arguments;

          // Find matching route
          final route = widget.routes.firstWhere(
            (r) => r.routeName == routeName,
            orElse: () => widget.routes.first,
          );

          return MaterialPageRoute(
            settings: settings,
            builder: (context) => route.builder(context, args),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    widget.dispose();
    super.dispose();
  }
}

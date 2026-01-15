import 'package:flutter/widgets.dart';
import 'environment.dart';

class AppConfig extends InheritedWidget {
  final Environment environment;
  final String baseUrl;

  const AppConfig({
    super.key,
    required this.environment,
    required this.baseUrl,
    required super.child,
  });

  static AppConfig of(BuildContext context) {
    final AppConfig? result =
        context.dependOnInheritedWidgetOfExactType<AppConfig>();
    assert(result != null, 'No AppConfig found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(AppConfig oldWidget) =>
      environment != oldWidget.environment || baseUrl != oldWidget.baseUrl;
}

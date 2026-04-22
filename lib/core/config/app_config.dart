import 'package:flutter/widgets.dart';
import 'environment.dart';

class AppConfig extends InheritedWidget {
  final Environment environment;

  const AppConfig({
    super.key,
    required this.environment,
    required super.child,
  });

  String get baseUrl {
    switch (environment) {
      case Environment.prod:
        return "https://matkadev.com/public/api";
      case Environment.uat:
      default:
        return "https://matkadev.technoscend.com/public/api";
    }
  }

  static AppConfig of(BuildContext context) {
    final AppConfig? result =
        context.dependOnInheritedWidgetOfExactType<AppConfig>();
    assert(result != null, 'No AppConfig found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(AppConfig oldWidget) =>
      environment != oldWidget.environment;
}

import 'package:stacked/stacked.dart';

class ServiceRegistry {
  static final List<ListenableServiceMixin> _services = [];

  /// Registers a service in the registry
  static void register(ListenableServiceMixin service) {
    _services.add(service);
  }

  /// Gets all registered services
  static List<ListenableServiceMixin> get services => _services;
}

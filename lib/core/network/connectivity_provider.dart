import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

enum ConnectivityStatus { isConnected, isDisconnected, isNotDetermined }

class ConnectivityNotifier extends Notifier<ConnectivityStatus> {
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  @override
  ConnectivityStatus build() {
    _init();
    _subscription = Connectivity().onConnectivityChanged.listen(_updateStatus);
    
    ref.onDispose(() {
      _subscription?.cancel();
    });

    return ConnectivityStatus.isNotDetermined;
  }

  Future<void> _init() async {
    final result = await Connectivity().checkConnectivity();
    _updateStatus(result);
  }

  void _updateStatus(List<ConnectivityResult> results) {
    if (results.contains(ConnectivityResult.none)) {
      state = ConnectivityStatus.isDisconnected;
    } else {
      state = ConnectivityStatus.isConnected;
    }
  }
}

final connectivityProvider =
    NotifierProvider<ConnectivityNotifier, ConnectivityStatus>(() {
  return ConnectivityNotifier();
});

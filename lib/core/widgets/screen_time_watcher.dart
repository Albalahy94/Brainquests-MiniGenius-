import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/screen_time_service.dart';
import '../services/licensing_api_service.dart';
import '../providers/app_state_provider.dart';
import '../../features/parent_dashboard/ui/screen_time_locked_screen.dart';

class ScreenTimeWatcher extends StatefulWidget {
  final Widget child;

  const ScreenTimeWatcher({
    super.key,
    required this.child,
  });

  @override
  State<ScreenTimeWatcher> createState() => _ScreenTimeWatcherState();
}

class _ScreenTimeWatcherState extends State<ScreenTimeWatcher>
    with WidgetsBindingObserver {
  final ScreenTimeService _screenTimeService = ScreenTimeService();
  Timer? _timer;
  bool _isResumed = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _screenTimeService.addListener(_onServiceUpdate);
    _startTimer();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _screenTimeService.removeListener(_onServiceUpdate);
    _stopTimer();
    super.dispose();
  }

  void _onServiceUpdate() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _isResumed = true;
      _startTimer();
      // Seamlessly re-verify central license status on app resume
      try {
        final appState = Provider.of<AppStateProvider>(context, listen: false);
        LicensingApiService().verifyLicense().then((res) {
          if (res['data'] != null && mounted) {
            appState.refreshUserProgress();
          }
        }).catchError((_) {});
      } catch (_) {}
    } else {
      _isResumed = false;
      _stopTimer();
    }
  }

  void _startTimer() {
    _stopTimer();
    if (!_isResumed) return;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isResumed && mounted) {
        _screenTimeService.recordTick(seconds: 1);
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  Widget build(BuildContext context) {
    // If the active child's daily limit has been reached, lock the app!
    if (_screenTimeService.isLocked) {
      return const ScreenTimeLockedScreen();
    }

    return widget.child;
  }
}


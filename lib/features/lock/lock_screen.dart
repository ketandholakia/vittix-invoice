import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/app_lock_provider.dart';

/// Full-screen PIN gate shown while the app lock is engaged.
class LockScreen extends ConsumerStatefulWidget {
  const LockScreen({super.key});

  @override
  ConsumerState<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends ConsumerState<LockScreen> {
  final _pinController = TextEditingController();
  String? _error;
  bool _checking = false;
  bool _biometricsAvailable = false;
  Duration _lockoutRemaining = Duration.zero;
  Timer? _lockoutTick;

  @override
  void initState() {
    super.initState();
    unawaited(_checkBiometrics());
    _refreshLockout();
  }

  Future<void> _checkBiometrics() async {
    final available = await ref
        .read(appLockServiceProvider)
        .biometricsAvailable();
    if (!mounted) return;
    setState(() => _biometricsAvailable = available);
  }

  void _refreshLockout() {
    final remaining = ref.read(appLockedProvider.notifier).lockoutRemaining;
    if (remaining > Duration.zero) {
      setState(() => _lockoutRemaining = remaining);
      _startLockoutTick();
    }
  }

  void _startLockoutTick() {
    _lockoutTick?.cancel();
    _lockoutTick = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      final remaining = ref.read(appLockedProvider.notifier).lockoutRemaining;
      setState(() => _lockoutRemaining = remaining);
      if (remaining <= Duration.zero) timer.cancel();
    });
  }

  Future<void> _unlockWithBiometrics() async {
    final ok = await ref
        .read(appLockServiceProvider)
        .authenticateWithBiometrics();
    if (!mounted || !ok) return;
    ref.read(appLockedProvider.notifier).unlockWithBiometrics();
  }

  @override
  void dispose() {
    _lockoutTick?.cancel();
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _unlock() async {
    if (_lockoutRemaining > Duration.zero) return;

    final pin = _pinController.text.trim();
    if (pin.length < 4) {
      setState(() => _error = 'Enter at least 4 digits');
      return;
    }

    setState(() {
      _checking = true;
      _error = null;
    });

    final unlocked = await ref.read(appLockedProvider.notifier).unlock(pin);
    if (!mounted) return;
    final remaining = ref.read(appLockedProvider.notifier).lockoutRemaining;
    setState(() {
      _checking = false;
      if (unlocked) {
        _error = null;
      } else if (remaining > Duration.zero) {
        _lockoutRemaining = remaining;
        _error = 'Too many wrong attempts. Try again in '
            '${remaining.inSeconds + 1} seconds.';
        _startLockoutTick();
        _pinController.clear();
      } else {
        _error = 'Incorrect PIN';
        _pinController.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!ref.watch(appLockedProvider)) return const SizedBox.shrink();

    final lockedOut = _lockoutRemaining > Duration.zero;

    return Material(
      color: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.lock_outline, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    'Enter your PIN',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _pinController,
                    autofocus: true,
                    obscureText: true,
                    enabled: !lockedOut,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(8),
                    ],
                    decoration: InputDecoration(
                      labelText: 'PIN',
                      border: const OutlineInputBorder(),
                      errorText: _error,
                    ),
                    onSubmitted: (_) => _unlock(),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: (_checking || lockedOut) ? null : _unlock,
                    icon: const Icon(Icons.lock_open),
                    label: Text(
                      lockedOut
                          ? 'Locked (${_lockoutRemaining.inSeconds + 1}s)'
                          : _checking
                          ? 'Checking...'
                          : 'Unlock',
                    ),
                  ),
                  if (_biometricsAvailable) ...[
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: _checking ? null : _unlockWithBiometrics,
                      icon: const Icon(Icons.fingerprint),
                      label: const Text('Unlock with biometrics'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

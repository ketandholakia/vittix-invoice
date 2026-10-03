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

  @override
  void initState() {
    super.initState();
    unawaited(_checkBiometrics());
  }

  Future<void> _checkBiometrics() async {
    final available = await ref
        .read(appLockServiceProvider)
        .biometricsAvailable();
    if (!mounted) return;
    setState(() => _biometricsAvailable = available);
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
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _unlock() async {
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
    setState(() {
      _checking = false;
      _error = unlocked ? null : 'Incorrect PIN';
      if (!unlocked) _pinController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!ref.watch(appLockedProvider)) return const SizedBox.shrink();

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
                    onPressed: _checking ? null : _unlock,
                    icon: const Icon(Icons.lock_open),
                    label: Text(_checking ? 'Checking...' : 'Unlock'),
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

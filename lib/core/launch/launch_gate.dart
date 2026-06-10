import 'package:flutter/material.dart';
import 'package:laqta/core/launch/launch_config.dart';
import 'package:laqta/core/launch/launch_config_service.dart';
import 'package:laqta/core/launch/waitlist_screen.dart';

class LaunchGate extends StatefulWidget {
  const LaunchGate({
    super.key,
    required this.child,
    LaunchConfigService? service,
  }) : _service = service;

  final Widget child;
  final LaunchConfigService? _service;

  @override
  State<LaunchGate> createState() => _LaunchGateState();
}

class _LaunchGateState extends State<LaunchGate> {
  late final LaunchConfigService _service =
      widget._service ?? LaunchConfigService();
  Future<_LaunchDecision>? _decision;

  @override
  void initState() {
    super.initState();
    _decision = _loadDecision();
  }

  Future<_LaunchDecision> _loadDecision() async {
    final config = await _service.fetchLaunchConfig();
    if (config == null || !config.softLaunchEnabled) {
      return const _LaunchDecision.allowed();
    }

    final city = await _service.selectedCity();
    if (!config.allowsCity(city)) {
      return _LaunchDecision.blockedCity(config: config, city: city);
    }

    if (config.capacityReached) {
      return _LaunchDecision.capacityReached(config: config, city: city);
    }

    return const _LaunchDecision.allowed();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_LaunchDecision>(
      future: _decision,
      builder: (context, snapshot) {
        final decision = snapshot.data;
        if (decision == null || decision.allowed) {
          return widget.child;
        }

        return WaitlistScreen(
          city: decision.city,
          capacityReached: decision.capacityReached,
          service: _service,
          onRetry: () {
            setState(() {
              _decision = _loadDecision();
            });
          },
        );
      },
    );
  }
}

class _LaunchDecision {
  const _LaunchDecision.allowed()
    : allowed = true,
      capacityReached = false,
      city = 'Baghdad',
      config = null;

  const _LaunchDecision.blockedCity({required this.config, required this.city})
    : allowed = false,
      capacityReached = false;

  const _LaunchDecision.capacityReached({
    required this.config,
    required this.city,
  }) : allowed = false,
       capacityReached = true;

  final bool allowed;
  final bool capacityReached;
  final String city;
  final LaunchConfig? config;
}

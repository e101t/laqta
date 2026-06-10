import 'dart:async';

import 'package:flutter/material.dart';
import 'package:laqta/core/update/force_update_service.dart';
import 'package:url_launcher/url_launcher.dart';

class ForceUpdateGate extends StatefulWidget {
  const ForceUpdateGate({
    super.key,
    required this.child,
    ForceUpdateService? service,
  }) : _service = service;

  final Widget child;
  final ForceUpdateService? _service;

  @override
  State<ForceUpdateGate> createState() => _ForceUpdateGateState();
}

class _ForceUpdateGateState extends State<ForceUpdateGate> {
  late final ForceUpdateService _service;
  bool _checkedThisSession = false;
  bool _optionalShown = false;
  ForceUpdateResult? _blockingUpdate;

  @override
  void initState() {
    super.initState();
    _service = widget._service ?? ForceUpdateService();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_check());
    });
  }

  @override
  void dispose() {
    if (widget._service == null) {
      _service.close();
    }
    super.dispose();
  }

  Future<void> _check() async {
    if (_checkedThisSession) return;
    _checkedThisSession = true;
    final result = await _service.checkForUpdate();
    if (!mounted || result == null) return;
    if (result.isForceRequired) {
      setState(() => _blockingUpdate = result);
      return;
    }
    if (result.isOptionalAvailable && !_optionalShown) {
      _optionalShown = true;
      await _showOptionalSheet(result);
    }
  }

  Future<void> _showOptionalSheet(ForceUpdateResult result) async {
    await showModalBottomSheet<void>(
      context: context,
      isDismissible: true,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('تحديث متاح', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(
                result.info.releaseNotesAr.isEmpty
                    ? 'يتوفر إصدار جديد من LAQTA.'
                    : result.info.releaseNotesAr,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => _openStore(result.info.updateUrl),
                child: const Text('تحديث'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('لاحقاً'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openStore(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final blocking = _blockingUpdate;
    if (blocking == null) {
      return widget.child;
    }
    return _ForceUpdateBlocker(
      result: blocking,
      onUpdate: () => _openStore(blocking.info.updateUrl),
    );
  }
}

class _ForceUpdateBlocker extends StatelessWidget {
  const _ForceUpdateBlocker({required this.result, required this.onUpdate});

  final ForceUpdateResult result;
  final VoidCallback onUpdate;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: PopScope(
        canPop: false,
        child: Scaffold(
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.system_update_rounded, size: 64),
                  const SizedBox(height: 18),
                  Text(
                    'تحديث إلزامي',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    result.info.releaseNotesAr.isEmpty
                        ? 'يجب تحديث التطبيق للمتابعة.'
                        : result.info.releaseNotesAr,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: onUpdate,
                    child: const Text('تحديث الآن'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

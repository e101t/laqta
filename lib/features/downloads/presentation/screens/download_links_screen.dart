import 'package:flutter/material.dart';
import 'package:luqta/features/downloads/domain/entities/download_link_entity.dart';
import 'package:luqta/features/downloads/presentation/providers/download_provider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class DownloadLinksScreen extends StatefulWidget {
  final String bookingId;
  final String photographerId;
  final String customerId;
  final List<String> fileIds;
  final bool canManageLinks;

  const DownloadLinksScreen({
    super.key,
    required this.bookingId,
    required this.photographerId,
    required this.customerId,
    required this.fileIds,
    this.canManageLinks = true,
  });

  @override
  State<DownloadLinksScreen> createState() => _DownloadLinksScreenState();
}

class _DownloadLinksScreenState extends State<DownloadLinksScreen> {
  DownloadProvider? _provider;
  bool _providerMissing = false;

  @override
  void initState() {
    super.initState();
    try {
      _provider = Provider.of<DownloadProvider>(context, listen: false);
    } catch (_) {
      _provider = null;
    }
    if (_provider == null) {
      _providerMissing = true;
      return;
    }
    _loadLinks();
  }

  Future<void> _loadLinks() async {
    await _provider?.loadLinks(widget.bookingId);
  }

  Future<void> _generateLinks() async {
    if (_providerMissing || !widget.canManageLinks) return;
    if (widget.fileIds.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Upload files before generating links')),
        );
      }
      return;
    }

    try {
      await _provider?.generateLinks(
        widget.photographerId,
        widget.bookingId,
        widget.customerId,
        widget.fileIds,
      );
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Download links created')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate links: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _extendLink(String linkId) async {
    if (!widget.canManageLinks) return;
    try {
      await _provider?.extendLink(linkId);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Link validity extended')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to extend link: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_providerMissing) {
      return Scaffold(
        appBar: AppBar(title: const Text('Download Links')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Download links are not available in this build.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    final provider = context.watch<DownloadProvider>();
    final batch = provider.batch;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Download Links')),
      body: RefreshIndicator(
        onRefresh: _loadLinks,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Temporary download links stay valid for 30 days. '
              'Extend links before they expire to keep them accessible.',
              style: textTheme.bodySmall,
            ),
            if (widget.canManageLinks) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: provider.loading ? null : _generateLinks,
                icon: const Icon(Icons.download_for_offline),
                label: const Text('Generate download links'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: scheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ],
            const SizedBox(height: 16),
            if (provider.error != null) ...[
              Text(
                provider.error!,
                style: textTheme.bodySmall?.copyWith(color: scheme.error),
              ),
            ],
            if (provider.loading && batch == null)
              const Center(child: CircularProgressIndicator())
            else if (batch == null)
              const Padding(
                padding: EdgeInsets.only(top: 12),
                child: Text('No download links found yet.'),
              )
            else ...[
              _DownloadBatchHeader(batch: batch),
              const SizedBox(height: 16),
              ...batch.links.map(
                (link) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _DownloadLinkCard(
                    link: link,
                    onExtend: widget.canManageLinks
                        ? () => _extendLink(link.linkId)
                        : null,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DownloadBatchHeader extends StatelessWidget {
  final DownloadLinkBatch batch;

  const _DownloadBatchHeader({required this.batch});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final active = batch.links.where((l) => l.isValid).length;
    final expiresAt = batch.links.isNotEmpty
        ? batch.links.first.expiresAt
        : DateTime.now().add(const Duration(days: 30));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Batch: ${batch.batchId}', style: textTheme.bodyMedium),
        const SizedBox(height: 4),
        Text(
          'Valid links: $active / ${batch.links.length}',
          style: textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: 4),
        Text(
          'Expires on ${expiresAt.toLocal().toIso8601String().split('T').first}',
          style: textTheme.labelSmall,
        ),
      ],
    );
  }
}

class _DownloadLinkCard extends StatelessWidget {
  final DownloadLinkEntity link;
  final Future<void> Function()? onExtend;

  const _DownloadLinkCard({required this.link, required this.onExtend});

  Future<void> _openLink() async {
    final uri = Uri.tryParse(link.temporaryUrl);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final statusText = link.getStatusText();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Link ID: ${link.linkId}',
              style: textTheme.labelSmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              statusText,
              style: textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: link.isValid ? scheme.tertiary : scheme.secondary,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    link.temporaryUrl,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodySmall?.copyWith(color: scheme.primary),
                  ),
                ),
                IconButton(
                  onPressed: _openLink,
                  icon: const Icon(Icons.open_in_new),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Downloads: ${link.downloadCount}',
                  style: textTheme.labelSmall,
                ),
                Text(
                  'Extensions: ${link.extensionsUsed}/${link.maxExtensions}',
                  style: textTheme.labelSmall,
                ),
              ],
            ),
            if (onExtend != null) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: link.canExtend ? () => onExtend!() : null,
                  child: const Text('Extend validity'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

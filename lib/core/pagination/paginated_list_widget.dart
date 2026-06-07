import 'package:flutter/material.dart';

typedef PageLoader<T> = Future<List<T>> Function(int page, int pageSize);
typedef PageItemBuilder<T> =
    Widget Function(BuildContext context, T item, int index);

class PaginatedListWidget<T> extends StatefulWidget {
  const PaginatedListWidget({
    super.key,
    required this.itemBuilder,
    required this.onLoadMore,
    this.emptyWidget,
    this.errorWidget,
    this.loadingWidget,
    this.pageSize = 20,
    this.padding,
    this.physics,
    this.reverse = false,
    this.preserveKey,
    this.onRefresh,
  });

  final PageItemBuilder<T> itemBuilder;
  final PageLoader<T> onLoadMore;
  final Widget? emptyWidget;
  final Widget? errorWidget;
  final Widget? loadingWidget;
  final int pageSize;
  final EdgeInsetsGeometry? padding;
  final ScrollPhysics? physics;
  final bool reverse;
  final PageStorageKey<String>? preserveKey;
  final Future<void> Function()? onRefresh;

  @override
  State<PaginatedListWidget<T>> createState() => _PaginatedListWidgetState<T>();
}

class _PaginatedListWidgetState<T> extends State<PaginatedListWidget<T>> {
  final ScrollController _controller = ScrollController();
  final List<T> _items = <T>[];
  int _page = 1;
  bool _initialLoading = true;
  bool _pageLoading = false;
  bool _endReached = false;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_maybeLoadNextPage);
    _loadInitial();
  }

  @override
  void dispose() {
    _controller.removeListener(_maybeLoadNextPage);
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadInitial() async {
    setState(() {
      _initialLoading = true;
      _error = null;
      _endReached = false;
      _page = 1;
    });
    try {
      final items = await widget.onLoadMore(1, widget.pageSize);
      if (!mounted) return;
      setState(() {
        _items
          ..clear()
          ..addAll(items);
        _initialLoading = false;
        _endReached = items.length < widget.pageSize;
        _page = 2;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error;
        _initialLoading = false;
      });
    }
  }

  Future<void> _refresh() async {
    if (widget.onRefresh != null) {
      await widget.onRefresh!();
    }
    await _loadInitial();
  }

  void _maybeLoadNextPage() {
    if (_initialLoading || _pageLoading || _endReached) return;
    if (!_controller.hasClients) return;
    final extentAfter = _controller.position.extentAfter;
    if (extentAfter < 420) {
      _loadNextPage();
    }
  }

  Future<void> _loadNextPage() async {
    setState(() => _pageLoading = true);
    try {
      final items = await widget.onLoadMore(_page, widget.pageSize);
      if (!mounted) return;
      setState(() {
        _items.addAll(items);
        _page += 1;
        _pageLoading = false;
        _endReached = items.length < widget.pageSize;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _pageLoading = false);
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        SnackBar(
          content: const Text('فشل تحميل المزيد'),
          action: SnackBarAction(label: 'إعادة', onPressed: _loadNextPage),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_initialLoading) {
      return widget.loadingWidget ?? const _DefaultLoadingList();
    }

    if (_error != null && _items.isEmpty) {
      return widget.errorWidget ?? _DefaultErrorWidget(onRetry: _loadInitial);
    }

    if (_items.isEmpty) {
      return widget.emptyWidget ?? const _DefaultEmptyWidget();
    }

    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView.builder(
        key: widget.preserveKey,
        controller: _controller,
        padding: widget.padding,
        physics: widget.physics ?? const AlwaysScrollableScrollPhysics(),
        reverse: widget.reverse,
        itemCount: _items.length + (_pageLoading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= _items.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 18),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          return widget.itemBuilder(context, _items[index], index);
        },
      ),
    );
  }
}

class _DefaultLoadingList extends StatelessWidget {
  const _DefaultLoadingList();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 6,
      itemBuilder: (context, index) => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: _SkeletonBox(),
      ),
    );
  }
}

class _DefaultEmptyWidget extends StatelessWidget {
  const _DefaultEmptyWidget();

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('لا توجد عناصر'));
  }
}

class _DefaultErrorWidget extends StatelessWidget {
  const _DefaultErrorWidget({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('فشل التحميل'),
          const SizedBox(height: 12),
          FilledButton(onPressed: onRetry, child: const Text('إعادة المحاولة')),
        ],
      ),
    );
  }
}

class _SkeletonBox extends StatefulWidget {
  const _SkeletonBox();

  @override
  State<_SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<_SkeletonBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: .35, end: .7).animate(_controller),
      child: Container(
        height: 86,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(18),
        ),
      ),
    );
  }
}

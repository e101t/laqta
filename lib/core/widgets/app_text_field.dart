import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:luqta/core/localization/app_localizations.dart';

/// Custom Text Field Widget
class AppTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? initialValue;
  final String? label;
  final String? hint;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final Widget? prefix;
  final Widget? suffix;
  final VoidCallback? onSuffixTap;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final bool readOnly;
  final bool autofocus;
  final bool enableSuggestions;
  final bool expands;
  final int? minLines;
  final int? maxLines;
  final int? maxLength;
  final String? Function(String?)? validator;
  final VoidCallback? onTap;
  final void Function(String)? onChanged;
  final void Function(String)? onFieldSubmitted;
  final bool enabled;
  final TextAlign textAlign;
  final TextDirection? textDirection;
  final TextCapitalization textCapitalization;
  final FocusNode? focusNode;
  final List<TextInputFormatter>? inputFormatters;
  final Iterable<String>? autofillHints;
  final AutovalidateMode? autovalidateMode;
  final String? helperText;
  final String? errorText;
  final EdgeInsetsGeometry? contentPadding;
  final TextStyle? textStyle;
  final InputDecoration? decoration;

  const AppTextField({
    super.key,
    this.controller,
    this.initialValue,
    this.label,
    this.hint,
    this.prefixIcon,
    this.suffixIcon,
    this.prefix,
    this.suffix,
    this.onSuffixTap,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.readOnly = false,
    this.autofocus = false,
    this.enableSuggestions = true,
    this.expands = false,
    this.minLines,
    this.maxLines = 1,
    this.maxLength,
    this.validator,
    this.onTap,
    this.onChanged,
    this.onFieldSubmitted,
    this.enabled = true,
    this.textAlign = TextAlign.start,
    this.textDirection,
    this.textCapitalization = TextCapitalization.sentences,
    this.focusNode,
    this.inputFormatters,
    this.autofillHints,
    this.autovalidateMode,
    this.helperText,
    this.errorText,
    this.contentPadding,
    this.textStyle,
    this.decoration,
  }) : assert(
         controller == null || initialValue == null,
         'Cannot provide both a controller and an initialValue',
       );

  @override
  Widget build(BuildContext context) {
    final effectivePrefix =
        prefix ?? (prefixIcon != null ? Icon(prefixIcon) : null);
    final effectiveSuffix =
        suffix ??
        (suffixIcon != null
            ? IconButton(onPressed: onSuffixTap, icon: Icon(suffixIcon))
            : null);

    return TextFormField(
      controller: controller,
      initialValue: controller == null ? initialValue : null,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      obscureText: obscureText,
      readOnly: readOnly,
      autofocus: autofocus,
      enableSuggestions: enableSuggestions,
      expands: expands,
      minLines: minLines,
      maxLines: maxLines,
      maxLength: maxLength,
      validator: validator,
      onChanged: onChanged,
      onTap: onTap,
      onFieldSubmitted: onFieldSubmitted,
      enabled: enabled,
      textAlign: textAlign,
      textDirection: textDirection,
      textCapitalization: textCapitalization,
      focusNode: focusNode,
      inputFormatters: inputFormatters,
      autofillHints: autofillHints,
      autovalidateMode: autovalidateMode,
      style: textStyle ?? Theme.of(context).textTheme.bodyMedium,
      decoration: _buildDecoration(effectivePrefix, effectiveSuffix),
    );
  }

  InputDecoration _buildDecoration(
    Widget? effectivePrefix,
    Widget? effectiveSuffix,
  ) {
    final base = InputDecoration(
      labelText: label,
      hintText: hint,
      helperText: helperText,
      errorText: errorText,
      prefixIcon: effectivePrefix,
      suffixIcon: effectiveSuffix,
      contentPadding:
          contentPadding ??
          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );

    if (decoration == null) return base;

    return decoration!.copyWith(
      labelText: decoration!.labelText ?? label,
      hintText: decoration!.hintText ?? hint,
      helperText: decoration!.helperText ?? helperText,
      errorText: decoration!.errorText ?? errorText,
      prefixIcon: decoration!.prefixIcon ?? effectivePrefix,
      suffixIcon: decoration!.suffixIcon ?? effectiveSuffix,
      contentPadding: decoration!.contentPadding ?? base.contentPadding,
    );
  }
}

/// Password field with built-in visibility toggle.
class AppPasswordField extends StatefulWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final bool enableStrengthIndicator;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final Iterable<String>? autofillHints;
  final TextInputAction? textInputAction;

  const AppPasswordField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.enableStrengthIndicator = false,
    this.validator,
    this.onChanged,
    this.autofillHints,
    this.textInputAction,
  });

  @override
  State<AppPasswordField> createState() => _AppPasswordFieldState();
}

class _AppPasswordFieldState extends State<AppPasswordField> {
  bool _obscure = true;
  TextEditingController? _internalController;

  TextEditingController get _effectiveController =>
      widget.controller ?? _internalController!;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _internalController = TextEditingController();
    }
    _effectiveController.addListener(_handleTextChanged);
  }

  @override
  void didUpdateWidget(covariant AppPasswordField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      (oldWidget.controller ?? _internalController)?.removeListener(
        _handleTextChanged,
      );

      if (widget.controller == null && _internalController == null) {
        _internalController = TextEditingController();
      } else if (widget.controller != null && _internalController != null) {
        _internalController?.dispose();
        _internalController = null;
      }
      _effectiveController.addListener(_handleTextChanged);
    }
  }

  @override
  void dispose() {
    _effectiveController.removeListener(_handleTextChanged);
    _internalController?.dispose();
    super.dispose();
  }

  void _handleTextChanged() {
    if (widget.enableStrengthIndicator) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppTextField(
          controller: _effectiveController,
          label: widget.label,
          hint: widget.hint,
          obscureText: _obscure,
          validator: widget.validator,
          onChanged: widget.onChanged,
          autofillHints: widget.autofillHints,
          textInputAction: widget.textInputAction,
          suffixIcon: _obscure ? Icons.visibility : Icons.visibility_off,
          onSuffixTap: () => setState(() => _obscure = !_obscure),
        ),
        if (widget.enableStrengthIndicator)
          _PasswordStrengthIndicator(text: _effectiveController.text),
      ],
    );
  }
}

class _PasswordStrengthIndicator extends StatelessWidget {
  final String text;

  const _PasswordStrengthIndicator({required this.text});

  double get _score {
    if (text.isEmpty) return 0;
    double score = 0;
    if (text.length >= 8) score += 0.25;
    if (RegExp(r'[A-Z]').hasMatch(text)) score += 0.25;
    if (RegExp(r'[0-9]').hasMatch(text)) score += 0.25;
    if (RegExp(r'[^A-Za-z0-9]').hasMatch(text)) score += 0.25;
    return score.clamp(0, 1);
  }

  @override
  Widget build(BuildContext context) {
    if (_score == 0) return const SizedBox.shrink();

    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final color = _score < 0.25
        ? scheme.error
        : _score < 0.5
        ? scheme.secondary
        : _score < 0.75
        ? scheme.tertiary
        : scheme.primary;

    final label = _score < 0.25
        ? localizations.weakPassword
        : _score < 0.5
        ? localizations.fairPassword
        : _score < 0.75
        ? localizations.goodPassword
        : localizations.strongPassword;

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: _score,
              minHeight: 6,
              backgroundColor: scheme.surfaceContainerHighest,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: textTheme.labelSmall?.copyWith(color: color)),
        ],
      ),
    );
  }
}

/// Dropdown Field Widget
class AppDropdownField<T> extends StatelessWidget {
  final T? initialValue;
  final String? label;
  final String? hint;
  final List<DropdownMenuItem<T>> items;
  final void Function(T?)? onChanged;
  final IconData? prefixIcon;
  final bool enabled;
  final String? helperText;
  final String? errorText;
  final AutovalidateMode? autovalidateMode;
  final String? Function(T?)? validator;
  final FocusNode? focusNode;
  final InputDecoration? decoration;

  const AppDropdownField({
    super.key,
    this.initialValue,
    this.label,
    this.hint,
    required this.items,
    this.onChanged,
    this.prefixIcon,
    this.enabled = true,
    this.helperText,
    this.errorText,
    this.autovalidateMode,
    this.validator,
    this.focusNode,
    this.decoration,
  });

  @override
  Widget build(BuildContext context) {
    final prefix = prefixIcon != null ? Icon(prefixIcon) : null;
    // Ensure the initial value exists in items to avoid dropdown assertion.
    final safeInitialValue =
        (initialValue != null &&
            items.any((item) => item.value == initialValue))
        ? initialValue
        : null;

    final baseDecoration = InputDecoration(
      labelText: label,
      hintText: hint,
      helperText: helperText,
      errorText: errorText,
      prefixIcon: prefix,
    );

    final effectiveDecoration = decoration == null
        ? baseDecoration
        : decoration!.copyWith(
            labelText: decoration!.labelText ?? label,
            hintText: decoration!.hintText ?? hint,
            helperText: decoration!.helperText ?? helperText,
            errorText: decoration!.errorText ?? errorText,
            prefixIcon: decoration!.prefixIcon ?? prefix,
          );

    return FormField<T>(
      key: ValueKey(safeInitialValue),
      enabled: enabled,
      initialValue: safeInitialValue,
      validator: validator,
      autovalidateMode: autovalidateMode,
      builder: (state) {
        final decorationWithError = effectiveDecoration.copyWith(
          errorText: state.errorText ?? effectiveDecoration.errorText,
        );

        return InputDecorator(
          decoration: decorationWithError,
          isEmpty: state.value == null,
          isFocused: focusNode?.hasFocus ?? false,
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              focusNode: focusNode,
              value: state.value,
              isExpanded: true,
              items: items,
              onChanged: enabled
                  ? (value) {
                      state.didChange(value);
                      onChanged?.call(value);
                    }
                  : null,
            ),
          ),
        );
      },
    );
  }
}

/// Multi-Select Chip Field
class ChipSelectionField extends StatelessWidget {
  final String label;
  final List<String> options;
  final List<String> selectedValues;
  final void Function(String) onSelected;
  final bool multiSelect;
  final WrapAlignment alignment;
  final double spacing;
  final double runSpacing;

  const ChipSelectionField({
    super.key,
    required this.label,
    required this.options,
    required this.selectedValues,
    required this.onSelected,
    this.multiSelect = true,
    this.alignment = WrapAlignment.start,
    this.spacing = 8,
    this.runSpacing = 8,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: textTheme.titleSmall),
        const SizedBox(height: 8),
        Wrap(
          alignment: alignment,
          spacing: spacing,
          runSpacing: runSpacing,
          children: options.map((option) {
            final isSelected = selectedValues.contains(option);
            return FilterChip(
              label: Text(option),
              selected: isSelected,
              onSelected: (selected) {
                if (multiSelect) {
                  onSelected(option);
                } else if (!isSelected) {
                  onSelected(option);
                }
              },
              backgroundColor: scheme.surface,
              selectedColor: scheme.primary.withValues(alpha: 0.12),
              checkmarkColor: scheme.primary,
              labelStyle: textTheme.bodySmall?.copyWith(
                color: isSelected ? scheme.primary : scheme.onSurface,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class AppSearchField extends StatefulWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;
  final VoidCallback? onBack;
  final VoidCallback? onTap;
  final bool showBackButton;
  final bool autoFocus;
  final bool readOnly;
  final Duration debounceDuration;
  final Widget? leading;
  final Widget? trailing;
  final Color? backgroundColor;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry? contentPadding;
  final EdgeInsetsGeometry? margin;
  final TextStyle? textStyle;
  final TextInputAction textInputAction;
  final TextInputType keyboardType;
  final Iterable<String>? autofillHints;
  final bool enableSuggestions;
  final TextCapitalization textCapitalization;

  const AppSearchField({
    super.key,
    this.controller,
    this.focusNode,
    this.hintText,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.onBack,
    this.onTap,
    this.showBackButton = false,
    this.autoFocus = false,
    this.readOnly = false,
    this.debounceDuration = const Duration(milliseconds: 250),
    this.leading,
    this.trailing,
    this.backgroundColor,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
    this.contentPadding,
    this.margin,
    this.textStyle,
    this.textInputAction = TextInputAction.search,
    this.keyboardType = TextInputType.text,
    this.autofillHints,
    this.enableSuggestions = true,
    this.textCapitalization = TextCapitalization.none,
  });

  @override
  State<AppSearchField> createState() => _AppSearchFieldState();
}

class _AppSearchFieldState extends State<AppSearchField> {
  TextEditingController? _internalController;
  FocusNode? _internalFocusNode;
  Timer? _debounceTimer;

  TextEditingController get _controller =>
      widget.controller ?? _internalController!;

  FocusNode get _focusNode => widget.focusNode ?? _internalFocusNode!;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _internalController = TextEditingController();
    }
    if (widget.focusNode == null) {
      _internalFocusNode = FocusNode();
    }
    _controller.addListener(_handleControllerChanged);
  }

  @override
  void didUpdateWidget(covariant AppSearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      (oldWidget.controller ?? _internalController)?.removeListener(
        _handleControllerChanged,
      );
      if (widget.controller == null && _internalController == null) {
        _internalController = TextEditingController();
      } else if (widget.controller != null && _internalController != null) {
        _internalController?.dispose();
        _internalController = null;
      }
      _controller.addListener(_handleControllerChanged);
    }

    if (oldWidget.focusNode != widget.focusNode) {
      if (oldWidget.focusNode == null) {
        _internalFocusNode?.dispose();
        _internalFocusNode = null;
      }
      if (widget.focusNode == null && _internalFocusNode == null) {
        _internalFocusNode = FocusNode();
      }
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _controller.removeListener(_handleControllerChanged);
    _internalController?.dispose();
    _internalFocusNode?.dispose();
    super.dispose();
  }

  void _handleControllerChanged() {
    setState(() {});
  }

  void _handleChanged(String value) {
    if (widget.onChanged == null) return;

    if (widget.debounceDuration <= Duration.zero) {
      widget.onChanged!(value);
      return;
    }

    _debounceTimer?.cancel();
    _debounceTimer = Timer(widget.debounceDuration, () {
      widget.onChanged?.call(_controller.text);
    });
  }

  void _handleClear() {
    if (_controller.text.isEmpty) return;
    _debounceTimer?.cancel();
    _controller.clear();
    widget.onClear?.call();
    widget.onChanged?.call('');
  }

  Widget? _buildPrefix(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final searchIcon =
        widget.leading ??
        Icon(Icons.search, color: scheme.onSurfaceVariant);

    final showBack = widget.showBackButton || widget.onBack != null;
    if (!showBack) return searchIcon;

    return SizedBox(
      width: 92,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            splashRadius: 20,
            onPressed:
                widget.onBack ??
                () {
                  Navigator.of(context).maybePop();
                },
          ),
          const SizedBox(width: 4),
          Flexible(child: searchIcon),
        ],
      ),
    );
  }

  Widget? _buildSuffix() {
    final hasText = _controller.text.isNotEmpty;
    final clearButton = hasText && !widget.readOnly
        ? IconButton(
            icon: const Icon(Icons.close),
            splashRadius: 18,
            onPressed: _handleClear,
          )
        : null;

    if (widget.trailing == null) {
      return clearButton;
    }

    return SizedBox(
      width: clearButton == null ? 40 : 88,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [...?(clearButton == null ? null : [clearButton]), widget.trailing!],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final border = OutlineInputBorder(
      borderRadius: widget.borderRadius,
      borderSide: BorderSide(color: scheme.outlineVariant),
    );

    return Container(
      margin: widget.margin,
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        textInputAction: widget.textInputAction,
        keyboardType: widget.keyboardType,
        textCapitalization: widget.textCapitalization,
        enableSuggestions: widget.enableSuggestions,
        autofillHints: widget.autofillHints,
        autofocus: widget.autoFocus,
        readOnly: widget.readOnly,
        onTap: widget.onTap,
        onChanged: _handleChanged,
        onSubmitted: widget.onSubmitted,
        style: widget.textStyle ?? theme.textTheme.bodyMedium,
        decoration: InputDecoration(
          hintText: widget.hintText ?? localizations.searchPhotographers,
          prefixIcon: _buildPrefix(context),
          suffixIcon: _buildSuffix(),
          filled: true,
          fillColor: widget.backgroundColor ?? scheme.surface,
          contentPadding:
              widget.contentPadding ??
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          enabledBorder: border,
          focusedBorder: border.copyWith(
            borderSide: BorderSide(color: scheme.primary, width: 1.5),
          ),
          border: border,
        ),
      ),
    );
  }
}

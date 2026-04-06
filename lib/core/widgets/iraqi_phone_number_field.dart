import 'package:flutter/material.dart';
import 'package:laqta/core/localization/app_localizations.dart';
import 'package:laqta/features/auth/data/utils/phone_number_utils.dart';

class IraqiPhoneNumberField extends FormField<String> {
  IraqiPhoneNumberField({
    super.key,
    required BuildContext context,
    required TextEditingController controller,
    required String label,
    String hint = '07XXXXXXXXX',
    bool enabled = true,
    super.validator,
  }) : super(
         initialValue: normalizePhoneNumberForLocalInput(controller.text),
         builder: (state) {
           final localizations = AppLocalizations.of(context);
           final effectiveValue = normalizePhoneNumberForLocalInput(
             controller.text.isNotEmpty ? controller.text : (state.value ?? ''),
           );

           Future<void> openPicker() async {
             if (!enabled) return;

             var current = effectiveValue;
             final result = await showModalBottomSheet<String>(
               context: context,
               isScrollControlled: true,
               useSafeArea: true,
               builder: (sheetContext) {
                 final theme = Theme.of(sheetContext);
                 final scheme = theme.colorScheme;
                 final textTheme = theme.textTheme;
                 const digits = ['1', '2', '3', '4', '5', '6', '7', '8', '9'];

                 return StatefulBuilder(
                   builder: (context, setModalState) {
                     void addDigit(String digit) {
                       if (current.length >= 11) return;
                       setModalState(() {
                         current = '$current$digit';
                       });
                     }

                     void removeDigit() {
                       if (current.isEmpty) return;
                       setModalState(() {
                         current = current.substring(0, current.length - 1);
                       });
                     }

                     return Padding(
                       padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                       child: Column(
                         mainAxisSize: MainAxisSize.min,
                         crossAxisAlignment: CrossAxisAlignment.stretch,
                         children: [
                           Text(
                             label,
                             style: textTheme.titleMedium?.copyWith(
                               fontWeight: FontWeight.w700,
                             ),
                           ),
                           const SizedBox(height: 12),
                           Container(
                             padding: const EdgeInsets.symmetric(
                               horizontal: 16,
                               vertical: 18,
                             ),
                             decoration: BoxDecoration(
                               color: scheme.surfaceContainerHighest.withValues(
                                 alpha: 0.4,
                               ),
                               borderRadius: BorderRadius.circular(16),
                               border: Border.all(
                                 color: scheme.outlineVariant.withValues(
                                   alpha: 0.7,
                                 ),
                               ),
                             ),
                             child: Text(
                               current.isEmpty ? hint : current,
                               textAlign: TextAlign.center,
                               textDirection: TextDirection.ltr,
                               style: textTheme.headlineSmall?.copyWith(
                                 fontWeight: FontWeight.w700,
                                 color: current.isEmpty
                                     ? scheme.onSurfaceVariant
                                     : scheme.onSurface,
                               ),
                             ),
                           ),
                           const SizedBox(height: 16),
                           Wrap(
                             spacing: 12,
                             runSpacing: 12,
                             children: [
                               for (final digit in digits)
                                 _PhoneKey(
                                   label: digit,
                                   onTap: () => addDigit(digit),
                                 ),
                               _PhoneKey(
                                 label: localizations.clearAll,
                                 isWide: true,
                                 onTap: () => setModalState(() => current = ''),
                               ),
                               _PhoneKey(
                                 label: '0',
                                 onTap: () => addDigit('0'),
                               ),
                               _PhoneKey(
                                 icon: Icons.backspace_outlined,
                                 onTap: removeDigit,
                               ),
                             ],
                           ),
                           const SizedBox(height: 20),
                           Row(
                             children: [
                               Expanded(
                                 child: OutlinedButton(
                                   onPressed: () =>
                                       Navigator.of(sheetContext).pop(),
                                   child: Text(localizations.cancel),
                                 ),
                               ),
                               const SizedBox(width: 12),
                               Expanded(
                                 child: FilledButton(
                                   onPressed: () => Navigator.of(
                                     sheetContext,
                                   ).pop(current),
                                   child: Text(localizations.done),
                                 ),
                               ),
                             ],
                           ),
                         ],
                       ),
                     );
                   },
                 );
               },
             );

             if (result == null) return;

             final normalized = normalizePhoneNumberForLocalInput(result);
             controller.text = normalized;
             state.didChange(normalized);
           }

           return GestureDetector(
             onTap: openPicker,
             child: AbsorbPointer(
               child: TextFormField(
                 controller: controller,
                 enabled: enabled,
                 readOnly: true,
                 textDirection: TextDirection.ltr,
                 validator: (_) => state.widget.validator?.call(controller.text),
                 decoration: InputDecoration(
                   labelText: label,
                   hintText: hint,
                   prefixIcon: const Icon(Icons.phone),
                   errorText: state.errorText,
                 ),
               ),
             ),
           );
         },
       );
}

class _PhoneKey extends StatelessWidget {
  final String? label;
  final IconData? icon;
  final VoidCallback onTap;
  final bool isWide;

  const _PhoneKey({
    this.label,
    this.icon,
    required this.onTap,
    this.isWide = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final width = isWide ? 216.0 : 102.0;

    return SizedBox(
      width: width,
      height: 58,
      child: Material(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: icon != null
                ? Icon(icon)
                : Text(
                    label ?? '',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

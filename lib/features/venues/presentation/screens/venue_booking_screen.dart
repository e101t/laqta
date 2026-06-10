import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:laqta/core/theme/laqta_tokens.dart';
import 'package:laqta/core/widgets/laqta_marketplace_widgets.dart';
import 'package:laqta/features/marketplace/marketplace_dependencies.dart';
import 'package:laqta/features/marketplace/presentation/controllers/marketplace_controllers.dart';

class VenueBookingScreen extends StatelessWidget {
  final String venueId;

  const VenueBookingScreen({super.key, required this.venueId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
          VenueDetailsController(MarketplaceDependencies.repository, venueId)
            ..load(),
      child: const _VenueBookingView(),
    );
  }
}

class _VenueBookingView extends StatefulWidget {
  const _VenueBookingView();

  @override
  State<_VenueBookingView> createState() => _VenueBookingViewState();
}

class _VenueBookingViewState extends State<_VenueBookingView> {
  DateTime? _eventDate;
  final TextEditingController _guestController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  @override
  void dispose() {
    _guestController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<VenueDetailsController>();
    final venue = controller.venue;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    return Scaffold(
      backgroundColor: LaqtaColors.canvasDark,
      body: controller.isLoading
          ? const Center(child: CircularProgressIndicator())
          : venue == null
          ? Center(
              child: Text(
                controller.error ?? 'تعذر تحميل بيانات القاعة.',
                style: const TextStyle(color: Colors.white70),
              ),
            )
          : SafeArea(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
                children: [
                  Row(
                    children: [
                      const LaqtaHeaderBackButton(),
                      const Spacer(),
                      Text(
                        'حجز القاعة',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const Spacer(),
                      const SizedBox(width: 36),
                    ],
                  ),
                  const SizedBox(height: 14),
                  LaqtaLuxurySurface(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          venue.name,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${venue.city}${venue.area == null ? '' : ' - ${venue.area}'}',
                          style: const TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          venue.description ??
                              'احجز موعدك وأرسل التفاصيل الأولية للقاعة.',
                          style: const TextStyle(
                            color: Colors.white70,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _FieldCard(
                    label: 'تاريخ المناسبة',
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        _eventDate == null
                            ? 'اختر التاريخ'
                            : DateFormat('yyyy/MM/dd').format(_eventDate!),
                        style: const TextStyle(color: Colors.white),
                      ),
                      trailing: const Icon(
                        Icons.calendar_month_outlined,
                        color: LaqtaColors.accent,
                      ),
                      onTap: () async {
                        final selected = await showDatePicker(
                          context: context,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(
                            const Duration(days: 365 * 2),
                          ),
                          initialDate:
                              _eventDate ??
                              DateTime.now().add(const Duration(days: 7)),
                        );
                        if (selected != null) {
                          setState(() => _eventDate = selected);
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  _FieldCard(
                    label: 'عدد الضيوف',
                    child: TextField(
                      controller: _guestController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: 'مثال: 250',
                        hintStyle: TextStyle(color: Colors.white38),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _FieldCard(
                    label: 'ملاحظات إضافية',
                    child: TextField(
                      controller: _noteController,
                      maxLines: 4,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: 'اذكر تفاصيل المناسبة أو الخدمة المطلوبة...',
                        hintStyle: TextStyle(color: Colors.white38),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 54,
                    child: ElevatedButton(
                      onPressed: controller.isSubmittingBooking
                          ? null
                          : () async {
                              if (_eventDate == null) {
                                messenger.showSnackBar(
                                  const SnackBar(
                                    content: Text('اختر تاريخ المناسبة أولًا.'),
                                  ),
                                );
                                return;
                              }

                              final success = await controller.submitBooking(
                                eventDate: _eventDate!,
                                guestCount: int.tryParse(
                                  _guestController.text.trim(),
                                ),
                                note: _noteController.text.trim(),
                              );

                              if (!mounted) {
                                return;
                              }

                              if (success) {
                                messenger.showSnackBar(
                                  const SnackBar(
                                    content: Text('تم إرسال طلب الحجز بنجاح.'),
                                  ),
                                );
                                navigator.pop();
                                return;
                              }

                              messenger.showSnackBar(
                                SnackBar(
                                  content: Text(
                                    controller.error ?? 'تعذر إرسال الحجز.',
                                  ),
                                ),
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: LaqtaColors.accent,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: controller.isSubmittingBooking
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                              ),
                            )
                          : const Text(
                              'تأكيد الحجز',
                              style: TextStyle(fontWeight: FontWeight.w900),
                            ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _FieldCard extends StatelessWidget {
  final String label;
  final Widget child;

  const _FieldCard({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return LaqtaLuxurySurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

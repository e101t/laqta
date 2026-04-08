import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:laqta/app/router/app_router.dart';
import 'package:laqta/core/constants/app_constants.dart';
import 'package:laqta/core/localization/app_localizations.dart';
import 'package:laqta/core/widgets/app_buttons.dart';
import 'package:logger/logger.dart';
import 'package:laqta/features/payment/payment_dependencies.dart';
import 'package:laqta/features/payment/domain/entities/payment_intent.dart';

class PaymentScreen extends StatefulWidget {
  final String bookingId;
  final double amount; // Amount in IQD
  final String photographerName;
  final String sessionType;

  const PaymentScreen({
    super.key,
    required this.bookingId,
    required this.amount,
    required this.photographerName,
    required this.sessionType,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final Logger _logger = Logger(level: kDebugMode ? Level.debug : Level.off);
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (AppConstants.paymentsConfigured) {
      // Initialize Stripe with your publishable key
      Stripe.publishableKey = AppConstants.stripePublishableKey;
    }
  }

  Future<void> _processPayment() async {
    if (_isLoading) return;
    final localizations = AppLocalizations.of(context);

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Create payment intent on your backend
      final paymentIntent = await _createPaymentIntent();
      if (!mounted) return;

      if (paymentIntent == null) {
        if (!mounted) return;
        setState(() {
          _error = localizations.paymentFailed;
        });
        return;
      }

      // Confirm payment
      final confirmPayment = await _confirmPayment(paymentIntent);
      if (!mounted) return;

      if (confirmPayment) {
        // Update booking status to paid
        await _updateBookingPaymentStatus(paymentIntent.paymentIntentId);

        // Show success and navigate to success screen
        if (mounted) {
          _showPaymentSuccess();
        }
      } else {
        if (!mounted) return;
        setState(() {
          _error = localizations.paymentFailed;
        });
      }
    } catch (e) {
      _logger.e('Payment error: $e');
      if (mounted) {
        setState(() {
          _error = localizations.paymentFailed;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<PaymentIntentData?> _createPaymentIntent() async {
    try {
      final result = await PaymentDependencies.createPaymentIntent().call(
        bookingId: widget.bookingId,
        amount: widget.amount,
        currency: AppConstants.currencyIQD,
      );
      if (!result.isSuccess) {
        _logger.e('Failed to create payment intent');
        return null;
      }
      return result.valueOrNull;
    } catch (e) {
      _logger.e('Error creating payment intent: $e');
      return null;
    }
  }

  Future<bool> _confirmPayment(PaymentIntentData paymentIntent) async {
    try {
      return await _showPaymentSheet(paymentIntent);
    } catch (e) {
      _logger.e('Error confirming payment: $e');
      return false;
    }
  }

  Future<bool> _showPaymentSheet(PaymentIntentData paymentIntent) async {
    try {
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntent.clientSecret,
          merchantDisplayName: 'Laqta',
          customerId: paymentIntent.customerId,
          customerEphemeralKeySecret: paymentIntent.ephemeralKey,
          // Add UI customizations
          style: ThemeMode.light,
        ),
      );

      await Stripe.instance.presentPaymentSheet();

      return true;
    } catch (e) {
      _logger.e('Payment sheet error: $e');
      rethrow;
    }
  }

  Future<void> _updateBookingPaymentStatus(String paymentIntentId) async {
    final result = await PaymentDependencies.updateBookingPaymentStatus().call(
      bookingId: widget.bookingId,
      paymentIntentId: paymentIntentId,
      amount: widget.amount,
    );
    if (!result.isSuccess) {
      throw StateError(
        result.failureOrNull?.message ?? 'Failed to update payment status',
      );
    }
  }

  void _showPaymentSuccess() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Payment Successful!'),
        content: Text(
          'Your payment of ${widget.amount.toStringAsFixed(0)} IQD was processed successfully.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Go back to previous screen
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    if (!AppConstants.paymentsConfigured) {
      return Scaffold(
        appBar: AppBar(title: Text(localizations.payment)),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: scheme.error.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: scheme.error.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: scheme.error),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            localizations.paymentsUnavailable,
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (widget.bookingId.isNotEmpty)
                      Text(
                        'Booking ID: ${widget.bookingId}',
                        style: textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    if (widget.photographerName.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        Icons.camera_alt,
                        'Photographer',
                        widget.photographerName,
                      ),
                    ],
                    if (widget.sessionType.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        Icons.event,
                        'Session Type',
                        widget.sessionType,
                      ),
                    ],
                    if (widget.amount > 0) ...[
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        Icons.attach_money,
                        'Amount',
                        '${widget.amount.toStringAsFixed(0)} IQD',
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'This build does not include a live payment gateway yet. You can return to the booking and continue the booking flow normally.',
                style: textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              CTAButton(
                text: 'Back to booking',
                onPressed: () => Navigator.of(context).maybePop(),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => AppRouter.goToBookingPolicies(context),
                icon: const Icon(Icons.policy_outlined),
                label: const Text('Review booking policies'),
              ),
            ],
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(title: Text(localizations.payment)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Payment summary card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: scheme.surface,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Payment Details',
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Photographer info
                  _buildInfoRow(
                    Icons.camera_alt,
                    'Photographer',
                    widget.photographerName,
                  ),
                  const Divider(height: 24),

                  // Session type
                  _buildInfoRow(
                    Icons.event,
                    'Session Type',
                    widget.sessionType,
                  ),
                  const Divider(height: 24),

                  // Amount
                  _buildInfoRow(
                    Icons.attach_money,
                    'Amount',
                    '${widget.amount.toStringAsFixed(0)} IQD',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Payment methods
            Text(
              'Choose Payment Method',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),

            // Payment method options
            _buildPaymentMethod(
              Icons.credit_card,
              'Credit/Debit Card',
              'Pay with Visa, Mastercard, or other cards',
            ),
            const SizedBox(height: 8),

            _buildPaymentMethod(
              Icons.account_balance,
              'Bank Transfer',
              'Direct bank transfer is not enabled in this build',
              enabled: false,
            ),
            const SizedBox(height: 8),

            _buildPaymentMethod(
              Icons.wallet,
              'Wallet',
              'Wallet payments are not enabled in this build',
              enabled: false,
            ),

            // Error message if any
            if (_error != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: scheme.error.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: scheme.error),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error, color: scheme.error),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _error!,
                        style: textTheme.bodyMedium?.copyWith(
                          color: scheme.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Pay button
            CTAButton(
              text: 'Pay Now',
              isLoading: _isLoading,
              onPressed: _isLoading ? null : _processPayment,
            ),

            const SizedBox(height: 16),

            // Security info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: scheme.primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: scheme.primary.withValues(alpha: 0.25),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.lock, color: scheme.primary, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Your payment information is secured with bank-level encryption.',
                      style: textTheme.bodySmall?.copyWith(
                        color: scheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Row(
      children: [
        Icon(icon, color: scheme.primary, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: textTheme.labelSmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethod(
    IconData icon,
    String title,
    String subtitle, {
    bool enabled = true,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final effectiveSurface = enabled
        ? scheme.surface
        : scheme.surface.withValues(alpha: 0.55);
    final effectiveOutline = enabled
        ? scheme.outlineVariant
        : scheme.outlineVariant.withValues(alpha: 0.55);

    return Container(
      decoration: BoxDecoration(
        color: effectiveSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: effectiveOutline),
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: enabled
                ? scheme.primary.withValues(alpha: 0.12)
                : scheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: enabled ? scheme.primary : scheme.onSurfaceVariant,
          ),
        ),
        title: Text(
          title,
          style: textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: enabled ? scheme.onSurface : scheme.onSurfaceVariant,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: textTheme.bodySmall?.copyWith(
            color: enabled
                ? scheme.onSurfaceVariant
                : scheme.onSurfaceVariant.withValues(alpha: 0.6),
          ),
        ),
        trailing: enabled
            ? const Icon(Icons.arrow_forward_ios, size: 16)
            : null,
        enabled: enabled,
        onTap: enabled
            ? () {
                // Select this payment method
                setState(() {
                  // For now, just highlight this as selected
                });
              }
            : null,
      ),
    );
  }
}

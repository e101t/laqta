import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:luqta/core/constants/app_theme.dart';
import 'package:luqta/core/constants/app_constants.dart';
import 'package:luqta/core/localization/app_localizations.dart';
import 'package:luqta/core/widgets/app_buttons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';

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
  final Logger _logger = Logger();
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Initialize Stripe with your publishable key
    Stripe.publishableKey = AppConstants.stripePublishableKey;
  }

  Future<void> _processPayment() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Create payment intent on your backend
      final paymentIntent = await _createPaymentIntent();

      if (paymentIntent == null) {
        setState(() {
          _error = 'Failed to create payment intent';
        });
        return;
      }

      // Confirm payment
      final confirmPayment = await _confirmPayment(
        paymentIntent['client_secret'],
      );

      if (confirmPayment) {
        // Update booking status to paid
        await _updateBookingPaymentStatus(paymentIntent['id']);

        // Show success and navigate to success screen
        if (mounted) {
          _showPaymentSuccess();
        }
      } else {
        setState(() {
          _error = 'Payment failed. Please try again.';
        });
      }
    } catch (e) {
      _logger.e('Payment error: $e');
      if (mounted) {
        setState(() {
          _error = e.toString();
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

  Future<Map<String, dynamic>?> _createPaymentIntent() async {
    try {
      // This should call your backend API to create a payment intent
      // For now, returning a mock response
      return {
        'id': 'pi_mock_payment_intent_id',
        'client_secret': 'pi_mock_client_secret',
      };
    } catch (e) {
      _logger.e('Error creating payment intent: $e');
      return null;
    }
  }

  Future<bool> _confirmPayment(String clientSecret) async {
    try {
      // Use Stripe's payment sheet to confirm payment
      final paymentMethod = await _showPaymentSheet(clientSecret);
      return paymentMethod != null;
    } catch (e) {
      _logger.e('Error confirming payment: $e');
      return false;
    }
  }

  Future<PaymentMethod?> _showPaymentSheet(String clientSecret) async {
    try {
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'LAQTA',
          customerId: FirebaseAuth.instance.currentUser?.uid,
          customerEphemeralKeySecret: null, // Should come from backend
          // Add UI customizations
          style: ThemeMode.light,
        ),
      );

      await Stripe.instance.presentPaymentSheet();

      // Return payment method if successful
      final paymentIntent = await Stripe.instance.retrievePaymentIntent(
        clientSecret,
      );
      // Use paymentIntent.paymentMethodId instead of paymentIntent.paymentMethod
      if (paymentIntent.paymentMethodId != null) {
        // Create a basic PaymentMethod object since we can't access the full details
        return PaymentMethod.fromJson({
          'id': paymentIntent.paymentMethodId,
          'type': 'card', // Default to card
        });
      }
      return null;
    } catch (e) {
      _logger.e('Payment sheet error: $e');
      rethrow;
    }
  }

  Future<void> _updateBookingPaymentStatus(String paymentIntentId) async {
    final bookingRef = FirebaseFirestore.instance
        .collection('bookings')
        .doc(widget.bookingId);

    await bookingRef.update({
      'payment.status': 'succeeded',
      'payment.intentId': paymentIntentId,
      'payment.paidAt': FieldValue.serverTimestamp(),
      'payment.amount': widget.amount,
      'status': 'confirmed', // Update booking status to confirmed
      'updatedAt': FieldValue.serverTimestamp(),
    });
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

    return Scaffold(
      backgroundColor: AppColors.background,
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
                color: AppColors.surface,
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
                    style: AppTypography.h3.copyWith(
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
              style: AppTypography.h4.copyWith(fontWeight: FontWeight.w600),
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
              'Direct bank transfer (Coming soon)',
              enabled: false,
            ),
            const SizedBox(height: 8),

            _buildPaymentMethod(
              Icons.wallet,
              'Wallet',
              'Pay from your LAQTA wallet (Coming soon)',
              enabled: false,
            ),

            // Error message if any
            if (_error != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.error),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error, color: AppColors.error),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _error!,
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.error,
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
                color: AppColors.info.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.info.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lock, color: AppColors.info, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Your payment information is secured with bank-level encryption.',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.info,
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
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: AppTypography.bodyMedium.copyWith(
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
    return Container(
      decoration: BoxDecoration(
        color: enabled
            ? AppColors.surface
            : AppColors.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: enabled
              ? AppColors.divider
              : AppColors.divider.withValues(alpha: 0.5),
        ),
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: enabled
                ? AppColors.primary.withValues(alpha: 0.1)
                : AppColors.divider.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: enabled ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
        title: Text(
          title,
          style: AppTypography.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: enabled ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: AppTypography.bodySmall.copyWith(
            color: enabled
                ? AppColors.textSecondary
                : AppColors.textSecondary.withValues(alpha: 0.5),
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

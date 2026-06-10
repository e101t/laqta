import 'package:laqta/core/services/backend_api_client.dart';

class VerificationStatusModel {
  const VerificationStatusModel({
    required this.status,
    required this.phoneVerified,
    required this.portfolioReviewed,
    required this.identityReviewed,
    this.rejectionReason,
  });

  factory VerificationStatusModel.fromJson(Map<String, dynamic> json) {
    return VerificationStatusModel(
      status: json['status'] as String? ?? 'not_submitted',
      phoneVerified: json['phoneVerified'] as bool? ?? false,
      portfolioReviewed: json['portfolioReviewed'] as bool? ?? false,
      identityReviewed: json['identityReviewed'] as bool? ?? false,
      rejectionReason: json['rejectionReason'] as String?,
    );
  }

  final String status;
  final bool phoneVerified;
  final bool portfolioReviewed;
  final bool identityReviewed;
  final String? rejectionReason;
}

class VerificationService {
  VerificationService({BackendApiClient? apiClient})
    : _apiClient = apiClient ?? BackendApiClient();

  final BackendApiClient _apiClient;

  Future<VerificationStatusModel> getMyVerification() async {
    final response = await _apiClient.get('/verification/me');
    if (response is Map<String, dynamic>) {
      final verification = response['verification'];
      if (verification is Map<String, dynamic>) {
        return VerificationStatusModel.fromJson(verification);
      }
    }
    return const VerificationStatusModel(
      status: 'not_submitted',
      phoneVerified: false,
      portfolioReviewed: false,
      identityReviewed: false,
    );
  }

  Future<VerificationStatusModel> submit() async {
    final response = await _apiClient.post(
      '/verification/submit',
      body: <String, dynamic>{'documents': <Map<String, dynamic>>[]},
    );
    if (response is Map<String, dynamic>) {
      final verification = response['verification'];
      if (verification is Map<String, dynamic>) {
        return VerificationStatusModel.fromJson(verification);
      }
    }
    return getMyVerification();
  }
}

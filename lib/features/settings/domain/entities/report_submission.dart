class ReportSubmission {
  final String reporterId;
  final String? reportedUserId;
  final String? reportedUserName;
  final String reportType;
  final String reason;
  final String details;

  const ReportSubmission({
    required this.reporterId,
    this.reportedUserId,
    this.reportedUserName,
    required this.reportType,
    required this.reason,
    required this.details,
  });
}

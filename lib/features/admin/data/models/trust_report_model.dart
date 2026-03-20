class TrustReportModel {
  const TrustReportModel({
    required this.id,
    required this.reporterId,
    required this.reportedId,
    required this.reason,
    required this.status,
    required this.createdAt,
    this.bookingId,
    this.adminNote,
    this.reporterEmail,
    this.reportedEmail,
  });

  final String id;
  final String reporterId;
  final String reportedId;
  final String reason;
  final String status; // PENDING | REVIEWED | DISMISSED
  final DateTime createdAt;
  final String? bookingId;
  final String? adminNote;
  final String? reporterEmail;
  final String? reportedEmail;

  bool get isPending => status == 'PENDING';

  factory TrustReportModel.fromJson(Map<String, dynamic> json) {
    final reporter = json['reporter'] as Map<String, dynamic>?;
    final reported = json['reported'] as Map<String, dynamic>?;

    return TrustReportModel(
      id: json['id'] as String,
      reporterId: json['reporterId'] as String? ??
          json['reporter_id'] as String? ??
          reporter?['id'] as String? ??
          '',
      reportedId: json['reportedId'] as String? ??
          json['reported_id'] as String? ??
          reported?['id'] as String? ??
          '',
      reason: json['reason'] as String,
      status: json['status'] as String,
      createdAt: DateTime.parse(
          json['createdAt'] as String? ?? json['created_at'] as String),
      bookingId:
          json['bookingId'] as String? ?? json['booking_id'] as String?,
      adminNote:
          json['adminNote'] as String? ?? json['admin_note'] as String?,
      reporterEmail: reporter?['email'] as String?,
      reportedEmail: reported?['email'] as String?,
    );
  }
}

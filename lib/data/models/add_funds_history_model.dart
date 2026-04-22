class AddFundHistoryModel {
  final int id;
  final int userId;
  final int amount;
  final String status;
  final String metadata;
  final String? comment;
  final DateTime createdAt;

  AddFundHistoryModel({
    required this.id,
    required this.userId,
    required this.amount,
    required this.status,
    required this.metadata,
    this.comment,
    required this.createdAt,
  });

  factory AddFundHistoryModel.fromJson(Map<String, dynamic> json) {
    return AddFundHistoryModel(
      id: json['id'],
      userId: json['user_id'],
      amount: json['amount'],
      status: json['status'],
      metadata: json['metadata'],
      comment: json['comment'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

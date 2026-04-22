class WalletTransactionModel {
  final String txnId;
  final String type; // credit / debit
  final String txnFor; // deposit / withdraw
  final String amount;
  final String balance;
  final String description;
  final String status;
  final String date;

  WalletTransactionModel({
    required this.txnId,
    required this.type,
    required this.txnFor,
    required this.amount,
    required this.balance,
    required this.description,
    required this.status,
    required this.date,
  });

  factory WalletTransactionModel.fromJson(Map<String, dynamic> json) {
    return WalletTransactionModel(
      txnId: json['txn_id'],
      type: json['txn_type'],
      txnFor: json['txn_for'],
      amount: json['txn_amount'],
      balance: json['balance'],
      description: json['description'],
      status: json['status'],
      date: json['created_at'],
    );
  }
}

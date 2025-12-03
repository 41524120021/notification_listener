class BankRule {
  final String bankName;
  final String accountNumber;
  final String packageName;
  final String title;
  final String detail;
  final String extractMethod;
  final bool isActive;

  BankRule({
    required this.bankName,
    required this.accountNumber,
    required this.packageName,
    required this.title,
    required this.detail,
    required this.extractMethod,
    this.isActive = true,
  });

  factory BankRule.fromJson(Map<String, dynamic> json) {
    return BankRule(
      bankName: json['bankName'] ?? json['bank'] ?? '',
      accountNumber: json['accountNumber'] ?? json['norek'] ?? json['account'] ?? '',
      packageName: json['packageName'] ?? json['packagename'] ?? '',
      title: json['title'] ?? '',
      detail: json['detail'] ?? json['trigger'] ?? '',
      extractMethod: json['extractMethod'] ?? json['parsemethod'] ?? 'ExtractWithRp',
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bankName': bankName,
      'accountNumber': accountNumber,
      'packageName': packageName,
      'title': title,
      'detail': detail,
      'extractMethod': extractMethod,
      'isActive': isActive,
    };
  }
}

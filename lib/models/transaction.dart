class Transaction {
  final int? id; // Local database ID
  final String? idTransaksi; // ID dari server (id_transaksi)
  final String? idWeb; // ID dari web/server (parsing)
  final String bankName;
  final String? amount;
  final String detail; // text dari server
  final DateTime timestamp;
  final bool isSynced; // Flag: sudah terkirim ke server atau belum
  final int retryCount; // Jumlah percobaan kirim ulang
  final DateTime? lastSyncAttempt; // Waktu terakhir coba kirim
  final bool isQris; // Flag: transaksi QRIS (qris=1) atau biasa (qris=0)

  Transaction({
    this.id,
    this.idTransaksi,
    this.idWeb,
    required this.bankName,
    this.amount,
    required this.detail,
    required this.timestamp,
    this.isSynced = false, // Default: belum terkirim
    this.retryCount = 0,
    this.lastSyncAttempt,
    this.isQris = false, // Default: bukan QRIS
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      idTransaksi: json['idTransaksi'],
      idWeb: json['idWeb'],
      bankName: json['bankName'] ?? '',
      amount: json['amount'],
      detail: json['detail'] ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
      isSynced: json['isSynced'] == 1 || json['isSynced'] == true,
      retryCount: json['retryCount'] ?? 0,
      lastSyncAttempt: json['lastSyncAttempt'] != null
          ? DateTime.parse(json['lastSyncAttempt'])
          : null,
      isQris: json['isQris'] == 1 || json['isQris'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'idTransaksi': idTransaksi,
      'idWeb': idWeb,
      'bankName': bankName,
      'amount': amount,
      'detail': detail,
      'timestamp': timestamp.toIso8601String(),
      'isSynced': isSynced ? 1 : 0,
      'retryCount': retryCount,
      'lastSyncAttempt': lastSyncAttempt?.toIso8601String(),
      'isQris': isQris ? 1 : 0,
    };
  }

  // Helper method untuk create copy dengan update status
  Transaction copyWith({
    int? id,
    String? idTransaksi,
    String? idWeb,
    String? bankName,
    String? amount,
    String? detail,
    DateTime? timestamp,
    bool? isSynced,
    int? retryCount,
    DateTime? lastSyncAttempt,
    bool? isQris,
  }) {
    return Transaction(
      id: id ?? this.id,
      idTransaksi: idTransaksi ?? this.idTransaksi,
      idWeb: idWeb ?? this.idWeb,
      bankName: bankName ?? this.bankName,
      amount: amount ?? this.amount,
      detail: detail ?? this.detail,
      timestamp: timestamp ?? this.timestamp,
      isSynced: isSynced ?? this.isSynced,
      retryCount: retryCount ?? this.retryCount,
      lastSyncAttempt: lastSyncAttempt ?? this.lastSyncAttempt,
      isQris: isQris ?? this.isQris,
    );
  }
}

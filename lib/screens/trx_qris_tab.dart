import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import '../models/transaction.dart';
import '../services/transaction_service.dart';
import '../services/notification_service.dart';

class TrxQrisTab extends StatefulWidget {
  const TrxQrisTab({super.key});

  @override
  State<TrxQrisTab> createState() => _TrxQrisTabState();
}

class _TrxQrisTabState extends State<TrxQrisTab> {
  List<Transaction> qrisTransactions = [];
  bool isLoading = true;
  StreamSubscription<String>? _transactionSubscription;

  @override
  void initState() {
    super.initState();
    // Auto load dari server seperti B4A GetTrxQris
    _loadFromServer();
    
    // Listen untuk event transaksi baru berhasil dipost
    _transactionSubscription = NotificationService.onTransactionPosted.listen((_) {
      print('📱 TrxQrisTab: Received transaction posted event, refreshing...');
      _loadFromServer(silent: true); // Silent refresh, no SnackBar
    });
  }
  
  @override
  void dispose() {
    _transactionSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadFromServer({bool silent = false}) async {
    setState(() => isLoading = true);
    try {
      // Load from server
      final serverTransactions = await TransactionService.getQrisFromServer();
      
      setState(() {
        qrisTransactions = serverTransactions;
        isLoading = false;
      });
      
      // Hanya tampilkan SnackBar jika tidak silent
      if (!silent && mounted && serverTransactions.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Berhasil memuat ${serverTransactions.length} transaksi QRIS dari server')),
        );
      } else if (!silent && mounted && serverTransactions.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak ada data QRIS di server')),
        );
      }
    } catch (e) {
      setState(() {
        qrisTransactions = [];
        isLoading = false;
      });
      if (!silent && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
  }

  String _formatCurrency(String? amount) {
    if (amount == null || amount.isEmpty) return 'Rp 0';
    final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return formatter.format(int.tryParse(amount) ?? 0);
  }

  @override
  Widget build(BuildContext context) {
    // Filter hanya transaksi QRIS
    final qrisOnlyTransactions = qrisTransactions.where((t) => t.isQris).toList();

    return RefreshIndicator(
      onRefresh: _loadFromServer,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total: ${qrisOnlyTransactions.length}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  onPressed: isLoading ? null : _loadFromServer,
                  icon: isLoading 
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.cloud_download),
                  label: const Text('Ambil dari Server'),
                ),
              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : qrisOnlyTransactions.isEmpty
                    ? const Center(child: Text('Belum ada transaksi QRIS'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: qrisOnlyTransactions.length,
                        itemBuilder: (context, index) {
                          final transaction = qrisOnlyTransactions[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: Colors.purple.shade100,
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              'QRIS',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.purple.shade800,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          if (transaction.idTransaksi != null)
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: Colors.blue.shade100,
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                'ID: ${transaction.idTransaksi}',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: Colors.blue.shade800,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          if (transaction.idWeb != null && transaction.idWeb != '0')
                                            const SizedBox(width: 4),
                                          if (transaction.idWeb != null && transaction.idWeb != '0')
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: Colors.orange.shade100,
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                'idweb: ${transaction.idWeb}',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: Colors.orange.shade800,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                      Text(
                                        _formatCurrency(transaction.amount),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.green,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _formatDateTime(transaction.timestamp),
                                    style: const TextStyle(
                                      fontSize: 11, 
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    transaction.detail,
                                    style: const TextStyle(fontSize: 12),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

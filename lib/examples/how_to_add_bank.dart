// Contoh cara menambahkan bank baru ke rules

import 'package:notlistfl/services/rules_manager.dart';
import 'package:notlistfl/models/bank_rule.dart';

void main() async {
  // 1. Menambahkan rule baru
  await RulesManager.addRule(
    BankRule(
      bankName: 'MANDIRI',
      accountNumber: '1234567890',
      packageName: 'com.bankmandiri.app',
      title: 'Transaksi Berhasil',
      detail: 'masuk',
      extractMethod: 'ExtractWithRp',
    ),
  );

  // 2. Membaca semua rules
  final rules = await RulesManager.loadRules();
  print('Total rules: ${rules.length}');

  // 3. Update rule tertentu
  await RulesManager.updateRule(
    0, // index
    BankRule(
      bankName: 'BCA',
      accountNumber: '7620740041',
      packageName: 'com.bca.mybca.omni.android',
      title: 'Catatan Finansial',
      detail: 'Pemasukan',
      extractMethod: 'ExtractWithComma',
      isActive: true, // Aktifkan/non-aktifkan
    ),
  );

  // 4. Hapus rule
  await RulesManager.deleteRule(0); // index

  // 5. Match notification dengan rules
  final matchedRule = await RulesManager.matchNotification(
    'com.bca.mybca.omni.android', // packageName
    'Catatan Finansial', // title
    'Pemasukan Rp 500.000', // detail
  );

  if (matchedRule != null) {
    print('Match found: ${matchedRule.bankName}');
    print('Extract method: ${matchedRule.extractMethod}');
  }
}

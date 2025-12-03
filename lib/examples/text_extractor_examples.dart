// Contoh cara menggunakan TextExtractor

import 'package:notlistfl/utils/text_extractor.dart';

void main() {
  // Test ExtractWithRp
  String text1 = 'Transfer masuk Rp 500.000 dari John';
  String? amount1 = TextExtractor.extractWithRp(text1);
  print('ExtractWithRp: $amount1'); // Output: 500.000

  // Test ExtractWithComma
  String text2 = 'Amount 1,250,000.50 credited';
  String? amount2 = TextExtractor.extractWithComma(text2);
  print('ExtractWithComma: $amount2'); // Output: 1,250,000.50

  // Test ExtractWithDot
  String text3 = 'Saldo 750.000 tersedia';
  String? amount3 = TextExtractor.extractWithDot(text3);
  print('ExtractWithDot: $amount3'); // Output: 750.000

  // Parse to double
  double? parsed = TextExtractor.parseAmount('1.250.000');
  print('Parsed: $parsed'); // Output: 1250000.0

  // Auto extract berdasarkan method
  String amount4 = TextExtractor.extract(
    'Transfer Rp 100.000',
    'ExtractWithRp',
  ) ?? '0';
  print('Auto extract: $amount4'); // Output: 100.000

  // Contoh real dari notifikasi BCA
  String bcaNotif = 'Catatan Finansial\nPemasukan 1,500,000.00';
  String? bcaAmount = TextExtractor.extract(bcaNotif, 'ExtractWithComma');
  print('BCA Amount: $bcaAmount'); // Output: 1,500,000.00

  // Contoh dari BNI
  String bniNotif = 'Transaksi diterima!\nJumlah Rp 2.500.000';
  String? bniAmount = TextExtractor.extract(bniNotif, 'ExtractWithRp');
  print('BNI Amount: $bniAmount'); // Output: 2.500.000

  // Contoh dari BRI
  String briNotif = 'BRImo - Transfer masuk sebesar Rp 750000';
  String? briAmount = TextExtractor.extract(briNotif, 'ExtractWithRp');
  print('BRI Amount: $briAmount'); // Output: 750000
}

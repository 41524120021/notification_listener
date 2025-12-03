class TextExtractor {
  // Extract dengan format Rp (contoh: Rp 100.000 atau Rp100.000)
  // Sesuai B4A: _extractnominalwithrp
  static String? extractWithRp(String text) {
    final regex = RegExp(r'Rp\s?[\d.,]+');
    final match = regex.firstMatch(text);
    if (match != null) {
      String amount = match.group(0)!;
      // Remove Rp and spaces, keep numbers and dots/commas
      amount = amount.replaceAll('Rp', '').replaceAll(' ', '').trim();
      return amount;
    }
    return null;
  }

  // Extract dengan format koma (contoh: IDR 100,000.50 atau 100,000.50)
  // Sesuai B4A: _extractnominal dengan separator koma
  // Return: angka tanpa format (contoh: "770000" atau "29102340")
  static String? extractWithComma(String text) {
    String? result;
    
    // Prioritas 1: Cari format "IDR xxx,xxx.xx"
    final regexIDR = RegExp(r'IDR\s+([\d,]+\.?\d*)');
    final matchIDR = regexIDR.firstMatch(text);
    if (matchIDR != null) {
      result = matchIDR.group(1); // Ambil angka tanpa "IDR"
    } else {
      // Prioritas 2: Cari format angka dengan koma (fallback)
      final regex = RegExp(r'[\d,]+\.?\d*');
      final match = regex.firstMatch(text);
      if (match != null) {
        result = match.group(0);
      }
    }
    
    // Proses: hapus koma, lalu buang bagian desimal
    if (result != null) {
      // Hapus koma (thousand separator)
      result = result.replaceAll(',', '');
      // Buang bagian desimal jika ada (ambil hanya bagian sebelum titik)
      if (result.contains('.')) {
        result = result.split('.')[0];
      }
      return result;
    }
    return null;
  }

  // Extract dengan format dot (contoh: 100.000 atau 100000)
  // Sesuai B4A: _extractnominaldot
  static String? extractWithDot(String text) {
    final regex = RegExp(r'[\d.]+');
    final match = regex.firstMatch(text);
    if (match != null) {
      return match.group(0);
    }
    return null;
  }

  // Helper untuk convert ke angka
  static double? parseAmount(String? amount) {
    if (amount == null) return null;
    
    // Remove all dots and commas, keep only numbers
    String cleaned = amount.replaceAll('.', '').replaceAll(',', '');
    
    try {
      return double.parse(cleaned);
    } catch (e) {
      return null;
    }
  }

  // Extract berdasarkan method yang dipilih
  // Support format dari JSON server (tanpa underscore)
  static String? extract(String text, String method) {
    // Normalize method name (case insensitive, remove underscore)
    final normalizedMethod = method.toLowerCase().replaceAll('_', '');
    
    switch (normalizedMethod) {
      // Format dari server: "extractnominalwithrp" atau "ExtractWithRp"
      case 'extractnominalwithrp':
      case 'extractwithrp':
        return extractWithRp(text);
      
      // Format dari server: "extractnominal" atau "ExtractWithComma"
      case 'extractnominal':
      case 'extractwithcomma':
        return extractWithComma(text);
      
      // Format dari server: "extractnominaldot" atau "ExtractWithDot"
      case 'extractnominaldot':
      case 'extractwithdot':
        return extractWithDot(text);
      
      // Default fallback
      default:
        print('⚠️ Unknown extract method: $method, using ExtractWithRp as fallback');
        return extractWithRp(text);
    }
  }
}

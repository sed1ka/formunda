class FormundaConditionEvaluator {
  /// Mengevaluasi apakah suatu node harus disembunyikan.
  /// Saat ini mendukung ekspresi sederhana seperti:
  /// ="NG" != key_name
  /// =(key1 == "A") and (key2 != "B")
  static bool isHidden(String? expr, Map<String, dynamic> state) {
    if (expr == null || expr.isEmpty) return false;

    // Bersihkan prefix '=' dari Camunda
    String cleanExpr = expr.startsWith('=') ? expr.substring(1).trim() : expr.trim();

    try {
      // Logic sederhana untuk demo: jika mengandung "NG" dan "!= atau =="
      // Kita coba cari key yang ada di dalam state
      
      bool result = _evaluateLogic(cleanExpr, state);
      return result;
    } catch (e) {
      // Jika gagal parse, default ke tidak sembunyi (tampil)
      return false;
    }
  }

  static bool _evaluateLogic(String expr, Map<String, dynamic> state) {
    // Implementasi sederhana: Cek apakah ekspresi mengandung perbandingan '!=' atau '=='
    // Untuk 'kesempurnaan' nyata, disarankan menggunakan library seperti 'expressions' atau 'petitparser'
    
    // Contoh handle: ("NG" != a01_konstruksi)
    // Kita lakukan replacement key dengan value asli
    String evaluated = expr;
    state.forEach((key, value) {
      final stringValue = value is String ? '"$value"' : value.toString();
      evaluated = evaluated.replaceAll(key, stringValue);
    });

    // Handle 'and' dan 'or'
    evaluated = evaluated.replaceAll(' and ', ' && ').replaceAll(' or ', ' || ');

    // Catatan: Ini adalah evaluasi string sederhana. 
    // Untuk project produksi, gunakan interpreter yang aman.
    if (evaluated.contains('&&')) {
      final parts = evaluated.split('&&');
      return parts.every((p) => _evalSingle(p.trim()));
    }
    
    return _evalSingle(evaluated);
  }

  static bool _evalSingle(String part) {
    part = part.replaceAll('(', '').replaceAll(')', '').trim();
    
    if (part.contains('!=')) {
      final sides = part.split('!=');
      return _clean(sides[0]) != _clean(sides[1]);
    }
    if (part.contains('==')) {
      final sides = part.split('==');
      return _clean(sides[0]) == _clean(sides[1]);
    }
    
    return false; // Default
  }

  static String _clean(String s) => s.trim().replaceAll('"', '').replaceAll("'", "");
}

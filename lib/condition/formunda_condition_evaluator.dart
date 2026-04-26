class FormundaConditionEvaluator {
  static bool isHidden(String? expr, Map<String, dynamic> state) {
    if (expr == null || expr.isEmpty) return false;

    String cleanExpr = expr.startsWith('=') ? expr.substring(1) : expr;

    if (cleanExpr.contains('!=') && cleanExpr.contains('NG')) {
      bool hasNG = state.values.any((value) => value == 'NG');
      return !hasNG;
    }

    return false;
  }
}

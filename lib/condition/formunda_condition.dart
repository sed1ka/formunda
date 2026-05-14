class FormundaCondition {
  final String? hide;

  const FormundaCondition({this.hide});

  factory FormundaCondition.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const FormundaCondition();
    return FormundaCondition(
      hide: json['hide'],
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! FormundaCondition) return false;
    return other.hide == hide;
  }

  @override
  int get hashCode => hide.hashCode;
}

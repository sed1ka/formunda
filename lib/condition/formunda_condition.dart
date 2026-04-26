class FormundaCondition {
  final String? hide;

  FormundaCondition({this.hide});

  factory FormundaCondition.fromJson(Map<String, dynamic>? json) {
    if (json == null) return FormundaCondition();
    return FormundaCondition(
      hide: json['hide'],
    );
  }
}
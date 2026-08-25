class AttributeValueModel {
  final String id;
  final String attributeId;
  final String value;

  AttributeValueModel({
    required this.id,
    required this.attributeId,
    required this.value,
  });

  factory AttributeValueModel.fromJson(Map<String, dynamic> json) {
    return AttributeValueModel(
      id: json['id'] as String,
      attributeId: json['attributeId'] as String? ?? '',
      value: json['value'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'attributeId': attributeId,
      'value': value,
    };
  }
}

import 'attribute_value_model.dart';

class AttributeModel {
  final String id;
  final String name;
  final String status;
  final List<AttributeValueModel> values;

  AttributeModel({
    required this.id,
    required this.name,
    required this.status,
    this.values = const [],
  });

  factory AttributeModel.fromJson(Map<String, dynamic> json) {
    var rawValues = json['values'] as List<dynamic>? ?? [];
    return AttributeModel(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      status: json['status'] as String? ?? 'ACTIVE',
      values: rawValues
          .map((v) => AttributeValueModel.fromJson(v as Map<String, dynamic>))
          .toList(),
    );
  }

  AttributeModel copyWith({
    String? id,
    String? name,
    String? status,
    List<AttributeValueModel>? values,
  }) {
    return AttributeModel(
      id: id ?? this.id,
      name: name ?? this.name,
      status: status ?? this.status,
      values: values ?? this.values,
    );
  }
}

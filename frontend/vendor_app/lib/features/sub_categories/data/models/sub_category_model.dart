import 'package:equatable/equatable.dart';

class SubCategoryModel extends Equatable {
  final String id;
  final String categoryId;
  final String name;
  final String? description;
  final String? image;
  final String status;
  final String? rejectedReason;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SubCategoryModel({
    required this.id,
    required this.categoryId,
    required this.name,
    this.description,
    this.image,
    required this.status,
    this.rejectedReason,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SubCategoryModel.fromJson(Map<String, dynamic> json) {
    return SubCategoryModel(
      id: json['id'] as String,
      categoryId: json['categoryId'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      image: json['image'] as String?,
      status: json['status'] as String? ?? 'PENDING',
      rejectedReason: json['rejectedReason'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'categoryId': categoryId,
      'name': name,
      'description': description,
      'image': image,
      'status': status,
      'rejectedReason': rejectedReason,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        categoryId,
        name,
        description,
        image,
        status,
        rejectedReason,
        createdAt,
        updatedAt,
      ];
}

import 'cart_item_model.dart';
import 'cart_summary_model.dart';

class CartFullResponseModel {
  final List<CartItemModel> items;
  final CartSummaryModel summary;

  CartFullResponseModel({
    required this.items,
    required this.summary,
  });

  factory CartFullResponseModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? [];
    final items = rawItems
        .map((i) => CartItemModel.fromJson(i as Map<String, dynamic>))
        .toList();

    final summaryMap = json['summary'] as Map<String, dynamic>? ?? {};
    final summary = CartSummaryModel.fromJson(summaryMap);

    return CartFullResponseModel(
      items: items,
      summary: summary,
    );
  }

  factory CartFullResponseModel.empty() {
    return CartFullResponseModel(
      items: [],
      summary: CartSummaryModel.empty(),
    );
  }
}

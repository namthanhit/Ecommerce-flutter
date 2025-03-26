// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:ecommerce/data/order/models/product_ordered.dart';

import '../../../domain/order/entities/product_ordered.dart';

class OrderRegistrationReq {
  final String code; // ✨ Thêm mã đơn hàng
  final List<ProductOrderedEntity> products;
  final String createdDate;
  final String shippingAddress;
  final int itemCount;
  final double totalPrice;

  OrderRegistrationReq({
    required this.code, // Thêm vào constructor
    required this.products,
    required this.createdDate,
    required this.itemCount,
    required this.totalPrice,
    required this.shippingAddress
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'code': code,
      'products': products.map((e) => e.fromEntity().toMap()).toList(),
      'createdDate': createdDate,
      'itemCount': itemCount,
      'totalPrice': totalPrice,
      'shippingAddress': shippingAddress
    };
  }
}

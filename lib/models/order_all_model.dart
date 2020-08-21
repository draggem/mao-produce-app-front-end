import 'order_model.dart';

class OrderAllModel extends OrderModel {
  String custId;
  String custName;
  Map<String, String> signature;
  OrderAllModel({
    id,
    totalPrice,
    isOpen,
    orderDate,
    products,
    this.custId,
    this.custName,
    this.signature,
  }) : super(
          id: id,
          totalPrice: totalPrice,
          isOpen: isOpen,
          orderDate: orderDate,
          products: products,
        );
}

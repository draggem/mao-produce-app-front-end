import 'order_model.dart';

class OrderAllModel extends OrderModel {
  String custId;
  String custName;

  OrderAllModel({
    id,
    totalPrice,
    isOpen,
    orderDate,
    products,
    this.custId,
    this.custName,
  }) : super(
          id: id,
          totalPrice: totalPrice,
          isOpen: isOpen,
          orderDate: orderDate,
          products: products,
        );
}

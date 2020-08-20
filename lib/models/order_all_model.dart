import 'order_model.dart';

class OrderAllModel extends OrderModel {
  String custId;
  String custName;
  Map<String, dynamic> signature = {'signature': '', 'signee': ''};
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

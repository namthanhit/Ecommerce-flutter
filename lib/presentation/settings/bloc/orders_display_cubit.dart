import 'package:ecommerce/domain/order/usecases/get_orders.dart';
import 'package:ecommerce/presentation/settings/bloc/orders_display_state.dart';
import 'package:ecommerce/service_locator.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OrdersDisplayCubit extends Cubit<OrdersDisplayState> {
  OrdersDisplayCubit() : super(OrdersLoading());

  void displayOrders() async {
    emit(OrdersLoading()); // Đảm bảo trạng thái bắt đầu là loading

    try {
      var returnedData = await sl<GetOrdersUseCase>().call();

      returnedData.fold(
            (error) {
          print("Error fetching orders: $error"); // Debug lỗi
          emit(LoadOrdersFailure(errorMessage: error));
        },
            (orders) {
          if (orders.isEmpty) {
            print("No orders found"); // Debug nếu không có đơn hàng
            emit(LoadOrdersFailure(errorMessage: "No orders available"));
          } else {
            print("Fetched ${orders.length} orders"); // Debug số lượng đơn hàng
            for (var order in orders) {
              print("Order Code: ${order.code}"); // Kiểm tra mã đơn hàng
            }
            emit(OrdersLoaded(orders: orders));
          }
        },
      );
    } catch (e) {
      print("Exception in displayOrders: $e"); // Debug lỗi không mong muốn
      emit(LoadOrdersFailure(errorMessage: "Something went wrong"));
    }
  }
}

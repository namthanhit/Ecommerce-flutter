import 'package:ecommerce/common/bloc/button/button_state_cubit.dart';
import 'package:ecommerce/common/helper/cart/cart.dart';
import 'package:ecommerce/common/widgets/button/basic_reactive_button.dart';
import 'package:ecommerce/data/order/models/order_registration_req.dart';
import 'package:ecommerce/domain/order/usecases/order_registration.dart';
import 'package:ecommerce/presentation/cart/pages/order_placed.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../common/bloc/button/button_state.dart';
import '../../../common/helper/navigator/app_navigator.dart';
import '../../../common/widgets/appbar/app_bar.dart';
import '../../../domain/order/entities/product_ordered.dart';
import 'package:ecommerce/presentation/cart/bloc/code.dart';

class CheckOutPage extends StatefulWidget {
  final List<ProductOrderedEntity> products;

  CheckOutPage({required this.products, super.key});

  @override
  State<CheckOutPage> createState() => _CheckOutPageState();
}

class _CheckOutPageState extends State<CheckOutPage> {
  final TextEditingController _addressCon = TextEditingController();
  String _selectedPaymentMethod = 'Cash on Delivery'; // Mặc định

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BasicAppbar(title: Text('Checkout')),
      body: BlocProvider(
        create: (context) => ButtonStateCubit(),
        child: BlocListener<ButtonStateCubit, ButtonState>(
          listener: (context, state) {
            if (state is ButtonSuccessState) {
              AppNavigator.pushAndRemove(context, const OrderPlacedPage());
            }
            if (state is ButtonFailureState) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.errorMessage),
                    behavior: SnackBarBehavior.floating),
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _addressSection(),
                const SizedBox(height: 16),
                _paymentMethodSection(),
                const Spacer(),
                _placeOrderButton(), // Giữ nguyên nút thanh toán
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget _addressSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Shipping Address",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _addressCon,
              minLines: 2,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Enter your shipping address...',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _paymentMethodSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Payment Method",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedPaymentMethod,
              items: ['Credit Card', 'PayPal', 'Cash on Delivery']
                  .map((method) =>
                  DropdownMenuItem(
                    value: method,
                    child: Text(method),
                  ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedPaymentMethod = value!;
                });
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _placeOrderButton() {
    return BlocBuilder<ButtonStateCubit, ButtonState>(
      builder: (context, state) {
        double subtotal = CartHelper.calculateCartSubtotal(widget.products);
        double shippingFee = 8;
        double totalPrice = subtotal + shippingFee; // Thêm phí ship

        return ElevatedButton(
          onPressed: state is ButtonLoadingState
              ? null
              : () async {
            String orderCode = await OrderCodeHelper.getNextOrderCode();

            context.read<ButtonStateCubit>().execute(
              usecase: OrderRegistrationUseCase(),
              params: OrderRegistrationReq(
                code: orderCode,
                products: widget.products,
                createdDate: DateTime.now().toString(),
                itemCount: widget.products.length,
                totalPrice: totalPrice, // Đã bao gồm phí ship
                shippingAddress: _addressCon.text,
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8)),
          ),
          child: state is ButtonLoadingState
              ? const CircularProgressIndicator(color: Colors.white)
              : Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '\$${totalPrice.toStringAsFixed(2)}', // Hiển thị tổng tiền sau khi cộng phí ship
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
              const Text(
                'Place Order',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 16),
              ),
            ],
          ),
        );
      },
    );
  }
}
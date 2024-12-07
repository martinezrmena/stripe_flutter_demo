import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:stripe_app/bloc/pagar/pagar_bloc.dart';

import 'package:stripe_app/widgets/total_pay_button.dart';

class TarjetaPage extends StatelessWidget {
  const TarjetaPage({super.key});

  @override
  Widget build(BuildContext context) {
    final tarjeta = BlocProvider.of<PagarBloc>(context, listen: false).state.tarjeta;

    return Scaffold(
        appBar: AppBar(
          title: const Text('Pagar'),
          leading: IconButton(
            onPressed: () {
              BlocProvider.of<PagarBloc>(context, listen: false)
                  .add(OnDesactivarTarjeta());

              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back_ios),
          ),
        ),
        body: Stack(
          children: [
            Container(),
            Hero(
              tag: tarjeta?.cardNumber ?? '',
              child: CreditCardWidget(
                cardNumber: tarjeta?.cardNumberHidden ?? '',
                expiryDate: tarjeta?.expiracyDate ?? '',
                cardHolderName: tarjeta?.cardHolderName ?? '',
                cvvCode: tarjeta?.cvv ?? '',
                showBackView: false,
                onCreditCardWidgetChange: (p0) {},
              ),
            ),
            const Positioned(bottom: 0, child: TotalPayButton())
          ],
        ));
  }
}

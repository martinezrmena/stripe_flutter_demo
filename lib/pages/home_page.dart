// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:stripe_app/bloc/pagar/pagar_bloc.dart';

import 'package:stripe_app/data/tarjetas.dart';
import 'package:stripe_app/helpers/helpers.dart';
import 'package:stripe_app/pages/tarjeta_page.dart';
import 'package:stripe_app/services/stripe_service.dart';
import 'package:stripe_app/widgets/total_pay_button.dart';

class HomePage extends StatelessWidget {
  final stripeService = StripeService();

  HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final pagarBloc = BlocProvider.of<PagarBloc>(context);

    return Scaffold(
        appBar: AppBar(
          title: const Text('Pagar'),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () async {
                mostrarLoading(context);

                final response = await stripeService.pagarConNuevaTarjeta(
                  amount: pagarBloc.state.montoPagarString,
                  currency: pagarBloc.state.moneda,
                );

                if (response.ok) {
                  mostrarAlerta(context, 'Tarjeta OK', 'Todo correcto');
                } else {
                  mostrarAlerta(context, 'Algo salio mal',
                      response.msg ?? 'Sin Informacion');
                }
              },
            )
          ],
        ),
        body: Stack(
          children: [
            Positioned(
              width: size.width,
              height: size.height,
              top: 200,
              child: PageView.builder(
                  controller: PageController(viewportFraction: 0.9),
                  physics: const BouncingScrollPhysics(),
                  itemCount: tarjetas.length,
                  itemBuilder: (_, i) {
                    final tarjeta = tarjetas[i];

                    return GestureDetector(
                      onTap: () {
                        BlocProvider.of<PagarBloc>(context, listen: false)
                            .add(OnSeleccionarTarjeta(tarjeta));

                        Navigator.push(
                          context,
                          navegarFadeIn(
                            context,
                            const TarjetaPage(),
                          ),
                        );
                      },
                      child: Hero(
                        tag: tarjeta.cardNumber,
                        child: CreditCardWidget(
                          cardNumber: tarjeta.cardNumberHidden,
                          expiryDate: tarjeta.expiracyDate,
                          cardHolderName: tarjeta.cardHolderName,
                          cvvCode: tarjeta.cvv,
                          showBackView: false,
                          onCreditCardWidgetChange: (p0) {},
                        ),
                      ),
                    );
                  }),
            ),
            const Positioned(bottom: 0, child: TotalPayButton())
          ],
        ));
  }
}

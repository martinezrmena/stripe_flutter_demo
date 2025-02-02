// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:stripe_app/services/stripe_service.dart';
import 'package:stripe_payment/stripe_payment.dart';

import '../bloc/pagar/pagar_bloc.dart';
import '../helpers/helpers.dart';

class TotalPayButton extends StatelessWidget {
  const TotalPayButton({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final pagarBloc = BlocProvider.of<PagarBloc>(context).state;

    return Container(
      width: width,
      height: 100,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          )),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Total',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Text('${pagarBloc.montoPagar} ${pagarBloc.moneda}',
                  style: const TextStyle(fontSize: 20))
            ],
          ),
          BlocBuilder<PagarBloc, PagarState>(
            builder: (context, state) {
              return _BtnPay(state: state);
            },
          )
        ],
      ),
    );
  }
}

class _BtnPay extends StatelessWidget {
  final PagarState state;

  const _BtnPay({
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return state.tarjetaActiva
        ? buildBotonTarjeta(context)
        : buildAppleAndGooglePay(context);
  }

  Widget buildBotonTarjeta(BuildContext context) {
    return MaterialButton(
        height: 45,
        minWidth: 170,
        shape: const StadiumBorder(),
        elevation: 0,
        color: Colors.black,
        child: const Row(
          children: [
            Icon(FontAwesomeIcons.solidCreditCard, color: Colors.white),
            Text('  Pagar',
                style: TextStyle(color: Colors.white, fontSize: 22)),
          ],
        ),
        onPressed: () async {
          mostrarLoading(context);

          final stripeService = StripeService();
          final state = BlocProvider.of<PagarBloc>(context).state;
          final tarjeta = state.tarjeta;
          final mesAnio = tarjeta?.expiracyDate.split('/');

          final response = await stripeService.pagarConTarjetaExiste(
            amount: state.montoPagarString,
            currency: state.moneda,
            card: CreditCard(
              number: tarjeta?.cardNumber,
              expMonth: int.parse(mesAnio![0]),
              expYear: int.parse(mesAnio[1]),
            ),
          );

          Navigator.pop(context);

          if (response.ok) {
            mostrarAlerta(context, 'Tarjeta OK', 'Todo correcto');
          } else {
            mostrarAlerta(context, 'Algo salió mal', response.msg ?? 'Error');
          }
        });
  }

  Widget buildAppleAndGooglePay(BuildContext context) {
    return MaterialButton(
        height: 45,
        minWidth: 150,
        shape: const StadiumBorder(),
        elevation: 0,
        color: Colors.black,
        child: Row(
          children: [
            Icon(
                Platform.isAndroid
                    ? FontAwesomeIcons.google
                    : FontAwesomeIcons.apple,
                color: Colors.white),
            const Text(' Pay',
                style: TextStyle(color: Colors.white, fontSize: 22)),
          ],
        ),
        onPressed: () async {
          final stripeService = StripeService();
          final state = BlocProvider.of<PagarBloc>(context, listen: false).state;

          final resp = await stripeService.pagarApplePayGooglePay(
              amount: state.montoPagarString, 
              currency: state.moneda,
            );
            
          
        });
  }
}

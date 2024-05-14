import 'dart:math';

import 'package:events_emitter/events_emitter.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../dao/account_dao.dart';
import '../../dao/payment_dao.dart';
import '../../events.dart';
import '../../model/account.model.dart';
import '../../model/payment.model.dart';
import '../../theme/colors.dart';
import '../../widgets/currency.dart';
import '../../widgets/dialog/account_form.dialog.dart';
import '../../widgets/dialog/confirm.modal.dart';
import '../payment_form.screen.dart';

maskAccount(String value, [int lastLength = 4]){
  if(value.length <4 ) return value;
  int length = value.length - lastLength;
  String generated = "";
  if(length > 0){
    generated+= value.substring(0, length).split("").map((e) => e==" "? " ": "X").join("");
  }
  generated += value.substring(length);
  return generated;
}
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AccountDao _accountDao = AccountDao();
  final PaymentDao _paymentDao = PaymentDao();

  EventListener? _accountEventListener;
  EventListener? _paymentEventListener;

  List<Account> _accounts = [];
  List<Payment> _payments = [];
  double _income = 0;
  double _expense = 0;

  void openAddPaymentPage(PaymentType type) async {
    Navigator.of(context).push(MaterialPageRoute(builder: (builder)=>PaymentForm(type: type)));
  }

  void loadData() async {
    List<Account> accounts = await _accountDao.find(withSummery: true);
    setState(() {
      _accounts = accounts;
    });
  }

  void loadPayments() async {
    List<Payment> payment = await _paymentDao.find();
    setState(() {
      _payments = payment;
    });
  }

  @override
  void initState() {
    super.initState();
    loadData();

    _fetchTransactions();

    _accountEventListener = globalEvent.on("account_update", (data){
      debugPrint("accounts are changed");
      loadData();
    });

    _paymentEventListener = globalEvent.on("payment_update", (data){
      debugPrint("payment are changed");
      //loadPayments();
      _fetchTransactions();
    });
  }

  void _fetchTransactions() async {
    List<Payment> trans = await _paymentDao.find();
    double income = 0;
    double expense = 0;
    for (var payment in trans) {
      if(payment.type == PaymentType.credit) income += payment.amount;
      if(payment.type == PaymentType.debit) expense += payment.amount;
    }

    //fetch accounts
    List<Account> accounts = await _accountDao.find(withSummery: true);

    setState(() {
      _payments = trans;
      _income = income;
      _expense = expense;
      _accounts = accounts;
    });
  }

  @override
  void dispose() {

    _accountEventListener?.cancel();

    super.dispose();
  }
  @override
  Widget build(BuildContext context) {

    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/th.jpeg'),
          fit: BoxFit.cover,
        )
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text("Home", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 25, color: Colors.white),),
          titleSpacing: 40.0,
          toolbarHeight: 100.0,
          backgroundColor: Colors.transparent,
        ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children:[
              const SizedBox(height: 130.0,),
              Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Container(
                        alignment: AlignmentDirectional.topStart,
                        margin: const EdgeInsets.only(bottom: 20),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            color: Colors.grey[300],
                        ),
                        child: Column(
                          //mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 20,),
                            const Text.rich(
                                TextSpan(
                                    children: [
                                      TextSpan(text:"Total Balance", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
                                    ]
                                )
                            ),
                            CurrencyText((_income - _expense), style:  TextStyle(fontSize: 25, fontWeight: FontWeight.w700, fontFamily: GoogleFonts.jetBrainsMono().fontFamily),),
                            const SizedBox(height: 10,),

                            const SizedBox(height: 30,),

                            Padding(
                              padding: const EdgeInsets.only(right: 20),
                              child: Row(
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text.rich(
                                          TextSpan(
                                              children: [
                                                //TextSpan(text: "▼", style: TextStyle(color: ThemeColors.success)),
                                                TextSpan(text:"Income", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
                                              ]
                                          )
                                      ),
                                      CurrencyText(_income, style:  TextStyle(fontSize: 25, fontWeight: FontWeight.w700, color: ThemeColors.success, fontFamily: GoogleFonts.jetBrainsMono().fontFamily),)
                                    ],
                                  ),
                                  const Spacer(),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text.rich(
                                          TextSpan(
                                              children: [
                                                //TextSpan(text: "▲", style: TextStyle(color: ThemeColors.error)),
                                                TextSpan(text:"Expense", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
                                              ]
                                          )
                                      ),
                                      CurrencyText(_expense, style:  TextStyle(fontSize: 25, fontWeight: FontWeight.w700, color: ThemeColors.error, fontFamily: GoogleFonts.jetBrainsMono().fontFamily),)
                                    ],
                                  )
                                ],
                              ),
                            )
                          ],
                        )
                    ),
                  ),
                ],
              ),
            ],
          ),
        floatingActionButton: FloatingActionButton(
          onPressed: ()=> openAddPaymentPage(PaymentType.credit),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

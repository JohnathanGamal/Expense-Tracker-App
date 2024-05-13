import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../helpers/db.helper.dart';
import '../model/account.model.dart';
import '../model/category.model.dart';
import '../model/payment.model.dart';
import 'account_dao.dart';
import 'category_dao.dart';


class PaymentDao {
  Future<int> create(Payment payment) async {
    final db = await getDBInstance();
    var result = db.insert("payments", payment.toJson());
    return result;
  }

  Future<List<Payment>> find({
    DateTimeRange? range,
    PaymentType? type,
    Category? category,
    Account? account
  }) async {
    final db = await getDBInstance();
    String where = "";

    if(range!=null){
      where += "AND datetime BETWEEN DATE('${DateFormat('yyyy-MM-dd kk:mm:ss').format(range.start)}') AND DATE('${DateFormat('yyyy-MM-dd kk:mm:ss').format(range.end.add(const Duration(days: 1)))}')";
    }

    //type check
    if(type != null){
      where += "AND type='${type == PaymentType.credit?"DR":"CR"}' ";
    }

    //icon check

    //icon check
    if(category != null){
      where += "AND category='${category.id}' ";
    }

    //categories
    List<Category> categories = await CategoryDao().find();
    List<Account> accounts = await AccountDao().find();


    List<Payment> payments = [];
    List<Map<String, Object?>> rows =  await db.query(
        "payments",
    );
    for (var row in rows) {
      Map<String, dynamic> payment = Map<String, dynamic>.from(row);
      Category category = categories.firstWhere((c) => c.id == payment["category"]);
      payment["category"] = category.toJson();
      payments.add(Payment.fromJson(payment));
    }

    return payments;
  }

  Future<int> update(Payment payment) async {
    final db = await getDBInstance();

    var result = await db.update("payments", payment.toJson(), where: "id = ?", whereArgs: [payment.id]);

    return result;
  }

  Future<int> upsert(Payment payment) async {
    final db = await getDBInstance();
    int result;
    if(payment.id != null) {
      result = await db.update(
          "payments", payment.toJson(), where: "id = ?",
          whereArgs: [payment.id]);
    } else {
      result = await db.insert("payments", payment.toJson());
    }
    return result;
  }


  Future<int> deleteTransaction(int id) async {
    final db = await getDBInstance();
    var result = await db.delete("payments", where: 'id = ?', whereArgs: [id]);
    return result;
  }

  Future deleteAllTransactions() async {
    final db = await getDBInstance();
    var result = await db.delete(
      "payments",
    );
    return result;
  }
}
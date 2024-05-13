
import 'package:intl/intl.dart';

import 'account.model.dart';
import 'category.model.dart';

enum PaymentType {
  debit,
  credit
}
class Payment {
  int? id;
  Category category;
  double amount;
  PaymentType type;
  DateTime datetime;
  String title;
  String description;

  Payment({
    this.id,
    required this.category,
    required this.amount,
    required this.type,
    required this.datetime,
    required this.title,
    required this.description
  });


  factory Payment.fromJson(Map<String, dynamic> data) {
    return Payment(
      id: data["id"],
      title: data["title"] ??"",
      description: data["description"]??"",
      category: Category.fromJson(data["category"]),
      amount: data["amount"],
      type: data["type"] == "CR" ? PaymentType.credit : PaymentType
          .debit,
      datetime: DateTime.parse(data["datetime"]),
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "description": description,
    "category": category.id,
    "amount": amount,
    "datetime": DateFormat('yyyy-MM-dd kk:mm:ss').format(datetime),
    "type": type == PaymentType.credit ? "CR": "DR",
  };
}
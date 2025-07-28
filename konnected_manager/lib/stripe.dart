import 'dart:convert';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:teledart/model.dart';

class MyStripeProduct {
  final String name;
  final String id;
  final String priceID;
  final double price;
  const MyStripeProduct(
      {required this.name,
      required this.id,
      required this.priceID,
      required this.price});
}

class StripeUtils {
  static String baseUrl = "https://api.stripe.com/v1";
  static String key = '*';
  static String basicAuth = 'Basic ${base64.encode(utf8.encode('$key:'))}';
  static final headers = {
    'Content-Type': 'application/x-www-form-urlencoded',
    'Authorization': basicAuth,
  };

  static Future<void> reply(
    TeleDartMessage message,
    String text, {
    String? parseMode,
    ReplyMarkup? replyMarkup,
  }) async {
    try {
      await message.reply(text, parseMode: parseMode, replyMarkup: replyMarkup);
    } catch (e) {
      //
    }
  }

  static Future<List<MyStripeProduct>> getAllProducts() async {
    List<MyStripeProduct> myProducts = [];
    final params = {'limit': '15'};
    var response = await http.get(
        Uri.parse("$baseUrl/products").replace(queryParameters: params),
        headers: headers);
    var body = jsonDecode(response.body);
    List<dynamic> data = body["data"];
    for (var product in data) {
      bool active = product["active"];
      if (active) {
        String name = product["name"];
        print(name);
        String id = product["id"];
        print(id);
        String priceID = product["default_price"] ?? "None";
        print(priceID);
        var priceResponse = await http
            .get(Uri.parse("$baseUrl/prices/$priceID"), headers: headers);
        var priceBody = jsonDecode(priceResponse.body);
        var priceUnitAmount = priceBody["unit_amount"];
        double priceValue = priceUnitAmount / 100;
        print(priceValue.toStringAsFixed(2));
        myProducts.add(MyStripeProduct(
            name: name, id: id, priceID: priceID, price: priceValue));
      }
    }

    return myProducts;
  }

  static MyStripeProduct matchSubtoProduct(
          String name, double price, List<MyStripeProduct> products) =>
      products.firstWhere((p) => p.name == name && p.price == price);

  static DateTime stripeTimestampToDate(int timestamp) =>
      DateTime.fromMillisecondsSinceEpoch(timestamp * 1000, isUtc: true)
          .toLocal();
  static DateTime nowUtc() => DateTime.now().toUtc();

  static Future<List<dynamic>> generatePaymentLink(String priceID) async {
    final now = nowUtc();
    final int halfHourInMilliseconds = 2100 * 1000;
    final expirationMilliseconds =
        now.millisecondsSinceEpoch + halfHourInMilliseconds;
    final expirationSeconds = expirationMilliseconds / 1000;
    final data =
        'success_url=https%3A%2F%2Ft.me%2Fkonnectedlobby_bot&line_items[0][price]=$priceID&line_items[0][quantity]=1&mode=payment&expires_at=${expirationSeconds.toInt()}';
    final response = await http.post(Uri.parse("$baseUrl/checkout/sessions"),
        headers: headers, body: data);
    final status = response.statusCode;
    if (status == 200) {
      final body = jsonDecode(response.body);
      final paymentID = body["id"];
      final url = body["url"];
      final expiresAt = body["expires_at"];
      final expirationDate = stripeTimestampToDate(expiresAt);
      return [url, paymentID, expirationDate];
    } else {
      return ['', '', DateTime(2025)];
    }
  }

  static Future<bool> checkHasBeenPaid(String paymentID) async {
    final response = await http.post(
        Uri.parse("$baseUrl/checkout/sessions/$paymentID"),
        headers: headers);
    final body = jsonDecode(response.body);
    final status = body["payment_status"];
    if (status == "paid") {
      return true;
    }
    return false;
  }

  static Future<String?> checkIsExpiredOrComplete(
      String paymentID, TeleDartMessage message) async {
    final response = await http.post(
        Uri.parse("$baseUrl/checkout/sessions/$paymentID"),
        headers: headers);
    final body = jsonDecode(response.body);
    final status = body["status"];
    if (status == "expired") {
      reply(message,
          "Payment link has expired! Repeat the previous command to create a new payment.");
    }
    if (status == "complete") {
      reply(message,
          "Checkout complete, payment may still be processing. Please wait 1-2 minutes.");
    }
    return status;
  }
}

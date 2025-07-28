import 'dart:io';
import 'package:teledart/model.dart';
import 'package:teledart/teledart.dart';
import 'package:teledart/telegram.dart';
import '../lib/firestore.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main(List<String> arguments) async {
  HttpOverrides.global = MyHttpOverrides();
  var botToken = '*';
  final username = (await Telegram(botToken).getMe()).username;
  var teledart = TeleDart(botToken, Event(username!));

  teledart.start();

  Future<void> reply(
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

  teledart.onCommand('start').listen((message) async {
    FirestoreUtils.startReporter(message);
  });

  teledart.onCommand('timeout1day').listen((message) async {
    FirestoreUtils.timeoutUser(message, 1, teledart);
  });

  teledart.onCommand('timeout3day').listen((message) async {
    FirestoreUtils.timeoutUser(message, 3, teledart);
  });

  teledart.onCommand('timeout7day').listen((message) async {
    FirestoreUtils.timeoutUser(message, 7, teledart);
  });

  teledart.onCommand('ban').listen((message) async {
    FirestoreUtils.banUser(message, teledart);
  });

  teledart.onCommand('lifttimeout').listen((message) async {
    FirestoreUtils.liftTimeout(message, teledart);
  });

  teledart.onCommand('liftban').listen((message) async {
    FirestoreUtils.liftBan(message, teledart);
  });

  teledart.onCommand('fetchuser').listen((message) {
    FirestoreUtils.fetchUser(message);
  });

  teledart.onCommand('ping').listen((message) {
    reply(message, "pong");
  });

  FirestoreUtils.reporterListenToReports(teledart);
}

  /*
commands:
fetchuser - Fetch a user details
timeout1day - Time-out for one day
timeout3day - Time-out for three days
timeout7day - Time-out for four days
ban - Permanently ban user
lifttimeout - Lift a time-out placed on a user
liftban - Lift a ban placed on a user
ping - Status
   */

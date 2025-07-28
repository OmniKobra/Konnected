// import 'package:konnected_support/konnected_support.dart' as konnected_support;
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
  // print('Hello world: ${konnected_support.calculate()}!');
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

  teledart.onCommand('start').listen((message) {
    reply(message,
        "Welcome to Konnected support bot.\n\nType /newticket followed by a description of your issue to speak with a Support admin.\n\nType /closeticket followed by the Ticket ID to close an ongoing ticket.\n\nType /reply followed by the Ticket ID to reply to an ongoing ticket.\n\n🛋 Lobby: ${FirestoreUtils.lobbyBot}\n\n🛍 For Consumers: ${FirestoreUtils.consumerBot}\n\n🏬 For Providers: ${FirestoreUtils.providerBot}\n\n🛟 For Support: ${FirestoreUtils.supportBot}\n\nFollow us on X: https://x.com/KonnectedServer \n\nFollow us on Instagram: https://www.instagram.com/konnected2025/");
    FirestoreUtils.startSupport(message);
    reply(message, FirestoreUtils.disclaimer);
  });

  teledart.onCommand('newticket').listen((message) {
    FirestoreUtils.newSupportTicket(message);
  });

  teledart.onCommand('closeticket').listen((message) {
    FirestoreUtils.closeSupportTicket(message);
  });

  teledart.onCommand('reply').listen((message) {
    FirestoreUtils.replySupportTicket(message);
  });

  teledart.onCommand('fetchuser').listen((message) {
    FirestoreUtils.fetchUser(message);
  });

  teledart.onCommand('ping').listen((message) {
    reply(message, "pong");
  });

  FirestoreUtils.supporterListen(teledart);
}

  /* 
commands:
newticket - Create a new support ticket
closeticket - Close an open support ticket
reply - Reply to an open support ticket
fetchuser - Fetch a user details
ping - Status
  */

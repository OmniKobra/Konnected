// import 'package:konnected_consumer/konnected_consumer.dart' as konnected_consumer;
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
    reply(message,
        "🛍 Welcome to the consumer section of Konnected, @${message.from!.username}. 👋\nI will be forwarding your requests to our network of local or global providers.\n\nType /want and what you're requesting to send a request to your local providers.\n\nType /wantglobal and what you're requesting to send a request to global providers.\n\nType /report followed by an offer's ID to report it to admins.\n\nBe as descriptive as possible when making requests, describe the details or location of what you want for the best result.\n\n🛋 Lobby: ${FirestoreUtils.lobbyBot}\n\n🛍 For Consumers: ${FirestoreUtils.consumerBot}\n\n🏬 For Providers: ${FirestoreUtils.providerBot}\n\n🛟 For Support: ${FirestoreUtils.supportBot}\n\nFollow us on X: https://x.com/KonnectedServer \n\nFollow us on Instagram: https://www.instagram.com/konnected2025/");
    reply(message, FirestoreUtils.disclaimer);
  });

  teledart.onCommand('want').listen((message) {
    FirestoreUtils.sendNewRequest(message, false);
  });

  teledart.onCommand('wantglobal').listen((message) {
    FirestoreUtils.sendNewRequest(message, true);
  });

  teledart.onCommand('accept').listen((message) {
    FirestoreUtils.acceptRequestOffer(message);
  });

  teledart.onCommand('decline').listen((message) {
    FirestoreUtils.declineRequestOffer(message);
  });

  teledart.onCommand('discuss').listen((message) {
    FirestoreUtils.discussOffer(message);
  });

  teledart.onCommand('reply').listen((message) {
    FirestoreUtils.replyDiscussion(message);
  });

  teledart.onCommand('cancel').listen((message) {
    FirestoreUtils.cancelRequest(message);
  });

  teledart.onCommand('report').listen((message) {
    FirestoreUtils.reportOffer(message);
  });

  teledart.onCommand('help').listen((message) async {
    reply(message,
        "If you are facing trouble while using Konnected, open a support ticket with ${FirestoreUtils.supportBot}");
  });

  teledart.onCommand('ping').listen((message) {
    reply(message, "pong");
  });

  FirestoreUtils.listenToRequests(teledart);
}  
    /*
Commands:
want - Make a local request
wantglobal - Make a global request
accept - Accept an offer
decline - Decline an offer
discuss - Discuss an offer with the provider
reply - Reply to a discussion with a provider
cancel - Cancel a request
help - Get help from Konnected admins
report - Report an offer or request
ping - Status
   
  */


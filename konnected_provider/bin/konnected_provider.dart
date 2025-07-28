// import 'package:konnected_provider/konnected_provider.dart' as konnected_provider;
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
    FirestoreUtils.startProvider(message);
    reply(
      message,
      "🏬 Welcome to the provider section of Konnected, @${message.from!.username}. 👋\nI will be forwarding requests from our network of local or global consumers to you.\n\nType /offer followed by the request ID to send an offer to a request.\n\nType /reply followed by the request ID to reply to discussion with a consumer.\n\nType /report followed by a request's ID to report it to admins.\n\nBe as descriptive as possible when making offers, describe the details or location of what you're offering for optimal results.\n\n🛋 Lobby: ${FirestoreUtils.lobbyBot}\n\n🛍 For Consumers: ${FirestoreUtils.consumerBot}\n\n🏬 For Providers: ${FirestoreUtils.providerBot}\n\n🛟 For Support: ${FirestoreUtils.supportBot}\n\nFollow us on X: https://x.com/KonnectedServer \n\nFollow us on Instagram: https://www.instagram.com/konnected2025/",
    );
    reply(message, FirestoreUtils.disclaimer);
  });

  teledart.onCommand('offer').listen((message) async {
    FirestoreUtils.makeOffer(message);
  });

  teledart.onCommand('reply').listen((message) async {
    FirestoreUtils.providerReplyDiscussion(message);
  });

  teledart.onCommand('report').listen((message) async {
    FirestoreUtils.reportRequest(message);
  });

  teledart.onCommand('help').listen((message) async {
    reply(message,
        "If you are facing trouble while using Konnected, open a support ticket with ${FirestoreUtils.supportBot}");
  });

  teledart.onCommand('ping').listen((message) {
    reply(message, "pong");
  });

  FirestoreUtils.providerListenToRequests(teledart);
}
  /*
Commands:
offer - Make an offer to a request
reply - Reply to a discussion with a consumer
help - Get help from Konnected admins
report - Report an offer or request
ping - Status

  */

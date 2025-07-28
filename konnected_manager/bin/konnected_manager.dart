// import 'package:konnected_manager/konnected_manager.dart' as konnected_manager;
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
  // print('Hello world: ${konnected_manager.calculate()}!');
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

  teledart.onCommand('info').listen((message) {
    FirestoreUtils.fetchInfo(message);
  });

  teledart.onCommand('addsupport').listen((message) {
    FirestoreUtils.addSupport(message);
  });

  teledart.onCommand('removesupport').listen((message) {
    FirestoreUtils.removeSupport(message);
  });

  teledart.onCommand('addreport').listen((message) {
    FirestoreUtils.addReport(message);
  });

  teledart.onCommand('removereport').listen((message) {
    FirestoreUtils.removeReport(message);
  });

  teledart.onCommand('resetbalance').listen((message) {
    FirestoreUtils.resetBalance(message);
  });

  teledart.onCommand('broadcast').listen((message) {
    FirestoreUtils.broadcast(message);
  });

  teledart.onCommand('makepermanent').listen((message) {
    FirestoreUtils.makePermanent(message);
  });

  teledart.onCommand('fetchsupporter').listen((message) {
    FirestoreUtils.fetchSupporter(message);
  });

  teledart.onCommand('fetchreporter').listen((message) {
    FirestoreUtils.fetchReporter(message);
  });

  teledart.onCommand('fetchuser').listen((message) {
    FirestoreUtils.fetchUser(message);
  });

  teledart.onCommand('revokesub').listen((message) {
    FirestoreUtils.revokeSubscription(message);
  });

  teledart.onCommand('revokeandban').listen((message) {
    FirestoreUtils.revokeAndBan(message);
  });

  teledart.onCommand('activatesubconsumer').listen((message) {
    FirestoreUtils.activateSub(message, "consumer");
  });

  teledart.onCommand('activatesubprovider').listen((message) {
    FirestoreUtils.activateSub(message, "provider");
  });

  teledart.onCommand('activatesubdual').listen((message) {
    FirestoreUtils.activateSub(message, "dual");
  });

  teledart.onCommand('resetreferrals').listen((message) {
    FirestoreUtils.resetUserReferrals(message);
  });

  teledart.onCommand('referraldata').listen((message) {
    FirestoreUtils.fetchReferralData(message);
  });

  teledart.onCommand('getactivesubscribers').listen((message) {
    FirestoreUtils.getSubscribersWithActiveSub(message);
  });

  teledart.onCommand('fetchpaymentuser').listen((message) {
    FirestoreUtils.fetchUserFromPayment(message);
  });

  teledart.onCommand('fetchpaymentstatus').listen((message) {
    FirestoreUtils.fetchPaymentStatus(message);
  });

  teledart.onCommand('bots').listen((message) {
    reply(message,
        "\n\nLobby: ${FirestoreUtils.lobbyBot}\n\nConsumers: ${FirestoreUtils.consumerBot}\n\nProviders: ${FirestoreUtils.providerBot}\n\nSupport: ${FirestoreUtils.supportBot}\n\nReport: ${FirestoreUtils.reportBot}");
  });

  teledart.onCommand('allperm').listen((message) {
    FirestoreUtils.allPerm(message);
  });

  teledart.onCommand('noperm').listen((message) {
    FirestoreUtils.noPerm(message);
  });

  teledart.onCommand('ping').listen((message) {
    reply(message, "pong");
  });
}

  /* 
commands:
info - Fetch info about konnected
addsupport - Add a support admin
removesupport - Remove a support admin
addreport - Add a report admin
removereport - Remove report admin
resetbalance - Reset the current balance
broadcast - Broadcast a message to the lobby
makepermanent - Make a user permanent
fetchsupporter - Fetch a support admin details
fetchreporter - Fetch a report admin details
fetchuser - Fetch a user details
revokesub - Revoke a user subscription
revokeandban - Revoke subscription and ban user
activatesubconsumer - Activate consumer subscription for a month
activatesubprovider - Activate provider subscription for a month
activatesubdual - Activate dual subscription for a month
resetreferrals - Reset user referrals
referraldata - Get current referral data of a user
getactivesubscribers - Get current paid subscribers
fetchpaymentuser - get user from payment id
fetchpaymentstatus - check a payment id status
bots - all bot usernames
ping - Status
allperm - make all nonpermanent users permanent
noperm - make all permanent users nonpermanent
  */

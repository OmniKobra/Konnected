import 'package:konnected/konnected.dart' as konnected;
import 'dart:io';

// ignore: avoid_relative_lib_imports
import '../lib/firestore.dart';
import '../lib/stripe.dart';

import 'package:teledart/model.dart' hide File;
import 'package:teledart/teledart.dart';
import 'package:teledart/telegram.dart';

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
  List<List<KeyboardButton>> mainMenu(bool userExists) => [
        if (!userExists) [KeyboardButton(text: "Join Konnected 🃏  [/begin]")],
        if (userExists) [KeyboardButton(text: "My Profile 👤  [/me]")],
        [KeyboardButton(text: "About Konnected 📖  [/more]")],
      ];
  List<List<KeyboardButton>> regions(bool isSetup) {
    String command = isSetup ? "/changeregion" : "/setprofileregion";
    return [
      [KeyboardButton(text: "North America  [$command na]")],
      [KeyboardButton(text: "South America  [$command sa]")],
      [KeyboardButton(text: "Europe  [$command eu]")],
      [KeyboardButton(text: "MENA  [$command MENA]")],
      [KeyboardButton(text: "Africa  [$command af]")],
      [KeyboardButton(text: "Asia  [$command as]")],
      [KeyboardButton(text: "Oceania  [$command oc]")],
      konnected.mainMenuButton(),
    ];
  }

  teledart.start();
  List<MyStripeProduct> products = await StripeUtils.getAllProducts();

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
    bool userExists = await FirestoreUtils.fetchUserExists(message);
    reply(
      message,
      "Welcome to Konnected @${message.from!.username}. 👋\n\n🌐 Konnected is the portal that connects providers and consumers locally and globally.\n\n🔊 To broadcast your promotions speak to @M0N3Y6\n\n🛋 Lobby: ${FirestoreUtils.lobbyBot}\n\n🛍 For Consumers: ${FirestoreUtils.consumerBot}\n\n🏬 For Providers: ${FirestoreUtils.providerBot}\n\n🛟 For Support: ${FirestoreUtils.supportBot}\n\nFollow us on X: https://x.com/KonnectedServer \n\nFollow us on Instagram: https://www.instagram.com/konnected2025/",
      replyMarkup: ReplyKeyboardMarkup(
          oneTimeKeyboard: false, keyboard: mainMenu(userExists)),
    );
    reply(message, FirestoreUtils.disclaimer);
  });

  teledart.onCommand('more').listen((message) {
    reply(message, "Showing more details about Konnected...",
        replyMarkup: ReplyKeyboardMarkup(oneTimeKeyboard: false, keyboard: [
          [KeyboardButton(text: "How does it work? ℹ️  [/about]")],
          [KeyboardButton(text: "Where is it availabe? 🌏  [/regions]")],
          [KeyboardButton(text: "Pricing 💰  [/pricing]")],
          [KeyboardButton(text: "Do we store data? 💻  [/safety]")],
          [KeyboardButton(text: "What are Konnected bots? 🤖  [/bots]")],
          konnected.mainMenuButton(),
        ]));
  });

  teledart.onCommand('main').listen((message) async {
    bool userExists = await FirestoreUtils.fetchUserExists(message);
    reply(message, "Showing main menu...",
        replyMarkup: ReplyKeyboardMarkup(
            oneTimeKeyboard: false, keyboard: mainMenu(userExists)));
  });

  teledart.onCommand('about').listen((message) => reply(message,
      "Konnected acts as an intermediary between providers and consumers. 🎩\n\n🛍 Any products or services wanted by a consumer are broadcast to our whole network of local and global providers.\n\n🏬 Providers can then offer and discuss details about the deal with the consumer.\n\n🚨 Disclaimer: Conducting any kind of business on the internet carries the risk of deception and fraud, Konnected is not responsible for the behaviours or deals done between providers and consumers. Always be cautious and do your own research before proceeding with a deal.\n\n❓Send /help to talk to our support team at any time."));
  teledart.onCommand('regions').listen((message) => reply(message,
      "Konnected is available in a wide range of countries in North America, South America, Europe, Mena, Africa, Asia, and Oceania. 🌎"));
  teledart.onCommand('safety').listen((message) => reply(message,
      "All the data exchanged between providers and consumers through Konnected bots is encrypted and exclusive to each individual on their device. 🔐\n\nKonnected does not store any deal's data. 🙅‍♂️"));
  teledart.onCommand('bots').listen((message) => reply(message,
      "Our middle-man bots are automated programs that forward data between providers and consumers. 🤖\n\n🛋 Lobby: ${FirestoreUtils.lobbyBot}\n\n🛍 Consumers: ${FirestoreUtils.consumerBot}\n\n🏬 Providers: ${FirestoreUtils.providerBot}\n\n🛟 Support: ${FirestoreUtils.supportBot}"));

  teledart.onCommand('begin').listen((message) async {
    bool userExists = await FirestoreUtils.fetchUserExists(message);
    if (userExists) {
      reply(message,
          "You already have a Konnected profile, type /me to manage your account. 👤");
    } else {
      FirestoreUtils.begin(message, regions(true));
    }
  });

  teledart.onCommand('selectregion').listen((message) {
    reply(
      message,
      "Pick your region",
      replyMarkup:
          ReplyKeyboardMarkup(oneTimeKeyboard: false, keyboard: regions(true)),
    );
  });

  teledart.onCommand('changeregion').listen((message) async {
    if (message.text! == "/changeregion") {
      reply(
        message,
        "Pick your region",
        replyMarkup: ReplyKeyboardMarkup(
            oneTimeKeyboard: false, keyboard: regions(true)),
      );
    } else {
      FirestoreUtils.setRegion(message);
      reply(
        message,
        "Choose your country",
        replyMarkup: ReplyKeyboardMarkup(
            oneTimeKeyboard: false,
            keyboard: konnected.giveCountriesInRegion(message.text!, true)),
      );
    }
  });

  teledart.onCommand('changecountry').listen((message) async {
    FirestoreUtils.setCountry(message);
    reply(
      message,
      "Would you like to transact globally?",
      replyMarkup: ReplyKeyboardMarkup(oneTimeKeyboard: false, keyboard: [
        [KeyboardButton(text: "Yes  [/enableglobal]")],
        [KeyboardButton(text: "No  [/disableglobal]")],
        konnected.mainMenuButton(),
      ]),
    );
  });

  teledart.onCommand('enableglobal').listen((message) async {
    FirestoreUtils.enableGlobal(message);
    reply(
      message,
      "Choose your role:\n\n🛍 Consumer: A user who wants to make requests locally or globally\n\n🏬 Provider: A product or service provider who can supply a consumer's requests\n\n↕️ Dual Role: A user who can be on both ends of the bargain",
      replyMarkup: ReplyKeyboardMarkup(oneTimeKeyboard: false, keyboard: [
        [KeyboardButton(text: "Provider  [/setrole provider]")],
        [KeyboardButton(text: "Consumer  [/setrole consumer]")],
        [KeyboardButton(text: "Dual Role  [/setrole dual]")],
        konnected.mainMenuButton(),
      ]),
    );
  });

  teledart.onCommand('disableglobal').listen((message) async {
    FirestoreUtils.disableGlobal(message);
    reply(
      message,
      "Choose your role:\n\n🛍 Consumer: A user who wants to make requests locally or globally\n\n🏬 Provider: A product or service provider who can supply a consumer's requests\n\n↕️ Dual Role: A user who can be on both ends of the bargain",
      replyMarkup: ReplyKeyboardMarkup(oneTimeKeyboard: false, keyboard: [
        [KeyboardButton(text: "Provider  [/setrole provider]")],
        [KeyboardButton(text: "Consumer  [/setrole consumer]")],
        [KeyboardButton(text: "Dual Role  [/setrole dual]")],
        konnected.mainMenuButton(),
      ]),
    );
  });

  teledart.onCommand('setrole').listen((message) async {
    FirestoreUtils.setRole(message);
  });

  teledart.onCommand('me').listen((message) async {
    FirestoreUtils.showProfile(message);
  });

  teledart.onCommand('help').listen((message) async {
    reply(message,
        "If you are facing trouble while using Konnected, open a support ticket with ${FirestoreUtils.supportBot}");
  });

  // teledart.onCommand('deleteme').listen((message) {
  //   reply(message,
  //     'Are your sure you want to delete your Konnected profile? Your account and your subscription cannot be recovered once your profile is deleted.',
  //     replyMarkup: ReplyKeyboardMarkup(oneTimeKeyboard: false, keyboard: [
  //       [KeyboardButton(text: "Yes, delete me  [/deletesure]")],
  //       konnected.mainMenuButton(),
  //     ]),
  //   );
  // });

  // teledart.onCommand('deletesure').listen((message) {
  //   FirestoreUtils.deleteProfile(message);
  // });

  teledart.onCommand('pricing').listen((message) {
    reply(message,
        "Subscription Plans:\n\n🛍 Consumer: £14/month\n\n🏬 Provider: £14/month\n\n↕️ Dual: £20/month\n\nAll first time users qualify for a 50% discount on their first month.\n\nAny user with a valid referral code qualifies for another 1-time 50% discount.\n\nYou will be credited with a 10% discount on your subsequent subscription for any subscriber who redeems your referral code on their second subscription.(capped at 50%)\n\nTo check out your subscription details and renew your subscription plan type /subscription");
  });

  teledart.onCommand('subscription').listen((message) {
    FirestoreUtils.fetchSubscriptionDetails(message);
  });

  teledart.onCommand('subscribeconsumer').listen((message) {
    //TODO HANDLE CONSUMER SUBSCRIPTION IF FIRST MONTH OR NOT
    FirestoreUtils.renewConsumerSubscription(message, products);
  });

  teledart.onCommand('subscribeprovider').listen((message) {
    //TODO HANDLE PROVIDER SUBSCRIPTION IF FIRST MONTH OR NOT
    FirestoreUtils.renewProviderSubscription(message, products);
  });

  teledart.onCommand('subscribedual').listen((message) {
    //TODO HANDLE DUAL SUBSCRIPTION IF FIRST MONTH OR NOT
    FirestoreUtils.renewDualSubscription(message, products);
  });

  teledart.onCommand('profilechangeregion').listen((message) {
    reply(
      message,
      "Pick your region",
      replyMarkup:
          ReplyKeyboardMarkup(oneTimeKeyboard: false, keyboard: regions(false)),
    );
  });

  teledart.onCommand('setprofileregion').listen((message) {
    FirestoreUtils.setRegion(message);
    reply(message, "Type /me to go back to managing your profile.");
  });

  teledart.onCommand('profilechangecountry').listen((message) async {
    final profile = await FirestoreUtils.fetchProfile(message);
    final region = profile?["Region"] ?? "None";
    if (region != "None") {
      final region2 = "$region]";
      reply(
        message,
        "Choose your country",
        replyMarkup: ReplyKeyboardMarkup(
            oneTimeKeyboard: false,
            keyboard: konnected.giveCountriesInRegion(region2, false)),
      );
    } else {
      reply(
        message,
        "Your profile has not been set up properly, type /me to learn more.",
      );
    }
  });

  teledart.onCommand('setprofilecountry').listen((message) {
    FirestoreUtils.setCountry(message);
    reply(message, "Type /me to go back to managing your profile.");
  });

  teledart.onCommand('profilechangerole').listen((message) {
    reply(
      message,
      "Choose your role:\n\n🛍 Consumer: A user who wants to make requests locally or globally\n\n🏬 Provider: A product or service provider who can supply a consumer's requests\n\n↕️ Dual Role: A user who can be on both ends of the bargain",
      replyMarkup: ReplyKeyboardMarkup(oneTimeKeyboard: false, keyboard: [
        [KeyboardButton(text: "Provider  [/setprofilerole provider]")],
        [KeyboardButton(text: "Consumer  [/setprofilerole consumer]")],
        [KeyboardButton(text: "Dual Role  [/setprofilerole dual]")],
        konnected.mainMenuButton(),
      ]),
    );
  });

  teledart.onCommand('setprofilerole').listen((message) {
    FirestoreUtils.setRole(message);
    reply(message, "Type /me to go back to managing your profile.");
  });

  teledart.onCommand('profileglobalmode').listen((message) {
    reply(
      message,
      "Would you like to transact globally?",
      replyMarkup: ReplyKeyboardMarkup(oneTimeKeyboard: false, keyboard: [
        [KeyboardButton(text: "Yes  [/profileenableglobal]")],
        [KeyboardButton(text: "No  [/profiledisableglobal]")],
        konnected.mainMenuButton(),
      ]),
    );
  });

  teledart.onCommand('profileenableglobal').listen((message) {
    FirestoreUtils.enableGlobal(message);
    reply(message, "Type /me to go back to managing your profile.");
  });

  teledart.onCommand('profiledisableglobal').listen((message) {
    FirestoreUtils.disableGlobal(message);
    reply(message, "Type /me to go back to managing your profile.");
  });

  teledart.onCommand('ping').listen((message) {
    reply(message, "pong");
  });

  //TODO HANDLE LISTENING FOR BROADCAST MESSAGES
  FirestoreUtils.listenForBroadcasts(teledart);
}

/*
Commands: 
me - My profile
about - How does it work
more - Show more info
main - Show main menu
regions - Where is Konnected available
safety - Is any data collected
bots - What are Konnected bots
changeregion - Change my location
changecountry - Change my country
selectregion - Select my region
setrole - Set my Konnected role
enableglobal - Allow global mode
disableglobal - Disable global mode
pricing - Learn about pricing plans
subscription - Manage my suscription
subscribeconsumer - Renew consumer plan
subscribeprovider - Renew provider plan
subscribedual - Renew dual plan
help - Get help from Konnected admins
profilechangeregion - Change profile region
profilechangecountry - Change profile country
profilechangerole - Change profile role
profileglobalmode - Change profile global mode
profileenableglobal - Enable Profile Global mode
profiledisableglobal - Disable Profile Global mode
setprofilerole - Set profile role
setprofileregion - Set profile region
setprofilecountry - Set Profile country
ping - Status


deleteme - Delete my Konnected profile
deletesure - Delete profile for sure
  */

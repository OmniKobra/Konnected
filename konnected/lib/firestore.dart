import 'dart:io';

import 'package:konnected/konnected.dart' as konnected;
import 'package:dart_firebase_admin/firestore.dart';
import 'package:dart_firebase_admin/dart_firebase_admin.dart' as core;
import 'package:intl/intl.dart';
import 'stripe.dart';
import 'package:teledart/model.dart' hide File;
import 'package:teledart/teledart.dart';
import 'package:firedart/firedart.dart' as firedart;
// import 'package:shared_preferences/shared_preferences.dart';

class FirestoreUtils {
  static final admin = core.FirebaseAdminApp.initializeApp(
      'konnected-97cf9',
      core.Credential.fromServiceAccount(File(
          'C:\\Users\\Administrator\\Desktop\\Telly\\service-account.json')));
  static final firestore = Firestore(admin);
  static const String foot =
      "\n\nType /main to go back to the main menu.\nType /me to manage your profile.\nType /help to contact a support admin.\n\nFor consumers: Speak to @konnectedconsumers\\_bot\n\nFor providers: speak to @konnectedproviders\\_bot\n";
  static final formatter = DateFormat('yyyy-MM-dd HH:mm UTC');
  static RegExp regex = RegExp(r'^(?!\.\.?$)(?!.*__.*__)([^/]{1,1500})$');

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

  //TODO STORE ALL BOT NAMES
  static const lobbyBot = "@konnectedlobby_bot";
  static const String supportBot = "@konnectedsupport_bot";
  static const String consumerBot = "@konnectedconsumers_bot";
  static const String providerBot = "@konnectedproviders_bot";
  static const String reportBot = "@konnectedreports_bot";
  static const String managerBot = "@konnectedmanagers_bot";

  static const String disclaimer =
      "🚨Disclaimer: Transacting on the internet comes with the risk of falling victim to fraud, crimes, or danger. Konnected holds no responsibility for the actions of its users or any actions performed by individuals using Konnected. All users are advised to do their own due diligence towards any requests or offers received on Konnected.";

  static void showLoading(TeleDartMessage message) =>
      reply(message, "Loading, please wait.. ⏳");
  static void showError(TeleDartMessage message) =>
      reply(message, "An error has occured.. 😬$foot", parseMode: 'Markdown');
  static void showSuccess(TeleDartMessage message, String operation) =>
      reply(message, "✅ Success, $operation $foot", parseMode: 'Markdown');

  static void showNoProfile(TeleDartMessage message) => reply(message,
      'You do not have a Konnected profile, type /begin to create a profile. 👤');

  static String getUID(TeleDartMessage message) => message.from!.id.toString();

  static DateTime nowUtc() => DateTime.now().toUtc();

  static String extractRegion(TeleDartMessage message) {
    final String text = message.text!;
    String extractedText = "None";
    if (text.contains("[") && text.contains("]")) {
      int firstBracket = text.indexOf("[");
      int secondBracket = text.indexOf("]");
      String firstSubstring = text.substring(firstBracket + 1, secondBracket);
      if (firstSubstring.contains("/changeregion ")) {
        String secondString = firstSubstring.replaceFirst("/changeregion ", "");
        extractedText = secondString;
      } else if (firstSubstring.contains("/setprofileregion ")) {
        String secondString =
            firstSubstring.replaceFirst("/setprofileregion ", "");
        extractedText = secondString;
      } else {
        reply(message, "Unrecognized command pattern, please try again");
      }
      return extractedText;
    } else {
      if (text.contains("/changeregion ")) {
        String secondString = text.replaceFirst("/changeregion ", "");
        extractedText = secondString;
      } else if (text.contains("/setprofileregion ")) {
        String secondString = text.replaceFirst("/setprofileregion ", "");
        extractedText = secondString;
      } else {
        reply(message, "Unrecognized command pattern, please try again");
      }
      return extractedText;
    }
  }

  static String extractCountry(TeleDartMessage message) {
    final String text = message.text!;
    String extractedText = "None";
    if (text.contains("[") && text.contains("]")) {
      int firstBracket = text.indexOf("[");
      int secondBracket = text.indexOf("]");
      String firstSubstring = text.substring(firstBracket + 1, secondBracket);
      if (firstSubstring.contains("/changecountry ")) {
        String secondString =
            firstSubstring.replaceFirst("/changecountry ", "");
        extractedText = secondString;
      } else if (firstSubstring.contains("/setprofilecountry ")) {
        String secondString =
            firstSubstring.replaceFirst("/setprofilecountry ", "");
        extractedText = secondString;
      } else {
        reply(message, "Unrecognized command pattern, please try again");
      }
      return extractedText;
    } else {
      if (text.contains("/changecountry ")) {
        String secondString = text.replaceFirst("/changecountry ", "");
        extractedText = secondString;
      } else if (text.contains("/setprofilecountry ")) {
        String secondString = text.replaceFirst("/setprofilecountry ", "");
        extractedText = secondString;
      } else {
        reply(message, "Unrecognized command pattern, please try again");
      }
      return extractedText;
    }
  }

  static String extractRole(TeleDartMessage message) {
    final String text = message.text!;
    String extractedText = "None";
    if (text.contains("[") && text.contains("]")) {
      int firstBracket = text.indexOf("[");
      int secondBracket = text.indexOf("]");
      String firstSubstring = text.substring(firstBracket + 1, secondBracket);
      if (firstSubstring.contains("/setrole ")) {
        String secondString = firstSubstring.replaceFirst("/setrole ", "");
        extractedText = secondString;
      } else if (firstSubstring.contains("/setprofilerole ")) {
        String secondString =
            firstSubstring.replaceFirst("/setprofilerole ", "");
        extractedText = secondString;
      } else {
        reply(message, "Unrecognized command pattern, please try again");
      }
      return extractedText;
    } else {
      if (text.contains("/setrole ")) {
        String secondString = text.replaceFirst("/setrole ", "");
        extractedText = secondString;
      } else if (text.contains("/setprofilerole ")) {
        String secondString = text.replaceFirst("/setprofilerole ", "");
        extractedText = secondString;
      } else {
        reply(message, "Unrecognized command pattern, please try again");
      }
      return extractedText;
    }
  }

  static String timestampToString(Timestamp? timestamp) {
    DateTime? dateJoinedConverted = timestamp == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(timestamp.seconds * 1000,
            isUtc: true);
    DateTime? dateJoinedConvertedLocal = dateJoinedConverted?.toLocal();
    String formattedDate = dateJoinedConvertedLocal == null
        ? "None"
        : formatter.format(dateJoinedConvertedLocal);
    return formattedDate;
  }

  static DateTime? timestampToDate(Timestamp? timestamp) {
    return timestamp == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(timestamp.seconds * 1000,
                isUtc: true)
            .toLocal();
  }

  static DateTime nowHere() => DateTime.now();

  // static DateTime timestampToDate(Timestamp timestamp) =>
  //     DateTime.fromMillisecondsSinceEpoch(timestamp.seconds * 1000,
  //         isUtc: true);

  static Future<void> handleUserExistenceOp(
      TeleDartMessage message, Future<void> Function() continuation) async {
    bool userExists = await fetchUserExists(message);
    if (userExists) {
      continuation();
    } else {
      showNoProfile(message);
    }
  }

  static Future<bool> fetchUserExists(TeleDartMessage message) async {
    showLoading(message);
    final userID = getUID(message);
    final docSnapshot = await firestore.doc("Lobby/$userID").get();
    return docSnapshot.exists;
  }

  static Future<Map<String, Object?>?> fetchProfile(
      TeleDartMessage message) async {
    final userID = getUID(message);
    final docSnapshot = await firestore.doc("Lobby/$userID").get();
    return docSnapshot.data();
  }

  static void showProfile(TeleDartMessage message) {
    Future<void> continuation() async {
      final userID = getUID(message);
      Map<String, Object?>? profile = await fetchProfile(message);
      var region = profile!["Region"] ?? "None";
      var country = profile["Country"] ?? "None";
      var role = profile["Role"] ?? "None";
      var subscriptionRole = profile["subscriptionRole"] ?? "None";
      var global = profile["Global"] ?? "None";
      var globalMode = global == "None"
          ? "None"
          : global == true
              ? "Enabled"
              : "Disabled";
      var dateJoined = profile["dateJoined"] ?? "None";
      Timestamp? timestamp =
          dateJoined != "None" ? dateJoined as Timestamp : null;
      String formattedJoinDate = timestampToString(timestamp);
      var dateSubscribed = profile["dateSubscribed"] ?? "None";
      Timestamp? subscribeTimestamp =
          dateSubscribed != "None" ? dateSubscribed as Timestamp : null;
      String formattedSubscribeDate = timestampToString(subscribeTimestamp);
      final String currentReferralCode = profile["referralCode"] as String;
      reply(
        message,
        "My Profile Details:\n\n🌎 Region: $region\n📍 Country: $country\n🎭 Role: $role\n🌐 Global Mode: $globalMode\n🗓 Date Joined: $formattedJoinDate\n⏲️ Subscription Date: $formattedSubscribeDate\n💼 Subscription Role: $subscriptionRole\n🔄 Referrer: $currentReferralCode\n\nYour referral code is __`$userID`__ \nTap your referral code to copy it.",
        replyMarkup: ReplyKeyboardMarkup(oneTimeKeyboard: false, keyboard: [
          [KeyboardButton(text: "⏲️ Subscription  [/subscription]")],
          [KeyboardButton(text: "🌎 Region  [/profilechangeregion]")],
          [KeyboardButton(text: "📍 Country  [/profilechangecountry]")],
          [KeyboardButton(text: "💼 Role  [/profilechangerole]")],
          [KeyboardButton(text: "🌐 Globalist  [/profileglobalmode]")],
          // [KeyboardButton(text: "🗑 Delete My Profile  [/deleteme]")],
          konnected.mainMenuButton(),
        ]),
        parseMode: 'Markdown',
      );
    }

    handleUserExistenceOp(message, continuation);
  }

  static Future<void> begin(
      TeleDartMessage message, List<List<KeyboardButton>> regions) async {
    final userID = getUID(message);
    final userDoc = firestore.doc("Lobby/$userID");
    final beginningDate = nowUtc();
    final endDate = beginningDate.add(Duration(days: 3));
    userDoc.set({
      "chatID": message.chat.id,
      "userID": userID,
      "dateJoined": beginningDate,
      "dateTrialStart": beginningDate,
      "dateTrialEnd": endDate,
      "dateSubscriptionEnd": endDate,
      "isPermanentlySubscribed": false,
      "firstMonthCharged": false,
      "secondMonthCharged": false,
      "Country": "None",
      "Global": false,
      "Role": "None",
      "referrals": 0,
      "latestSubAmount": 0.0,
      "referralCode": "None",
      "transaction": "None",
      "isBanned": false,
    }).then((_) {
      showSuccess(message,
          "\n🚦 Your Konnected profile has been created, follow the next steps to complete your registration.\n\n🏁 Your Konnected 3-day free trial has begun. Additionally, your first month of subscription will have a 50% discount.\n\nShare with your friends using your referral code and they’ll get 50% off for 2 months. And you’ll get 10% off for helping them join (Monthly 10% accumulative limit: 5) Just tap it below and share!\nYour referral code is: __`$userID`__");
      reply(
        message,
        "Pick your region",
        replyMarkup:
            ReplyKeyboardMarkup(oneTimeKeyboard: false, keyboard: regions),
      );
    }).catchError((_) {
      showError(message);
    });
  }

  static void setRegion(TeleDartMessage message) {
    Future<void> continuation() async {
      final userID = getUID(message);
      final userDoc = firestore.doc("Lobby/$userID");
      final extractedRegion = extractRegion(message);
      final emptySpacer = extractedRegion.replaceAll(" ", "");
      if (extractedRegion != "None" && emptySpacer != "") {
        userDoc.update({
          "Region": extractedRegion,
          "chatID": message.chat.id,
          "userID": userID
        }).then((_) {
          showSuccess(message, "Region set to: $extractedRegion");
        }).catchError((_) {
          showError(message);
        });
      }
    }

    handleUserExistenceOp(message, continuation);
  }

  static void setCountry(TeleDartMessage message) {
    Future<void> continuation() async {
      final userID = getUID(message);
      final userDoc = firestore.doc("Lobby/$userID");
      final extractedCountry = extractCountry(message);
      final emptySpacer = extractedCountry.replaceAll(" ", "");
      if (extractedCountry != "None" && emptySpacer != "") {
        userDoc.update({
          "Country": extractedCountry,
          "chatID": message.chat.id,
          "userID": userID
        }).then((_) {
          showSuccess(message, "Country set to: $extractedCountry");
        }).catchError((_) {
          showError(message);
        });
      }
    }

    handleUserExistenceOp(message, continuation);
  }

  static void setRole(TeleDartMessage message) {
    Future<void> continuation() async {
      final userID = getUID(message);
      final userDoc = firestore.doc("Lobby/$userID");
      final extractedRole = extractRole(message);
      final emptySpacer = extractedRole.replaceAll(" ", "");
      if (extractedRole != "None" && emptySpacer != "") {
        userDoc.update({
          "Role": extractedRole,
          "chatID": message.chat.id,
          "userID": userID
        }).then((_) {
          showSuccess(message, "Role set to: $extractedRole");
          reply(message,
              "🛍 To make local or global requests as a consumer talk to ${FirestoreUtils.consumerBot}\n\n🏬 To start receiving requests locally or globally as a provider talk to ${FirestoreUtils.providerBot}");
        }).catchError((_) {
          showError(message);
        });
      }
    }

    handleUserExistenceOp(message, continuation);
  }

  static void enableGlobal(TeleDartMessage message) {
    Future<void> continuation() async {
      final userID = getUID(message);
      final userDoc = firestore.doc("Lobby/$userID");
      userDoc.update({
        "Global": true,
        "chatID": message.chat.id,
        "userID": userID
      }).then((_) {
        showSuccess(
            message, "Global mode enabled - you can now transact globally 🌏");
      }).catchError((_) {
        showError(message);
      });
    }

    handleUserExistenceOp(message, continuation);
  }

  static void disableGlobal(TeleDartMessage message) {
    Future<void> continuation() async {
      final userID = getUID(message);
      final userDoc = firestore.doc("Lobby/$userID");
      userDoc.update({
        "Global": false,
        "chatID": message.chat.id,
        "userID": userID
      }).then((_) {
        showSuccess(message,
            "Global mode disabled - you can no longer transact globally ❌ 🌏");
      }).catchError((_) {
        showError(message);
      });
    }

    handleUserExistenceOp(message, continuation);
  }

  // static void deleteProfile(TeleDartMessage message) {
  //   Future<void> continuation() async {
  //     final userID = getUID(message);
  //     final userDoc = firestore.doc("Lobby/$userID");
  //     userDoc.delete().then((_) {
  //       showSuccess(message, "Your profile has been deleted from Konnected 🗑");
  //     }).catchError((_) {
  //       showError(message);
  //     });
  //   }

  //   handleUserExistenceOp(message, continuation);
  // }

  static void fetchSubscriptionDetails(TeleDartMessage message) {
    Future<void> continuation() async {
      var profile = await fetchProfile(message);

      var trialStartDate = profile!["dateTrialStart"] ?? "None";
      Timestamp? trialTimestamp =
          trialStartDate != "None" ? trialStartDate as Timestamp : null;
      String formattedTrialStartDate = timestampToString(trialTimestamp);

      var dateSubscribed = profile["dateSubscribed"] ?? "None";
      Timestamp? subscribeTimestamp =
          dateSubscribed != "None" ? dateSubscribed as Timestamp : null;
      String formattedSubscribeDate = timestampToString(subscribeTimestamp);

      var referralCount = profile["referrals"] as int;
      var discountAmount = referralCount > 5 ? 50 : referralCount * 10;

      var subscriptionRole = profile["subscriptionRole"] ?? "None";

      DateTime? subscriptionDateTime = formattedSubscribeDate == "None"
          ? null
          : timestampToDate(subscribeTimestamp);
      DateTime? subscriptionTerminationDateTime =
          subscriptionDateTime?.add(Duration(days: 30));
      String formattedSubscriptionTermination =
          subscriptionTerminationDateTime == null
              ? "None"
              : formatter.format(subscriptionTerminationDateTime);

      DateTime? trialDateTime = formattedTrialStartDate == "None"
          ? null
          : timestampToDate(trialTimestamp);
      DateTime? trialTerminationDateTime =
          trialDateTime?.add(Duration(days: 3));
      String formattedTrialTermination = trialTerminationDateTime == null
          ? "None"
          : formatter.format(trialTerminationDateTime);
      reply(message,
          "Subscription Details:\n\n🚦 Trial Start Date: $formattedTrialStartDate\n\n🚩 Trial End Date: $formattedTrialTermination\n\n🏁 Subscription Start Date:$formattedSubscribeDate\n\n🚩 Subscription End Date: $formattedSubscriptionTermination\n\n🎭 Role of Subscription: $subscriptionRole\n🎟 Referrals: $referralCount\n🤑 Referrals Discount: %$discountAmount\n\n🛍 To subscribe as a consumer, type /subscribeconsumer\n\n🏬 To subscribe as a provider, type /subscribeprovider\n\n↕️ To subscribe as a dual role, type /subscribedual\n\nIf you have a referral code type it after the command.\n\nEx: '/subscribedual 1234567890'");
    }

    handleUserExistenceOp(message, continuation);
  }

  static Future<bool> checkIsAllowed(TeleDartMessage message) async {
    bool timeoutActive = false;
    bool isBanned = false;
    bool profileExists = await fetchUserExists(message);
    if (profileExists) {
      Map<String, Object?>? profile = await fetchProfile(message);
      var dateTimedOut = profile!["dateTimeout"] ?? "None";
      var timeoutDuration = profile["timeoutDuration"] ?? "None";
      Timestamp? timeoutTimestamp =
          dateTimedOut != "None" ? dateTimedOut as Timestamp : null;
      if (timeoutTimestamp != null) {
        DateTime timeoutDateTime = timestampToDate(timeoutTimestamp)!;
        var now = nowHere();
        var difference = now.difference(timeoutDateTime);
        var differenceDays = difference.inDays;
        var durationInt = timeoutDuration as int;
        timeoutActive = differenceDays < durationInt && durationInt > 0;
        if (timeoutActive) {
          DateTime timeoutEndDate =
              timeoutDateTime.add(Duration(days: durationInt));
          String formattedEndDate = formatter.format(timeoutEndDate);
          reply(message,
              "You have been timed-out $durationInt day(s) for violating our Terms & Guidelines. Your time-out ends on: $formattedEndDate");
        }
      }
      var databaseBanned = profile["isBanned"] ?? false;
      isBanned = databaseBanned as bool;
      if (isBanned) {
        reply(message,
            "You have been permanently banned for violating our Terms & Guidelines. If you feel this was a mistake, contact support at $supportBot");
      }
    }
    return !timeoutActive && !isBanned;
  }

  static Future<void> renewConsumerSubscription(
      TeleDartMessage message, List<MyStripeProduct> products) async {
    Future<void> continuation() async {
      var allowed = await checkIsAllowed(message);
      if (allowed) {
        double firstPercent = 1.0;
        bool referrerValid = false;
        void Function() resetReferrals = () {};
        void Function() updateReferrerDoc = () {};
        final referralCode =
            message.text!.trim().replaceFirst("/subscribeconsumer", "").trim();
        if (referralCode.isNotEmpty && regex.hasMatch(referralCode)) {
          final getReferrer = await firestore.doc("Lobby/$referralCode").get();
          referrerValid = getReferrer.exists;
        }
        final userID = getUID(message);
        if (referralCode == userID) {
          reply(message,
              "⁉️ Invalid referral code, you cannot use your own referral code.");
        } else {
          if (referralCode.isNotEmpty && !referrerValid) {
            reply(message,
                "❌ Invalid referral code, this referral code does not exist.");
          } else {
            double amountToPay = 14.00;
            final userDoc = firestore.doc("Lobby/$userID");
            final getUser = await fetchProfile(message);
            final bool hasBeenChargedFirstMonth =
                getUser!["firstMonthCharged"] as bool;
            final bool hasBeenChargedSecondMonth =
                getUser["secondMonthCharged"] as bool;
            final int referrals = getUser["referrals"] as int;
            final String currentReferralCode =
                getUser["referralCode"] as String;
            if (hasBeenChargedFirstMonth) {
              if ((currentReferralCode != "None" &&
                      !hasBeenChargedSecondMonth) ||
                  (referrerValid &&
                      currentReferralCode == "None" &&
                      !hasBeenChargedSecondMonth)) {
                amountToPay = amountToPay / 2;
                String referrerToBeCredited = currentReferralCode != "None"
                    ? currentReferralCode
                    : referralCode;
                final referrerDoc =
                    firestore.doc("Lobby/$referrerToBeCredited");
                updateReferrerDoc = () {
                  referrerDoc
                      .update({"referrals": FieldValue.increment(1)})
                      .then((_) {})
                      .catchError((_) {});
                };
                reply(message,
                    "🤑 Due to the referral code provided, you are eligible for another 50% discount.");
              } else {
                if (referrals > 0) {
                  double referralPercentage = 0.0;
                  if (referrals > 5) {
                    firstPercent -= 0.5;
                    referralPercentage = 0.5;
                  } else {
                    referralPercentage = referrals * 0.1;
                    firstPercent -= referralPercentage;
                  }
                  resetReferrals = () {
                    userDoc
                        .update({"referrals": 0})
                        .then((_) {})
                        .catchError((_) {});
                  };
                  var discountPercent = referralPercentage * 100;
                  reply(message,
                      "🤑 You have referred $referrals subscribers this month, You qualify for a %${discountPercent.toStringAsFixed(0)} discount (capped at 50%).\nYour referrals will be reset after you subscribe.");
                }
                amountToPay *= firstPercent;
              }
            } else {
              amountToPay = amountToPay / 2;
              reply(message,
                  "🤑 Since its your first month subscribing to Konnected, you will benefit from a %50 discount.");
            }
            reply(message,
                "You will now be charged £${amountToPay.toStringAsFixed(2)} through Stripe.");
            String amountString = amountToPay.toStringAsFixed(2);
            double amountDouble = double.parse(amountString);
            MyStripeProduct product = StripeUtils.matchSubtoProduct(
                "KONNECTED", amountDouble, products);
            List<dynamic> generatedPayment =
                await StripeUtils.generatePaymentLink(product.priceID);
            final String paymentUrl = generatedPayment[0];
            final String paymentID = generatedPayment[1];
            final DateTime expiration = generatedPayment[2];
            final rn = nowHere();
            final difference = expiration.difference(rn);
            final differenceMinutes = difference.inMinutes;
            final String formattedExpiration = formatter.format(expiration);
            reply(message, "Payment ID: __`$paymentID`__",
                parseMode: 'Markdown');
            reply(message,
                "💳 Your payment link is:\n\n$paymentUrl\n\nIt is valid for $differenceMinutes minutes until $formattedExpiration\n\nYour subscription will automatically be renewed after the payment is confirmed (takes approx. 2 mins).");
            final dateStart = nowUtc();
            final dateEnd = dateStart.add(Duration(days: 30));
            final dateEndHere = dateEnd.toLocal();
            final formattedEndDate = formatter.format(dateEndHere);
            String status = "open";
            bool isPaid = false;
            for (var i = 1; i <= 35; i++) {
              Future.delayed(Duration(minutes: i), () async {
                if (!isPaid) {
                  status = await StripeUtils.checkIsExpiredOrComplete(
                      paymentID, message);
                  if (status == "open" || (status == "complete" && !isPaid)) {
                    isPaid = await StripeUtils.checkHasBeenPaid(paymentID);
                    if (isPaid) {
                      userDoc.update({
                        "subscriptionRole": "consumer",
                        "Role": "consumer",
                        "dateSubscribed": dateStart,
                        "dateSubscriptionEnd": dateEnd,
                        "latestSubAmount": amountDouble,
                        "transaction": paymentID,
                        if (!hasBeenChargedFirstMonth)
                          "firstMonthCharged": true,
                        if (hasBeenChargedFirstMonth &&
                            !hasBeenChargedSecondMonth &&
                            (currentReferralCode != "None" || referrerValid))
                          "secondMonthCharged": true,
                        if (referrerValid &&
                            referralCode != userID &&
                            currentReferralCode == "None")
                          "referralCode": referralCode,
                      }).then((_) async {
                        updateReferrerDoc();
                        resetReferrals();
                        showSuccess(message,
                            "✅ 🛍 Your consumer subscription has been activated and will remain valid until $formattedEndDate");
                        reply(message,
                            "🛍 To make local or global requests as a consumer talk to ${FirestoreUtils.consumerBot}");
                        await firestore
                            .doc("Info/Details")
                            .update(
                                {"balance": FieldValue.increment(amountDouble)})
                            .then((_) {})
                            .catchError((_) {});
                      }).catchError((_) {
                        showError(message);
                        reply(message,
                            "Contact support at $supportBot and provide your payment ID to resolve your consumer subscription renewal issues.");
                      });
                    }
                  }
                }
              });
            }
          }
        }
      }
    }

    handleUserExistenceOp(message, continuation);
  }

  static Future<void> renewProviderSubscription(
      TeleDartMessage message, List<MyStripeProduct> products) async {
    Future<void> continuation() async {
      var allowed = await checkIsAllowed(message);
      if (allowed) {
        double firstPercent = 1.0;
        bool referrerValid = false;
        void Function() resetReferrals = () {};
        void Function() updateReferrerDoc = () {};
        final referralCode =
            message.text!.trim().replaceFirst("/subscribeprovider", "").trim();
        if (referralCode.isNotEmpty && regex.hasMatch(referralCode)) {
          final getReferrer = await firestore.doc("Lobby/$referralCode").get();
          referrerValid = getReferrer.exists;
        }
        final userID = getUID(message);
        if (referralCode == userID) {
          reply(message,
              "⁉️ Invalid referral code, you cannot use your own referral code.");
        } else {
          if (referralCode.isNotEmpty && !referrerValid) {
            reply(message,
                "❌ Invalid referral code, this referral code does not exist.");
          } else {
            double amountToPay = 14.00;
            final userDoc = firestore.doc("Lobby/$userID");
            final getUser = await fetchProfile(message);
            final bool hasBeenChargedFirstMonth =
                getUser!["firstMonthCharged"] as bool;
            final bool hasBeenChargedSecondMonth =
                getUser["secondMonthCharged"] as bool;
            final int referrals = getUser["referrals"] as int;
            final String currentReferralCode =
                getUser["referralCode"] as String;
            if (hasBeenChargedFirstMonth) {
              if ((currentReferralCode != "None" &&
                      !hasBeenChargedSecondMonth) ||
                  (referrerValid &&
                      currentReferralCode == "None" &&
                      !hasBeenChargedSecondMonth)) {
                amountToPay = amountToPay / 2;
                String referrerToBeCredited = currentReferralCode != "None"
                    ? currentReferralCode
                    : referralCode;
                final referrerDoc =
                    firestore.doc("Lobby/$referrerToBeCredited");
                updateReferrerDoc = () {
                  referrerDoc
                      .update({"referrals": FieldValue.increment(1)})
                      .then((_) {})
                      .catchError((_) {});
                };
                reply(message,
                    "🤑 Due to the referral code provided, you are eligible for another 50% discount.");
              } else {
                if (referrals > 0) {
                  double referralPercentage = 0.0;
                  if (referrals > 5) {
                    firstPercent -= 0.5;
                    referralPercentage = 0.5;
                  } else {
                    referralPercentage = referrals * 0.1;
                    firstPercent -= referralPercentage;
                  }
                  resetReferrals = () {
                    userDoc
                        .update({"referrals": 0})
                        .then((_) {})
                        .catchError((_) {});
                  };
                  var discountPercent = referralPercentage * 100;
                  reply(message,
                      "🤑 You have referred $referrals subscribers this month, You qualify for a %${discountPercent.toStringAsFixed(0)} discount (capped at 50%).\nYour referrals will be reset after you subscribe.");
                }
                amountToPay *= firstPercent;
              }
            } else {
              amountToPay = amountToPay / 2;
              reply(message,
                  "🤑 Since its your first month subscribing to Konnected, you will benefit from a %50 discount.");
            }
            reply(message,
                "You will now be charged £${amountToPay.toStringAsFixed(2)} through Stripe.");
            String amountString = amountToPay.toStringAsFixed(2);
            double amountDouble = double.parse(amountString);
            MyStripeProduct product = StripeUtils.matchSubtoProduct(
                "KONNECTED", amountDouble, products);
            List<dynamic> generatedPayment =
                await StripeUtils.generatePaymentLink(product.priceID);
            final String paymentUrl = generatedPayment[0];
            final String paymentID = generatedPayment[1];
            final DateTime expiration = generatedPayment[2];
            final rn = nowHere();
            final difference = expiration.difference(rn);
            final differenceMinutes = difference.inMinutes;
            final String formattedExpiration = formatter.format(expiration);
            reply(message, "Payment ID: __`$paymentID`__",
                parseMode: 'Markdown');
            reply(message,
                "💳 Your payment link is:\n\n$paymentUrl\n\nIt is valid for $differenceMinutes minutes until $formattedExpiration\n\nYour subscription will automatically be renewed after the payment is confirmed (takes approx. 2 mins).");
            final dateStart = nowUtc();
            final dateEnd = dateStart.add(Duration(days: 30));
            final dateEndHere = dateEnd.toLocal();
            final formattedEndDate = formatter.format(dateEndHere);
            String status = "open";
            bool isPaid = false;
            for (var i = 1; i <= 35; i++) {
              Future.delayed(Duration(minutes: i), () async {
                if (!isPaid) {
                  status = await StripeUtils.checkIsExpiredOrComplete(
                      paymentID, message);
                  if (status == "open" || (status == "complete" && !isPaid)) {
                    isPaid = await StripeUtils.checkHasBeenPaid(paymentID);
                    if (isPaid) {
                      userDoc.update({
                        "subscriptionRole": "provider",
                        "Role": "provider",
                        "dateSubscribed": dateStart,
                        "dateSubscriptionEnd": dateEnd,
                        "latestSubAmount": amountDouble,
                        "transaction": paymentID,
                        if (!hasBeenChargedFirstMonth)
                          "firstMonthCharged": true,
                        if (hasBeenChargedFirstMonth &&
                            !hasBeenChargedSecondMonth &&
                            (currentReferralCode != "None" || referrerValid))
                          "secondMonthCharged": true,
                        if (referrerValid &&
                            referralCode != userID &&
                            currentReferralCode == "None")
                          "referralCode": referralCode,
                      }).then((_) async {
                        updateReferrerDoc();
                        resetReferrals();
                        showSuccess(message,
                            "✅ 🏬 Your provider subscription has been activated and will remain valid until $formattedEndDate");
                        reply(message,
                            "🏬 To start receiving requests locally or globally as a provider talk to ${FirestoreUtils.providerBot}");
                        await firestore
                            .doc("Info/Details")
                            .update(
                                {"balance": FieldValue.increment(amountDouble)})
                            .then((_) {})
                            .catchError((_) {});
                      }).catchError((_) {
                        showError(message);
                        reply(message,
                            "Contact support at $supportBot and provide your payment ID to resolve your consumer subscription renewal issues.");
                      });
                    }
                  }
                }
              });
            }
          }
        }
      }
    }

    handleUserExistenceOp(message, continuation);
  }

  static Future<void> renewDualSubscription(
      TeleDartMessage message, List<MyStripeProduct> products) async {
    Future<void> continuation() async {
      var allowed = await checkIsAllowed(message);
      if (allowed) {
        double firstPercent = 1.0;
        bool referrerValid = false;
        void Function() resetReferrals = () {};
        void Function() updateReferrerDoc = () {};
        final referralCode =
            message.text!.trim().replaceFirst("/subscribedual", "").trim();
        if (referralCode.isNotEmpty && regex.hasMatch(referralCode)) {
          final getReferrer = await firestore.doc("Lobby/$referralCode").get();
          referrerValid = getReferrer.exists;
        }
        final userID = getUID(message);
        if (referralCode == userID) {
          reply(message,
              "⁉️ Invalid referral code, you cannot use your own referral code.");
        } else {
          if (referralCode.isNotEmpty && !referrerValid) {
            reply(message,
                "❌ Invalid referral code, this referral code does not exist.");
          } else {
            double amountToPay = 20.00;
            final userDoc = firestore.doc("Lobby/$userID");
            final getUser = await fetchProfile(message);
            final bool hasBeenChargedFirstMonth =
                getUser!["firstMonthCharged"] as bool;
            final bool hasBeenChargedSecondMonth =
                getUser["secondMonthCharged"] as bool;
            final int referrals = getUser["referrals"] as int;
            final String currentReferralCode =
                getUser["referralCode"] as String;
            if (hasBeenChargedFirstMonth) {
              if ((currentReferralCode != "None" &&
                      !hasBeenChargedSecondMonth) ||
                  (referrerValid &&
                      currentReferralCode == "None" &&
                      !hasBeenChargedSecondMonth)) {
                amountToPay = amountToPay / 2;
                String referrerToBeCredited = currentReferralCode != "None"
                    ? currentReferralCode
                    : referralCode;
                final referrerDoc =
                    firestore.doc("Lobby/$referrerToBeCredited");
                updateReferrerDoc = () {
                  referrerDoc
                      .update({"referrals": FieldValue.increment(1)})
                      .then((_) {})
                      .catchError((_) {});
                };
                reply(message,
                    "🤑 Due to the referral code provided, you are eligible for another 50% discount.");
              } else {
                if (referrals > 0) {
                  double referralPercentage = 0.0;
                  if (referrals > 5) {
                    firstPercent -= 0.5;
                    referralPercentage = 0.5;
                  } else {
                    referralPercentage = referrals * 0.1;
                    firstPercent -= referralPercentage;
                  }
                  resetReferrals = () {
                    userDoc
                        .update({"referrals": 0})
                        .then((_) {})
                        .catchError((_) {});
                  };
                  var discountPercent = referralPercentage * 100;
                  reply(message,
                      "🤑 You have referred $referrals subscribers this month, You qualify for a %${discountPercent.toStringAsFixed(0)} discount (capped at 50%).\nYour referrals will be reset after you subscribe.");
                }
                amountToPay *= firstPercent;
              }
            } else {
              amountToPay = amountToPay / 2;
              reply(message,
                  "🤑 Since its your first month subscribing to Konnected, you will benefit from a %50 discount.");
            }
            reply(message,
                "You will now be charged £${amountToPay.toStringAsFixed(2)} through Stripe.");
            String amountString = amountToPay.toStringAsFixed(2);
            double amountDouble = double.parse(amountString);
            MyStripeProduct product = StripeUtils.matchSubtoProduct(
                "KONNECTED DUAL", amountDouble, products);
            List<dynamic> generatedPayment =
                await StripeUtils.generatePaymentLink(product.priceID);
            final String paymentUrl = generatedPayment[0];
            final String paymentID = generatedPayment[1];
            final DateTime expiration = generatedPayment[2];
            final rn = nowHere();
            final difference = expiration.difference(rn);
            final differenceMinutes = difference.inMinutes;
            final String formattedExpiration = formatter.format(expiration);
            reply(message, "Payment ID: __`$paymentID`__",
                parseMode: 'Markdown');
            reply(message,
                "💳 Your payment link is:\n\n$paymentUrl\n\nIt is valid for $differenceMinutes minutes until $formattedExpiration\n\nYour subscription will automatically be renewed after the payment is confirmed (takes approx. 2 mins).");
            final dateStart = nowUtc();
            final dateEnd = dateStart.add(Duration(days: 30));
            final dateEndHere = dateEnd.toLocal();
            final formattedEndDate = formatter.format(dateEndHere);
            String status = "open";
            bool isPaid = false;
            for (var i = 1; i <= 35; i++) {
              Future.delayed(Duration(minutes: i), () async {
                if (!isPaid) {
                  status = await StripeUtils.checkIsExpiredOrComplete(
                      paymentID, message);
                  if (status == "open" || (status == "complete" && !isPaid)) {
                    isPaid = await StripeUtils.checkHasBeenPaid(paymentID);
                    if (isPaid) {
                      userDoc.update({
                        "subscriptionRole": "dual",
                        "Role": "dual",
                        "dateSubscribed": dateStart,
                        "dateSubscriptionEnd": dateEnd,
                        "latestSubAmount": amountDouble,
                        "transaction": paymentID,
                        if (!hasBeenChargedFirstMonth)
                          "firstMonthCharged": true,
                        if (hasBeenChargedFirstMonth &&
                            !hasBeenChargedSecondMonth &&
                            (currentReferralCode != "None" || referrerValid))
                          "secondMonthCharged": true,
                        if (referrerValid &&
                            referralCode != userID &&
                            currentReferralCode == "None")
                          "referralCode": referralCode,
                      }).then((_) async {
                        updateReferrerDoc();
                        resetReferrals();
                        showSuccess(message,
                            "✅ ↕️ Your dual subscription has been activated and will remain valid until $formattedEndDate");
                        reply(message,
                            "🛍 To make local or global requests as a consumer talk to ${FirestoreUtils.consumerBot}\n\n🏬 To start receiving requests locally or globally as a provider talk to ${FirestoreUtils.providerBot}");
                        await firestore
                            .doc("Info/Details")
                            .update(
                                {"balance": FieldValue.increment(amountDouble)})
                            .then((_) {})
                            .catchError((_) {});
                      }).catchError((_) {
                        showError(message);
                        reply(message,
                            "Contact support at $supportBot and provide your payment ID to resolve your consumer subscription renewal issues.");
                      });
                    }
                  }
                }
              });
            }
          }
        }
      }
    }

    handleUserExistenceOp(message, continuation);
  }

  static void listenForBroadcasts(TeleDart teledart) async {
    firedart.FirebaseAuth.initialize(
        "AIzaSyCPSi0Kxed6cJzSv5BBrLtVn70OS-cq7gQ", firedart.VolatileStore());
    firedart.FirebaseAuth.instance.signInAnonymously().then((val) {
      firedart.Firestore.initialize("konnected-97cf9");
      var broadcasts = firedart.Firestore.instance.collection("Broadcasts");
      broadcasts.stream.listen((onData) async {
        var newBroadcasts = onData.where((d) {
          final fields = d.map;
          bool hasBeenBroadcast = fields["broadcasted"];
          return hasBeenBroadcast == false;
        }).toList();
        for (var broadcast in newBroadcasts) {
          final users = await firestore.collection("Lobby").get();
          var broadcastFields = broadcast.map;
          var description = broadcastFields["description"];
          for (var user in users.docs) {
            var chatID = user.data()["chatID"];
            try {
              await teledart.sendMessage(chatID,
                  "$description\n\n🔊 To broadcast your promotions speak to @M0N3Y6");
            } catch (e) {
              //
            }
          }
          firestore
              .doc("Broadcasts/${broadcast.id}")
              .update({"broadcasted": true})
              .then((_) {})
              .catchError((_) {});
        }
      });
    });
  }
}

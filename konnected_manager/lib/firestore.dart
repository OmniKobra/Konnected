// import 'dart:async';
import 'dart:async';
import 'dart:io';

import 'package:dart_firebase_admin/firestore.dart';
import 'package:dart_firebase_admin/dart_firebase_admin.dart' as core;
import 'package:intl/intl.dart';
import 'stripe.dart';
import 'package:teledart/model.dart' hide File, Document;

import 'package:firedart/firedart.dart' as firedart;
// import 'package:shared_preferences/shared_preferences.dart';

class FirestoreUtils {
  static final admin = core.FirebaseAdminApp.initializeApp(
      'konnected-97cf9',
      core.Credential.fromServiceAccount(File(
          'C:\\Users\\Administrator\\Desktop\\Telly\\service-account.json')));
  static final firestore = Firestore(admin);
  static const String foot = "\n\nType /help to contact a support admin.";
  static String offerFoot(String offerID) =>
      "\n\nTo accept this offer - Type /accept $offerID\nTo decline this offer - Type /decline $offerID\nTo discuss more details with the provider type /discuss $offerID followed by your query\nIf you want to report this offer - Type /report $offerID";
  static String requestFoot(String requestID) =>
      "\n\nTo reply to this discusion - Tap __`/reply $requestID`__ followed by your reply.\n";
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
  static Map<String, StreamSubscription<List<firedart.Document>>?>
      requestStreams = {};
  static Map<String, StreamSubscription<List<firedart.Document>>?>
      offerStreams = {};

  static void showLoading(TeleDartMessage message) =>
      reply(message, "Loading, please wait.. ⏳");
  static void showError(TeleDartMessage message) =>
      reply(message, "An error has occured.. 😬$foot");
  static void showSuccess(TeleDartMessage message, String operation) =>
      reply(message, "✅ Success, $operation $foot", parseMode: 'Markdown');

  static void showNoProfile(TeleDartMessage message) => reply(message,
      'You do not have a Konnected profile, type /begin to create a profile. 👤');

  static String getUID(TeleDartMessage message) => message.from!.id.toString();

  static DateTime nowUtc() => DateTime.now().toUtc();

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

  static Future<bool> checkIsTopDog(TeleDartMessage message) async {
    var userID = getUID(message);
    var topDogDoc = await firestore.doc("Managers/$userID").get();
    if (!topDogDoc.exists) {
      reply(message, "You are not a Konnected manager.");
    }
    return topDogDoc.exists;
  }

  //TODO FETCH INFO balance, number of consumers, number of providers, number of dual, number of unassigned, number of requests, number of offers
  static Future<void> fetchInfo(TeleDartMessage message) async {
    bool isTopDog = await checkIsTopDog(message);
    if (isTopDog) {
      var infoDoc = await firestore.doc("Info/Details").get();
      var infoFields = infoDoc.data();
      // var balance = infoFields!["balance"];
      var offers = infoFields!["offers"];
      var requests = infoFields["requests"];
      var acceptedOffers = infoFields["acceptedOffers"];
      var declinedOffers = infoFields["declinedOffers"];
      var reportedOffers = infoFields["reportedOffers"];
      var reportedRequests = infoFields["reportedRequests"];
      var consumers = await firestore
          .collection("Lobby")
          .where("Role", WhereFilter.equal, "consumer")
          .get();
      var providers = await firestore
          .collection("Lobby")
          .where("Role", WhereFilter.equal, "provider")
          .get();
      var duals = await firestore
          .collection("Lobby")
          .where("Role", WhereFilter.equal, "dual")
          .get();
      var unassigned = await firestore
          .collection("Lobby")
          .where("Role", WhereFilter.equal, "None")
          .get();
      reply(message,
          "Info:\n\nOffers: $offers\nRequests: $requests\nAccepted Offers: $acceptedOffers\nDeclined Offers: $declinedOffers\nReported Offers: $reportedOffers\nReported Requests: $reportedRequests\nConsumers: ${consumers.docs.length}\nProviders: ${providers.docs.length}\nDuals: ${duals.docs.length}\nUnassigned: ${unassigned.docs.length}");
    }
  }

  //TODO reset balance
  static Future<void> resetBalance(TeleDartMessage message) async {
    bool isTopDog = await checkIsTopDog(message);
    if (isTopDog) {
      firestore.doc("Info/Details").update({"balance": 0}).then((_) {
        showSuccess(message, "Balance has been reset!");
      }).catchError((_) {
        showError(message);
      });
    }
  }

  //TODO Add support admins /addsupport
  static Future<void> addSupport(TeleDartMessage message) async {
    bool isTopDog = await checkIsTopDog(message);
    if (isTopDog) {
      var user = message.text!.replaceFirst("/addsupport ", "");
      if (user.isNotEmpty && regex.hasMatch(user)) {
        firestore.doc("Support Admins/$user").set({
          "date": nowUtc(),
          "closedTickets": 0,
          "chatID": 1,
        }).then((_) {
          showSuccess(message, "New Support Admin added!");
        }).catchError((_) {
          showError(message);
        });
      }
    }
  }

  //TODO Remove support admins /removesupport
  static Future<void> removeSupport(TeleDartMessage message) async {
    bool isTopDog = await checkIsTopDog(message);
    if (isTopDog) {
      var user = message.text!.replaceFirst("/removesupport ", "");
      if (user.isNotEmpty && regex.hasMatch(user)) {
        firestore.doc("Support Admins/$user").delete().then((_) {
          showSuccess(message, "Support Admin removed!");
        }).catchError((_) {
          showError(message);
        });
      }
    }
  }

  //TODO Add report admins /addreport
  static Future<void> addReport(TeleDartMessage message) async {
    bool isTopDog = await checkIsTopDog(message);
    if (isTopDog) {
      var user = message.text!.replaceFirst("/addreport ", "");
      if (user.isNotEmpty && regex.hasMatch(user)) {
        firestore.doc("Report Admins/$user").set({
          "date": nowUtc(),
          "timeoutUsers": 0,
          "bannedUsers": 0,
          "chatID": 1
        }).then((_) {
          showSuccess(message, "New Report Admin added!");
        }).catchError((_) {
          showError(message);
        });
      }
    }
  }

  //TODO Remove report admins /removereport
  static Future<void> removeReport(TeleDartMessage message) async {
    bool isTopDog = await checkIsTopDog(message);
    if (isTopDog) {
      var user = message.text!.replaceFirst("/removereport ", "");
      if (user.isNotEmpty && regex.hasMatch(user)) {
        firestore.doc("Report Admins/$user").delete().then((_) {
          showSuccess(message, "Report Admin removed!");
        }).catchError((_) {
          showError(message);
        });
      }
    }
  }

  static Future<void> broadcast(TeleDartMessage message) async {
    bool isTopDog = await checkIsTopDog(message);
    if (isTopDog) {
      var broadcastDescription = message.text!.replaceFirst("/broadcast ", "");
      firestore.collection("Broadcasts").doc().set({
        "broadcasted": false,
        "description": broadcastDescription
      }).then((_) {
        showSuccess(message, "Broadcast has been broadcasted");
      }).catchError((_) {
        showError(message);
      });
    }
  }

  static Future<void> makePermanent(TeleDartMessage message) async {
    bool isTopDog = await checkIsTopDog(message);
    if (isTopDog) {
      var userID = message.text!.replaceFirst("/makepermanent ", "");
      if (userID.isNotEmpty && regex.hasMatch(userID)) {
        var getUser = await firestore.collection("Lobby").doc(userID).get();
        if (getUser.exists) {
          firestore
              .collection("Lobby")
              .doc(userID)
              .update({"isPermanentlySubscribed": true}).then((_) {
            showSuccess(message, "User $userID has become a permanent user.");
          }).catchError((_) {
            showError(message);
          });
        } else {
          reply(message, "User does not exist.");
        }
      }
    }
  }

  static Future<void> fetchSupporter(TeleDartMessage message) async {
    bool isTopDog = await checkIsTopDog(message);
    if (isTopDog) {
      var userID = message.text!.replaceFirst("/fetchsupporter ", "");
      if (userID.isNotEmpty && regex.hasMatch(userID)) {
        var supporter = await firestore.doc("Support Admins/$userID").get();
        if (supporter.exists) {
          var fields = supporter.data();
          var dateJoined = fields!["date"] as Timestamp;
          var closedTickets = fields["closedTickets"];
          reply(message,
              "Supporter $userID:\n\nDate Started: ${timestampToString(dateJoined)}\n\nClosed Tickets: $closedTickets");
        }
      }
    }
  }

  static Future<void> fetchReporter(TeleDartMessage message) async {
    bool isTopDog = await checkIsTopDog(message);
    if (isTopDog) {
      var userID = message.text!.replaceFirst("/fetchreporter ", "");
      if (userID.isNotEmpty && regex.hasMatch(userID)) {
        var supporter = await firestore.doc("Report Admins/$userID").get();
        if (supporter.exists) {
          var fields = supporter.data();
          var dateJoined = fields!["date"] as Timestamp;
          var timeoutUsers = fields["timeoutUsers"];
          var bannedUsers = fields["bannedUsers"];
          reply(message,
              "Reporter $userID:\n\nDate Started: ${timestampToString(dateJoined)}\n\nTime-outs issued: $timeoutUsers\n\nUsers banned: $bannedUsers");
        }
      }
    }
  }

  static Future<void> fetchUser(TeleDartMessage message) async {
    bool isTopDog = await checkIsTopDog(message);
    if (isTopDog) {
      var userID = message.text!.replaceFirst("/fetchuser ", "");
      if (userID.isNotEmpty && regex.hasMatch(userID)) {
        final docSnapshot = await firestore.doc("Lobby/$userID").get();
        if (docSnapshot.exists) {
          Map<String, Object?>? profile = docSnapshot.data();
          var region = profile!["Region"] ?? "None";
          var country = profile["Country"] ?? "None";
          var role = profile["Role"] ?? "None";
          var subscriptionRole = profile["subscriptionRole"] ?? "None";
          var global = profile["Global"] ?? "None";
          var transaction = profile["transaction"] ?? "None";
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
          var trialStartDate = profile["dateTrialStart"] ?? "None";
          Timestamp? trialTimestamp =
              trialStartDate != "None" ? trialStartDate as Timestamp : null;
          String formattedTrialStartDate = timestampToString(trialTimestamp);
          var referralCount = profile["referrals"] as int;
          var discountAmount = referralCount > 10 ? 50 : referralCount * 10;
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
          reply(
            message,
            "Profile Details:\n\n🌎 Region: $region\n📍 Country: $country\n🎭 Role: $role\n🌐 Global Mode: $globalMode\n🗓 Date Joined: $formattedJoinDate\n⏲️ Subscription Date: $formattedSubscribeDate\n💼 Subscription Role: $subscriptionRole\n\n\nSubscription Details:\n\n🚦 Trial Start Date: $formattedTrialStartDate\n🚩 Trial End Date: $formattedTrialTermination\n Subscription Start Date:🏁 $formattedSubscribeDate\n🚩 Subscription End Date: $formattedSubscriptionTermination\n🎭 Role of Subscription: $subscriptionRole\n🎟 Referrals: $referralCount\n🤑 Referral Discount: $discountAmount\n💳 Transaction: $transaction",
          );
        } else {
          reply(message, "User not found");
        }
      }
    }
  }

  static Future<void> revokeSubscription(TeleDartMessage message) async {
    bool isTopDog = await checkIsTopDog(message);
    if (isTopDog) {
      var userID = message.text!.replaceFirst("/revokesub ", "");
      if (userID.isNotEmpty && regex.hasMatch(userID)) {
        final docSnapshot = await firestore.doc("Lobby/$userID").get();
        if (docSnapshot.exists) {
          firestore.doc("Lobby/$userID").update({
            "dateSubscribed": DateTime(1970),
            "dateSubscriptionEnd": DateTime(1970),
          }).then((_) {
            showSuccess(message, "Subscription revoked from $userID");
          }).catchError((_) {
            showError(message);
          });
        } else {
          reply(message, "User not found");
        }
      }
    }
  }

  static Future<void> revokeAndBan(TeleDartMessage message) async {
    bool isTopDog = await checkIsTopDog(message);
    if (isTopDog) {
      var userID = message.text!.replaceFirst("/revokeandban ", "");
      if (userID.isNotEmpty && regex.hasMatch(userID)) {
        final docSnapshot = await firestore.doc("Lobby/$userID").get();
        if (docSnapshot.exists) {
          firestore.doc("Lobby/$userID").update({
            "dateSubscribed": DateTime(1970),
            "dateSubscriptionEnd": DateTime(1970),
            "isBanned": true
          }).then((_) {
            showSuccess(message, "Subscription revoked and banned for $userID");
          }).catchError((_) {});
        } else {
          reply(message, "User not found");
        }
      }
    }
  }

  static Future<void> activateSub(TeleDartMessage message, String role) async {
    bool isTopDog = await checkIsTopDog(message);
    var pattern = role == "consumer"
        ? "/activatesubconsumer "
        : role == "provider"
            ? "/activatesubprovider "
            : "/activatesubdual ";
    if (isTopDog) {
      var userID = message.text!.replaceFirst(pattern, "");
      if (userID.isNotEmpty && regex.hasMatch(userID)) {
        final userDoc = firestore.doc("Lobby/$userID");
        final getUser = await userDoc.get();
        if (getUser.exists) {
          final getUser = await fetchProfile(message);
          final bool hasBeenChargedFirstMonth =
              getUser!["firstMonthCharged"] as bool;
          final dateStart = nowUtc();
          final dateEnd = dateStart.add(Duration(days: 30));
          final dateEndHere = dateEnd.toLocal();
          final formattedEndDate = formatter.format(dateEndHere);
          userDoc.update({
            "subscriptionRole": role,
            "Role": role,
            "dateSubscribed": dateStart,
            "dateSubscriptionEnd": dateEnd,
            if (!hasBeenChargedFirstMonth) "firstMonthCharged": true,
          }).then((_) async {
            showSuccess(message,
                "$role subscription has been renewed for user $userID until $formattedEndDate");
          }).catchError((_) {
            showError(message);
          });
        } else {
          reply(message, "User does not exist.");
        }
      } else {
        reply(message, "invalid user");
      }
    }
  }

  static Future<void> resetUserReferrals(TeleDartMessage message) async {
    bool isTopDog = await checkIsTopDog(message);
    if (isTopDog) {
      var userID = message.text!.replaceFirst("/resetreferrals ", "");
      if (userID.isNotEmpty && regex.hasMatch(userID)) {
        final userDoc = firestore.doc("Lobby/$userID");
        final getUser = await userDoc.get();
        if (getUser.exists) {
          userDoc.update({"referrals": 0}).then((_) {
            showSuccess(message, "User $userID referals have been reset to 0");
          }).catchError((_) {
            showError(message);
          });
        } else {
          reply(message, "User does not exist.");
        }
      } else {
        reply(message, "invalid user");
      }
    }
  }

  static Future<void> fetchReferralData(TeleDartMessage message) async {
    bool isTopDog = await checkIsTopDog(message);
    double totalAmountGained = 0.0;
    int numOfActiveUsers = 0;
    final rightNow = nowHere();
    if (isTopDog) {
      var userID = message.text!.replaceFirst("/referraldata ", "");
      if (userID.isNotEmpty && regex.hasMatch(userID)) {
        final userDoc = firestore.doc("Lobby/$userID");
        final getUser = await userDoc.get();
        if (getUser.exists) {
          final userIDReferrals = await firestore
              .collection("Lobby")
              .where("referralCode", WhereFilter.equal, userID)
              .where("secondMonthCharged", WhereFilter.equal, true)
              .get();
          if (userIDReferrals.docs.isNotEmpty) {
            for (var ref in userIDReferrals.docs) {
              final refData = ref.data();
              var subscriptionEndStamp =
                  refData["dateSubscriptionEnd"] as Timestamp;
              var subscriptionEndDate = timestampToDate(subscriptionEndStamp);
              var subscriptionValid = subscriptionEndDate!.isAfter(rightNow);
              if (subscriptionValid) {
                var lastSubAmount = refData["latestSubAmount"] as double;
                totalAmountGained += lastSubAmount;
                numOfActiveUsers++;
              }
            }
            reply(message,
                "Total money paid by users with a currently active subscription who were referred by $userID: \n\n£$totalAmountGained\n\nA total of $numOfActiveUsers users referred by $userID currently have an active subscription.");
          } else {
            reply(message,
                "No currently active subscriptions with referral from $userID");
          }
        } else {
          reply(message, "User does not exist.");
        }
      } else {
        reply(message, "invalid user");
      }
    }
  }

  static Future<void> getSubscribersWithActiveSub(
      TeleDartMessage message) async {
    bool isTopDog = await checkIsTopDog(message);
    double totalAmountGained = 0.0;
    int numOfActiveUsers = 0;
    final rightNow = nowHere();
    if (isTopDog) {
      final userIDReferrals = await firestore.collection("Lobby").get();
      if (userIDReferrals.docs.isNotEmpty) {
        for (var ref in userIDReferrals.docs) {
          final refData = ref.data();
          var subscriptionEndStamp =
              refData["dateSubscriptionEnd"] as Timestamp;
          var subscriptionEndDate = timestampToDate(subscriptionEndStamp);
          var subscriptionValid = subscriptionEndDate!.isAfter(rightNow);
          if (subscriptionValid) {
            var lastSubAmount = refData["latestSubAmount"] as double;
            totalAmountGained += lastSubAmount;
            numOfActiveUsers++;
          }
        }
        reply(message,
            "Total money paid by users with a currently active subscription: \n\n£$totalAmountGained\n\nA total of $numOfActiveUsers users currently have an active subscription.");
      } else {
        reply(message, "No currently active subscriptions");
      }
    }
  }

  static Future<void> fetchUserFromPayment(TeleDartMessage message) async {
    bool isTopDog = await checkIsTopDog(message);
    if (isTopDog) {
      var paymentID = message.text!.replaceFirst("/fetchpaymentuser ", "");
      if (paymentID.isNotEmpty && regex.hasMatch(paymentID)) {
        final paymentIDDocs = await firestore
            .collection("Lobby")
            .where("transaction", WhereFilter.equal, paymentID)
            .get();
        if (paymentIDDocs.docs.isNotEmpty) {
          final firstID = paymentIDDocs.docs.first.id;
          reply(message, "The user who made this payment is: __`$firstID`__",
              parseMode: 'Markdown');
        } else {
          reply(message, "No match found");
        }
      }
    }
  }

  static Future<void> fetchPaymentStatus(TeleDartMessage message) async {
    bool isTopDog = await checkIsTopDog(message);
    if (isTopDog) {
      var paymentID = message.text!.replaceFirst("/fetchpaymentstatus ", "");
      if (paymentID.isNotEmpty && regex.hasMatch(paymentID)) {
        final status =
            await StripeUtils.checkIsExpiredOrComplete(paymentID, message);
        final bool isPaid = await StripeUtils.checkHasBeenPaid(paymentID);
        message.reply(
            "Payment ID: $paymentID\n\nStatus: $status\n\nIs Paid: $isPaid");
      }
    }
  }

  static Future<void> allPerm(TeleDartMessage message) async {
    bool isTopDog = await checkIsTopDog(message);
    if (isTopDog) {
      var nonPerms = await firestore
          .collection('Lobby')
          .where("isPermanentlySubscribed", WhereFilter.equal, false)
          .get();
      var docs = nonPerms.docs;
      for (var user in docs) {
        firestore
            .doc("Lobby/${user.id}")
            .update({"isPermanentlySubscribed": true})
            .then((_) {})
            .catchError((_) {});
      }
      firestore.collection("Broadcasts").doc().set({
        "broadcasted": false,
        "description":
            "🤑 All non-permanent users have been given permanent membership!"
      }).then((_) {
        showSuccess(message,
            "${docs.length} non-permanent users have been made permanent users");
      }).catchError((_) {
        showError(message);
      });
    }
  }

  static Future<void> noPerm(TeleDartMessage message) async {
    bool isTopDog = await checkIsTopDog(message);
    if (isTopDog) {
      var perms = await firestore
          .collection('Lobby')
          .where("isPermanentlySubscribed", WhereFilter.equal, true)
          .get();
      var docs = perms.docs;
      for (var user in docs) {
        firestore
            .doc("Lobby/${user.id}")
            .update({"isPermanentlySubscribed": false})
            .then((_) {})
            .catchError((_) {});
      }
      firestore.collection("Broadcasts").doc().set({
        "broadcasted": false,
        "description": "Permanent users are no longer subscribed."
      }).then((_) {
        showSuccess(
            message, "${docs.length} permanent users have been cancelled");
      }).catchError((_) {
        showError(message);
      });
    }
  }
}

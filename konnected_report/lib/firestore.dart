// import 'dart:async';
import 'dart:async';
import 'dart:io';

import 'package:dart_firebase_admin/firestore.dart';
import 'package:dart_firebase_admin/dart_firebase_admin.dart' as core;
import 'package:intl/intl.dart';
import 'package:teledart/model.dart' hide File, Document;
import 'package:teledart/teledart.dart';
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
      "\n\nTo reply to this discusion - Type /reply $requestID followed by your reply.\n";
  static String reportFoot(dynamic userID) =>
      "\n\n__`/timeout1day $userID`__\n\n__`/timeout3day $userID`__\n\n__`/timeout7day $userID`__\n\n__`/ban $userID`__\n\n__`/fetchuser $userID`__";
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
      'You do not have a Konnected profile, go to $lobbyBot and type /begin to create a profile. 👤');

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

  static String generateID({
    required bool isRequest,
    required bool isOffer,
    required bool isReport,
    required bool isSupport,
  }) {
    var date = nowUtc();
    var prefix = "K";
    if (isOffer) {
      prefix = "O";
    }
    if (isReport) {
      prefix = "R";
    }
    if (isSupport) {
      prefix = "S";
    }
    return "$prefix${date.year}${date.month}${date.day}${date.hour}${date.second}${date.millisecond}${date.microsecond}";
  }

  //TODO CHECK IF REPORT ADMIN
  static Future<bool> checkIsReportAdmin(TeleDartMessage message) async {
    var userID = getUID(message);
    var reporterDoc =
        await firestore.collection("Report Admins").doc(userID).get();
    return reporterDoc.exists;
  }

  static Future<void> fetchUser(TeleDartMessage message) async {
    bool isReporter = await checkIsReportAdmin(message);
    if (isReporter) {
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

  //TODO CHECK IF REPORT ADMIN DOC EXISTS, SET CHAT ID TO IT
  static Future<void> startReporter(TeleDartMessage message) async {
    var userID = getUID(message);
    bool isReporter = await checkIsReportAdmin(message);
    if (isReporter) {
      firestore
          .doc("Report Admins/$userID")
          .update({"chatID": message.chat.id}).then((_) {
        showSuccess(message, "Welcome to the Report admin bot.");
      }).catchError((_) {
        reply(message,
            "Something wrong happened, please type /start again to begin receiving reports.");
      });
    } else {
      reply(message, "You are not a Konnected admin.");
    }
  }

  //TODO set Timeout to duration in days
  static Future<void> timeoutUser(
      TeleDartMessage message, int duration, TeleDart teledart) async {
    bool isReporter = await checkIsReportAdmin(message);
    if (isReporter) {
      String userID = "";
      if (duration == 1) {
        userID = message.text!.replaceFirst("/timeout1day ", "");
      }
      if (duration == 3) {
        userID = message.text!.replaceFirst("/timeout3day ", "");
      }
      if (duration == 7) {
        userID = message.text!.replaceFirst("/timeout7day ", "");
      }
      if (userID.isNotEmpty && regex.hasMatch(userID)) {
        var userDoc = await firestore.doc("Lobby/$userID").get();
        if (userDoc.exists) {
          firestore.doc("Lobby/$userID").update({
            "dateTimeout": nowUtc(),
            "timeoutDuration": duration
          }).then((_) async {
            firestore
                .collection("Report Admins")
                .doc(message.from!.id.toString())
                .update({"timeoutUsers": FieldValue.increment(1)})
                .then((_) {})
                .catchError((_) {});
            showSuccess(
                message, "User $userID has been timed out for $duration days");
            var reportAdmins =
                await firestore.collection("Report Admins").get();
            for (var admin in reportAdmins.docs) {
              var chatID = admin.data()["chatID"];
              if (chatID as int != 1) {
                try {
                  await teledart.sendMessage(chatID,
                      "User $userID has been timed out for $duration days\nby admin: ${admin.id}");
                } catch (e) {
                  //
                }
              }
            }
          }).catchError((_) {
            showError(message);
          });
        } else {
          reply(message, "❌ User does not exist.");
        }
      }
    }
  }

  //TODO ban user
  static Future<void> banUser(
      TeleDartMessage message, TeleDart teledart) async {
    bool isReporter = await checkIsReportAdmin(message);
    if (isReporter) {
      String userID = message.text!.replaceFirst("/ban ", "");
      if (userID.isNotEmpty && regex.hasMatch(userID)) {
        var userDoc = await firestore.doc("Lobby/$userID").get();
        if (userDoc.exists) {
          firestore
              .doc("Lobby/$userID")
              .update({"isBanned": true}).then((_) async {
            showSuccess(message, "User $userID has been permanently banned");
            firestore
                .collection("Report Admins")
                .doc(message.from!.id.toString())
                .update({"bannedUsers": FieldValue.increment(1)})
                .then((_) {})
                .catchError((_) {});
            var reportAdmins =
                await firestore.collection("Report Admins").get();
            for (var admin in reportAdmins.docs) {
              var chatID = admin.data()["chatID"];
              if (chatID as int != 1) {
                try {
                  await teledart.sendMessage(chatID,
                      "User $userID has been permanently banned\nby admin: ${admin.id}");
                } catch (e) {
                  //
                }
              }
            }
          }).catchError((_) {
            showError(message);
          });
        } else {
          reply(message, "User does not exist.");
        }
      }
    }
  }

  //TODO set timeout duration to 0
  static Future<void> liftTimeout(
      TeleDartMessage message, TeleDart teledart) async {
    bool isReporter = await checkIsReportAdmin(message);
    if (isReporter) {
      String userID = message.text!.replaceFirst("/lifttimeout ", "");
      if (userID.isNotEmpty && regex.hasMatch(userID)) {
        var userDoc = await firestore.doc("Lobby/$userID").get();
        if (userDoc.exists) {
          firestore
              .doc("Lobby/$userID")
              .update({"timeoutDuration": 0}).then((_) async {
            showSuccess(message, "Time-out lifted from User $userID");
            var reportAdmins =
                await firestore.collection("Report Admins").get();
            for (var admin in reportAdmins.docs) {
              var chatID = admin.data()["chatID"];
              if (chatID as int != 1) {
                try {
                  await teledart.sendMessage(chatID,
                      "Time-out lifted from User $userID\nby admin: ${admin.id}");
                } catch (e) {
                  //
                }
              }
            }
          }).catchError((_) {
            showError(message);
          });
        } else {
          reply(message, "User does not exist.");
        }
      }
    }
  }

  //TODO set is banned to false
  static Future<void> liftBan(
      TeleDartMessage message, TeleDart teledart) async {
    bool isReporter = await checkIsReportAdmin(message);
    if (isReporter) {
      String userID = message.text!.replaceFirst("/liftban ", "");
      if (userID.isNotEmpty && regex.hasMatch(userID)) {
        var userDoc = await firestore.doc("Lobby/$userID").get();
        if (userDoc.exists) {
          firestore
              .doc("Lobby/$userID")
              .update({"isBanned": false}).then((_) async {
            showSuccess(message, "Ban has been lifted from User $userID");
            var reportAdmins =
                await firestore.collection("Report Admins").get();
            for (var admin in reportAdmins.docs) {
              var chatID = admin.data()["chatID"];
              if (chatID as int != 1) {
                try {
                  await teledart.sendMessage(chatID,
                      "Ban has been lifted from User $userID\nby admin: ${admin.id}");
                } catch (e) {
                  //
                }
              }
            }
          }).catchError((_) {
            showError(message);
          });
        } else {
          reply(message, "User does not exist.");
        }
      }
    }
  }

  //TODO FETCH NEW REPORTS AND DISPLAY THEM TO ALL ADMINS
  static void reporterListenToReports(TeleDart teledart) async {
    firedart.FirebaseAuth.initialize(
        "AIzaSyCPSi0Kxed6cJzSv5BBrLtVn70OS-cq7gQ", firedart.VolatileStore());
    firedart.FirebaseAuth.instance.signInAnonymously().then((val) {
      firedart.Firestore.initialize("konnected-97cf9");
      var reports = firedart.Firestore.instance.collection("Report Tickets");
      reports.stream.listen((onData) async {
        var newReports = onData.where((d) {
          final fields = d.map;
          bool isBroadcasted = fields["broadcasted"];
          return isBroadcasted == false;
        }).toList();
        var reportAdmins = await firestore.collection("Report Admins").get();
        for (var report in newReports) {
          var fields = report.map;
          var type = fields["type"];
          var description = fields["description"];
          var user = fields["user"];
          var reporter = fields["reporter"];
          String prefix = type as String == "request"
              ? "New Request Report:\n"
              : "New Offer Report:\n";
          var compactMessage =
              "$prefix$description\n\nBelongs to user: *$user\n\nReporting User:*$reporter";
          for (var admin in reportAdmins.docs) {
            var chatID = admin.data()["chatID"];
            if (chatID as int != 1) {
              try {
                await teledart.sendMessage(
                    chatID, "$compactMessage${reportFoot(user)}",
                    parseMode: "Markdown");
              } catch (e) {
                //
              }
            }
          }
          firestore
              .doc("Report Tickets/${report.id}")
              .update({"broadcasted": true})
              .then((_) {})
              .catchError((_) {});
        }
        var oldReports = onData.where((d) {
          final fields = d.map;
          bool isBroadcasted = fields["broadcasted"];
          return isBroadcasted != false;
        }).toList();
        for (var oldReport in oldReports) {
          firestore
              .doc("Report Tickets/${oldReport.id}")
              .delete()
              .then((_) {})
              .catchError((_) {});
        }
      });
    });
  }
}

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
  static String supportFoot(String ticketID) =>
      "\n\nTo reply to this ticket tap __`/reply $ticketID`__ then paste & type your reply.\n\nTo close this ticket tap __`/closeticket $ticketID`__ then paste & enter it.";
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

  static Map<String, StreamSubscription<List<firedart.Document>>?>
      requestStreams = {};
  static Map<String, StreamSubscription<List<firedart.Document>>?>
      offerStreams = {};
  static Map<String, StreamSubscription<List<firedart.Document>>?>
      supportStreams = {};

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

  static Future<bool> isSupportAdmin(TeleDartMessage message) async {
    var userID = getUID(message);
    var supporterDoc = await firestore.doc("Support Admins/$userID").get();
    return supporterDoc.exists;
  }

  static Future<void> startSupport(TeleDartMessage message) async {
    var userID = getUID(message);
    bool isAdmin = await isSupportAdmin(message);
    if (isAdmin) {
      firestore
          .doc("Support Admins/$userID")
          .update({"chatID": message.chat.id}).then((_) {
        showSuccess(message, "Welcome to support admin panel.");
      }).catchError((_) {
        reply(message,
            "Something wrong happened, please type /start again to begin receiving support tickets.");
      });
    }
  }

  static Future<void> newSupportTicket(TeleDartMessage message) async {
    Future<void> continuation() async {
      var userID = getUID(message);
      var currentUserTicket = await firestore
          .collection("Support Tickets")
          .where("user", WhereFilter.equal, userID)
          .get();
      if (currentUserTicket.docs.isEmpty) {
        var ticketID = generateID(
            isRequest: false, isOffer: false, isReport: false, isSupport: true);
        String description = message.text!.replaceFirst("/newticket ", "");
        if (description.isNotEmpty && description != "/newticket") {
          firestore.doc("Support Tickets/$ticketID").set({
            "user": userID,
            "date": nowUtc(),
            "chatID": message.chat.id,
            "description": description,
            "broadcasted": false,
            "isListening": false,
            "replies": 0,
          }).then((_) {
            firestore
                .doc("Support Tickets/$ticketID")
                .collection("Discussions")
                .doc()
                .set({
                  "description": "foo",
                  "date": nowUtc(),
                  "user": userID,
                  "broadcasted": true
                })
                .then((_) {})
                .catchError((_) {});
            showSuccess(message,
                "New support ticket $ticketID created.${supportFoot(ticketID)}");
          }).catchError((_) {
            showError(message);
          });
        } else {
          reply(message,
              "Invalid support ticket, please provide a description for the problem you are currently facing.");
        }
      } else {
        reply(message,
            "❌ You already have an ongoing support ticket, close it to create a new one.\n\nTo close your ongoing support ticket, tap __`/closeticket ${currentUserTicket.docs.first.id}`__ then paste & enter it.",
            parseMode: 'Markdown');
      }
    }

    handleUserExistenceOp(message, continuation);
  }

  static Future<void> closeSupportTicket(TeleDartMessage message) async {
    var userID = getUID(message);
    bool isSupport = await isSupportAdmin(message);
    var ticketID = message.text!.replaceFirst("/closeticket ", "");
    if (ticketID.isNotEmpty && regex.hasMatch(ticketID)) {
      var getTicket = await firestore.doc("Support Tickets/$ticketID").get();
      if (getTicket.exists) {
        var fields = getTicket.data();
        var user = fields!["user"];
        if (isSupport || user == userID) {
          firestore.doc("Support Tickets/$ticketID").delete().then((_) {
            if (isSupport) {
              firestore
                  .doc("Support Admins/$userID")
                  .update({"closedTickets": FieldValue.increment(1)})
                  .then((_) {})
                  .catchError((_) {});
            }
            showSuccess(message, "Ticket $ticketID closed.");
            if (supportStreams[ticketID] != null) {
              supportStreams[ticketID]!.cancel();
              supportStreams.remove(ticketID);
            }
          }).catchError((_) {
            showError(message);
          });
        }
      } else {
        reply(message,
            "❌ No ticket with that ID was found. It might have been closed by the user or an admin.");
      }
    }
  }

  static Future<void> replySupportTicket(TeleDartMessage message) async {
    var text = message.text!;
    var userID = getUID(message);
    var split = text.split(" ");
    if (split.length >= 3) {
      if (split[1].isNotEmpty && regex.hasMatch(split[1])) {
        var currentTicket =
            await firestore.doc("Support Tickets/${split[1]}").get();
        if (currentTicket.exists) {
          var discussions =
              firestore.collection("Support Tickets/${split[1]}/Discussions");
          String description = "";
          for (var i = 2; i < split.length; i++) {
            description = "$description${split[i]} ";
          }
          discussions.doc().set({
            "description": description,
            "date": nowUtc(),
            "user": userID,
            "broadcasted": false
          }).then((_) {
            firestore
                .doc("Support Tickets/${split[1]}")
                .update({"replies": FieldValue.increment(1)})
                .then((_) {})
                .catchError((_) {});
          }).catchError((_) {
            showError(message);
          });
        } else {
          reply(message,
              "❌ No ticket with that ID was found. It might have been closed by the user or an admin.");
        }
      }
    } else {
      reply(message,
          "❌ Invalid command syntax, type /reply and your ticket ID followed by response, ex: '/reply S202347349 I will try that solution.'");
    }
  }

  static Future<void> fetchUser(TeleDartMessage message) async {
    bool isSupport = await isSupportAdmin(message);
    if (isSupport) {
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

  static void supporterListen(TeleDart teledart) async {
    firedart.FirebaseAuth.initialize(
        "AIzaSyCPSi0Kxed6cJzSv5BBrLtVn70OS-cq7gQ", firedart.VolatileStore());
    firedart.FirebaseAuth.instance.signInAnonymously().then((val) {
      firedart.Firestore.initialize("konnected-97cf9");
      var supports = firedart.Firestore.instance.collection("Support Tickets");
      supports.stream.listen((onData) async {
        var newTickets = onData.where((d) {
          final fields = d.map;
          bool isBroadcasted = fields["broadcasted"];
          bool isListening = fields["isListening"];
          return isBroadcasted == false || isListening == false;
        }).toList();
        for (var ticket in newTickets) {
          var ticketFields = ticket.map;
          var ticketOwner = ticketFields["user"];
          var ticketOwnerChat = ticketFields["chatID"];
          var ticketDescription = ticketFields["description"];
          var supportersCollection0 =
              await firestore.collection("Support Admins").get();
          var supporterDocs0 = supportersCollection0.docs;
          for (var supporter0 in supporterDocs0) {
            var supporterFields = supporter0.data();
            var supporterChatID = supporterFields["chatID"];
            if (supporterChatID as int != 1) {
              try {
                await teledart.sendMessage(supporterChatID,
                    "$ticketDescription${supportFoot(ticket.id)}\n\n__`/fetchUser $ticketOwner`__",
                    parseMode: 'Markdown');
              } catch (e) {
                //
              }
            }
          }
          firestore
              .doc("Support Tickets/${ticket.id}")
              .update({"isListening": true, "broadcasted": true})
              .then((_) {})
              .catchError((_) {});
          var discussions = firedart.Firestore.instance
              .collection("Support Tickets/${ticket.id}/Discussions");
          supportStreams[ticket.id] = discussions.stream.listen((onData) async {
            var newDiscussions = onData.where((disc) {
              final discussionFields = disc.map;
              final broadcasted = discussionFields["broadcasted"];
              return broadcasted == false;
            });
            for (var reply in newDiscussions) {
              var replyFields = reply.map;
              var replyOwner = replyFields["user"];
              var replyDescription = replyFields["description"];
              if (replyOwner == ticketOwner) {
                var supportersCollection =
                    await firestore.collection("Support Admins").get();
                var supporterDocs = supportersCollection.docs;
                for (var supporter in supporterDocs) {
                  var supporterFields = supporter.data();
                  var supporterChatID = supporterFields["chatID"];
                  if (supporterChatID as int != 1) {
                    try {
                      await teledart.sendMessage(supporterChatID,
                          "$replyDescription${supportFoot(ticket.id)}\n\n__`/fetchUser $replyOwner`__",
                          parseMode: 'Markdown');
                    } catch (e) {
                      //
                    }
                  }
                }
              } else {
                try {
                  await teledart.sendMessage(ticketOwnerChat,
                      "$replyDescription${supportFoot(ticket.id)}",
                      parseMode: 'Markdown');
                } catch (e) {
                  //
                }
              }
              firestore
                  .doc("Support Tickets/${ticket.id}/Discussions/${reply.id}")
                  .update({"broadcasted": true})
                  .then((_) {})
                  .catchError((_) {});
            }
          });
        }
      });
    });
  }
}

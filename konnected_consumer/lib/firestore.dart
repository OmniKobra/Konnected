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
      "\n\nTo accept this offer - Tap __`/accept $offerID`__ then paste & enter it\n\nTo decline this offer - Tap __`/decline $offerID`__ then paste & enter it\n\nTo discuss more details with the provider tap __`/discuss $offerID`__ followed by your query\n\nIf you want to report this offer - Tap __`/report $offerID`__ then paste & enter it.";
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

  static Future<bool> checkIsPermanentUser(TeleDartMessage message) async {
    bool isPermanentUser = false;
    bool userExists = await fetchUserExists(message);
    if (userExists) {
      Map<String, Object?>? profile = await fetchProfile(message);
      bool isPermanentlySubscribed =
          profile!["isPermanentlySubscribed"] as bool? ?? false;
      isPermanentUser = isPermanentlySubscribed;
    }
    return isPermanentUser;
  }

  static Future<bool> hasValidTrial(TeleDartMessage message) async {
    bool hasTrial = false;
    bool userExists = await fetchUserExists(message);
    if (userExists) {
      Map<String, Object?>? profile = await fetchProfile(message);
      var dateTrialStart = profile!["dateTrialStart"] as Timestamp;
      var dateTimeTrialStart = timestampToDate(dateTrialStart);
      var now = nowHere();
      var difference = now.difference(dateTimeTrialStart!);
      var differenceDays = difference.inDays;
      hasTrial = differenceDays < 3;
    }
    return hasTrial;
  }

  static Future<bool> hasValidSubscription(TeleDartMessage message) async {
    bool hasSubscription = false;
    bool userExists = await fetchUserExists(message);
    if (userExists) {
      Map<String, Object?>? profile = await fetchProfile(message);
      var dateSubscribed = profile!["dateSubscribed"] ?? "None";
      Timestamp? subscribeTimestamp =
          dateSubscribed != "None" ? dateSubscribed as Timestamp : null;
      var dateTimeTrialStart = timestampToDate(subscribeTimestamp);
      if (dateTimeTrialStart == null) {
        hasSubscription = false;
        reply(message,
            "Your Konnected subscription is inactive or has expired, head to $lobbyBot and type /subscription to manage your plan.");
      } else {
        var now = nowHere();
        var difference = now.difference(dateTimeTrialStart);
        var differenceDays = difference.inDays;
        hasSubscription = differenceDays < 30;
        if (differenceDays >= 30) {
          reply(message,
              "Your Konnected subscription is inactive or has expired, head to $lobbyBot and type /subscription to manage your plan.");
        }
      }
    }
    return hasSubscription;
  }

  static Future<bool> subRoleMatchesRole(
      TeleDartMessage message, String expectedRole) async {
    bool areMatching = false;
    bool userExists = await fetchUserExists(message);
    if (userExists) {
      Map<String, Object?>? profile = await fetchProfile(message);
      final subRole = profile!["subscriptionRole"] ?? "None";
      final role = profile["Role"] ?? "None";
      if (subRole != "None" && role != "None") {
        if (subRole != role) {
          areMatching = false;
          reply(message,
              "Your subscription role does not match your assigned role, head to $lobbyBot and type /me to re-assign your role according to your subscription's role. Alternatively, you can renew your subscription based on your current chosen role. Subscribe to the dual role plan and access all of Konnected's features.");
        } else {
          if (subRole == expectedRole) {
            areMatching = true;
          } else {
            reply(message,
                "Your subscription role does not match your assigned role, head to $lobbyBot and type /me to re-assign your role according to your subscription's role. Alternatively, you can renew your subscription based on your current chosen role. Subscribe to the dual role plan and access all of Konnected's features.");
          }
        }
      } else {
        areMatching = false;
        reply(message,
            "Your role has not been assigned properly, head to $lobbyBot and type /me to resolve this issue");
      }
    }
    return areMatching;
  }

  static Future<bool> checkConsumerSubscriptionValid(
      TeleDartMessage message) async {
    bool isValid = false;
    bool userExists = await fetchUserExists(message);
    if (userExists) {
      bool hasTrial = await hasValidTrial(message);
      if (hasTrial) {
        isValid = true;
      } else {
        bool isPermanentUser = await checkIsPermanentUser(message);
        bool hasSubscription = await hasValidSubscription(message);
        bool rolesMatch = await subRoleMatchesRole(message, "consumer");
        if (isPermanentUser || (hasSubscription && rolesMatch)) {
          isValid = true;
        }
      }
    }
    return isValid;
  }

  static Future<bool> checkDualSubscriptionValid(
      TeleDartMessage message) async {
    bool isValid = false;
    bool hasTrial = await hasValidTrial(message);
    if (hasTrial) {
      isValid = true;
    } else {
      bool isPermanentUser = await checkIsPermanentUser(message);
      bool hasSubscription = await hasValidSubscription(message);
      bool rolesMatch = await subRoleMatchesRole(message, "dual");
      if (isPermanentUser || (hasSubscription && rolesMatch)) {
        isValid = true;
      }
    }
    return isValid;
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

  static Future<bool> requestExists(
      TeleDartMessage message, String requestID) async {
    var doc = await firestore.doc("Requests/$requestID").get();
    var exists = doc.exists;
    if (!exists) {
      reply(message,
          "❌ No requests found with id: $requestID, It may have been cancelled or the consumer accepted an offer.");
    }
    return exists;
  }

  static Future<bool> hasOngoingRequest(TeleDartMessage message) async {
    final userID = getUID(message);
    final usersRequests = await firestore
        .collection("Requests")
        .where('user', WhereFilter.equal, userID)
        .get();
    bool hasRequest = usersRequests.docs.isNotEmpty;
    if (hasRequest) {
      reply(message,
          "You already have an ongoing request, You need to either accept an offer or cancel the request to make another one.\n\nTo cancel your current request tap __`/cancel ${usersRequests.docs.first.id}`__ then paste & enter it.",
          parseMode: 'Markdown');
    }
    return hasRequest;
  }

  //TODO SEND NEW REQUEST
  static Future<void> sendNewRequest(
      TeleDartMessage message, bool isGlobal) async {
    Future<void> continuation() async {
      final userID = getUID(message);
      final profile = await fetchProfile(message);
      final location = profile!["Country"] ?? "None";
      final profileIsGlobalist = profile["Global"] ?? false;
      if (location == "None") {
        reply(message,
            "Your location has not been set up properly, head to $lobbyBot and type /me to finish setting up your profile.");
      } else {
        var description = isGlobal
            ? message.text!.replaceFirst("/wantglobal", "")
            : message.text!.replaceFirst("/want", "");
        if (description.isEmpty) {
          reply(message,
              "❌ Invalid empty Request, please provide an accurate description for all your requests.");
        } else {
          bool isGlobalist = profileIsGlobalist as bool;
          if (isGlobal && !isGlobalist) {
            reply(message,
                "You are trying to make a global request while your profile does not have global mode enabled, head to $lobbyBot and type /me to manage your global mode.");
          } else {
            var allowed = await checkIsAllowed(message);
            var dualActive = await checkDualSubscriptionValid(message);
            var subActive = dualActive
                ? true
                : await checkConsumerSubscriptionValid(message);
            var hasOngoing = await hasOngoingRequest(message);
            bool canParticipate =
                allowed && (dualActive || subActive) && !hasOngoing;
            if (canParticipate) {
              var requestID = generateID(
                  isRequest: true,
                  isOffer: false,
                  isReport: false,
                  isSupport: false);
              var requestDoc = firestore.doc("Requests/$requestID");
              requestDoc.set({
                "description": description,
                "user": userID,
                "chatID": message.chat.id,
                "offerCount": 0,
                "date": nowUtc(),
                "isGlobal": isGlobal,
                "location": location,
                "broadcasted": false,
                "listening": false,
                "declined": false,
                "accepted": false
              }).then((_) {
                String prefix = isGlobal ? "🌎 Global" : "📍 $location";
                requestDoc
                    .collection("Offers")
                    .doc()
                    .set({
                      "description": "foo",
                      "user": userID,
                      "date": nowUtc(),
                      "isBroadcasted": true,
                      "listening": true,
                      "declined": false,
                    })
                    .then((_) {})
                    .catchError((_) {});
                showSuccess(message,
                    "$prefix Request $requestID has been created.\n\nTo cancel this request tap __`/cancel $requestID`__ then paste it & press enter.");
                firestore
                    .doc("Info/Details")
                    .update({"requests": FieldValue.increment(1)})
                    .then((_) {})
                    .catchError((_) {});
              }).catchError((_) {
                showError(message);
              });
            }
          }
        }
      }
    }

    handleUserExistenceOp(message, continuation);
  }

  //TODO ACCEPT AN OFFER IN REQUEST
  static Future<void> acceptRequestOffer(TeleDartMessage message) async {
    var offerID = message.text!.replaceFirst("/accept ", "");
    var userID = getUID(message);
    if (offerID.isEmpty || !regex.hasMatch(offerID)) {
      reply(message, "❌ Invalid offer ID, make sure you paste the offer's ID.");
    } else {
      final usersRequests = await firestore
          .collection("Requests")
          .where('user', WhereFilter.equal, userID)
          .get();
      final docs = usersRequests.docs;
      if (docs.isNotEmpty) {
        var id = docs.first.id;
        bool exists = await requestExists(message, id);
        if (exists) {
          var offerDoc =
              await firestore.doc("Requests/$id/Offers/$offerID").get();
          if (offerDoc.exists) {
            if (requestStreams[id] != null) {
              requestStreams[id]!.cancel();
              requestStreams.remove(id);
            }
            var allOffers =
                await firestore.collection("Requests/$id/Offers").get();
            var allOfferDocs = allOffers.docs;
            if (allOfferDocs.isNotEmpty) {
              for (var off in allOfferDocs) {
                var offID = off.id;
                if (offerStreams[offID] != null) {
                  offerStreams[offID]!.cancel();
                  offerStreams.remove(offID);
                }
              }
            }

            firestore
                .doc("Requests/$id/Offers/$offerID")
                .update({"accepted": true, "declined": false}).then((_) {
              showSuccess(message, "Offer $offerID has been accepted.");
              firestore
                  .doc("Info/Details")
                  .update({"acceptedOffers": FieldValue.increment(1)})
                  .then((_) {})
                  .catchError((_) {});
            }).catchError((_) {
              showError(message);
            });
            Future.delayed(Duration(minutes: 1), () {
              firestore
                  .doc("Requests/$id")
                  .delete()
                  .then((_) {})
                  .catchError((_) {
                showError(message);
              });
            });
          }
        }
      }
    }
  }

  //TODO DECLINE AN OFFER IN REQUEST
  static Future<void> declineRequestOffer(TeleDartMessage message) async {
    var offerID = message.text!.replaceFirst("/decline ", "");
    var userID = getUID(message);
    if (offerID.isEmpty || !regex.hasMatch(offerID)) {
      reply(message, "❌ Invalid offer ID, make sure you paste the offer's ID.");
    } else {
      final usersRequests = await firestore
          .collection("Requests")
          .where('user', WhereFilter.equal, userID)
          .get();
      final docs = usersRequests.docs;
      if (docs.isNotEmpty) {
        var id = docs.first.id;
        bool exists = await requestExists(message, id);
        if (exists) {
          var offerDoc =
              await firestore.doc("Requests/$id/Offers/$offerID").get();
          if (offerDoc.exists) {
            if (offerStreams[offerID] != null) {
              offerStreams[offerID]!.cancel();
              offerStreams.remove(offerID);
            }
            firestore
                .doc("Requests/$id/Offers/$offerID")
                .update({"declined": true, "accepted": false}).then((_) {
              showSuccess(message, "Offer $offerID has been declined.");
              firestore
                  .doc("Info/Details")
                  .update({"declinedOffers": FieldValue.increment(1)})
                  .then((_) {})
                  .catchError((_) {});
            }).catchError((_) {
              showError(message);
            });
          }
        }
      }
    }
  }

  //TODO DISCUSS AN OFFER
  static Future<void> discussOffer(TeleDartMessage message) async {
    var splitMessage = message.text!.split(" ");
    var length = splitMessage.length;
    if (length < 3) {
      reply(message,
          "❌ Invalid discussion syntax, make sure to provide the offer's ID after /discuss, and provide your query after the id.\n\nExample: '/discuss O20251638930 can i know when you can deliver to my area?'");
    } else {
      var offerID = splitMessage[1];
      if (offerID.isNotEmpty && regex.hasMatch(offerID)) {
        final userID = getUID(message);
        final usersRequests = await firestore
            .collection("Requests")
            .where('user', WhereFilter.equal, userID)
            .get();
        final docs = usersRequests.docs;
        if (docs.isNotEmpty) {
          final currentRequestID = docs.first.id;
          bool exists = await requestExists(message, currentRequestID);
          if (exists) {
            var offerDoc = await firestore
                .doc("Requests/$currentRequestID/Offers/$offerID")
                .get();
            bool offerExists = offerDoc.exists;
            if (offerExists) {
              bool canSend = true;
              var discussionCollection = await firestore
                  .collection(
                      "Requests/$currentRequestID/Offers/$offerID/Discussions")
                  .orderBy("date", descending: true)
                  .get();
              if (discussionCollection.docs.isNotEmpty) {
                var firstOne = discussionCollection.docs.first;
                var firstData = firstOne.data();
                var firstSender = firstData["sender"];
                if (firstSender == userID) {
                  canSend = false;
                }
              }
              if (canSend) {
                String description = "";
                for (var i = 2; i < length; i++) {
                  description = "$description${splitMessage[i]} ";
                }
                firestore
                    .collection(
                        "Requests/$currentRequestID/Offers/$offerID/Discussions")
                    .doc()
                    .set({
                  "sender": userID,
                  "description": description,
                  "date": nowUtc(),
                  "broadcasted": false
                }).then((_) {
                  showSuccess(message,
                      "Your response has been sent to the offer's provider, you can reply again once they respond!");
                }).catchError((_) {
                  showError(message);
                });
              } else {
                reply(message,
                    "❌ You have already sent a query to this offer, you can discuss again once the provider returns a response by typing /reply $offerID followed by your reply.");
              }
            } else {
              reply(message, "❌ An offer with this ID does not exist.");
            }
          }
        }
      } else {
        reply(message,
            "❌ Invalid offer ID, make sure you provide a valid offer ID with no special characters");
      }
    }
  }

  //TODO REPLY TO A DISCUSSION
  static Future<void> replyDiscussion(TeleDartMessage message) async {
    var splitMessage = message.text!.split(" ");
    var length = splitMessage.length;
    if (length < 3) {
      reply(message,
          "❌ Invalid reply syntax, make sure to provide the offer's ID after /reply, and provide your query after the id.\n\nExample: '/reply O20251638930 can i know when you can deliver to my area?'");
    } else {
      var offerID = splitMessage[1];
      if (offerID.isNotEmpty && regex.hasMatch(offerID)) {
        final userID = getUID(message);
        final usersRequests = await firestore
            .collection("Requests")
            .where('user', WhereFilter.equal, userID)
            .get();
        final docs = usersRequests.docs;
        if (docs.isNotEmpty) {
          final currentRequestID = docs.first.id;
          bool exists = await requestExists(message, currentRequestID);
          if (exists) {
            var offerDoc = await firestore
                .doc("Requests/$currentRequestID/Offers/$offerID")
                .get();
            bool offerExists = offerDoc.exists;
            if (offerExists) {
              bool canSend = true;
              var discussionCollection = await firestore
                  .collection(
                      "Requests/$currentRequestID/Offers/$offerID/Discussions")
                  .orderBy("date", descending: true)
                  .get();
              if (discussionCollection.docs.isNotEmpty) {
                var firstOne = discussionCollection.docs.first;
                var firstData = firstOne.data();
                var firstSender = firstData["sender"];
                if (firstSender == userID) {
                  canSend = false;
                }
              }
              if (canSend) {
                String description = "";
                for (var i = 2; i < length; i++) {
                  description = "$description${splitMessage[i]} ";
                }
                firestore
                    .collection(
                        "Requests/$currentRequestID/Offers/$offerID/Discussions")
                    .doc()
                    .set({
                  "sender": userID,
                  "description": description,
                  "date": nowUtc(),
                  "broadcasted": false
                }).then((_) {
                  showSuccess(message,
                      "Your response has been sent to the offer's provider, you can reply again once they respond!");
                }).catchError((_) {
                  showError(message);
                });
              } else {
                reply(message,
                    "❌ You have already sent a query to this offer, you can discuss again once the provider returns a response by typing /reply $offerID followed by your reply.");
              }
            } else {
              reply(message, "❌ An offer with this ID does not exist.");
            }
          }
        }
      } else {
        reply(message,
            "❌ Invalid offer ID, make sure you provide a valid offer ID with no special characters");
      }
    }
  }

  //TODO REPORT AN OFFER
  static Future<void> reportOffer(TeleDartMessage message) async {
    final userID = getUID(message);
    var allowed = await checkIsAllowed(message);
    if (allowed) {
      final usersRequests = await firestore
          .collection("Requests")
          .where('user', WhereFilter.equal, userID)
          .get();
      final docs = usersRequests.docs;
      if (docs.isNotEmpty) {
        final currentRequestID = docs.first.id;
        bool exists = await requestExists(message, currentRequestID);
        if (exists) {
          final msgText = message.text!;
          final offerID = msgText.replaceFirst("/report ", "");
          if (offerID.isNotEmpty && regex.hasMatch(offerID)) {
            final offer = await firestore
                .doc("Requests/$currentRequestID/Offers/$offerID")
                .get();
            if (offer.exists) {
              final offerData = offer.data();
              var reportID = generateID(
                  isRequest: false,
                  isOffer: false,
                  isReport: true,
                  isSupport: false);
              final offerDescription = offerData!["description"];
              final offerUser = offerData["user"];
              final offerDate = offerData["date"];
              firestore.doc("Report Tickets/$reportID").set({
                "type": "offer",
                "description": offerDescription,
                "user": offerUser,
                "reporter": userID,
                "date": offerDate,
                "broadcasted": false,
                "reportDate": nowUtc()
              }).then((_) {
                showSuccess(message,
                    "Offer $offerID has been reported successfully, our admins will review the report and take action soon.");
                firestore
                    .doc("Info/Details")
                    .update({"reportedOffers": FieldValue.increment(1)})
                    .then((_) {})
                    .catchError((_) {});
              }).catchError((_) {
                showError(message);
              });
            } else {
              reply(message, "❌ No offers found matching that ID.");
            }
          } else {
            message
                .reply("❌ Invalid offer ID, please provide a valid offer ID.");
          }
        }
      }
    }
  }

  static Future<void> cancelRequest(TeleDartMessage message) async {
    var id = message.text!.replaceFirst("/cancel ", "");
    if (id.isEmpty || !regex.hasMatch(id)) {
      reply(message,
          "❌ Invalid request ID, make sure you paste your request's ID.");
    } else {
      bool exists = await requestExists(message, id);
      if (exists) {
        if (requestStreams[id] != null) {
          requestStreams[id]!.cancel();
          requestStreams.remove(id);
        }
        var allOffers = await firestore.collection("Requests/$id/Offers").get();
        var allOfferDocs = allOffers.docs;
        if (allOfferDocs.isNotEmpty) {
          for (var off in allOfferDocs) {
            var offID = off.id;
            if (offerStreams[offID] != null) {
              offerStreams[offID]!.cancel();
              offerStreams.remove(offID);
            }
          }
        }
        firestore.doc("Requests/$id").delete().then((_) {
          showSuccess(message, "Request $id has been cancelled.");
        }).catchError((_) {
          showError(message);
        });
      }
    }
  }

  static void listenToRequests(TeleDart teledart) async {
    firedart.FirebaseAuth.initialize(
        "AIzaSyCPSi0Kxed6cJzSv5BBrLtVn70OS-cq7gQ", firedart.VolatileStore());
    firedart.FirebaseAuth.instance.signInAnonymously().then((val) {
      firedart.Firestore.initialize("konnected-97cf9");
      var requests = firedart.Firestore.instance.collection("Requests");
      requests.stream.listen((onData) async {
        var newRequests = onData.where((d) {
          final fields = d.map;
          bool isListening = fields["listening"];
          int offerCount = fields["offerCount"];
          return isListening == false && offerCount > 0;
        }).toList();
        for (var request in newRequests) {
          var offers = firedart.Firestore.instance
              .collection("Requests/${request.id}/Offers");
          var requestFields = request.map;
          var consumer = requestFields["user"];
          requestStreams[request.id] =
              offers.stream.listen((onOfferData) async {
            var newOffers = onOfferData.where((o) {
              final fields = o.map;
              final broadcasted = fields["isBroadcasted"];
              return broadcasted == false;
            }).toList();
            for (var offer in newOffers) {
              var offerFields = offer.map;
              var offerDescription = offerFields["description"];
              // var user = await firestore.doc("Lobby/$consumer").get();
              // var userData = user.data();
              var chatID = requestFields["chatID"];
              try {
                await teledart.sendMessage(chatID,
                    "📬 New offer received for request ${request.id}:\n\n$offerDescription\n\n${offerFoot(offer.id)}",
                    parseMode: 'Markdown');
              } catch (e) {
                //
              }
              firestore
                  .doc("Requests/${request.id}/Offers/${offer.id}")
                  .update({"isBroadcasted": true})
                  .then((_) {})
                  .catchError((_) {});

              var discussions = firedart.Firestore.instance.collection(
                  "Requests/${request.id}/Offers/${offer.id}/Discussions");
              offerStreams[offer.id] =
                  discussions.stream.listen((onDiscussData) async {
                var newDiscussions = onDiscussData.where((disc) {
                  final discussionFields = disc.map;
                  final broadcasted = discussionFields["broadcasted"];
                  final sender = discussionFields["sender"];
                  return broadcasted == false && sender != consumer;
                }).toList();
                for (var diss in newDiscussions) {
                  var dissFields = diss.map;
                  var dissDescription = dissFields["description"];
                  try {
                    await teledart.sendMessage(chatID,
                        "📩 New Discussion reply received on offer ${offer.id}:\n\n$dissDescription\n\n${offerFoot(offer.id)}",
                        parseMode: 'Markdown');
                  } catch (e) {
                    //
                  }
                  firestore
                      .doc(
                          "Requests/${request.id}/Offers/${offer.id}/Discussions/${diss.id}")
                      .update({"broadcasted": true})
                      .then((_) {})
                      .catchError((_) {});
                }
              });
            }
          });

          firestore
              .doc("Requests/${request.id}")
              .update({"listening": true})
              .then((_) {})
              .catchError((_) {});
        }
      });
    });
  }
}

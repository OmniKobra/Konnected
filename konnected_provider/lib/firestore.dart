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
      "\n\nTo reply to this discusion - Tap __`/reply $requestID`__ then paste it followed by your reply and send it.\nIf you want to report this request - __`Tap /report $requestID`__";
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

  static Future<bool> checkProviderSubscriptionValid(
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
        bool rolesMatch = await subRoleMatchesRole(message, "provider");
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

  static Future<void> startProvider(TeleDartMessage message) async {
    final userID = getUID(message);
    firestore
        .doc("Provider Chats/$userID")
        .set({"chatID": message.chat.id})
        .then((_) {})
        .catchError((_) {
          reply(message,
              "Something wrong happend, please type /start again to ensure that you receive requests.");
        });
  }

  static Future<bool> hasOngoingOffer(
      TeleDartMessage message, String requestID) async {
    bool hasOffer = false;
    final userID = getUID(message);
    final requestDoc =
        await firestore.collection("Requests").doc(requestID).get();
    final fields = requestDoc.data();
    final offerCount = fields!["offerCount"];
    if (offerCount as int > 0) {
      final userOffer = await firestore
          .collection("Requests")
          .doc(requestID)
          .collection("Offers")
          .where("user", WhereFilter.equal, userID)
          .get();
      hasOffer = userOffer.docs.isNotEmpty;
      if (hasOffer) {
        reply(message, "❌ You already have an ongoing offer to this request.");
      }
    } else {
      hasOffer = false;
    }
    return hasOffer;
  }

  //TODO MAKE NEW OFFER - check if already made offer - and if request exists - and if has membership
  static Future<void> makeOffer(TeleDartMessage message) async {
    Future<void> continuation() async {
      var userID = getUID(message);
      var splitMessage = message.text!.split(" ");
      var length = splitMessage.length;
      if (length < 3) {
        reply(message,
            "❌ Invalid offer syntax, make sure to provide the request's ID after /offer, and provide your description after the id.\n\nExample: '/offer K20251638930 I've got your request, start a discussion so we can discuss more details.'");
      } else {
        var requestID = splitMessage[1];
        if (requestID.isNotEmpty && regex.hasMatch(requestID)) {
          var reqExists = await requestExists(message, requestID);
          if (reqExists) {
            var allowed = await checkIsAllowed(message);
            var dualActive = await checkDualSubscriptionValid(message);
            var subActive = dualActive
                ? true
                : await checkProviderSubscriptionValid(message);
            var hasOngoing = await hasOngoingOffer(message, requestID);
            bool canParticipate =
                allowed && (dualActive || subActive) && !hasOngoing;
            if (canParticipate) {
              var offerID = generateID(
                  isRequest: false,
                  isOffer: true,
                  isReport: false,
                  isSupport: false);
              var offerDoc =
                  firestore.doc("Requests/$requestID/Offers/$offerID");
              String description = "";
              for (var i = 2; i < length; i++) {
                description = "$description${splitMessage[i]} ";
              }
              var requestDoc = firestore.doc("Requests/$requestID");
              requestDoc
                  .update({"offerCount": FieldValue.increment(1)}).then((_) {
                offerDoc.set({
                  "description": description,
                  "user": userID,
                  "date": nowUtc(),
                  "isBroadcasted": false,
                  "listening": false,
                  "declined": false,
                }).then((_) {
                  showSuccess(message,
                      "Offer $offerID to Request $requestID has been created.");
                  offerDoc
                      .collection("Discussions")
                      .doc()
                      .set({
                        "broadcasted": true,
                        "sender": userID,
                        "description": "foo",
                        "date": nowUtc(),
                      })
                      .then((_) {})
                      .catchError((_) {});
                  firestore
                      .doc("Info/Details")
                      .update({"offers": FieldValue.increment(1)})
                      .then((_) {})
                      .catchError((_) {});
                }).catchError((_) {
                  showError(message);
                });
              }).catchError((_) {
                showError(message);
              });
            }
          }
        } else {
          message
              .reply("❌ Invalid request ID, please provide a valid request ID");
        }
      }
    }

    handleUserExistenceOp(message, continuation);
  }

  //TODO REPLY TO REQUEST DISCUSSION - check if has offer - check if offer was declined
  static Future<void> providerReplyDiscussion(TeleDartMessage message) async {
    var splitMessage = message.text!.split(" ");
    var length = splitMessage.length;
    if (length < 3) {
      reply(message,
          "❌ Invalid reply syntax, make sure to provide the request's ID after /reply, and provide your query after the id.\n\nExample: '/reply K20251638930 When do you need it delivered?'");
    } else {
      var requestID = splitMessage[1];
      if (requestID.isNotEmpty && regex.hasMatch(requestID)) {
        final userID = getUID(message);
        final request =
            await firestore.collection("Requests").doc(requestID).get();
        if (request.exists) {
          var offerDocs = await firestore
              .collection("Requests/$requestID/Offers")
              .where("user", WhereFilter.equal, userID)
              .get();
          bool offerExists = offerDocs.docs.isNotEmpty;
          if (offerExists) {
            bool canSend = true;
            var offerData = offerDocs.docs.first.data();
            var isDeclined = offerData["declined"];
            if (isDeclined as bool) {
              canSend = false;
              reply(message,
                  "❌ The request's consumer has declined your offer, you can no longer send replies to the discussion.");
            }
            var discussionCollection = await firestore
                .collection(
                    "Requests/$requestID/Offers/${offerDocs.docs.first.id}/Discussions")
                .orderBy("date", descending: true)
                .get();
            if (discussionCollection.docs.isNotEmpty) {
              var firstOne = discussionCollection.docs.first;
              var firstData = firstOne.data();
              var firstSender = firstData["sender"];
              if (firstSender == userID) {
                canSend = false;
                reply(message,
                    "❌ You have already sent a reply to this discussion, you can discuss again once the consumer returns a response by typing /reply $requestID followed by your reply.");
              }
            } else {
              canSend = false;
              reply(message,
                  "❌ The consumer has not opened a discussion about your offer yet, you can only reply to discussions once the request's consumer asks for more details.");
            }
            if (canSend) {
              String description = "";
              for (var i = 2; i < length; i++) {
                description = "$description${splitMessage[i]} ";
              }
              firestore
                  .collection(
                      "Requests/$requestID/Offers/${offerDocs.docs.first.id}/Discussions")
                  .doc()
                  .set({
                "sender": userID,
                "description": description,
                "date": nowUtc(),
                "broadcasted": false
              }).then((_) {
                showSuccess(message, "reply sent!");
              }).catchError((_) {
                showError(message);
              });
            }
          } else {
            reply(message,
                "❌ You do not have an ongoing offer in this request. You can make an offer by tapping __`/offer $requestID`__ then pasting it followed by your offer's details and then sending it.",
                parseMode: 'Markdown');
          }
        } else {
          reply(message,
              "❌ No requests found with id: $requestID, It may have been cancelled or the consumer accepted an offer.");
        }
      } else {
        reply(message,
            "❌ Invalid request ID, make sure you provide a valid request ID with no special characters");
      }
    }
  }

  //TODO REPORT REQUEST
  static Future<void> reportRequest(TeleDartMessage message) async {
    final userID = getUID(message);
    final msgText = message.text!;
    final requestID = msgText.replaceFirst("/report ", "");
    var allowed = await checkIsAllowed(message);
    if (allowed) {
      if (requestID.isNotEmpty && regex.hasMatch(requestID)) {
        bool exists = await requestExists(message, requestID.trim());
        if (exists) {
          final request = await firestore.doc("Requests/$requestID").get();
          final offerData = request.data();
          var reportID = generateID(
              isRequest: false,
              isOffer: false,
              isReport: true,
              isSupport: false);
          final requestDescription = offerData!["description"];
          final requestUser = offerData["user"];
          final requestDate = offerData["date"];
          firestore.doc("Report Tickets/$reportID").set({
            "type": "request",
            "description": requestDescription,
            "user": requestUser,
            "reporter": userID,
            "date": requestDate,
            "broadcasted": false,
            "reportDate": nowUtc()
          }).then((_) {
            showSuccess(message,
                "Request $requestID has been reported successfully, our admins will review the report and take action soon.");
            firestore
                .doc("Info/Details")
                .update({"reportedRequests": FieldValue.increment(1)})
                .then((_) {})
                .catchError((_) {});
          }).catchError((_) {
            showError(message);
          });
        } else {
          reply(message, "❌ No requests found matching that ID.");
        }
      } else {
        message
            .reply("❌ Invalid request ID, please provide a valid request ID.");
      }
    }
  }

  // TODO LISTEN FOR NEW REQUESTS
  static void providerListenToRequests(TeleDart teledart) async {
    firedart.FirebaseAuth.initialize(
        "AIzaSyCPSi0Kxed6cJzSv5BBrLtVn70OS-cq7gQ", firedart.VolatileStore());
    firedart.FirebaseAuth.instance.signInAnonymously().then((val) {
      firedart.Firestore.initialize("konnected-97cf9");
      var requests = firedart.Firestore.instance.collection("Requests");
      requests.stream.listen((onData) async {
        var newRequests = onData.where((d) {
          final fields = d.map;
          bool isBroadcasted = fields["broadcasted"];
          return isBroadcasted == false;
        }).toList();
        for (var request in newRequests) {
          var requestFields = request.map;
          var description = requestFields["description"] as String;
          var country = requestFields["location"] as String;
          var isGlobal = requestFields["isGlobal"] as bool;
          String prefix = isGlobal ? "🌎 Global" : "📍 $country";
          if (isGlobal) {
            var globalUsers = await firestore
                .collection("Lobby")
                .where("Global", WhereFilter.equal, true)
                .where("Role", WhereFilter.equal, "provider")
                .get();
            var globalDualUsers = await firestore
                .collection("Lobby")
                .where("Global", WhereFilter.equal, true)
                .where("Role", WhereFilter.equal, "dual")
                .get();
            var globalUserDocs = globalUsers.docs;
            var globualDualUserDocs = globalDualUsers.docs;
            for (var globalUser in globalUserDocs) {
              var rightNow = nowUtc();
              var globalUserData = globalUser.data();
              var trialEndStamp = globalUserData["dateTrialEnd"] as Timestamp;
              var trialEndDate = timestampToDate(trialEndStamp);
              var trialOver = trialEndDate!.isBefore(rightNow);
              var subscriptionEndStamp =
                  globalUserData["dateSubscriptionEnd"] as Timestamp;
              var subscriptionEndDate = timestampToDate(subscriptionEndStamp);
              var subscriptionOver = subscriptionEndDate!.isBefore(rightNow);
              var isPermanentUser =
                  globalUserData["isPermanentlySubscribed"] as bool;
              var isBanned = globalUserData["isBanned"] as bool;
              if (!isBanned) {
                var providerChatDoc = await firestore
                    .doc("Provider Chats/${globalUser.id}")
                    .get();
                if (providerChatDoc.exists) {
                  var chatID = providerChatDoc.data()!["chatID"];
                  if (trialOver && subscriptionOver && !isPermanentUser) {
                    try {
                      await teledart.sendMessage(chatID,
                          "Your Konnected subscription is inactive or has expired, head to $lobbyBot and type /subscription to manage your plan.");
                    } catch (e) {
                      //
                    }
                  } else {
                    try {
                      await teledart.sendMessage(chatID,
                          "New $prefix Request received:\n\n$description\n\nTo make an offer to this request tap __`/offer ${request.id}`__ then paste it followed by your offer description.\nEx: '/offer ${request.id} I can provide what you want, discuss with me for more details'\n\nIf you want to report this request - Tap __`/report ${request.id}`__",
                          parseMode: 'Markdown');
                    } catch (e) {
                      //
                    }
                  }
                }
              }
            }
            for (var globalDualUser in globualDualUserDocs) {
              var rightNow = nowUtc();
              var globalDualUserData = globalDualUser.data();
              var trialEndStamp =
                  globalDualUserData["dateTrialEnd"] as Timestamp;
              var trialEndDate = timestampToDate(trialEndStamp);
              var trialOver = trialEndDate!.isBefore(rightNow);
              var subscriptionEndStamp =
                  globalDualUserData["dateSubscriptionEnd"] as Timestamp;
              var subscriptionEndDate = timestampToDate(subscriptionEndStamp);
              var subscriptionOver = subscriptionEndDate!.isBefore(rightNow);
              var isPermanentUser =
                  globalDualUserData["isPermanentlySubscribed"] as bool;
              var isBanned = globalDualUserData["isBanned"] as bool;
              if (!isBanned) {
                var providerChatDoc = await firestore
                    .doc("Provider Chats/${globalDualUser.id}")
                    .get();
                if (providerChatDoc.exists) {
                  var chatID = providerChatDoc.data()!["chatID"];
                  if (trialOver && subscriptionOver && !isPermanentUser) {
                    try {
                      await teledart.sendMessage(chatID,
                          "Your Konnected subscription is inactive or has expired, head to $lobbyBot and type /subscription to manage your plan.");
                    } catch (e) {
                      //
                    }
                  } else {
                    try {
                      await teledart.sendMessage(chatID,
                          "New $prefix Request received:\n\n$description\n\nTo make an offer to this request tap __`/offer ${request.id}`__ then paste it followed by your offer description.\nEx: '/offer ${request.id} I can provide what you want, discuss with me for more details'\n\nIf you want to report this request - Tap __`/report ${request.id}`__",
                          parseMode: 'Markdown');
                    } catch (e) {
                      //
                    }
                  }
                }
              }
            }
          } else {
            var countryUsers = await firestore
                .collection("Lobby")
                .where("Country", WhereFilter.equal, country)
                .where("Role", WhereFilter.equal, "provider")
                .get();
            var countryDualUsers = await firestore
                .collection("Lobby")
                .where("Country", WhereFilter.equal, country)
                .where("Role", WhereFilter.equal, "dual")
                .get();
            var countryUserDocs = countryUsers.docs;
            var countryDualUserDocs = countryDualUsers.docs;
            for (var countryUser in countryUserDocs) {
              var rightNow = nowUtc();
              var countryUserData = countryUser.data();
              var trialEndStamp = countryUserData["dateTrialEnd"] as Timestamp;
              var trialEndDate = timestampToDate(trialEndStamp);
              var trialOver = trialEndDate!.isBefore(rightNow);
              var subscriptionEndStamp =
                  countryUserData["dateSubscriptionEnd"] as Timestamp;
              var subscriptionEndDate = timestampToDate(subscriptionEndStamp);
              var subscriptionOver = subscriptionEndDate!.isBefore(rightNow);
              var isPermanentUser =
                  countryUserData["isPermanentlySubscribed"] as bool;
              var isBanned = countryUserData["isBanned"] as bool;
              if (!isBanned) {
                var providerChatDoc = await firestore
                    .doc("Provider Chats/${countryUser.id}")
                    .get();
                if (providerChatDoc.exists) {
                  var chatID = providerChatDoc.data()!["chatID"];
                  if (trialOver && subscriptionOver && !isPermanentUser) {
                    try {
                      await teledart.sendMessage(chatID,
                          "Your Konnected subscription is inactive or has expired, head to $lobbyBot and type /subscription to manage your plan.");
                    } catch (e) {
                      //
                    }
                  } else {
                    try {
                      await teledart.sendMessage(chatID,
                          "New $prefix Request received:\n\n$description\n\nTo make an offer to this request tap __`/offer ${request.id}`__ then paste it followed by your offer description.\nEx: '/offer ${request.id} I can provide what you want, discuss with me for more details'\n\nIf you want to report this request - Tap __`/report ${request.id}`__",
                          parseMode: 'Markdown');
                    } catch (e) {
                      //
                    }
                  }
                }
              }
            }
            for (var countryDualUser in countryDualUserDocs) {
              var rightNow = nowUtc();
              var countryDualUserData = countryDualUser.data();
              var trialEndStamp =
                  countryDualUserData["dateTrialEnd"] as Timestamp;
              var trialEndDate = timestampToDate(trialEndStamp);
              var trialOver = trialEndDate!.isBefore(rightNow);
              var subscriptionEndStamp =
                  countryDualUserData["dateSubscriptionEnd"] as Timestamp;
              var subscriptionEndDate = timestampToDate(subscriptionEndStamp);
              var subscriptionOver = subscriptionEndDate!.isBefore(rightNow);
              var isPermanentUser =
                  countryDualUserData["isPermanentlySubscribed"] as bool;
              var isBanned = countryDualUserData["isBanned"] as bool;
              if (!isBanned) {
                var providerChatDoc = await firestore
                    .doc("Provider Chats/${countryDualUser.id}")
                    .get();
                if (providerChatDoc.exists) {
                  var chatID = providerChatDoc.data()!["chatID"];
                  if (trialOver && subscriptionOver && !isPermanentUser) {
                    try {
                      await teledart.sendMessage(chatID,
                          "Your Konnected subscription is inactive or has expired, head to $lobbyBot and type /subscription to manage your plan.");
                    } catch (e) {
                      //
                    }
                  } else {
                    try {
                      await teledart.sendMessage(chatID,
                          "New $prefix Request received:\n\n$description\n\nTo make an offer to this request tap __`/offer ${request.id}`__ then paste it followed by your offer description.\nEx: '/offer ${request.id} I can provide what you want, discuss with me for more details'\n\nIf you want to report this request - Tap __`/report ${request.id}`__",
                          parseMode: 'Markdown');
                    } catch (e) {
                      //
                    }
                  }
                }
              }
            }
          }
          firestore
              .doc("Requests/${request.id}")
              .update({"broadcasted": true})
              .then((_) {})
              .catchError((_) {});
          var offers = firedart.Firestore.instance
              .collection("Requests/${request.id}/Offers");
          requestStreams[request.id] =
              offers.stream.listen((onOfferData) async {
            var newOffers = onOfferData.where((o) {
              final fields = o.map;
              final isListening = fields["listening"];
              return isListening == false;
            }).toList();
            for (var offer in newOffers) {
              var offerFields = offer.map;
              var provider = offerFields["user"];
              var providerChatDoc =
                  await firestore.doc("Provider Chats/$provider").get();
              firestore
                  .doc("Requests/${request.id}/Offers/${offer.id}")
                  .update({"listening": true})
                  .then((_) {})
                  .catchError((_) {});
              if (providerChatDoc.exists) {
                var userData = providerChatDoc.data();
                var chatID = userData!["chatID"];
                var discussions = firedart.Firestore.instance.collection(
                    "Requests/${request.id}/Offers/${offer.id}/Discussions");
                offerStreams[offer.id] =
                    discussions.stream.listen((onDiscussData) async {
                  var newDiscussions = onDiscussData.where((disc) {
                    final discussionFields = disc.map;
                    final broadcasted = discussionFields["broadcasted"];
                    final sender = discussionFields["sender"];
                    return broadcasted == false && sender != provider;
                  }).toList();
                  for (var diss in newDiscussions) {
                    var dissFields = diss.map;
                    var dissDescription = dissFields["description"];
                    try {
                      await teledart.sendMessage(chatID,
                          "📩 New Discussion reply received on request ${request.id}:\n\n$dissDescription\n\n${requestFoot(request.id)}",
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
            }
            var declinedOffers = onOfferData.where((o) {
              final fields = o.map;
              final isDeclined = fields["declined"];
              final isAccepted = fields["accepted"];
              return isDeclined == true && isAccepted == false;
            }).toList();
            for (var declinedOffer in declinedOffers) {
              var reqDoc = await firestore.doc("Requests/${request.id}").get();
              if (reqDoc.exists) {
                var declinedFields = declinedOffer.map;
                var offerer = declinedFields["user"];
                var providerChatDoc =
                    await firestore.doc("Provider Chats/$offerer").get();
                if (providerChatDoc.exists) {
                  var userData = providerChatDoc.data();
                  var chatID = userData!["chatID"];
                  try {
                    await teledart.sendMessage(chatID,
                        "🤬 Your offer to ${request.id} has been declined by the consumer.");
                  } catch (e) {
                    //
                  }
                }
                if (offerStreams[declinedOffer.id] != null) {
                  offerStreams[declinedOffer.id]!.cancel();
                  offerStreams.remove(declinedOffer.id);
                }
              }
            }
            var acceptedOffers = onOfferData.where((o) {
              final fields = o.map;
              final isAccepted = fields["accepted"];
              final isDeclined = fields["declined"];
              return isAccepted == true && isDeclined == false;
            }).toList();
            for (var acceptedOffer in acceptedOffers) {
              var reqDoc = await firestore.doc("Requests/${request.id}").get();
              if (reqDoc.exists) {
                var acceptedFields = acceptedOffer.map;
                var offerer = acceptedFields["user"];
                var providerChatDoc =
                    await firestore.doc("Provider Chats/$offerer").get();
                if (providerChatDoc.exists) {
                  var userData = providerChatDoc.data();
                  var chatID = userData!["chatID"];
                  try {
                    await teledart.sendMessage(chatID,
                        "🎉 Your offer to ${request.id} has been accepted by the consumer.");
                  } catch (e) {
                    //
                  }
                }
                if (offerStreams[acceptedOffer.id] != null) {
                  offerStreams[acceptedOffer.id]!.cancel();
                  offerStreams.remove(acceptedOffer.id);
                }
              }
            }
          });
        }
        // requestStreams.forEach((k, e) {
        //   if (!onData.any((doc) => doc.id == k)) {
        //     if (requestStreams[k] != null) {
        //       requestStreams[k]!.cancel();
        //       requestStreams.remove(k);
        //     }
        //   }
        // });
      });
    });
  }
}

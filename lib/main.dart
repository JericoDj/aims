import 'package:aims/screens/authentication/loginscreen.dart';
import 'package:aims/screens/authentication_repository.dart';
import 'package:aims/screens/offline_controller.dart';
import 'package:aims/utils/user_storage.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'controller/notification_controller.dart';
import 'firebase_options.dart';


// ✅ Initialize Local Notifications
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

/// ✅ Background message handler (Must be a top-level function)
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint("✅ Background Message: \${message.notification?.title}");
}

/// ✅ Initialize Firebase Messaging and Notifications
Future<void> _initializeNotifications() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // ✅ Request notification permissions
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    debugPrint("✅ Notifications enabled.");
  } else {
    debugPrint("❌ Notifications denied.");
  }

  // ✅ Initialize Local Notifications for Android & iOS
  const AndroidInitializationSettings androidInitializationSettings =
  AndroidInitializationSettings('@mipmap/ic_launcher');

  const DarwinInitializationSettings iosInitializationSettings =
  DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );

  final InitializationSettings initializationSettings = InitializationSettings(
    android: androidInitializationSettings,
    iOS: iosInitializationSettings,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) {
      debugPrint("🔔 Notification Clicked: \${response.payload}");
    },
  );

  // ✅ Listen for foreground messages
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    debugPrint("✅ Foreground Message: \${message.notification?.title}");
    _showNotification(message);
  });

  // ✅ Handle background messages
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // ✅ Ensure APNS token is fetched for iOS
  if (defaultTargetPlatform == TargetPlatform.iOS) {
    final apnsToken = await FirebaseMessaging.instance.getAPNSToken();
    if (apnsToken != null) {
      debugPrint("✅ APNS Token: \$apnsToken");
    } else {
      debugPrint("❌ Failed to fetch APNS token.");
    }
  }
}

/// ✅ Wait for APNs Token, then fetch FCM Token
Future<void> _waitForAPNSTokenAndGetFCMToken() async {
  String? apnsToken;
  int retries = 0;

  // Retry getting APNs token up to 5 times (1 sec apart)
  while (apnsToken == null && retries < 5) {
    await Future.delayed(const Duration(seconds: 1));
    apnsToken = await FirebaseMessaging.instance.getAPNSToken();
    retries++;
  }

  if (apnsToken != null) {
    debugPrint("✅ APNs Token: $apnsToken");

    // Now safely get FCM token
    final fcmToken = await FirebaseMessaging.instance.getToken();
    if (fcmToken != null) {
      debugPrint("✅ FCM Token: $fcmToken");
      // 🔐 Save or sync token with your backend if needed
    } else {
      debugPrint("❌ Failed to get FCM Token after APNs was set.");
    }
  } else {
    debugPrint("⚠️ APNs Token still null after retries. Skipping FCM registration.");
  }
}


/// ✅ Show local notification
Future<void> _showNotification(RemoteMessage message) async {
  AndroidNotificationDetails androidPlatformChannelSpecifics =
  const AndroidNotificationDetails(
    'default_channel', 'Default Channel',
    importance: Importance.max,
    priority: Priority.high,
    showWhen: false,
  );

  NotificationDetails platformChannelSpecifics =
  NotificationDetails(android: androidPlatformChannelSpecifics);

  await flutterLocalNotificationsPlugin.show(
    0,
    message.notification?.title ?? "New Notification",
    message.notification?.body ?? "You have a new message",
    platformChannelSpecifics,
  );
}

void main() async {
  // Register the NotificationController globally before running the app

  Get.put(ConnectToOfflineController());
  Get.put(NotificationController());

  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ).then((FirebaseApp value) => Get.put(AuthenticationRepository()));

    // ✅ Initialize notifications
    await _initializeNotifications();

    // ✅ 🆕 Wait for APNs token, then get FCM token
    await _waitForAPNSTokenAndGetFCMToken();

    // ✅ Initialize GetStorage
    await LocalStorage.init();

    // ✅ Request necessary permissions
    await _requestPermissions();

    if (kIsWeb) {
      // ✅ If running on web, use WebApp
      Get.testMode = true;
      runApp(WebApp());
    } else {
      // ✅ If running on mobile, use MyApp
      runApp(const MyApp());
    }
  } catch (e) {
    debugPrint("❌ Firebase initialization failed: \$e");
  }
}

/// ✅ Request Permissions for Android & iOS
Future<void> _requestPermissions() async {

  // Basic permissions
  await [
    Permission.camera,
    Permission.microphone,
    Permission.storage,
    Permission.manageExternalStorage,
  ].request();

  // Notifications
  if (await Permission.notification.isDenied) {
    await Permission.notification.request();
  }

  // Photos - handled separately for better control
  await _handlePhotoPermissions();
}


Future<void> _handlePhotoPermissions() async {
  final status = await Permission.photosAddOnly.status;

  if (status.isGranted) {
    debugPrint("✅ Photo add permission already granted");
    return;
  }

  if (status.isPermanentlyDenied) {
    // Custom GetX dialog to explain and guide user
    Get.defaultDialog(
      title: 'Permission Needed',
      content: const Text(
          'To save QR codes to your gallery, photo permission is required.\n\nPlease enable access in Settings.'
      ),
      confirm: TextButton(
        onPressed: () async {
          Get.back();
          await openAppSettings(); // Send to iOS Settings
        },
        child: const Text('Open Settings'),
      ),
      cancel: TextButton(
        onPressed: () => Get.back(),
        child: const Text('Cancel'),
      ),
    );
    return;
  }

  // Safe to request now
  final result = await Permission.photosAddOnly.request();

  if (result.isGranted) {
    debugPrint("✅ Photo permission granted after request");
  } else {
    debugPrint("❌ Photo permission still denied");
  }
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AIMS Inventory',
      theme: ThemeData(
        fontFamily: 'Bourgeois',
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}

class WebApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 600,
        height: 800,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black, width: 2),
        ),
        child: GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'AIMS Inventory',
          theme: ThemeData(primarySwatch: Colors.blue),
          home: const LoginScreen(),
        ),
      ),
    );
  }
}
import 'package:camera/camera.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get_it/get_it.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:wean_app/blocs/bloc_observer.dart';
import 'package:wean_app/blocs/chat/chat_bloc.dart';
import 'package:wean_app/blocs/conversation/conversation_bloc.dart';
import 'package:wean_app/blocs/cubit/yard_cubit.dart';
import 'package:wean_app/blocs/order/order_bloc.dart';
import 'package:wean_app/blocs/preferences/preferences_bloc.dart';
import 'package:wean_app/blocs/report_product_bloc/report_product_bloc.dart';
import 'package:wean_app/blocs/user_details/user_details_bloc.dart';
import 'package:wean_app/common/appTheme.dart';
import 'package:wean_app/common/routes.dart';
import 'package:wean_app/services/firebase_messaging_services.dart';
import 'package:wean_app/services/notification_services.dart';
import 'package:wean_app/translations/codegen_loader.g.dart';

NavigatorState? navigatorState;

final GetIt getIt = GetIt.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras(); //Get list of available cameras
  await EasyLocalization.ensureInitialized();
  await Firebase.initializeApp();
  getIt.registerLazySingleton<NotificationServices>(
    () => NotificationServices(),
  );
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    // navigation bar color
    statusBarColor: AppTheme.primaryStartColor, // status bar color
  ));

  // Pass all uncaught errors from the framework to Crashlytics.
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
  Bloc.observer = MyBlocObserver();
  await SentryFlutter.init((options) {
    options.dsn =
        'https://83cb10ca59164077a9c4af4de63a3eac@o1079481.ingest.sentry.io/6088053';
  },
      appRunner: () => runApp(EasyLocalization(
          child: WeanApp(cameras: cameras),
          assetLoader: CodegenLoader(),
          supportedLocales: [
            Locale('en'),
            Locale('ar'),
          ],
          fallbackLocale: Locale('en'),
          path: 'assets/translations')));
  configLoading();
}

void configLoading() {
  EasyLoading.instance
    ..displayDuration = const Duration(milliseconds: 2000)
    ..indicatorType = EasyLoadingIndicatorType.fadingCircle
    ..loadingStyle = EasyLoadingStyle.dark
    ..indicatorSize = 45.0
    ..radius = 10.0
    ..progressColor = Colors.yellow
    ..backgroundColor = Colors.green
    ..indicatorColor = Colors.yellow
    ..textColor = Colors.yellow
    ..maskColor = Colors.blue.withOpacity(0.5)
    ..userInteractions = true
    ..toastPosition = EasyLoadingToastPosition.top
    ..dismissOnTap = false;
}

class WeanApp extends StatefulWidget {
  final List<CameraDescription> cameras;
  const WeanApp({Key? key, required this.cameras}) : super(key: key);
  @override
  _WeanAppState createState() => _WeanAppState();
}

class _WeanAppState extends State<WeanApp> {
  final GlobalKey<NavigatorState> navigatorStateKey =
      GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    navigatorState = navigatorStateKey.currentState;
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => PreferencesBloc(),
        ),
        BlocProvider(
          create: (context) => OrderBloc(),
        ),
        BlocProvider(
          create: (context) => UserDetailsBloc(),
        ),
        BlocProvider(
          create: (context) => YardCubit(),
        ),
        BlocProvider(
          create: (context) => ConversationBloc(),
        ),
        BlocProvider(
          create: (context) => ChatBloc(),
        ),
        BlocProvider(
          create: (context) => ReportProductBloc(),
        ),
      ],
      child: MaterialApp(
        supportedLocales: context.supportedLocales,
        localizationsDelegates: context.localizationDelegates,
        locale: context.locale,
        navigatorKey: navigatorStateKey,
        initialRoute: '/',
        onGenerateRoute: RouteFinding().generateRoute,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.appThemeData,
        builder: (context, child) {
          return StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data != null)
                FirebaseMessagingServices().checkAndUpdateFCMToken();
              return FlutterEasyLoading(
                  child: MyInheritedWidget(
                child: child!,
                camera: widget.cameras,
              ));
            },
          );
        },
      ),
    );
  }
}

class MyInheritedWidget extends InheritedWidget {
  const MyInheritedWidget({
    Key? key,
    required this.camera,
    required Widget child,
  }) : super(key: key, child: child);

  final List<CameraDescription> camera;

  static MyInheritedWidget? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<MyInheritedWidget>();
  }

  @override
  bool updateShouldNotify(MyInheritedWidget old) => camera != old.camera;
}
//flutter pub run easy_localization:generate -S "assets/translations" -O "lib/translations"
//flutter pub run easy_localization:generate -S "assets/translations" -O "lib/translations" -o "locale_keys.g.dart" -f keys
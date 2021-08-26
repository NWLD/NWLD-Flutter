import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';

import 'l10n/base_localizations.dart';
import 'l10n/base_localizations_delegate.dart';
import 'models/settings_model.dart';
import 'models/theme.dart';
import 'pages/splash.dart';
import 'routes/routes.dart';
import 'util/cache_util.dart';

void main() async {
  Provider.debugCheckInvalidValueType = null;
  WidgetsFlutterBinding.ensureInitialized();
  await CacheUtil.init();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MyAppState();
  }
}

class MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return OKToast(
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: SettingsModel()),
        ],
        child: Consumer<SettingsModel>(
          builder: (BuildContext context, appStateModel, Widget child) {
            return ScreenUtilInit(
              designSize: Size(750, 1334),
              builder: () {
                return MaterialApp(
                  debugShowCheckedModeBanner: false,
                  theme: ThemeConfig.lightTheme,
                  darkTheme: ThemeConfig.lightTheme,
                  themeMode: appStateModel.isDarkMode
                      ? ThemeMode.dark
                      : ThemeMode.light,
                  onGenerateTitle: (context) =>
                      BaseLocalizations.$t('TopRich', context),
                  // locale
                  localizationsDelegates: [
                    BaseLocalizationsDelegate(),
                    GlobalCupertinoLocalizations.delegate,
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                  ],
                  locale: appStateModel.getSelectedLocale(),
                  supportedLocales: appStateModel.supportedLocales(),
                  localeListResolutionCallback: (locales, supportedLocales) {
                    final selectedLocale = appStateModel.getSelectedLocale();

                    if (selectedLocale != null) {
                      return selectedLocale;
                    }

                    for (Locale locale in locales) {
                      for (Locale supportedLocale in supportedLocales) {
                        if (locale.languageCode ==
                                supportedLocale.languageCode ||
                            locale.countryCode == supportedLocale.countryCode) {
                          return supportedLocale;
                        }
                      }
                    }

                    return supportedLocales.first;
                  },
                  home: SplashPage(),
                  onGenerateRoute: routes,
                  builder: EasyLoading.init(),
                  navigatorObservers: [],
                );
              },
            );
          },
        ),
      ),
    );
  }
}

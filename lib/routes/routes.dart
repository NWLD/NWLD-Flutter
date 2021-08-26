import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../pages/login.dart';
import '../pages/splash.dart';

class RouteMap {
  static const root = '/';
  static const home = '/home';
  static const game = '/game';
  static const wallet = '/wallet';
  static const walletRecords = '/wallet/records';
  static const team = '/team';
  static const teamInvitations = '/team/invitations';
  static const teamFriends = '/team/friends';
  static const teamWalletRecords = '/team/wallet/records';
  static const teamRules = '/team/rules';
  static const messages = '/messages';
  static const rank = '/rank';
  static const login = '/login';
  static const settings = '/settings';
  static const mineInviteCode = "/mininvitecode";

  static const dogs = '/dogs';
  static const effortDog = '/dogs/effort';
  static const dividendDogRecords = '/dogs/dividend/records';

  static const guide = '/guide';
  static const webview = '/webview';

  static const reviewHome = "/review/home";
  static const reviewDetail = "/review/detail";
}

Route routes(RouteSettings settings) {
  switch (settings.name) {
    case RouteMap.root:
      return MaterialPageRoute(builder: (context) => SplashPage());
    case RouteMap.home:
      return MaterialPageRoute(builder: (context) => SplashPage());
    case RouteMap.game:
      return MaterialPageRoute(
          builder: (context) => SplashPage(), settings: settings);
    case RouteMap.wallet:
      return CupertinoPageRoute(builder: (context) => SplashPage());
    case RouteMap.walletRecords:
      return CupertinoPageRoute(builder: (context) => SplashPage());
    case RouteMap.effortDog:
      return CupertinoPageRoute(builder: (context) => SplashPage());
    case RouteMap.guide:
      return MaterialPageRoute(builder: (context) => SplashPage());
    case RouteMap.login:
      return MaterialPageRoute(builder: (context) {
        return LoginPage();
      });
    case RouteMap.team:
      return CupertinoPageRoute(builder: (context) => SplashPage());
    case RouteMap.teamInvitations:
      return CupertinoPageRoute(builder: (context) => SplashPage());
    case RouteMap.teamFriends:
      return CupertinoPageRoute(builder: (context) => SplashPage());
    case RouteMap.teamWalletRecords:
      return CupertinoPageRoute(builder: (context) => SplashPage());
    case RouteMap.teamRules:
      return CupertinoPageRoute(builder: (context) => SplashPage());
    case RouteMap.messages:
      return CupertinoPageRoute(builder: (context) => SplashPage());
    case RouteMap.settings:
      return CupertinoPageRoute(builder: (context) => SplashPage());
    case RouteMap.dividendDogRecords:
      return CupertinoPageRoute(builder: (context) => SplashPage());
    case RouteMap.mineInviteCode:
      return CupertinoPageRoute(builder: (context) => SplashPage());
    case RouteMap.webview:
      return CupertinoPageRoute(builder: (BuildContext context) {
        Map<String, dynamic> args = settings.arguments;

        return SplashPage(
            // title: args['title'],
            // url: args['url'],
            );
      });
    case RouteMap.reviewHome:
      return CupertinoPageRoute(builder: (context) => SplashPage());
    case RouteMap.reviewDetail:
      return CupertinoPageRoute(builder: (BuildContext context) {
        Map<String, dynamic> args = settings.arguments;
        return SplashPage();
      });
  }
}

class RouteUtils {
  static openWebview(BuildContext context, String url, String title) {
    Navigator.pushNamed(context, RouteMap.webview, arguments: {
      'title': title,
      'url': url,
    });
  }
}

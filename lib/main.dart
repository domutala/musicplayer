import 'package:flutter/material.dart';
import 'package:musicplayer/interfaces/IPlaylist.dart';
import 'package:musicplayer/store/index.dart';
import 'package:musicplayer/utils/playlist.dart';
import 'package:musicplayer/views/index.dart';
import 'package:flutter/services.dart';
import 'package:musicplayer/components/Player.dart';
import 'package:musicplayer/utils/colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Store.init();

  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      // app bar
      statusBarColor: xTransparent,
      statusBarIconBrightness: xBrightness,

      // bottom navigation
      systemNavigationBarColor: xLight,
      systemNavigationBarIconBrightness: xBrightness,
      systemNavigationBarDividerColor: xLight,
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primaryColor: xPrimary,
        primaryColorLight: xLight,
        primaryColorDark: xDark,
        scaffoldBackgroundColor: xScafoldBg,
        textTheme: TextTheme(
          bodyText1: TextStyle(color: xDark),
          bodyText2: TextStyle(color: xDark),
        ),
        colorScheme: ColorScheme.fromSwatch().copyWith(secondary: xPrimary),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String? view;

  @override
  void initState() {
    super.initState();
    _init();
  }

  _init([bool? force]) async {
    if (force == true) {
      await init();
    } else {
      List pls = await Store.get('playlists');
      var playlists = pls.map((dt) => IPlaylist.fromJson(dt)).toList();
      var zero = playlists.where((p) => p.id == '0');

      if (zero.isEmpty) {
        addPlaylist(context, (p0) {});
        await init();
      } else if (zero.first.audios.isEmpty) {
        await init();
      }
    }
  }

  AppBar get appBar {
    return AppBar(
      backgroundColor: xPrimary,
      title: const Text(
        'Music',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
      toolbarHeight: 80,
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        // bottom navigation
        systemNavigationBarColor: xLight,
        systemNavigationBarIconBrightness: Brightness.light,
        systemNavigationBarDividerColor: xLight,
      ),
    );

    return Scaffold(
      appBar: appBar,
      body: Column(
        children: const [
          Flexible(
            fit: FlexFit.tight,
            child: VHome(),
          ),
          Player(),
        ],
      ),
    );
  }
}

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:music_player/bottombar/bottomnavigationbar.dart';
import 'package:music_player/database/songmodel_adapter.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';

import 'database/box.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(SongsAdapter());

  await Hive.openBox<List>(boxname);
  final box = Boxes.getInstance();

  List<dynamic> libraryKeys = box.keys.toList();

  if (!libraryKeys.contains("favorites")) {
    List<dynamic> likedSongs = [];
    await box.put("favorites", likedSongs);
  }

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final box = Boxes.getInstance();
  final assetAudioPlayer = AssetsAudioPlayer.withId("0");
  //final audioQuery = OnAudioQuery();

  List<Audio> audiosongs = [];
  final _audioQuery = OnAudioQuery();
  List<Songs> mappedSongs = [];
  List<Songs> dbSongs = [];
  List<SongModel> fetchedSongs = [];
  @override
  void initState() {
    super.initState();
    // requestPermission();
    fetchSongs();
  }

  List<SongModel> allsong = [];
  fetchSongs() async {
    bool permissionStatus = await _audioQuery.permissionsStatus();
    if (!permissionStatus) {
      await _audioQuery.permissionsRequest();
    }
    allsong = await _audioQuery.querySongs();

    mappedSongs = allsong
        .map((e) => Songs(
            title: e.title,
            id: e.id,
            uri: e.uri!,
            duration: e.duration,
            artist: e.artist))
        .toList();
    await box.put("musics", mappedSongs);
    dbSongs = box.get("musics") as List<Songs>;

    dbSongs.forEach((element) {
      audiosongs.add(Audio.file(element.uri.toString(),
          metas: Metas(
              title: element.title,
              id: element.id.toString(),
              artist: element.artist)));
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    //print(dbSongs.first.title);
    return MaterialApp(
        theme: ThemeData(
          textTheme: GoogleFonts.quandoTextTheme(
            ThemeData.light().textTheme,
          ),
        ),
        debugShowCheckedModeBanner: false,
        // home: BottomBar(allsong: audiosongs)

        home: AnimatedSplashScreen(
          backgroundColor: const Color(0xFF28172D),
          duration: 3000,
          splash: Padding(
            padding: const EdgeInsets.symmetric(vertical: 120),
            child: Column(children: [
              Image.asset("assets/images/musiclogo.png"),
              Text(
                "TuneBag",
                style: TextStyle(
                    color: Colors.pink,
                    fontSize: 20,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.bold),
              )
            ]),
          ),
          splashIconSize: double.infinity,
          nextScreen: BottomBar(allsong: audiosongs),
          splashTransition: SplashTransition.fadeTransition,
        ));
  }
}

import 'dart:ui';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:music_player/database/box.dart';
import 'package:music_player/database/songmodel_adapter.dart';
import 'package:music_player/openassetaudio/openassetaudio.dart';
import 'package:music_player/pages/playingsong.dart';

import 'package:music_player/pages/settings.dart';
import 'package:music_player/widgets/buildsheet.dart';
import 'package:music_player/widgets/snakbars.dart';

import 'package:on_audio_query/on_audio_query.dart';

// ignore: must_be_immutable
class Gridsong extends StatefulWidget {
  List<Audio> audiosongs = [];
  Gridsong({Key? key, required this.audiosongs}) : super(key: key);

  @override
  _GridsongState createState() => _GridsongState();
}

class _GridsongState extends State<Gridsong> {
  List? dbSongs = [];
  // late TextEditingController controller;
  List playlists = [];
  List<dynamic>? favorites = [];
  String? playlistName = '';

  List<dynamic>? likedSongs = [];

  final box = Boxes.getInstance();
  final AssetsAudioPlayer assetAudioPlayer = AssetsAudioPlayer.withId("0");
  final audioQuery = OnAudioQuery();

  Audio find(List<Audio> source, String fromPath) {
    return source.firstWhere((element) => element.path == fromPath);
  }

  @override
  void initState() {
    super.initState();
    dbSongs = box.get("musics");
    // controller = TextEditingController();
    likedSongs = box.get("favorites");
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    // controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFF091B46),
        appBar: AppBar(
          backgroundColor: const Color(0xFF091B46),
          elevation: 0,
          toolbarHeight: 65,
          title: const Text(
            "TuneBag",
            style: TextStyle(fontSize: 25),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) {
                  return Settings();
                }));
              },
            )
          ],
        ),
        body: Column(children: [
          Expanded(
            child: Stack(
              children: [
                GridView.builder(
                  physics: ScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 5,
                      crossAxisSpacing: 5,
                      childAspectRatio: 1.15),
                  itemCount: widget.audiosongs.length,
                  itemBuilder: (BuildContext ctx, int index) {
                    return Stack(
                        alignment: AlignmentDirectional.bottomCenter,
                        children: [
                          GestureDetector(
                            child: Stack(
                              alignment: AlignmentDirectional.bottomCenter,
                              children: [
                                Container(
                                  height: 160,
                                  width: 180,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(15.0),
                                    child: QueryArtworkWidget(
                                        nullArtworkWidget: Image.asset(
                                          "assets/images/default.jpeg",
                                        ),
                                        id: int.parse(widget
                                            .audiosongs[index].metas.id
                                            .toString()),
                                        type: ArtworkType.AUDIO),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 20, right: 20),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(15.0),
                                    child: Container(
                                      height: 40,
                                      width: 180,
                                      color: Colors.grey[400]!.withOpacity(0.5),
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            top: 8, left: 5),
                                        child: Text(
                                          widget.audiosongs[index].metas.title!,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 17),
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                            onTap: () async {
                              await OpenAssetAudio(allsong: [], index: index)
                                  .openAsset(
                                      index: index, audios: widget.audiosongs);
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => playingsong(
                                        index: index,
                                        audiosongs: widget.audiosongs,
                                      )));
                            },
                            onLongPress: () => showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                likedSongs = box.get("favorites");
                                return Dialog(
                                    backgroundColor: Colors.grey.withOpacity(1),
                                    // shape: RoundedRectangleBorder(
                                    //   borderRadius: BorderRadius.circular(50),
                                    // ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              widget
                                                  .audiosongs[index].metas.title
                                                  .toString(),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18),
                                            ),
                                            ListTile(
                                              title: const Text(
                                                "Add to Playlist",
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 20),
                                              ),
                                              // trailing: const Icon(Icons.add),
                                              onTap: () {
                                                Navigator.of(context).pop();
                                                showModalBottomSheet(
                                                    backgroundColor:
                                                        Colors.grey,
                                                    shape: const RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.vertical(
                                                                top: Radius
                                                                    .circular(
                                                                        20))),
                                                    context: context,
                                                    builder: (context) =>
                                                        BuildSheet(
                                                            song: widget
                                                                    .audiosongs[
                                                                index])
                                                    // buildSheet(song: dbSongs[index]),
                                                    );
                                              },
                                            ),
                                            likedSongs!
                                                    .where((element) =>
                                                        element.id.toString() ==
                                                        dbSongs![index]
                                                            .id
                                                            .toString())
                                                    .isEmpty
                                                ? ListTile(
                                                    title: const Text(
                                                      "Add to Favorites",
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 20),
                                                    ),
                                                    onTap: () async {
                                                      final songs =
                                                          box.get("musics")
                                                              as List<Songs>;
                                                      final temp = songs
                                                          .firstWhere((element) =>
                                                              element.id
                                                                  .toString() ==
                                                              widget
                                                                  .audiosongs[
                                                                      index]
                                                                  .metas
                                                                  .id
                                                                  .toString());
                                                      favorites = likedSongs;
                                                      favorites?.add(temp);
                                                      box.put("favorites",
                                                          favorites!);

                                                      Navigator.of(context)
                                                          .pop();
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                              SnackBars()
                                                                  .likedAdd);
                                                    },
                                                  )
                                                : ListTile(
                                                    title: const Text(
                                                        "Remove from Favorites"),
                                                    trailing: const Icon(
                                                      Icons.favorite_rounded,
                                                      color: Colors.redAccent,
                                                    ),
                                                    onTap: () async {
                                                      likedSongs?.removeWhere(
                                                          (elemet) =>
                                                              elemet.id
                                                                  .toString() ==
                                                              dbSongs![index]
                                                                  .id
                                                                  .toString());
                                                      await box.put("favorites",
                                                          likedSongs!);
                                                      setState(() {});

                                                      Navigator.of(context)
                                                          .pop();
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                              SnackBars()
                                                                  .likedRemove);
                                                    },
                                                  ),
                                          ]),
                                    ));
                              },
                            ),
                          )
                        ]);
                  },
                ),
                assetAudioPlayer.builderCurrent(
                    builder: (BuildContext context, Playing? playing) {
                  final myAudio =
                      find(widget.audiosongs, playing!.audio.assetAudioPath);
                  return Column(children: [
                    Expanded(
                        child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        height: 75,
                        decoration: BoxDecoration(
                            color: Colors.grey[900],
                            borderRadius: BorderRadius.all(Radius.circular(5))),
                        margin: const EdgeInsets.only(left: 5, right: 5),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => playingsong(
                                        index: 0,
                                        audiosongs: widget.audiosongs,
                                      )),
                            );
                          },
                          child: Row(
                            children: [
                              SizedBox(
                                height: 60,
                                width: 60,
                                child: QueryArtworkWidget(
                                  id: int.parse(myAudio.metas.id!),
                                  type: ArtworkType.AUDIO,
                                  artworkBorder: const BorderRadius.only(
                                      bottomLeft: Radius.circular(10),
                                      topLeft: Radius.circular(10)),
                                  artworkFit: BoxFit.cover,
                                  nullArtworkWidget: Container(
                                    height: 50,
                                    width: 50,
                                    decoration: const BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(10),
                                          topLeft: Radius.circular(10)),
                                      image: DecorationImage(
                                        image: AssetImage(
                                            "assets/images/default.jpeg"),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    left: 12,
                                    top: 12,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        myAudio.metas.title!,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 7),
                                      Text(
                                        myAudio.metas.artist!,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            color: Colors.grey,
                                            fontWeight: FontWeight.w400,
                                            fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 20),
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      assetAudioPlayer.previous();
                                    },
                                    child: const Icon(
                                      Icons.skip_previous_rounded,
                                      size: 35,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  PlayerBuilder.isPlaying(
                                      player: assetAudioPlayer,
                                      builder: (context, isPlaying) {
                                        return GestureDetector(
                                          onTap: () async {
                                            await assetAudioPlayer
                                                .playOrPause();
                                          },
                                          child: Icon(
                                            isPlaying
                                                ? Icons.pause_rounded
                                                : Icons.play_arrow_rounded,
                                            size: 35,
                                            color: Colors.white,
                                          ),
                                        );
                                      }),
                                  const SizedBox(width: 10),
                                  GestureDetector(
                                    onTap: () {
                                      assetAudioPlayer.next();
                                    },
                                    child: const Icon(
                                      Icons.skip_next_rounded,
                                      size: 35,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 15),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ))
                  ]);
                }),
              ],
            ),
          )
        ]));
  }
}

Widget dialogContainer(Widget child) {
  return ClipRRect(
    borderRadius: const BorderRadius.all(Radius.circular(15)),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
      child: Container(
        color: Colors.grey.withOpacity(0.1),
        child: child,
      ),
    ),
  );
}

Padding libraryList({required child}) {
  return Padding(
      padding: const EdgeInsets.only(left: 5, right: 5, bottom: 10),
      child: child);
}

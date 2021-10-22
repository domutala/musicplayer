import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:musicplayer/interfaces/IAudio.dart';
import 'package:musicplayer/interfaces/IPlaylist.dart';
import 'package:musicplayer/store/index.dart';
import 'package:musicplayer/utils/colors.dart';
import 'package:musicplayer/utils/showModalBottom.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:uuid/uuid.dart';

init() async {
  await addAudioToPlayList('0', []);

  final permitted = await PhotoManager.requestPermission();
  if (!permitted) return;

  final albums = await PhotoManager.getAssetPathList(
    type: RequestType.audio,
  );

  for (var album in albums) {
    for (var audio in (await album.assetList)) {
      var file = await audio.file;

      if (file != null) {
        await addAudioToPlayList('0', [
          IAudio(
            id: audio.id,
            title: audio.title,
            path: file.path,
            duration: audio.duration.toDouble(),
          )
        ]);
      }
    }
  }
}

addAudioToPlayList(String id, List<IAudio> audios) async {
  List pls = await Store.get('playlists');
  var _pls = pls.map((dt) => IPlaylist.fromJson(dt)).toList();

  if (_pls.isNotEmpty) {
    var pl = _pls.indexWhere((p) => p.id == id);
    if (pl != -1) {
      _pls[pl].audios.addAll(audios);

      await Store.save(key: 'playlists', value: []);
      for (var playlist in _pls) {
        List epls = await Store.get('playlists');
        epls.add(playlist.toJson);
        await Store.save(key: 'playlists', value: epls);
      }
    }
  }
}

removeAudioToPlayList(String id, List<IAudio> audios) async {
  List pls = await Store.get('playlists');
  var _pls = pls.map((dt) => IPlaylist.fromJson(dt)).toList();

  if (_pls.isNotEmpty) {
    var pl = _pls.indexWhere((p) => p.id == id);
    if (pl != -1) {
      for (var audio in audios) {
        _pls[pl].audios.remove(audio);
      }

      await Store.save(key: 'playlists', value: []);
      for (var playlist in _pls) {
        List epls = await Store.get('playlists');
        epls.add(playlist.toJson);
        await Store.save(key: 'playlists', value: epls);
      }
    }
  }
}

openPlaylist({
  required BuildContext context,
  List<IAudio>? audios,
  required Function(String id) goto,
}) async {
  Widget button(IPlaylist playlist) {
    return GestureDetector(
      onTap: () async {
        if (playlist.id != '0') {
          await addAudioToPlayList(playlist.id, audios ?? []);
        }
        Navigator.of(context).pop();
        goto(playlist.id);
      },
      child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
        color: xLight,
        child: Row(
          children: [
            Expanded(
              child: Text(
                playlist.name,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(),
              ),
            ),
            Container(
              child: playlist.id != '0'
                  ? GestureDetector(
                      onTap: () async {
                        List playlists = await Store.get('playlists');
                        var _playlists = playlists
                            .map((dt) => IPlaylist.fromJson(dt))
                            .toList();

                        _playlists.removeWhere((p) => p.id == playlist.id);

                        List pls = [];
                        for (var pl in _playlists) {
                          pls.add(pl.toJson);
                        }

                        await Store.save(key: 'playlists', value: pls);
                        Navigator.of(context).pop();
                        goto('0');
                      },
                      child: Container(
                        height: 20,
                        width: 20,
                        margin: const EdgeInsets.only(right: 10),
                        child: Center(
                          child: Icon(
                            FontAwesomeIcons.trash,
                            size: 13,
                            color: xDark,
                          ),
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  List playlists = await Store.get('playlists');
  var _playlists = playlists.map((dt) => IPlaylist.fromJson(dt)).toList();

  showModalBottom(
    color: xLight,
    context: context,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        addPlaylist(context, (_id) async {
          await addAudioToPlayList(_id, audios ?? []);
          Navigator.of(context).pop();
          goto(_id);
        }),
        for (var playlist in _playlists) button(playlist),
      ],
    ),
  );
}

Widget addPlaylist(BuildContext context, Function(String) onSave) {
  OutlineInputBorder border = OutlineInputBorder(
    borderSide: BorderSide(color: xDark, width: .1),
    borderRadius: BorderRadius.circular(10.0),
  );
  TextEditingController controller = TextEditingController();

  return Container(
    padding: const EdgeInsets.all(20),
    child: Material(
      borderRadius: BorderRadius.circular(5.0),
      color: xLight,
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: 'Ajouter',
          hintStyle: TextStyle(color: xDark.withOpacity(.5)),
          labelStyle: TextStyle(color: xDark.withOpacity(.5)),
          filled: true,
          fillColor: xDark.withOpacity(0.05),
          enabledBorder: border,
          border: border,
          focusedBorder: border,
          suffixIcon: Padding(
            padding: const EdgeInsetsDirectional.only(end: 12.0),
            child: GestureDetector(
              onTap: () async {
                if (controller.text.isNotEmpty) {
                  List playlists = await Store.get('playlists');
                  var _playlists =
                      playlists.map((dt) => IPlaylist.fromJson(dt)).toList();
                  var id = const Uuid().v1();

                  _playlists.add(IPlaylist(
                    id: id,
                    audios: [],
                    name: controller.text,
                  ));

                  List pls = [];
                  for (var pl in _playlists) {
                    pls.add(pl.toJson);
                  }

                  await Store.save(key: 'playlists', value: pls);

                  onSave(id);
                }
              },
              child: Container(
                width: 30,
                height: 30,
                alignment: Alignment.center,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: xPrimary,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Icon(Icons.check, color: xLight, size: 16),
                ),
              ),
            ),
          ),
        ),
        keyboardType: TextInputType.text,
        style: TextStyle(color: xDark),
        onChanged: (v) {},
      ),
    ),
  );
}

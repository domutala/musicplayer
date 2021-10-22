// ignore_for_file: file_names

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:musicplayer/interfaces/IAudio.dart';
import 'package:musicplayer/interfaces/ILecteur.dart';
import 'package:musicplayer/store/index.dart';
import 'package:musicplayer/utils/colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:musicplayer/utils/playlist.dart';
import 'package:musicplayer/utils/showModalBottom.dart';
import 'package:uuid/uuid.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Lister extends StatefulWidget {
  final String? playlistID;
  final List<IAudio> audios;
  final Function(List<IAudio>) submit;
  final Function([List<IAudio>? audios]) openPlaylist;

  const Lister({
    Key? key,
    this.playlistID,
    required this.audios,
    required this.submit,
    required this.openPlaylist,
  }) : super(key: key);

  @override
  _ListerState createState() => _ListerState();
}

class _ListerState extends State<Lister> {
  List<IAudio> _audioChoices = [];
  bool _openSelectable = false;
  String? _buttonTap;

  @override
  void initState() {
    super.initState();
  }

  Size get mediaSize => MediaQuery.of(context).size;

  submit() async {
    widget.submit(_audioChoices);
    Timer(
      const Duration(milliseconds: 100),
      () {
        setState(() => _openSelectable = false);
        setState(() => _audioChoices.clear());
      },
    );
  }

  submit2([List<IAudio>? audios]) async {
    var a = audios != null && audios.isNotEmpty ? audios : widget.audios;

    await Store.save(
      key: 'lecteur',
      value: ILecteur(id: const Uuid().v1(), audios: a).toJson,
    );
  }

  openMenu() async {
    Widget button(
        {required String text, Icon? icon, required Function() onTap}) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
          color: xLight,
          child: Row(
            children: [
              SizedBox(child: icon, width: 40),
              Expanded(
                child: Text(
                  text,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(),
                ),
              ),
            ],
          ),
        ),
      );
    }

    showModalBottom(
      color: xLight,
      context: context,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          button(
            text: 'Lire',
            icon: Icon(FontAwesomeIcons.play, size: 18, color: xDark),
            onTap: () {
              submit2(_audioChoices);
              Navigator.of(context).pop();
            },
          ),
          button(
            text: 'Ajouter au lecteur en cours',
            icon: Icon(FontAwesomeIcons.music, size: 18, color: xDark),
            onTap: () async {
              var lecteur = ILecteur.fromJson(await Store.get('lecteur'));

              for (var audio in _audioChoices) {
                lecteur.audios.add(audio);
              }

              await Store.save(key: 'lecteur', value: lecteur.toJson);
              Navigator.of(context).pop();
            },
          ),
          button(
            text: 'Ajouter à la playlist',
            icon: Icon(FontAwesomeIcons.plus, size: 18, color: xDark),
            onTap: () {
              Navigator.of(context).pop();
              widget.openPlaylist(_audioChoices);
            },
          ),
          Container(
            child: widget.playlistID != '0'
                ? button(
                    text: 'Supprimer de la playlist',
                    icon: Icon(FontAwesomeIcons.trash, size: 18, color: xDark),
                    onTap: () async {
                      await removeAudioToPlayList(
                          widget.playlistID!, _audioChoices);
                      Navigator.of(context).pop();
                    },
                  )
                : null,
          ),
        ],
      ),
    );
  }

  Widget get list {
    return SingleChildScrollView(
      child: Column(
        children: [
          for (var audio in widget.audios) buildOne2(audio),
        ],
      ),
    );
  }

  Widget buildOne2(IAudio audio) {
    return GestureDetector(
      onTapDown: (e) {
        setState(() => _buttonTap = audio.id);
      },
      onTapUp: (e) {
        if (_buttonTap == audio.id) {
          Timer(const Duration(milliseconds: 10), () {
            setState(() => _buttonTap = null);
          });
        }
      },
      onLongPressEnd: (e) {
        if (_buttonTap == audio.id) {
          setState(() => _buttonTap = null);
        }
      },
      onLongPress: () {
        setState(() => _openSelectable = true);
        setState(() => _audioChoices.add(audio));
      },
      onTap: () {
        if (_openSelectable) {
          var _is = _audioChoices.where((a) => a.id == audio.id).isNotEmpty;
          if (_is) {
            setState(() => _audioChoices.remove(audio));
          } else {
            setState(() => _audioChoices.add(audio));
          }
        } else {
          submit2([audio]);
        }
      },
      child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
        color: _buttonTap == audio.id
            ? xPrimary.withOpacity(.1)
            : xLight.withOpacity(.001),
        child: Row(
          children: [
            Container(
              child: _openSelectable
                  ? Container(
                      height: 20,
                      width: 20,
                      margin: const EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        color: _audioChoices
                                .where((a) => a.id == audio.id)
                                .isNotEmpty
                            ? xPrimary
                            : xDark.withOpacity(.1),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Center(
                        child: Icon(Icons.check, size: 13),
                      ),
                    )
                  : null,
            ),
            SizedBox(
              width: mediaSize.width - 100,
              child: Text(
                '${audio.title}',
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget get optionButton {
    // ignore: sized_box_for_whitespace
    return Container(
      width: 50,
      height: 50,
      child: _audioChoices.isNotEmpty
          ? TextButton(
              onPressed: openMenu,
              style: ButtonStyle(
                padding: MaterialStateProperty.all(EdgeInsets.zero),
                alignment: Alignment.center,
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
                overlayColor:
                    MaterialStateProperty.all<Color>(xDark.withOpacity(.3)),
                backgroundColor: MaterialStateProperty.all<Color>(xPrimary),
                foregroundColor: MaterialStateProperty.all<Color>(xDark),
              ),
              child: const Icon(Icons.more_vert, size: 20),
            )
          : TextButton(
              onPressed: () => submit2(_audioChoices),
              style: ButtonStyle(
                padding: MaterialStateProperty.all(EdgeInsets.zero),
                alignment: Alignment.center,
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
                overlayColor:
                    MaterialStateProperty.all<Color>(xDark.withOpacity(.3)),
                backgroundColor: MaterialStateProperty.all<Color>(xPrimary),
                foregroundColor: MaterialStateProperty.all<Color>(xDark),
              ),
              child: const Icon(
                Icons.play_arrow_rounded,
                size: 40,
              ),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        if (!_openSelectable) return Future.value(true);

        _audioChoices = [];
        _openSelectable = false;
        setState(() {});

        return Future.value(false);
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            child: widget.audios.isNotEmpty
                ? list
                : Center(
                    child: SvgPicture.asset(
                      'assets/icons/list.svg',
                      color: xDark.withOpacity(.2),
                      width: 72,
                    ),
                  ),
          ),
          Positioned(
            bottom: 30,
            right: 40,
            child: Container(
              child: widget.audios.isNotEmpty ? optionButton : null,
            ),
          )
        ],
      ),
    );
  }
}

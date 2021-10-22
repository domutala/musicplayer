// ignore_for_file: file_names

import 'dart:async';

import 'package:audioplayers/audioplayers.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:musicplayer/interfaces/ILecteur.dart';
import 'package:musicplayer/store/index.dart';
import 'package:musicplayer/utils/colors.dart';

class Player extends StatefulWidget {
  const Player({
    Key? key,
  }) : super(key: key);

  @override
  _PlayerState createState() => _PlayerState();
}

class _PlayerState extends State<Player> {
  ILecteur? _lecteur;
  String? _oldLecteurId;
  int _currentAudioIndex = 0;

  bool _dragSarted = false;
  String? repeat;

  // audio
  final AudioPlayer _player = AudioPlayer();
  double _duration = 0;
  double _progression = 0;
  bool _isPlaying = false;

  Timer? _timer;

  @override
  void dispose() async {
    super.dispose();
    await _player.stop();
    await _player.dispose();
    _timer?.cancel();
  }

  @override
  void initState() {
    super.initState();
    init0();
  }

  init0() async {
    var _repeat = await Store.get('repeat');
    setState(() => repeat = _repeat);

    _player.onDurationChanged.listen((d) {
      setState(() => _duration = d.inSeconds.toDouble());
    });
    _player.onAudioPositionChanged.listen((d) {
      setState(() => _progression = d.inSeconds.toDouble());
    });
    _player.onPlayerCompletion.listen((_) {
      onEnd();
    });
    setState(() {
      _timer = Timer.periodic(
        const Duration(milliseconds: 10),
        (timer) => buildLecteur(),
      );
    });
  }

  buildLecteur() async {
    try {
      var lecteur = await Store.get('lecteur');
      setState(() => _lecteur = ILecteur.fromJson(lecteur));

      if (_lecteur != null && _lecteur!.id != _oldLecteurId) {
        setState(() => _oldLecteurId = _lecteur!.id);
        try {
          setState(() => _player.stop());
          // ignore: empty_catches
        } catch (e) {}

        init1(0);
      }
      // ignore: empty_catches
    } catch (e) {}
  }

  init1(int index) async {
    try {
      await _player.stop();
      _duration = 0;
      _progression = 0;
      _isPlaying = false;
      setState(() {});
      // ignore: empty_catches
    } catch (e) {}

    if (_lecteur != null && _lecteur!.audios.length > index) {
      setState(() => _currentAudioIndex = index);

      _player.setUrl(_lecteur!.audios[index].path).then((value) {
        if (value == 1) {
          player();
        }
      });
    }
  }

  onEnd() {
    if (repeat == 'one') {
      init1(_currentAudioIndex);
    } else if (repeat == 'all') {
      init1(_currentAudioIndex + 1);
    }
  }

  Size get mediaSize => MediaQuery.of(context).size;
  double get size => mediaSize.width - 80;

  double get _progressWidth {
    if (_duration == 0) return 0;

    var p = (_progression * 100) / _duration;
    p = (mediaSize.width / 100) * p;
    return p;
  }

  // drag
  onHorizontalDragStart(drag) {
    setState(() => _dragSarted = true);
  }

  onHorizontalDragUpdate(DragUpdateDetails drag) {
    double dx = drag.localPosition.dx;

    if (dx > 0 && dx <= mediaSize.width) {
      var percent = dx * 100 / mediaSize.width;
      var e = percent * _duration / 100;

      setState(() {
        _player.pause();
        _player.seek(Duration(seconds: e.toInt()));
      });
    }
  }

  onHorizontalDragEnd() {
    setState(() => _dragSarted = false);

    if (_isPlaying) {
      setState(() {
        _player.resume();
      });
    }
  }

  formatRecordingVideoTime(double seconds) {
    var duration = Duration(seconds: seconds.toInt());

    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));

    var h = duration.inHours != 0 ? '${twoDigits(duration.inHours)}:' : '';
    return "$h$twoDigitMinutes:$twoDigitSeconds";
  }

  player() async {
    if (_progression == _duration) {
      await _player.seek(const Duration(milliseconds: 0));
    }

    if (!_isPlaying) {
      _player.resume();
    } else {
      _player.pause();
    }

    _isPlaying = !_isPlaying;
    setState(() {});
  }

  // --
  Widget get progresser {
    var e = GestureDetector(
      onHorizontalDragStart: onHorizontalDragStart,
      onHorizontalDragUpdate: onHorizontalDragUpdate,
      onHorizontalDragEnd: (darg) => onHorizontalDragEnd(),
      onHorizontalDragCancel: () => onHorizontalDragEnd(),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: _dragSarted ? 20 : 7,
              width: size,
              child: Stack(
                children: [
                  line(width: size),
                  line(width: _progressWidth, color: xDark),
                ],
              ),
            )
          ],
        ),
      ),
    );

    return e;
  }

  Widget get liner {
    return GestureDetector(
      onHorizontalDragStart: onHorizontalDragStart,
      onHorizontalDragUpdate: onHorizontalDragUpdate,
      onHorizontalDragEnd: (darg) => onHorizontalDragEnd(),
      onHorizontalDragCancel: () => onHorizontalDragEnd(),
      child: SizedBox(
        height: _dragSarted ? 20 : 2.5,
        width: mediaSize.width,
        child: Stack(
          children: [
            line(width: mediaSize.width),
            line(width: _progressWidth, color: xDark),
          ],
        ),
      ),
    );
  }

  Widget get controller {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 50,
              height: 50,
              child: TextButton(
                onPressed: () {
                  if (_progression > 3) {
                    _player.seek(const Duration(seconds: 0));
                    return;
                  }

                  if (_lecteur != null) {
                    if (_currentAudioIndex > 0) {
                      init1(_currentAudioIndex - 1);
                    } else {
                      init1(_lecteur!.audios.length - 1);
                    }
                  }
                },
                style: ButtonStyle(
                  padding: MaterialStateProperty.all(EdgeInsets.zero),
                  alignment: Alignment.center,
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  overlayColor:
                      MaterialStateProperty.all<Color>(xDark.withOpacity(.3)),
                  foregroundColor: MaterialStateProperty.all<Color>(xDark),
                ),
                child: Icon(
                  FontAwesomeIcons.backward,
                  size: 18,
                  color: xDark,
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              child: SizedBox(
                width: 50,
                height: 50,
                child: TextButton(
                  onPressed: player,
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
                    backgroundColor: MaterialStateProperty.all<Color>(
                        (xDark).withOpacity(.2)),
                    foregroundColor: MaterialStateProperty.all<Color>(xDark),
                  ),
                  child: Icon(
                    _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    size: 40,
                    color: xDark,
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 50,
              height: 50,
              child: TextButton(
                onPressed: () {
                  if (_lecteur != null) {
                    if (_currentAudioIndex + 1 < _lecteur!.audios.length) {
                      init1(_currentAudioIndex + 1);
                    } else {
                      init1(0);
                    }
                  }
                },
                style: ButtonStyle(
                  padding: MaterialStateProperty.all(EdgeInsets.zero),
                  alignment: Alignment.center,
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  overlayColor:
                      MaterialStateProperty.all<Color>(xDark.withOpacity(.3)),
                  foregroundColor: MaterialStateProperty.all<Color>(xDark),
                ),
                child: Icon(
                  FontAwesomeIcons.forward,
                  size: 18,
                  color: xDark,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget line({required double width, Color? color}) {
    return Positioned(
      top: 0,
      left: 0,
      bottom: 0,
      width: width,
      child: Container(
        decoration: BoxDecoration(
          color: color ?? (xDark).withOpacity(.5),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: _lecteur != null && _lecteur!.audios.isNotEmpty
          ? SizedBox(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  liner,
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 13),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 13),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  '${formatRecordingVideoTime(_progression)}',
                                  style: const TextStyle(fontSize: 10),
                                ),
                                Text(
                                  ' / ${formatRecordingVideoTime(_duration)}',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: (xDark).withOpacity(.5),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              repeat = repeat == null
                                  ? 'all'
                                  : repeat == 'all'
                                      ? 'one'
                                      : null;
                            });

                            Store.save(key: 'repeat', value: repeat);
                          },
                          child: Container(
                            height: 30,
                            width: 50,
                            alignment: Alignment.center,
                            child: Icon(
                              repeat == 'one'
                                  ? Icons.repeat_one_rounded
                                  : Icons.repeat_rounded,
                              color: repeat != null
                                  ? xDark
                                  : xDark.withOpacity(.5),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  controller,
                  Container(
                    margin: const EdgeInsets.only(top: 7),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          _lecteur!.audios[_currentAudioIndex].title ?? '',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: xDark,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          : null,
    );
  }
}

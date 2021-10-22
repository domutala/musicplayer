// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:musicplayer/components/lister.dart';
import 'package:musicplayer/interfaces/IAudio.dart';
import 'package:musicplayer/interfaces/IPlaylist.dart';
import 'package:musicplayer/store/index.dart';
import 'package:musicplayer/utils/colors.dart';
import 'package:flutter_svg/flutter_svg.dart';

class One extends StatefulWidget {
  final Function(List<IAudio>) submit;
  final String id;
  final Function([List<IAudio>? audios]) openPlaylist;

  const One({
    Key? key,
    required this.id,
    required this.submit,
    required this.openPlaylist,
  }) : super(key: key);

  @override
  _OneState createState() => _OneState();
}

class _OneState extends State<One> {
  IPlaylist? _playlist;
  Size get mediaSize => MediaQuery.of(context).size;

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    List pls = await Store.get('playlists');
    var playlists = pls.map((dt) => IPlaylist.fromJson(dt)).toList();
    var playlist = playlists.where((playlist) => playlist.id == widget.id);

    if (playlist.isNotEmpty) {
      setState(() {
        _playlist = playlist.first;
      });
    }
  }

  submit(List<IAudio> audios) {
    widget.submit(audios);
  }

  Widget get list {
    return Flexible(
      fit: FlexFit.tight,
      child: Lister(
        key: Key('${_playlist!.audios.length}'),
        playlistID: widget.id,
        audios: _playlist!.audios,
        submit: submit,
        openPlaylist: widget.openPlaylist,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: _playlist != null
          ? Column(
              children: [
                GestureDetector(
                  onTap: () => widget.openPlaylist(),
                  child: Container(
                    height: 35,
                    width: double.infinity,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    color: darken(xLight, .03),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _playlist!.name,
                            style: const TextStyle(),
                          ),
                        ),
                        Container(
                          height: 35,
                          width: 35,
                          alignment: Alignment.center,
                          child: SvgPicture.asset(
                            'assets/icons/list.svg',
                            color: xDark,
                            width: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                list,
              ],
            )
          : null,
    );
  }
}

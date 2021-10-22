import 'package:flutter/material.dart';
import 'package:musicplayer/interfaces/IAudio.dart';
import 'package:musicplayer/utils/playlist.dart';
import 'package:musicplayer/views/one.dart';

class VHome extends StatefulWidget {
  const VHome({
    Key? key,
  }) : super(key: key);

  @override
  State<VHome> createState() => _VHomeState();
}

class _VHomeState extends State<VHome> {
  String view = '0';

  _openPlaylist([List<IAudio>? audios]) {
    openPlaylist(
      context: context,
      audios: audios,
      goto: (id) {
        setState(() => view = id);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: One(
          key: Key(view),
          id: view,
          openPlaylist: _openPlaylist,
          submit: (audios) {
            openPlaylist(
              context: context,
              audios: audios,
              goto: (id) {
                setState(() => view = id);
              },
            );
          }),
    );
  }
}

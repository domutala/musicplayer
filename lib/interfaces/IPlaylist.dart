// ignore_for_file: file_names

import 'package:musicplayer/interfaces/IAudio.dart';

class IPlaylist {
  String id;
  String name;
  bool? favorite;
  List<IAudio> audios;

  IPlaylist({
    required this.id,
    required this.name,
    this.favorite,
    required this.audios,
  });

  IPlaylist._({
    required this.id,
    required this.name,
    this.favorite,
    required this.audios,
  });

  factory IPlaylist.fromJson(Map<String, dynamic> json) {
    var audios =
        (json['audios'] as List).map((dt) => IAudio.fromJson(dt)).toList();

    return IPlaylist._(
      id: json['id'],
      name: json['name'],
      favorite: json['favorite'],
      audios: audios,
    );
  }

  dynamic get toJson {
    var ads = audios.map((dt) => dt.toJson).toList();
    return {'id': id, 'name': name, 'favorite': favorite, 'audios': ads};
  }
}

// ignore_for_file: file_names

import 'package:musicplayer/interfaces/IAudio.dart';

class ILecteur {
  String id;
  List<IAudio> audios;

  ILecteur({
    required this.id,
    required this.audios,
  });

  ILecteur._({
    required this.id,
    required this.audios,
  });

  factory ILecteur.fromJson(Map<String, dynamic> json) {
    var audios =
        (json['audios'] as List).map((dt) => IAudio.fromJson(dt)).toList();

    return ILecteur._(
      id: json['id'],
      audios: audios,
    );
  }

  dynamic get toJson {
    var ads = audios.map((dt) => dt.toJson).toList();
    return {'id': id, 'audios': ads};
  }
}

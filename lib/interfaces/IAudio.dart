// ignore_for_file: file_names

class IAudio {
  String id;
  String? title;
  String path;
  double duration;

  IAudio({
    required this.id,
    this.title,
    required this.path,
    required this.duration,
  });
  IAudio._(
      {required this.id,
      this.title,
      required this.path,
      required this.duration});

  factory IAudio.fromJson(Map<String, dynamic> json) {
    return IAudio._(
      id: json['id'],
      title: json['title'],
      path: json['path'],
      duration: json['duration'],
    );
  }

  dynamic get toJson {
    return {
      'id': id,
      'title': title,
      'path': path,
      'duration': duration,
    };
  }
}

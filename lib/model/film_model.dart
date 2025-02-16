class FilmModel {
  String? name;
  String? language;
  String? id;
  String? bio;
  double? version;

  FilmModel({this.name, this.language, this.id, this.bio, this.version});

  FilmModel.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    language = json['language'];
    id = json['id'];
    bio = json['bio'];
    version = json['version'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['language'] = this.language;
    data['id'] = this.id;
    data['bio'] = this.bio;
    data['version'] = this.version;
    return data;
  }
}

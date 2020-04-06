import 'dart:convert';

class Connection {
  int id;
  String baseurl;
  String username;
  String password;

  Connection({
    this.id,
    this.baseurl,
    this.username,
    this.password,
  });

  Connection connectionFromJson(String str) {
    final jsonData = json.decode(str);
    return Connection.fromMap(jsonData);
  }

  String connectionToJson(Connection data) {
    final dyn = data.toMap();
    return json.encode(dyn);
  }

  factory Connection.fromMap(Map<String, dynamic> json) => Connection(
        id: json["id"],
        baseurl: json["baseurl"],
        username: json["username"],
        password: json["password"],
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "baseurl": baseurl,
        "username": username,
        "password": password,
      };
}

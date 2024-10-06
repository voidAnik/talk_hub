import 'package:talk_hub/features/home/domain/entities/room.dart';

class RoomModel extends Room {
  RoomModel({
    required super.id,
    required super.name,
    required super.description,
  });

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "name": name,
      "description": description,
    };
  }

  factory RoomModel.fromMap(Map<String, dynamic> json) {
    return RoomModel(
      id: json["id"],
      name: json["name"],
      description: json["description"],
    );
  }
//
}

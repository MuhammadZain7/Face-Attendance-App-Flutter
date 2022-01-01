// To parse this JSON data, do
//
//     final detectionModel = detectionModelFromJson(jsonString);

import 'dart:convert';

List<DetectionModel> detectionModelFromJson(String str) =>
    List<DetectionModel>.from(
        json.decode(str).map((x) => DetectionModel.fromJson(x)));

String detectionModelToJson(List<DetectionModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class DetectionModel {
  DetectionModel({
    required this.faceId,
    required this.faceRectangle,
  });

  String faceId;
  FaceRectangle faceRectangle;

  factory DetectionModel.fromJson(Map<String, dynamic> json) => DetectionModel(
        faceId: json["faceId"],
        faceRectangle: FaceRectangle.fromJson(json["faceRectangle"]),
      );

  Map<String, dynamic> toJson() => {
        "faceId": faceId,
        "faceRectangle": faceRectangle.toJson(),
      };
}

class FaceRectangle {
  FaceRectangle({
    required this.top,
    required this.left,
    required this.width,
    required this.height,
  });

  int top;
  int left;
  int width;
  int height;

  factory FaceRectangle.fromJson(Map<String, dynamic> json) => FaceRectangle(
        top: json["top"],
        left: json["left"],
        width: json["width"],
        height: json["height"],
      );

  Map<String, dynamic> toJson() => {
        "top": top,
        "left": left,
        "width": width,
        "height": height,
      };
}

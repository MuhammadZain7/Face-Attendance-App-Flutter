// To parse this JSON data, do
//
//     final identifyModel = identifyModelFromJson(jsonString);

import 'dart:convert';

List<IdentifyModel> identifyModelFromJson(String str) =>
    List<IdentifyModel>.from(
        json.decode(str).map((x) => IdentifyModel.fromJson(x)));

String identifyModelToJson(List<IdentifyModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class IdentifyModel {
  IdentifyModel({
    required this.faceId,
    this.candidates,
  });

  String faceId;
  List<Candidate>? candidates;

  factory IdentifyModel.fromJson(Map<String, dynamic> json) => IdentifyModel(
        faceId: json["faceId"],
        candidates: List<Candidate>.from(
            json["candidates"].map((x) => Candidate.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "faceId": faceId,
        "candidates": candidates == null
            ? []
            : List<dynamic>.from(candidates!.map((x) => x.toJson())),
      };
}

class Candidate {
  Candidate({
    required this.personId,
    required this.confidence,
  });

  String personId;
  int confidence;

  factory Candidate.fromJson(Map<String, dynamic> json) => Candidate(
        personId: json["personId"],
        confidence: json["confidence"],
      );

  Map<String, dynamic> toJson() => {
        "personId": personId,
        "confidence": confidence,
      };
}

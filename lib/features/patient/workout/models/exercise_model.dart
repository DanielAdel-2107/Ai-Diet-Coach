class ExerciseModel {
  final String id;
  final String name;
  final String bodyPart;
  final String equipment;
  final String gifUrl;
  final String videoUrl;
  final String instructions;

  ExerciseModel({
    required this.id,
    required this.name,
    required this.bodyPart,
    required this.equipment,
    required this.gifUrl,
    required this.videoUrl,
    required this.instructions,
  });

  factory ExerciseModel.fromJson(Map<String, dynamic> json) {
    return ExerciseModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Unnamed Exercise',
      bodyPart: json['body_part'] as String? ?? '',
      equipment: json['equipment'] as String? ?? 'None',
      gifUrl: json['gif_url'] as String? ?? '',
      videoUrl: json['video_url'] as String? ?? '',
      instructions: json['instructions'] as String? ?? 'No instructions available.',
    );
  }
}

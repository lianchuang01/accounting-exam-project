class VoiceSegment {
  final String type;
  final String text;
  final int? durationMs;
  final double? rate;
  final double? pitch;

  VoiceSegment({
    required this.type,
    required this.text,
    this.durationMs,
    this.rate,
    this.pitch,
  });

  factory VoiceSegment.fromJson(Map<String, dynamic> json) {
    return VoiceSegment(
      type: json['type'] as String,
      text: json['text'] as String,
      durationMs: (json['durationMs'] as num?)?.toInt(),
      rate: (json['rate'] as num?)?.toDouble(),
      pitch: (json['pitch'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'text': text,
      'durationMs': durationMs,
      'rate': rate,
      'pitch': pitch,
    };
  }
}

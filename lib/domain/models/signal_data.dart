enum SignalType {
  confused,
  tooFast,
  clear,
}

class SignalData {
  final int confusedCount;
  final int tooFastCount;
  final int clearCount;
  final DateTime lastUpdated;

  SignalData({
    required this.confusedCount,
    required this.tooFastCount,
    required this.clearCount,
    required this.lastUpdated,
  });

  factory SignalData.fromJson(Map<String, dynamic> json) {
    return SignalData(
      confusedCount: json['confused_count'] as int? ?? 0,
      tooFastCount: json['too_fast_count'] as int? ?? 0,
      clearCount: json['clear_count'] as int? ?? 0,
      lastUpdated: DateTime.fromMillisecondsSinceEpoch(
        json['last_updated'] as int? ?? DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'confused_count': confusedCount,
      'too_fast_count': tooFastCount,
      'clear_count': clearCount,
      'last_updated': lastUpdated.millisecondsSinceEpoch,
    };
  }

  int get totalCount => confusedCount + tooFastCount + clearCount;
}

class HistoryPoint {
  final DateTime timestamp;
  final int confusedCount;
  final int totalParticipants;

  HistoryPoint({
    required this.timestamp,
    required this.confusedCount,
    required this.totalParticipants,
  });

  factory HistoryPoint.fromJson(DateTime timestamp, Map<String, dynamic> json) {
    return HistoryPoint(
      timestamp: timestamp,
      confusedCount: json['confused'] as int? ?? 0,
      totalParticipants: json['total_participants'] as int? ?? 0,
    );
  }

  double get confusionRate =>
      totalParticipants > 0 ? confusedCount / totalParticipants : 0.0;
}

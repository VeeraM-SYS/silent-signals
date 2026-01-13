import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/signal_data.dart';

class FeedbackRepository {
  final FirebaseDatabase _database;
  final String sessionId;

  FeedbackRepository({
    required FirebaseDatabase database,
    required this.sessionId,
  }) : _database = database;

  DatabaseReference get _signalsRef =>
      _database.ref('signals/$sessionId');

  /// Vote for a signal type using atomic increment
  Future<void> vote(SignalType type) async {
    final String fieldName = _getFieldName(type);
    
    // Use runTransaction for atomic increment to ensure concurrency safety
    await _signalsRef.child(fieldName).runTransaction((Object? currentValue) {
      int current = 0;
      if (currentValue != null && currentValue is int) {
        current = currentValue;
      }
      return Transaction.success(current + 1);
    });

    // Update last_updated timestamp
    await _signalsRef.child('last_updated').set(ServerValue.timestamp);
  }

  /// Stream real-time signal data
  Stream<SignalData> streamSignals() {
    return _signalsRef.onValue.map((event) {
      if (event.snapshot.value == null) {
        return SignalData(
          confusedCount: 0,
          tooFastCount: 0,
          clearCount: 0,
          lastUpdated: DateTime.now(),
        );
      }
      
      final data = event.snapshot.value as Map<dynamic, dynamic>;
      return SignalData.fromJson(Map<String, dynamic>.from(data));
    });
  }

  /// Get current signal data (one-time read)
  Future<SignalData> getSignals() async {
    final snapshot = await _signalsRef.get();
    
    if (!snapshot.exists || snapshot.value == null) {
      return SignalData(
        confusedCount: 0,
        tooFastCount: 0,
        clearCount: 0,
        lastUpdated: DateTime.now(),
      );
    }

    final data = snapshot.value as Map<dynamic, dynamic>;
    return SignalData.fromJson(Map<String, dynamic>.from(data));
  }

  /// Reset all signals (faculty only)
  Future<void> resetSignals() async {
    await _signalsRef.set({
      'confused_count': 0,
      'too_fast_count': 0,
      'clear_count': 0,
      'last_updated': ServerValue.timestamp,
    });
  }

  String _getFieldName(SignalType type) {
    return switch (type) {
      SignalType.confused => 'confused_count',
      SignalType.tooFast => 'too_fast_count',
      SignalType.clear => 'clear_count',
    };
  }
}

// State provider for the current session ID
final currentSessionIdProvider = StateProvider<String>((ref) => 'demo_session');

// Riverpod Provider
final feedbackRepositoryProvider = Provider<FeedbackRepository>((ref) {
  final sessionId = ref.watch(currentSessionIdProvider);
  return FeedbackRepository(
    database: FirebaseDatabase.instance,
    sessionId: sessionId,
  );
});

// Stream provider for real-time signals
final signalsStreamProvider = StreamProvider<SignalData>((ref) {
  final repository = ref.watch(feedbackRepositoryProvider);
  return repository.streamSignals();
});

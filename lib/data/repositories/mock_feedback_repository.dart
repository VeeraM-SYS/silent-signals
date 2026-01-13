import 'dart:async';
import 'dart:math';
import '../../domain/models/signal_data.dart';
import 'feedback_repository.dart';

class MockFeedbackRepository implements FeedbackRepository {
  @override
  final String sessionId = 'mock_session'; // Added sessionId implementation

  // We don't use FirebaseDatabase in the mock
  final _controller = StreamController<SignalData>.broadcast();
  SignalData _currentData = SignalData(
    confusedCount: 0,
    tooFastCount: 0,
    clearCount: 0,
    lastUpdated: DateTime.now(),
  );

  MockFeedbackRepository() {
    // Simulate some background activity/noise from other students
    Timer.periodic(const Duration(seconds: 5), (timer) {
      if (Random().nextBool()) {
        // Randomly decay or add counts to make it feel alive
        _updateData((data) {
          return SignalData(
            confusedCount: max(0, data.confusedCount + (Random().nextBool() ? 1 : -1)),
            tooFastCount: max(0, data.tooFastCount + (Random().nextBool() ? 1 : -1)),
            clearCount: max(0, data.clearCount + (Random().nextBool() ? 1 : -1)),
            lastUpdated: DateTime.now(),
          );
        });
      }
    });
  }

  void _updateData(SignalData Function(SignalData) updateFn) {
    _currentData = updateFn(_currentData);
    _controller.add(_currentData);
  }

  @override
  Future<void> vote(SignalType type) async {
    await Future.delayed(const Duration(milliseconds: 200)); // Sim latency
    _updateData((data) {
      return SignalData(
        confusedCount: data.confusedCount + (type == SignalType.confused ? 1 : 0),
        tooFastCount: data.tooFastCount + (type == SignalType.tooFast ? 1 : 0),
        clearCount: data.clearCount + (type == SignalType.clear ? 1 : 0),
        lastUpdated: DateTime.now(),
      );
    });
  }

  @override
  Stream<SignalData> streamSignals() async* {
    // Emit current data immediately
    yield _currentData;
    yield* _controller.stream;
  }

  @override
  Future<SignalData> getSignals() async {
    return _currentData;
  }

  @override
  Future<void> resetSignals() async {
    _updateData((_) => SignalData(
          confusedCount: 0,
          tooFastCount: 0,
          clearCount: 0,
          lastUpdated: DateTime.now(),
        ));
  }
}

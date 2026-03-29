import 'dart:async';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:record/record.dart';
import 'sos_service.dart';

class PanicDetectionService {
  static final PanicDetectionService _instance = PanicDetectionService._internal();
  factory PanicDetectionService() => _instance;
  PanicDetectionService._internal();

  final SOSService _sosService = SOSService();
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  AudioRecorder? _audioRecorder;
  Timer? _soundCheckTimer;
  bool _isMonitoring = false;

  // Thresholds
  static const double accelerationThreshold = 15.0; // m/s² (sudden movement)
  static const double soundThreshold = 80.0; // dB (loud sound)
  static const Duration checkInterval = Duration(seconds: 1);

  bool get isMonitoring => _isMonitoring;

  Future<void> startMonitoring() async {
    if (_isMonitoring) return;

    _isMonitoring = true;

    // Start accelerometer monitoring
    _accelerometerSubscription = accelerometerEventStream().listen(
      (AccelerometerEvent event) {
        _checkAcceleration(event);
      },
      onError: (error) {
        print('Accelerometer error: $error');
      },
    );

    // Start sound monitoring
    await _startSoundMonitoring();
  }

  void stopMonitoring() {
    _isMonitoring = false;
    _accelerometerSubscription?.cancel();
    _accelerometerSubscription = null;
    _soundCheckTimer?.cancel();
    _soundCheckTimer = null;
    final recorder = _audioRecorder;
    _audioRecorder = null;
    if (recorder != null) {
      unawaited(recorder.dispose());
    }
  }

  void _checkAcceleration(AccelerometerEvent event) {
    // Calculate magnitude of acceleration
    double magnitude = (event.x * event.x + event.y * event.y + event.z * event.z) / 9.81;
    
    // Check for sudden acceleration (panic movement)
    if (magnitude > accelerationThreshold) {
      _triggerPanicDetection('Sudden acceleration detected');
    }
  }

  Future<void> _startSoundMonitoring() async {
    _audioRecorder = AudioRecorder();
    
    // Check if permission is granted
    if (await _audioRecorder!.hasPermission()) {
      _soundCheckTimer = Timer.periodic(checkInterval, (timer) async {
        await _checkSoundLevel();
      });
    }
  }

  Future<void> _checkSoundLevel() async {
    try {
      if (_audioRecorder == null) return;

      // Check if recorder is already recording
      if (await _audioRecorder!.isRecording()) {
        return;
      }

      // Start recording briefly to check sound level
      const config = RecordConfig(
        encoder: AudioEncoder.aacLc,
        sampleRate: 44100,
      );

      await _audioRecorder!.start(config, path: 'temp_audio');
      await Future.delayed(const Duration(milliseconds: 500));

      if (await _audioRecorder!.isRecording()) {
        // In a real implementation, you would analyze the audio file
        // For now, we'll use a simplified approach
        // This is a placeholder - actual implementation would require audio analysis
        
        await _audioRecorder!.stop();
        // Note: Actual sound level detection requires audio processing
        // This is a simplified version
      }
    } catch (e) {
      print('Sound monitoring error: $e');
    }
  }

  void _triggerPanicDetection(String reason) {
    print('Panic detected: $reason');
    
    // Start 10-second countdown
    _sosService.startPanicDetectionTimer(() {
      // Auto-trigger SOS after 10 seconds
      _sosService.triggerSOS();
    });
  }

  void cancelPanicDetection() {
    _sosService.cancelPanicDetection();
  }

  void dispose() {
    stopMonitoring();
  }
}

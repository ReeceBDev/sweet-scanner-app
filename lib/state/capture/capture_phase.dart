/// Camera session lifecycle of the capture screen.
enum CapturePhase {
  /// The camera has not been prepared yet.
  idle,

  /// The camera is being prepared.
  initializing,

  /// The camera is live.
  ready,

  /// Camera access was not granted.
  permissionDenied,

  /// The camera could not be prepared.
  failed,
}

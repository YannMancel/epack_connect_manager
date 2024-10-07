sealed class BluetoothCommunicationState {
  const BluetoothCommunicationState();
}

final class UnknownBluetoothCommunicationState
    extends BluetoothCommunicationState {
  const UnknownBluetoothCommunicationState();
}

final class ReadBluetoothCommunicationState
    extends BluetoothCommunicationState {
  const ReadBluetoothCommunicationState({
    this.message,
    this.canNotify = false,
    this.isNotifyActive = false,
  });

  final String? message;
  final bool canNotify;
  final bool isNotifyActive;
}

final class WriteBluetoothCommunicationState
    extends BluetoothCommunicationState {
  const WriteBluetoothCommunicationState();
}

extension BluetoothCommunicationStateExt on BluetoothCommunicationState {
  T when<T>({
    required T Function() unknown,
    required T Function(String?, bool, bool) read,
    required T Function() write,
  }) {
    return switch (this) {
      UnknownBluetoothCommunicationState() => unknown(),
      ReadBluetoothCommunicationState(
        :final message,
        :final canNotify,
        :final isNotifyActive,
      ) =>
        read(message, canNotify, isNotifyActive),
      WriteBluetoothCommunicationState() => write(),
    };
  }

  bool get canRead {
    return when<bool>(
      unknown: () => false,
      read: (_, __, ___) => true,
      write: () => false,
    );
  }

  bool get canWrite {
    return when<bool>(
      unknown: () => false,
      read: (_, __, ___) => false,
      write: () => true,
    );
  }

  bool get canNotify {
    return when<bool>(
      unknown: () => false,
      read: (_, c, __) => c,
      write: () => false,
    );
  }

  bool get isNotifyActive {
    return when<bool>(
      unknown: () => false,
      read: (_, __, i) => i,
      write: () => false,
    );
  }

  BluetoothCommunicationState copyWith({
    String? message,
    bool? canNotify,
    bool? isNotifyActive,
  }) {
    return when<BluetoothCommunicationState>(
      unknown: () => this,
      read: (m, c, i) => ReadBluetoothCommunicationState(
        message: message ?? m,
        canNotify: canNotify ?? c,
        isNotifyActive: isNotifyActive ?? i,
      ),
      write: () => this,
    );
  }
}

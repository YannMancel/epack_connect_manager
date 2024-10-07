import 'package:flutter/material.dart';

class BluetoothCharacteristicReadingWidget extends StatelessWidget {
  const BluetoothCharacteristicReadingWidget(
    this.message, {
    super.key,
    required this.canNotify,
    required this.onReadPressed,
    required this.hasNotifyActive,
    required this.onNotifyPressed,
  });

  final String? message;
  final bool canNotify;
  final VoidCallback onReadPressed;
  final bool hasNotifyActive;
  final ValueSetter<bool> onNotifyPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            (message?.trim().isNotEmpty ?? false) ? message! : '',
          ),
        ),
        IconButton(
          onPressed: onReadPressed,
          icon: const Icon(Icons.read_more),
        ),
        if (canNotify)
          IconButton(
            onPressed: () => onNotifyPressed(!hasNotifyActive),
            icon: Icon(
              hasNotifyActive ? Icons.notifications : Icons.notifications_off,
            ),
          ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

class BluetoothCharacteristicWritingWidget extends StatefulWidget {
  const BluetoothCharacteristicWritingWidget({
    super.key,
    required this.onSendPressed,
  });

  final ValueSetter<String> onSendPressed;

  @override
  State<BluetoothCharacteristicWritingWidget> createState() =>
      _BluetoothCharacteristicWritingWidgetState();
}

class _BluetoothCharacteristicWritingWidgetState
    extends State<BluetoothCharacteristicWritingWidget> {
  late TextEditingController _controller;
  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: TextFormField(
            controller: _controller,
          ),
        ),
        IconButton(
          onPressed: () => widget.onSendPressed(_controller.value.text),
          icon: const Icon(Icons.send),
        ),
      ],
    );
  }
}

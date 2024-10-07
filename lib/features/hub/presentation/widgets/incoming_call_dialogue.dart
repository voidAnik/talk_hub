import 'package:flutter/material.dart';
import 'package:talk_hub/features/authentication/data/models/user_model.dart';

class IncomingCallDialog extends StatelessWidget {
  final UserModel? caller;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const IncomingCallDialog({
    super.key,
    required this.caller,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Incoming Call'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
              'You have an incoming call from ${caller?.name ?? 'Unknown User'}.'),
          const SizedBox(height: 8),
          Text(caller?.email ?? ''),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.call_end, color: Colors.red),
          iconSize: 40,
          onPressed: onDecline,
          tooltip: 'Decline',
        ),
        IconButton(
          icon: const Icon(Icons.call, color: Colors.green),
          iconSize: 40,
          onPressed: onAccept,
          tooltip: 'Accept',
        ),
      ],
    );
  }
}

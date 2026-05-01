import 'package:flutter/material.dart';
import 'package:demo_project/routes/app_router.dart';
import '../../utils/app_enums.dart';

class CustomSnackbar {
  static void show({
    required String message,
    required SnackbarType type,
  }) {
    Color backgroundColor;
    IconData iconData;
    String defaultTitle;

    switch (type) {
      case SnackbarType.success:
        backgroundColor = Colors.green.shade600;
        iconData = Icons.check_circle;
        defaultTitle = 'Success';
        break;
      case SnackbarType.error:
        backgroundColor = Colors.red.shade600;
        iconData = Icons.error;
        defaultTitle = 'Error';
        break;
      case SnackbarType.warning:
        backgroundColor = Colors.orange.shade600;
        iconData = Icons.warning;
        defaultTitle = 'Warning';
        break;
      case SnackbarType.info:
        backgroundColor = Colors.blue.shade600;
        iconData = Icons.info;
        defaultTitle = 'Info';
        break;
    }

    final messengerState = AppRouter.scaffoldMessengerKey.currentState;
    if (messengerState == null) {
      return;
    }

    messengerState
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: backgroundColor,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 3),
          content: Row(
            children: [
              Icon(iconData, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '$defaultTitle: $message',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
  }
}

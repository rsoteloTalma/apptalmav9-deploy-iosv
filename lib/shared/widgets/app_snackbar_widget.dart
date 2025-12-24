import 'package:apptalma_v9/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class AppSnackbarWidget {
  static void show(BuildContext context, String message, IconData alertIcon,
      Color alertColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(alertIcon, color: alertColor),
                const SizedBox(width: 8.0),
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(fontSize: 15.0),
                  ),
                ),
              ],
            ),
          ],
        ),
        backgroundColor: AppColors.primaryColor,
        duration: Duration(seconds: 3),
      ),
    );
  }
}

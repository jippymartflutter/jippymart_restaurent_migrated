import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jippymart_restaurant/themes/app_them_data.dart';
import 'package:jippymart_restaurant/constant/constant.dart';

class AppUpdateDialog extends StatelessWidget {
  final bool isForceUpdate;
  final String updateMessage;
  final VoidCallback onUpdate;
  final VoidCallback? onDismiss;

  const AppUpdateDialog({
    Key? key,
    required this.isForceUpdate,
    required this.updateMessage,
    required this.onUpdate,
    this.onDismiss,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => !isForceUpdate,
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Theme.of(context).cardColor,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppThemeData.primary300.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.system_update,
                  size: 40,
                  color: AppThemeData.primary300,
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Title
              Text(
                isForceUpdate ? 'Update Required' : 'Update Available',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 12),
              
              // Message
              Text(
                updateMessage.isNotEmpty 
                    ? updateMessage 
                    : 'A new version of the app is available. Please update to continue using the app.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.8),
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 24),
              
              // Buttons
              Row(
                children: [
                  if (!isForceUpdate && onDismiss != null) ...[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onDismiss,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          side: BorderSide(
                            color: Theme.of(context).dividerColor,
                          ),
                        ),
                        child: Text(
                          'Later',
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onUpdate,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppThemeData.primary300,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Update Now',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              
              if (isForceUpdate) ...[
                const SizedBox(height: 12),
                Text(
                  'This update is required to continue using the app.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

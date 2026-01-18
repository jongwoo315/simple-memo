import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../services/storage_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final backgroundColor = themeProvider.backgroundColor(context);
    final isDark = themeProvider.isDark(context);
    final textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        elevation: 0,
      ),
      body: ListView(
        children: [
          // Theme Section
          ListTile(
            title: Text('Theme', style: TextStyle(color: textColor)),
            trailing: DropdownButton<AppThemeMode>(
              value: themeProvider.themeMode,
              dropdownColor: backgroundColor,
              onChanged: (mode) {
                if (mode != null) {
                  themeProvider.setThemeMode(mode);
                }
              },
              items: [
                DropdownMenuItem(
                  value: AppThemeMode.system,
                  child: Text('System', style: TextStyle(color: textColor)),
                ),
                DropdownMenuItem(
                  value: AppThemeMode.light,
                  child: Text('Light', style: TextStyle(color: textColor)),
                ),
                DropdownMenuItem(
                  value: AppThemeMode.dark,
                  child: Text('Dark', style: TextStyle(color: textColor)),
                ),
              ],
            ),
          ),
          const Divider(),

          // Sync Section (placeholder for Phase 2)
          ListTile(
            title: Text('Sync', style: TextStyle(color: textColor)),
            subtitle: Text('Sign in to sync', style: TextStyle(color: textColor.withValues(alpha: 0.6))),
            trailing: Icon(Icons.chevron_right, color: textColor),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Coming soon!')),
              );
            },
          ),
          const Divider(),

          // Danger Zone
          const SizedBox(height: 32),
          ListTile(
            title: const Text(
              '메모 모두 지우기',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () => _clearAllMemos(context),
          ),
        ],
      ),
    );
  }

  Future<void> _clearAllMemos(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('메모 모두 지우기'),
        content: const Text('정말로 모든 메모를 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('삭제', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final storageService = StorageService();
      await storageService.saveMemos([]);
      if (context.mounted) {
        Navigator.of(context).pop(true); // Return true to indicate memos cleared
      }
    }
  }
}

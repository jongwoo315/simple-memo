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
    final textColor = isDark ? Colors.white70 : Colors.black54;
    final pipeColor = themeProvider.pipeColor(context);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Back button row
              _buildSettingRow(
                context: context,
                children: [
                  _buildTappableText(
                    text: '← back',
                    color: textColor,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                ],
                pipeColor: pipeColor,
              ),
              const SizedBox(height: 24),

              // Theme row
              _buildSettingRow(
                context: context,
                children: [
                  Text('theme:', style: TextStyle(color: textColor.withValues(alpha: 0.6), fontSize: 14)),
                  _buildThemeOption(
                    text: 'system',
                    isSelected: themeProvider.themeMode == AppThemeMode.system,
                    color: textColor,
                    onTap: () => themeProvider.setThemeMode(AppThemeMode.system),
                  ),
                  _buildThemeOption(
                    text: 'light',
                    isSelected: themeProvider.themeMode == AppThemeMode.light,
                    color: textColor,
                    onTap: () => themeProvider.setThemeMode(AppThemeMode.light),
                  ),
                  _buildThemeOption(
                    text: 'dark',
                    isSelected: themeProvider.themeMode == AppThemeMode.dark,
                    color: textColor,
                    onTap: () => themeProvider.setThemeMode(AppThemeMode.dark),
                  ),
                ],
                pipeColor: pipeColor,
              ),
              const SizedBox(height: 16),

              // Sync row (placeholder)
              _buildSettingRow(
                context: context,
                children: [
                  _buildTappableText(
                    text: 'sync',
                    color: textColor,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Coming soon!'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                  Text('sign in to sync',
                    style: TextStyle(
                      color: textColor.withValues(alpha: 0.5),
                      fontSize: 14,
                    ),
                  ),
                ],
                pipeColor: pipeColor,
              ),
              const SizedBox(height: 32),

              // Clear all memos
              _buildSettingRow(
                context: context,
                children: [
                  _buildTappableText(
                    text: '메모 모두 지우기',
                    color: Colors.red.withValues(alpha: 0.7),
                    onTap: () => _clearAllMemos(context),
                  ),
                ],
                pipeColor: pipeColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingRow({
    required BuildContext context,
    required List<Widget> children,
    required Color pipeColor,
  }) {
    final List<Widget> rowChildren = [];
    for (int i = 0; i < children.length; i++) {
      rowChildren.add(children[i]);
      if (i < children.length - 1) {
        rowChildren.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text('|', style: TextStyle(color: pipeColor, fontSize: 16)),
          ),
        );
      }
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: rowChildren,
    );
  }

  Widget _buildTappableText({
    required String text,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 16),
      ),
    );
  }

  Widget _buildThemeOption({
    required String text,
    required bool isSelected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 16,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Future<void> _clearAllMemos(BuildContext context) async {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final backgroundColor = themeProvider.backgroundColor(context);
    final isDark = themeProvider.isDark(context);
    final textColor = isDark ? Colors.white70 : Colors.black87;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: backgroundColor,
        title: Text('메모 모두 지우기', style: TextStyle(color: textColor)),
        content: Text('정말로 모든 메모를 삭제하시겠습니까?', style: TextStyle(color: textColor)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('취소', style: TextStyle(color: textColor)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('삭제', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final storageService = StorageService();
      await storageService.saveMemos([]);
      if (context.mounted) {
        Navigator.of(context).pop(true);
      }
    }
  }
}

import 'package:flutter/material.dart';
import '../../../core/services/github_update_service.dart';
import 'ota_download_dialog.dart';

class UpdateDialog extends StatelessWidget {
  final GithubReleaseInfo releaseInfo;

  const UpdateDialog({super.key, required this.releaseInfo});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.system_update_rounded,
              color: theme.colorScheme.primary,
              size: 28,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Yeni Güncelleme!',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'v${releaseInfo.latestVersion} (Mevcut: v${releaseInfo.currentVersion})',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Velesbit\'in en yeni sürümü GitHub üzerinden yayınlandı. Güncel kaza ve navigasyon özellikleri için güncelleyin:',
            style: TextStyle(fontSize: 13),
          ),
          const SizedBox(height: 12),

          // Release Notes Container
          Container(
            padding: const EdgeInsets.all(12),
            width: double.infinity,
            constraints: const BoxConstraints(maxHeight: 120),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: SingleChildScrollView(
              child: Text(
                releaseInfo.releaseNotes,
                style: TextStyle(fontSize: 12, color: Colors.grey[800]),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Daha Sonra', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton.icon(
          onPressed: () {
            Navigator.pop(context);
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (dialogContext) => OtaDownloadDialog(
                downloadUrl: releaseInfo.downloadUrl,
                fallbackHtmlUrl: releaseInfo.htmlUrl,
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          icon: const Icon(Icons.download_rounded, size: 18),
          label: const Text('Şimdi Güncelle (APK)'),
        ),
      ],
    );
  }
}

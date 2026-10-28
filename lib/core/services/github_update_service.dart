import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class GithubReleaseInfo {
  final bool hasUpdate;
  final String currentVersion;
  final String latestVersion;
  final String releaseNotes;
  final String downloadUrl;
  final String htmlUrl;
  final bool forceUpdate;

  GithubReleaseInfo({
    required this.hasUpdate,
    required this.currentVersion,
    required this.latestVersion,
    required this.releaseNotes,
    required this.downloadUrl,
    required this.htmlUrl,
    this.forceUpdate = false,
  });
}

class GithubUpdateService {
  // GitHub repository owner and name
  static const String repoOwner = 'mnvkbvbm';
  static const String repoName = 'velesbit_app';

  // Raw GitHub version.json URL
  static const String versionJsonUrl = 'https://raw.githubusercontent.com/$repoOwner/$repoName/main/version.json';

  static Future<GithubReleaseInfo?> checkForUpdates() async {
    final packageInfo = await PackageInfo.fromPlatform();
    final currentVersion = packageInfo.version;

    // 1. Try reading version.json from GitHub raw URL first
    try {
      final jsonResponse = await http.get(Uri.parse(versionJsonUrl));
      if (jsonResponse.statusCode == 200) {
        final data = json.decode(jsonResponse.body);
        final String latestVersion = (data['version'] ?? '1.0.0').toString().replaceAll('v', '').trim();
        final String releaseNotes = data['release_notes'] ?? 'Yeni performans iyileştirmeleri ve hata düzeltmeleri eklendi.';
        final String downloadUrl = data['download_url'] ?? 'https://github.com/$repoOwner/$repoName/releases';
        final bool forceUpdate = data['force_update'] ?? false;

        final bool hasUpdate = _isVersionHigher(latestVersion, currentVersion);

        return GithubReleaseInfo(
          hasUpdate: hasUpdate,
          currentVersion: currentVersion,
          latestVersion: latestVersion,
          releaseNotes: releaseNotes,
          downloadUrl: downloadUrl,
          htmlUrl: 'https://github.com/$repoOwner/$repoName/releases',
          forceUpdate: forceUpdate,
        );
      }
    } catch (_) {}

    // 2. Fallback to GitHub Releases API if version.json is not reachable
    try {
      final url = Uri.parse('https://api.github.com/repos/$repoOwner/$repoName/releases/latest');
      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/vnd.github.v3+json',
          'User-Agent': 'VelesbitAppUpdater/1.0',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final String rawTagName = data['tag_name'] ?? '1.0.0';
        final String latestVersion = rawTagName.replaceAll('v', '').trim();
        final String releaseNotes = data['body'] ?? 'Yeni performans iyileştirmeleri ve hata düzeltmeleri eklendi.';
        final String htmlUrl = data['html_url'] ?? 'https://github.com/$repoOwner/$repoName/releases';

        String downloadUrl = htmlUrl;
        final assets = data['assets'] as List?;
        if (assets != null && assets.isNotEmpty) {
          for (final asset in assets) {
            final String name = (asset['name'] ?? '').toString();
            if (name.endsWith('.apk')) {
              downloadUrl = asset['browser_download_url'] ?? htmlUrl;
              break;
            }
          }
        }

        final bool hasUpdate = _isVersionHigher(latestVersion, currentVersion);

        return GithubReleaseInfo(
          hasUpdate: hasUpdate,
          currentVersion: currentVersion,
          latestVersion: latestVersion,
          releaseNotes: releaseNotes,
          downloadUrl: downloadUrl,
          htmlUrl: htmlUrl,
        );
      }
    } catch (_) {}

    return null;
  }

  static Future<bool> launchDownload(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
    return false;
  }

  static bool _isVersionHigher(String latest, String current) {
    try {
      final latestParts = latest.split('.').map((e) => int.tryParse(e) ?? 0).toList();
      final currentParts = current.split('.').map((e) => int.tryParse(e) ?? 0).toList();

      for (int i = 0; i < max(latestParts.length, currentParts.length); i++) {
        final l = i < latestParts.length ? latestParts[i] : 0;
        final c = i < currentParts.length ? currentParts[i] : 0;

        if (l > c) return true;
        if (l < c) return false;
      }
    } catch (_) {}
    return false;
  }

  static int max(int a, int b) => a > b ? a : b;
}

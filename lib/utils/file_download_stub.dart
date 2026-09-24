import 'package:url_launcher/url_launcher.dart';

/// Non-web fallback: just open the file URL.
Future<void> downloadFile(
  String url,
  String fileName, {
  void Function(double progress)? onProgress,
}) async {
  onProgress?.call(1);
  await launchUrl(Uri.parse(url));
}

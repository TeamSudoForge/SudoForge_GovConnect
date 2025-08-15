class UploadResult {
  final String key;
  final String url;

  UploadResult({required this.key, required this.url});

  factory UploadResult.fromJson(Map<String, dynamic> json) {
    return UploadResult(key: json['key'] as String, url: json['url'] as String);
  }
}

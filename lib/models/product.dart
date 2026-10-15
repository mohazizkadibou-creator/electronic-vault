/// A downloadable product produced by the build factory for a project.
enum ProductType { zip, apk, aab, web, exe, tarGz }

extension ProductTypeExtension on ProductType {
  String get label {
    switch (this) {
      case ProductType.zip:
        return 'ZIP (Windows / Linux)';
      case ProductType.apk:
        return 'APK (Android)';
      case ProductType.aab:
        return 'AAB (Play Store)';
      case ProductType.web:
        return 'Web (PWA)';
      case ProductType.exe:
        return 'EXE (Windows Installer)';
      case ProductType.tarGz:
        return 'TAR.GZ (Linux / macOS)';
    }
  }

  String get platform {
    switch (this) {
      case ProductType.zip:
        return 'Windows / Linux';
      case ProductType.apk:
      case ProductType.aab:
        return 'Android';
      case ProductType.web:
        return 'Web';
      case ProductType.exe:
        return 'Windows';
      case ProductType.tarGz:
        return 'Linux / macOS';
    }
  }

  String get wireName => name;

  static ProductType fromWire(String value) {
    return ProductType.values.firstWhere(
      (ProductType t) => t.name == value,
      orElse: () => ProductType.zip,
    );
  }
}

/// Metadata for a single downloadable product link.
class ProductInfo {
  ProductType type;
  String downloadUrl;
  int downloadCount;
  String checksum;
  String platform;
  DateTime createdAt;

  ProductInfo({
    this.type = ProductType.zip,
    this.downloadUrl = '',
    this.downloadCount = 0,
    this.checksum = '',
    this.platform = '',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => <String, dynamic>{
        'type': type.name,
        'downloadUrl': downloadUrl,
        'downloadCount': downloadCount,
        'checksum': checksum,
        'platform': platform.isEmpty ? type.platform : platform,
        'createdAt': createdAt.toIso8601String(),
      };

  factory ProductInfo.fromJson(Map<String, dynamic> json) {
    return ProductInfo(
      type: ProductTypeExtension.fromWire(json['type'] as String? ?? 'zip'),
      downloadUrl: json['downloadUrl'] as String? ?? '',
      downloadCount: json['downloadCount'] as int? ?? 0,
      checksum: json['checksum'] as String? ?? '',
      platform: json['platform'] as String? ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}

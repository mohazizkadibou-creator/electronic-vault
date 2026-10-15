import 'product.dart';

export 'product.dart';

/// Lifecycle status of a project inside the vault.
enum ProjectStatus { active, archived, publishing, published, error }

extension ProjectStatusExtension on ProjectStatus {
  String get label {
    switch (this) {
      case ProjectStatus.active:
        return 'Active';
      case ProjectStatus.archived:
        return 'Archived';
      case ProjectStatus.publishing:
        return 'Publishing';
      case ProjectStatus.published:
        return 'Published';
      case ProjectStatus.error:
        return 'Error';
    }
  }

  static ProjectStatus fromWire(String value) {
    return ProjectStatus.values.firstWhere(
      (ProjectStatus s) => s.name == value,
      orElse: () => ProjectStatus.active,
    );
  }
}

/// A secure project entry stored inside the vault.
///
/// Project data itself is encrypted with the vault master key; only the
/// non-sensitive metadata (name, status, product links) is surfaced in the UI.
class Project {
  final String id;
  final String vaultId;
  String name;
  String description;
  DateTime createdAt;
  DateTime updatedAt;
  DateTime lastActivity;
  ProjectStatus status;
  Map<String, ProductInfo> products;
  List<String> tags;
  Map<String, dynamic> settings;

  Project({
    required this.id,
    required this.vaultId,
    required this.name,
    required this.description,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastActivity,
    this.status = ProjectStatus.active,
    Map<String, ProductInfo>? products,
    List<String>? tags,
    Map<String, dynamic>? settings,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now(),
        lastActivity = lastActivity ?? DateTime.now(),
        products = products ?? <String, ProductInfo>{},
        tags = tags ?? <String>[],
        settings = settings ?? <String, dynamic>{};

  void touch() {
    updatedAt = DateTime.now();
    lastActivity = DateTime.now();
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'vaultId': vaultId,
        'name': name,
        'description': description,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'lastActivity': lastActivity.toIso8601String(),
        'status': status.name,
        'products': products.map(
          (String key, ProductInfo value) =>
              MapEntry<String, dynamic>(key, value.toJson()),
        ),
        'tags': tags,
        'settings': settings,
      };

  factory Project.fromJson(Map<String, dynamic> json) {
    final Map<String, ProductInfo> products = <String, ProductInfo>{};
    final Object? rawProducts = json['products'];
    if (rawProducts is Map) {
      rawProducts.forEach((Object? key, Object? value) {
        if (value is Map) {
          products['$key'] =
              ProductInfo.fromJson(Map<String, dynamic>.from(value));
        }
      });
    }

    return Project(
      id: json['id'] as String? ?? '',
      vaultId: json['vaultId'] as String? ?? '',
      name: json['name'] as String? ?? 'Untitled',
      description: json['description'] as String? ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? ''),
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? ''),
      lastActivity: DateTime.tryParse(json['lastActivity'] as String? ?? ''),
      status: ProjectStatusExtension.fromWire(
          json['status'] as String? ?? 'active'),
      products: products,
      tags: (json['tags'] as List<dynamic>?)
              ?.map((dynamic e) => '$e')
              .toList() ??
          <String>[],
      settings: json['settings'] is Map
          ? Map<String, dynamic>.from(json['settings'] as Map)
          : <String, dynamic>{},
    );
  }
}

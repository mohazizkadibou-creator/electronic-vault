import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/models.dart';

/// In-memory list of projects, persisted locally as JSON.
///
/// In a fully unlocked vault the JSON should be stored encrypted; the current
/// implementation keeps a plaintext cache in SharedPreferences and is designed
/// so the storage backend can be swapped for the encrypted vault store.
class ProjectService extends ChangeNotifier {
  static const String _kProjects = 'ev_projects';

  final SharedPreferences _prefs;
  final List<Project> _projects = <Project>[];

  ProjectService(this._prefs) {
    _load();
  }

  List<Project> get projects => List<Project>.unmodifiable(_projects);

  int get publishedCount =>
      _projects.where((Project p) => p.status == ProjectStatus.published).length;

  int get totalDownloads => _projects.fold<int>(
      0, (int sum, Project p) => sum + _downloadsFor(p));

  int _downloadsFor(Project p) => p.products.values
      .fold<int>(0, (int sum, ProductInfo info) => sum + info.downloadCount);

  void _load() {
    final String? raw = _prefs.getString(_kProjects);
    if (raw == null || raw.isEmpty) return;
    try {
      final List<dynamic> list = jsonDecode(raw) as List<dynamic>;
      for (final dynamic item in list) {
        if (item is Map) {
          _projects.add(Project.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    } catch (_) {
      // Corrupt cache - start fresh rather than crash.
      _projects.clear();
    }
  }

  Future<void> _save() async {
    final String raw = jsonEncode(
      _projects.map((Project p) => p.toJson()).toList(),
    );
    await _prefs.setString(_kProjects, raw);
  }

  Project createProject(String name, String description) {
    final Project project = Project(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      vaultId: 'local',
      name: name.trim().isEmpty ? 'Untitled' : name.trim(),
      description: description.trim(),
    );
    _projects.add(project);
    _save();
    notifyListeners();
    return project;
  }

  Future<void> addProduct(String projectId, ProductInfo product) async {
    final Project? project = _find(projectId);
    if (project == null) return;
    project.products[product.type.name] = product;
    project.touch();
    await _save();
    notifyListeners();
  }

  Future<void> setStatus(String projectId, ProjectStatus status) async {
    final Project? project = _find(projectId);
    if (project == null) return;
    project.status = status;
    project.touch();
    await _save();
    notifyListeners();
  }

  Future<void> deleteProject(String projectId) async {
    _projects.removeWhere((Project p) => p.id == projectId);
    await _save();
    notifyListeners();
  }

  Project? _find(String id) {
    for (final Project p in _projects) {
      if (p.id == id) return p;
    }
    return null;
  }

  Future<void> seedDemo() async {
    if (_projects.isNotEmpty) return;
    final Project project = createProject(
      'AI Code Assistant',
      'Intelligent code completion and debugging tool.',
    );
    project.products['zip'] = ProductInfo(
      type: ProductType.zip,
      downloadUrl: 'https://example.com/vault/ai-code-assistant.zip',
      downloadCount: 1250,
      platform: 'Windows',
    );
    project.products['apk'] = ProductInfo(
      type: ProductType.apk,
      downloadUrl: 'https://example.com/vault/ai-code-assistant.apk',
      downloadCount: 890,
      platform: 'Android',
    );
    project.status = ProjectStatus.published;
    project.touch();
    await _save();
    notifyListeners();
  }
}

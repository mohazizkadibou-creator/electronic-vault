import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_strings.dart';
import '../../core/localization.dart';
import '../../models/models.dart';
import '../../services/barrel.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProjectService>().seedDemo();
    });
  }

  Future<void> _createProject() async {
    final AppStrings s = context.read<LocalizationService>().strings;
    final TextEditingController name = TextEditingController();
    final TextEditingController desc = TextEditingController();

    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: Text(s.t('createProject')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextField(
              controller: name,
              autofocus: true,
              decoration: InputDecoration(labelText: s.t('projectName')),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: desc,
              decoration: InputDecoration(labelText: s.t('description')),
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(s.t('cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(s.t('create')),
          ),
        ],
      ),
    );

    if (ok == true && name.text.trim().isNotEmpty) {
      if (!mounted) return;
      context.read<ProjectService>().createProject(name.text, desc.text);
    }
    name.dispose();
    desc.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final LocalizationService l10n = context.watch<LocalizationService>();
    final AppStrings s = l10n.strings;
    final ProjectService projects = context.watch<ProjectService>();

    return Scaffold(
      appBar: AppBar(
        title: Text(s.t('appTitle')),
        actions: <Widget>[
          PopupMenuButton<String>(
            icon: const Icon(Icons.language),
            onSelected: l10n.setLanguage,
            itemBuilder: (BuildContext ctx) => AppStrings.supported
                .map((String c) => PopupMenuItem<String>(
                      value: c,
                      child: Text(c.toUpperCase()),
                    ))
                .toList(),
          ),
          IconButton(
            tooltip: s.t('lockVault'),
            icon: const Icon(Icons.lock_outline),
            onPressed: () => context.read<VaultService>().lockVault(),
          ),
          IconButton(
            tooltip: s.t('logout'),
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<VaultService>().lockVault();
              context.read<AuthService>().logout();
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createProject,
        icon: const Icon(Icons.add),
        label: Text(s.t('createProject')),
      ),
      body: Column(
        children: <Widget>[
          _StatsBar(
            projects: projects.projects.length,
            downloads: projects.totalDownloads,
            published: projects.publishedCount,
            strings: s,
          ),
          Expanded(
            child: projects.projects.isEmpty
                ? Center(child: Text(s.t('emptyProjects')))
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: projects.projects.length,
                    itemBuilder: (BuildContext ctx, int i) => _ProjectCard(
                      project: projects.projects[i],
                      strings: s,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _StatsBar extends StatelessWidget {
  const _StatsBar({
    required this.projects,
    required this.downloads,
    required this.published,
    required this.strings,
  });

  final int projects;
  final int downloads;
  final int published;
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      child: Row(
        children: <Widget>[
          _Stat(
            icon: Icons.folder_outlined,
            value: '$projects',
            label: strings.t('projects'),
          ),
          _Stat(
            icon: Icons.download_outlined,
            value: '$downloads',
            label: strings.t('downloads'),
          ),
          _Stat(
            icon: Icons.public,
            value: '$published',
            label: strings.t('published'),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.icon, required this.value, required this.label});

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: <Widget>[
          Icon(icon, size: 28),
          const SizedBox(height: 6),
          Text(value,
              style:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  const _ProjectCard({required this.project, required this.strings});

  final Project project;
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    project.name,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                Chip(
                  label: Text(project.status.label),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            if (project.description.isNotEmpty) ...<Widget>[
              const SizedBox(height: 4),
              Text(project.description),
            ],
            if (project.products.isNotEmpty) ...<Widget>[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: project.products.values
                    .map((ProductInfo p) => Chip(
                          avatar: const Icon(Icons.archive_outlined, size: 16),
                          label: Text(
                              '${p.type.label} - ${p.downloadCount}'),
                        ))
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

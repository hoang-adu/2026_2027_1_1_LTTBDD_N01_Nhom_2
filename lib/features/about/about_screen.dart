import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

/// Màn giới thiệu ứng dụng & nhóm phát triển. [Đạt]
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  /// Khớp `version` trong pubspec.yaml (không dùng package_info).
  static const String appVersion = '1.0.0';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final members = [
      _Member(l10n.about_member1Name, l10n.about_member1Role, isLeader: true),
      _Member(l10n.about_member2Name, l10n.about_member2Role),
      _Member(l10n.about_member3Name, l10n.about_member3Role),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(l10n.about_title)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const _AppHeader(version: appVersion),
              const SizedBox(height: 24),
              _SectionTitle(l10n.about_membersTitle),
              Card(
                child: Column(
                  children: [
                    for (var i = 0; i < members.length; i++) ...[
                      if (i > 0) const Divider(height: 1, indent: 72),
                      _MemberTile(member: members[i]),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _SectionTitle(l10n.about_courseTitle),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.menu_book_outlined),
                      title: Text(l10n.about_courseName),
                    ),
                    const Divider(height: 1, indent: 72),
                    ListTile(
                      leading: const Icon(Icons.school_outlined),
                      title: Text(l10n.about_university),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Member {
  const _Member(this.name, this.role, {this.isLeader = false});

  final String name;
  final String role;
  final bool isLeader;

  /// Monogram = chữ cái đầu của tên (từ cuối), vd "Nguyễn Tiến Đạt" → "Đ".
  String get monogram {
    final parts = name.trim().split(RegExp(r'\s+'));
    return parts.last.characters.first.toUpperCase();
  }
}

/// Logo chữ + tên app + mô tả + phiên bản.
class _AppHeader extends StatelessWidget {
  const _AppHeader({required this.version});

  final String version;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final s = theme.colorScheme;

    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: s.primaryContainer,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(Icons.style, size: 36, color: s.onPrimaryContainer),
        ),
        const SizedBox(height: 12),
        Text(
          l10n.app_title,
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          l10n.about_version(version),
          style: theme.textTheme.bodySmall?.copyWith(
            fontFamily: 'IBMPlexMono',
            color: s.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          l10n.about_appDescription,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: s.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
      child: Text(
        text,
        style: theme.textTheme.titleSmall?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _MemberTile extends StatelessWidget {
  const _MemberTile({required this.member});

  final _Member member;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final s = Theme.of(context).colorScheme;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: member.isLeader
            ? s.primaryContainer
            : s.secondaryContainer,
        foregroundColor: member.isLeader
            ? s.onPrimaryContainer
            : s.onSecondaryContainer,
        child: Text(
          member.monogram,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      title: Text(member.name),
      subtitle: Text(member.role),
      trailing: member.isLeader
          ? Chip(
              label: Text(l10n.about_leader),
              visualDensity: VisualDensity.compact,
              side: BorderSide.none,
              backgroundColor: s.tertiaryContainer,
              labelStyle: TextStyle(color: s.onTertiaryContainer),
            )
          : null,
    );
  }
}

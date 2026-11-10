import 'package:flutter/material.dart';

import '../../core/widgets/staggered_list.dart';
import '../../l10n/app_localizations.dart';

const String _kAppVersion = '1.0.0';

/// Thông tin một thành viên (mã sinh viên/email để trống thì không hiển thị).
class _Member {
  const _Member({required this.name, this.studentId = '', this.email = ''});

  final String name;
  final String studentId;
  final String email;
}

/// Danh sách thành viên
const List<_Member> _kMembers = [
  _Member(name: 'Nguyễn Việt Hoàng'),
  _Member(name: 'Nguyễn Hùng Hải Anh'),
  _Member(name: 'Nguyễn Tiến Đạt'),
];

/// Chữ cái đầu của tên gọi để làm monogram.
String _initialOf(String fullName) {
  final parts = fullName.trim().split(RegExp(r'\s+'));
  final given = parts.last;
  if (given.isEmpty) return '?';
  return String.fromCharCode(given.runes.first).toUpperCase();
}

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  /// Chiều rộng nội dung tối đa để màn rộng không bị kéo giãn.
  static const double _maxWidth = 600;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    // AppBar tự có nút quay lại khi màn được mở bằng Navigator.push.
    return Scaffold(
      appBar: AppBar(title: Text(l10n.about_title)),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _maxWidth),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const _HeaderCard(),
              const SizedBox(height: 16),
              const _InfoCard(),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
                child: Text(
                  l10n.about_teamTitle,
                  style: theme.textTheme.titleMedium,
                ),
              ),
              for (var i = 0; i < _kMembers.length; i++)
                StaggeredListItem(
                  key: ValueKey(_kMembers[i].name),
                  index: i,
                  child: _MemberCard(member: _kMembers[i]),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

//  Đầu trang

class _HeaderCard extends StatelessWidget {
  const _HeaderCard();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          children: [
            CircleAvatar(
              radius: 36,
              backgroundColor: scheme.primaryContainer,
              child: Icon(Icons.style_outlined,
                  size: 36, color: scheme.onPrimaryContainer),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.about_appName,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            Text(
              '${l10n.about_version} $_kAppVersion',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

// Thông tin môn học

class _InfoCard extends StatelessWidget {
  const _InfoCard();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            _InfoRow(
              icon: Icons.menu_book_outlined,
              label: l10n.about_courseLabel,
              value: l10n.about_courseValue,
            ),
            _InfoRow(
              icon: Icons.groups_outlined,
              label: l10n.about_groupLabel,
              value: l10n.about_groupValue,
            ),
            _InfoRow(
              icon: Icons.person_outline,
              label: l10n.about_lecturerLabel,
              value: l10n.about_lecturerValue,
            ),
            _InfoRow(
              icon: Icons.school_outlined,
              label: l10n.about_universityLabel,
              value: l10n.about_universityValue,
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: scheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelMedium
                      ?.copyWith(color: scheme.onSurfaceVariant),
                ),
                const SizedBox(height: 2),
                Text(value, style: theme.textTheme.bodyLarge),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

//  Thành viên

class _MemberCard extends StatelessWidget {
  const _MemberCard({required this.member});

  final _Member member;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final subStyle = theme.textTheme.bodySmall
        ?.copyWith(color: scheme.onSurfaceVariant);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: scheme.primaryContainer,
              child: Text(
                _initialOf(member.name),
                style: theme.textTheme.titleLarge
                    ?.copyWith(color: scheme.onPrimaryContainer),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(member.name, style: theme.textTheme.titleMedium),
                  if (member.studentId.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text('${l10n.about_studentId}: ${member.studentId}',
                        style: subStyle),
                  ],
                  if (member.email.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(member.email, style: subStyle),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

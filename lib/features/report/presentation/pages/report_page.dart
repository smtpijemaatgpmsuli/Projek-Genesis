import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../authentication/application/providers/auth_state.dart';
import '../../../authentication/domain/value_objects/user_role.dart';
import '../../../attendance/domain/entities/student_brief.dart';
import '../../application/controllers/report_controller.dart';
import '../../domain/entities/report_card.dart';

class ReportPage extends ConsumerWidget {
  const ReportPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final studentsAsync = ref.watch(reportStudentListProvider);

    final (isPengasuh, isAdmin, isParent, role) = switch (authState) {
      AuthAuthenticated(:final user) => (
          user.role == UserRole.pengasuh,
          user.role == UserRole.admin || user.role == UserRole.superAdmin,
          user.role == UserRole.orangTua,
          user.role,
        ),
      _ => (false, false, false, UserRole.pengasuh),
    };

    if (!isPengasuh && !isAdmin && !isParent) {
      return const Scaffold(
        body: Center(child: Text('Akses rapor dibatasi.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rapor Digital'),
      ),
      body: studentsAsync.when(
        data: (students) {
          if (students.isEmpty && !isParent) {
            return const Center(child: Text('Belum ada data siswa tersedia.'));
          }
          return _ReportBody(students: students, role: role);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Gagal memuat siswa: $e')),
      ),
    );
  }
}

class _ReportBody extends ConsumerStatefulWidget {
  const _ReportBody({required this.students, required this.role});

  final List<StudentBrief> students;
  final UserRole role;

  @override
  ConsumerState<_ReportBody> createState() => _ReportBodyState();
}

class _ReportBodyState extends ConsumerState<_ReportBody> {
  final _terms = const ['Semester 1', 'Semester 2'];
  StudentBrief? _selectedStudent;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = ref.read(reportStateProvider.notifier);
      controller.changeTerm('Semester 1');
      if (widget.students.isNotEmpty) {
        _selectedStudent = widget.students.first;
        controller.selectStudent(_selectedStudent!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(reportStateProvider);
    final controller = ref.read(reportStateProvider.notifier);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Periode Rapor'),
                  initialValue: state.currentTerm,
                  items: _terms
                      .map(
                        (term) => DropdownMenuItem(
                          value: term,
                          child: Text(term),
                        ),
                      )
                      .toList(),
                  onChanged: (term) {
                    if (term != null) {
                      controller.changeTerm(term);
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              if (widget.role != UserRole.orangTua)
                Expanded(
                  child: DropdownButtonFormField<StudentBrief>(
                    decoration: const InputDecoration(labelText: 'Pilih Siswa'),
                    initialValue: _selectedStudent,
                    items: widget.students
                        .map(
                          (student) => DropdownMenuItem(
                            value: student,
                            child: Text(student.fullName),
                          ),
                        )
                        .toList(),
                    onChanged: (student) {
                      if (student != null) {
                        setState(() => _selectedStudent = student);
                        controller.selectStudent(student);
                      }
                    },
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          state.report.when(
            data: (report) => report == null
                ? const Expanded(child: Center(child: Text('Pilih siswa untuk melihat rapor.')))
                : Expanded(child: _ReportCardView(report: report, role: widget.role)),
            loading: () => const Expanded(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, _) => Expanded(
              child: Center(child: Text('Gagal memuat rapor: $error')),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportCardView extends ConsumerWidget {
  const _ReportCardView({required this.report, required this.role});

  final ReportCard report;
  final UserRole role;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(reportStateProvider.notifier);
    final isAdmin = role == UserRole.admin || role == UserRole.superAdmin;
    final isCaregiver = role == UserRole.pengasuh;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Rapor Sekolah Minggu',
                          style: Theme.of(context).textTheme.titleLarge),
                      Text('Nama: ${report.student.fullName}'),
                      Text('Kelas: ${report.className}'),
                      Text('Periode: ${report.term}'),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Diterbitkan: ${DateFormat('dd MMM yyyy').format(report.issuedAt)}'),
                      Text('Total Sesi: ${report.attendanceSummary.totalSessions}'),
                    ],
                  ),
                ],
              ),
              const Divider(height: 32),
              Text('Ringkasan Penilaian',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              _ScoreRow(label: 'Spiritual', value: report.assessment.spiritual),
              _ScoreRow(label: 'Perilaku', value: report.assessment.behavior),
              _ScoreRow(label: 'Aktivitas', value: report.assessment.activity),
              const SizedBox(height: 12),
              Text('Catatan Pengasuh',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(report.assessment.notes.isEmpty
                  ? 'Belum ada catatan.'
                  : report.assessment.notes),
              const Divider(height: 32),
              Text('Ringkasan Kehadiran',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              Wrap(
                spacing: 16,
                children: [
                  _AttendanceBadge(label: 'Hadir', value: report.attendanceSummary.present, color: Colors.green),
                  _AttendanceBadge(label: 'Tidak Hadir', value: report.attendanceSummary.absent, color: Colors.red),
                  _AttendanceBadge(label: 'Izin', value: report.attendanceSummary.excused, color: Colors.orange),
                ],
              ),
              const Divider(height: 32),
              Text('Tanda Tangan', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _SignatureBox(
                    title: 'Admin',
                    name: report.signature.adminName,
                    signedAt: report.signature.adminSignedAt,
                    onSign: isAdmin
                        ? () => controller.signReport('admin')
                        : null,
                    isSigning: ref.watch(reportStateProvider).isSigning,
                  ),
                  _SignatureBox(
                    title: 'Pengasuh',
                    name: report.signature.caregiverName,
                    signedAt: report.signature.caregiverSignedAt,
                    onSign: isCaregiver
                        ? () => controller.signReport('caregiver')
                        : null,
                    isSigning: ref.watch(reportStateProvider).isSigning,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _showPrintPreview(context, report),
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text('Lihat Format Cetak'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPrintPreview(BuildContext context, ReportCard report) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        child: SizedBox(
          width: 720,
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Rapor Cetak', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),
                Text('Nama: ${report.student.fullName}'),
                Text('Kelas: ${report.className}'),
                Text('Periode: ${report.term}'),
                const Divider(height: 32),
                const Text('Penilaian'),
                Text('- Spiritual: ${report.assessment.spiritual}'),
                Text('- Perilaku: ${report.assessment.behavior}'),
                Text('- Aktivitas: ${report.assessment.activity}'),
                const Divider(height: 32),
                Text('Catatan: ${report.assessment.notes}'),
                const Divider(height: 32),
                Text('Kehadiran: Hadir ${report.attendanceSummary.present}, Tidak Hadir ${report.attendanceSummary.absent}, Izin ${report.attendanceSummary.excused}'),
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Tutup'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ScoreRow extends StatelessWidget {
  const _ScoreRow({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.blue.shade50,
            ),
            child: Text('$value / 100'),
          ),
        ],
      ),
    );
  }
}

class _AttendanceBadge extends StatelessWidget {
  const _AttendanceBadge({required this.label, required this.value, required this.color});

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text('$label: $value'),
      backgroundColor: color.withValues(alpha: 0.15),
      shape: StadiumBorder(side: BorderSide(color: color)),
    );
  }
}

class _SignatureBox extends StatelessWidget {
  const _SignatureBox({
    required this.title,
    required this.name,
    required this.signedAt,
    this.onSign,
    this.isSigning = false,
  });

  final String title;
  final String name;
  final DateTime? signedAt;
  final VoidCallback? onSign;
  final bool isSigning;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 240,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name),
                const SizedBox(height: 8),
                Text(
                  signedAt == null
                      ? 'Belum ditandatangani'
                      : 'Ditandatangani: ${DateFormat('dd MMM yyyy HH:mm').format(signedAt!)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (onSign != null)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: isSigning ? null : onSign,
                      child: isSigning
                          ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Tandatangani'),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

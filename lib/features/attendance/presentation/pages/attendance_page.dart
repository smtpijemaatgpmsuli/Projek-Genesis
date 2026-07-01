import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../application/controllers/attendance_controller.dart';
import '../../domain/entities/attendance_record.dart';
import '../../domain/entities/attendance_session.dart';
import '../../domain/entities/student_brief.dart';

final attendanceSessionListProvider = FutureProvider.family<List<AttendanceSession>, String>((ref, classId) {
  return ref.watch(attendanceRepositoryProvider).getSessions(classId);
});

final attendanceStudentListProvider = FutureProvider.family<List<StudentBrief>, String>((ref, classId) {
  return ref.watch(attendanceRepositoryProvider).getStudents(classId);
});

class AttendancePage extends ConsumerStatefulWidget {
  const AttendancePage({super.key});

  @override
  ConsumerState<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends ConsumerState<AttendancePage> {
  String? _selectedClassId;
  String? _selectedClassName;
  AttendanceSession? _selectedSession;
  Map<String, AttendanceStatus> _statusMap = {};

  @override
  void initState() {
    super.initState();
  }

  Future<void> _selectSession(AttendanceSession session) async {
    setState(() {
      _selectedSession = session;
      _statusMap = {};
    });

    final repo = ref.read(attendanceRepositoryProvider);
    final records = await repo.getRecords(session.id);
    if (records.isNotEmpty) {
      setState(() {
        for (final r in records) {
          _statusMap[r.studentId] = r.status;
        }
      });
    }
  }

  Future<void> _createSession() async {
    if (_selectedClassId == null) return;

    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2050),
    );
    if (date == null || !mounted) return;

    final topicController = TextEditingController();
    final topic = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Buat Pertemuan Baru'),
        content: TextField(
          controller: topicController,
          decoration: const InputDecoration(
            labelText: 'Topik (opsional)',
            hintText: 'Cth: Cerita Abraham',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(topicController.text),
            child: const Text('Buat'),
          ),
        ],
      ),
    );

    if (topic == null || !mounted) return;

    final client = Supabase.instance.client;
    final data = await client.from('attendance_sessions').insert({
      'class_id': _selectedClassId,
      'date': date.toIso8601String().split('T')[0],
      if (topic.isNotEmpty) 'topic': topic,
    }).select().single();

    final session = AttendanceSession.fromMap(data);
    setState(() => _selectedSession = session);
    // Refresh session list
    ref.invalidate(attendanceSessionListProvider(_selectedClassId!));
  }

  Future<void> _save() async {
    if (_selectedSession == null) return;

    final repo = ref.read(attendanceRepositoryProvider);
    final records = _statusMap.entries.map((e) => AttendanceRecord(
      id: '${_selectedSession!.id}_${e.key}',
      sessionId: _selectedSession!.id,
      studentId: e.key,
      status: e.value,
    )).toList();

    await repo.saveRecords(records);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Absensi berhasil disimpan')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final classes = ref.watch(classListForAttendanceProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Absensi')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Step 1: Pilih kelas dari dropdown real
          Text('Pilih Kelas', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          classes.when(
            data: (data) => DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Kelas',
                prefixIcon: Icon(Icons.school),
              ),
              initialValue: _selectedClassId,
              items: data
                  .map((c) => DropdownMenuItem(
                        value: c.id,
                        child: Text(c.name),
                      ))
                  .toList(),
              onChanged: (id) {
                if (id != null) {
                  setState(() {
                    _selectedClassId = id;
                    _selectedClassName = data.firstWhere((c) => c.id == id).name;
                    _selectedSession = null;
                    _statusMap = {};
                  });
                  ref.read(attendanceStateProvider.notifier).loadStudents(id);
                  ref.invalidate(attendanceSessionListProvider(id));
                }
              },
            ),
            loading: () => DropdownButtonFormField(
              decoration: InputDecoration(labelText: 'Kelas', prefixIcon: Icon(Icons.school)),
              items: [],
              onChanged: null,
            ),
            error: (e, _) => Text('Gagal memuat kelas: $e'),
          ),
          const SizedBox(height: 24),

          if (_selectedClassId != null) ...[
            // Step 2: Pilih sesi / buat baru
            Text('Pilih Pertemuan', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            _SessionSelector(
              classId: _selectedClassId!,
              selectedSession: _selectedSession,
              onSelect: _selectSession,
              onCreate: _createSession,
            ),
            const SizedBox(height: 24),

            // Step 3: Form absensi
            if (_selectedSession != null) ...[
              Row(
                children: [
                  Text('Absensi: ${_selectedClassName ?? _selectedClassId}',
                      style: theme.textTheme.titleSmall),
                  const Spacer(),
                  Text(
                    _selectedSession!.date.toLocal().toString().split(' ')[0],
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
              if (_selectedSession!.topic != null &&
                  _selectedSession!.topic!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text('Topik: ${_selectedSession!.topic}',
                      style: theme.textTheme.bodySmall),
                ),
              const SizedBox(height: 16),
              _AttendanceForm(
                classId: _selectedClassId!,
                statusMap: _statusMap,
                onChanged: (studentId, status) {
                  setState(() => _statusMap[studentId] = status);
                },
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _statusMap.isEmpty ? null : _save,
                icon: const Icon(Icons.save),
                label: const Text('Simpan Absensi'),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _SessionSelector extends ConsumerWidget {
  const _SessionSelector({
    required this.classId,
    required this.selectedSession,
    required this.onSelect,
    required this.onCreate,
  });

  final String classId;
  final AttendanceSession? selectedSession;
  final ValueChanged<AttendanceSession> onSelect;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessions = ref.watch(attendanceSessionListProvider(classId));

    return sessions.when(
      data: (data) => Column(
        children: [
          DropdownButtonFormField<AttendanceSession>(
            decoration: const InputDecoration(labelText: 'Pilih Pertemuan'),
            initialValue: selectedSession,
            items: data.map((s) => DropdownMenuItem(
              value: s,
              child: Text('${s.date.toLocal().toString().split(' ')[0]}${s.topic != null && s.topic!.isNotEmpty ? ' - ${s.topic}' : ''}'),
            )).toList(),
            onChanged: (s) {
              if (s != null) onSelect(s);
            },
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: onCreate,
            icon: const Icon(Icons.add),
            label: const Text('Buat Pertemuan Baru'),
          ),
        ],
      ),
      loading: () => const CircularProgressIndicator(),
      error: (e, _) => Text('Error: $e'),
    );
  }
}

class _AttendanceForm extends ConsumerWidget {
  const _AttendanceForm({
    required this.classId,
    required this.statusMap,
    required this.onChanged,
  });

  final String classId;
  final Map<String, AttendanceStatus> statusMap;
  final void Function(String studentId, AttendanceStatus status) onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final students = ref.watch(attendanceStudentListProvider(classId));

    return students.when(
      data: (data) => Column(
        children: data.map((student) {
          final status = statusMap[student.id] ?? AttendanceStatus.present;
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              title: Text(student.fullName),
              trailing: SegmentedButton<AttendanceStatus>(
                segments: const [
                  ButtonSegment(value: AttendanceStatus.present, label: Text('H'), icon: Icon(Icons.check_circle, size: 18)),
                  ButtonSegment(value: AttendanceStatus.absent, label: Text('A'), icon: Icon(Icons.cancel, size: 18)),
                  ButtonSegment(value: AttendanceStatus.excused, label: Text('I'), icon: Icon(Icons.info, size: 18)),
                ],
                selected: {status},
                onSelectionChanged: (set) => onChanged(student.id, set.first),
                showSelectedIcon: false,
              ),
            ),
          );
        }).toList(),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Text('Error: $e'),
    );
  }
}

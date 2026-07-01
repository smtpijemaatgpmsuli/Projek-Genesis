import 'package:flutter/material.dart';

/// Navigasi item untuk shell.
class ShellTab {
  const ShellTab({
    required this.label,
    required this.icon,
    required this.activeIcon,
  });

  final String label;
  final IconData icon;
  final IconData activeIcon;
}

/// Shell tabs — disesuaikan dengan role (admin/pengasuh/ortu).
const adminTabs = [
  ShellTab(label: 'Dashboard', icon: Icons.dashboard_outlined, activeIcon: Icons.dashboard),
  ShellTab(label: 'Kelas', icon: Icons.school_outlined, activeIcon: Icons.school),
  ShellTab(label: 'Siswa', icon: Icons.people_outlined, activeIcon: Icons.people),
  ShellTab(label: 'Rapor', icon: Icons.assignment_outlined, activeIcon: Icons.assignment),
  ShellTab(label: 'Lainnya', icon: Icons.more_horiz_outlined, activeIcon: Icons.more_horiz),
];

const caregiverTabs = [
  ShellTab(label: 'Dashboard', icon: Icons.dashboard_outlined, activeIcon: Icons.dashboard),
  ShellTab(label: 'Absensi', icon: Icons.calendar_today_outlined, activeIcon: Icons.calendar_today),
  ShellTab(label: 'Nilai', icon: Icons.grading_outlined, activeIcon: Icons.grading),
  ShellTab(label: 'Rapor', icon: Icons.assignment_outlined, activeIcon: Icons.assignment),
];

const parentTabs = [
  ShellTab(label: 'Dashboard', icon: Icons.dashboard_outlined, activeIcon: Icons.dashboard),
  ShellTab(label: 'Rapor', icon: Icons.assignment_outlined, activeIcon: Icons.assignment),
  ShellTab(label: 'Profil', icon: Icons.person_outlined, activeIcon: Icons.person),
];

/// Mendapatkan daftar tab berdasarkan lokasi dan role.
List<ShellTab> tabsForRoute(String location) {
  // Default: admin tabs — akan di-filter oleh AuthGuard nanti
  return adminTabs;
}

/// Index tab berdasarkan path.
int indexForLocation(String location) {
  if (location.startsWith('/kelas')) return 1;
  if (location.startsWith('/siswa')) return 2;
  if (location.startsWith('/rapor')) return 3;
  if (location.startsWith('/lainnya') || location.startsWith('/pengaturan')) return 4;
  return 0; // dashboard
}

String locationForIndex(int index) {
  switch (index) {
    case 0: return '/';
    case 1: return '/kelas';
    case 2: return '/siswa';
    case 3: return '/rapor';
    case 4: return '/lainnya';
    default: return '/';
  }
}

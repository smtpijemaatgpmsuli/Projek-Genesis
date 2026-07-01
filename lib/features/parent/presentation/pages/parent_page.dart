import 'package:flutter/material.dart';

import 'package:genesis/shared/pages/placeholder_page.dart';

class ParentPage extends StatelessWidget {
  const ParentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderPage(
      title: 'Profil Saya',
      icon: Icons.person,
      description: 'Lihat data orang tua dan anak.',
    );
  }
}

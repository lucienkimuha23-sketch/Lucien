import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const CvApp());
}

const _navy = Color(0xFF203047);
const _teal = Color(0xFF287C78);
const _cream = Color(0xFFF7F5EF);

class CvApp extends StatelessWidget {
  const CvApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mon CV Flutter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: _teal, surface: _cream),
        scaffoldBackgroundColor: _cream,
        appBarTheme: const AppBarTheme(
          backgroundColor: _cream,
          foregroundColor: _navy,
          centerTitle: false,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _hidePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _signIn() {
    if (!_formKey.currentState!.validate()) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const PortfolioPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const CircleAvatar(
                      radius: 42,
                      backgroundColor: _teal,
                      child: Icon(
                        Icons.badge_outlined,
                        size: 42,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Bienvenue !',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(color: _navy, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Connecte-toi pour découvrir mon CV.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 32),
                    TextFormField(
                      controller: _usernameController,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Identifiant',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? 'Entre ton identifiant.'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _hidePassword,
                      onFieldSubmitted: (_) => _signIn(),
                      decoration: InputDecoration(
                        labelText: 'Mot de passe',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          tooltip: _hidePassword
                              ? 'Afficher le mot de passe'
                              : 'Masquer le mot de passe',
                          onPressed: () =>
                              setState(() => _hidePassword = !_hidePassword),
                          icon: Icon(
                            _hidePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Entre ton mot de passe.'
                          : null,
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: _signIn,
                      icon: const Icon(Icons.login),
                      label: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        child: Text('Se connecter'),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Démo locale : saisis simplement un identifiant et un '
                      'mot de passe non vides. Aucun compte n’est créé.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PortfolioPage extends StatefulWidget {
  const PortfolioPage({super.key});

  @override
  State<PortfolioPage> createState() => _PortfolioPageState();
}

class _PortfolioPageState extends State<PortfolioPage> {
  int _selectedIndex = 0;

  static const _titles = ['Mon CV', 'Ma famille', 'Me contacter'];
  static const _pages = [_CvTab(), _FamilyTab(), _ContactTab()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        actions: [
          IconButton(
            tooltip: 'Se déconnecter',
            onPressed: () => Navigator.of(context).pushReplacement(
              MaterialPageRoute<void>(builder: (_) => const LoginPage()),
            ),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: SafeArea(
        child: IndexedStack(index: _selectedIndex, children: _pages),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) =>
            setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.badge_outlined),
            selectedIcon: Icon(Icons.badge),
            label: 'CV',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: 'Famille',
          ),
          NavigationDestination(
            icon: Icon(Icons.contact_mail_outlined),
            selectedIcon: Icon(Icons.contact_mail),
            label: 'Contact',
          ),
        ],
      ),
    );
  }
}

class _CvTab extends StatelessWidget {
  const _CvTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
      children: [
        Card(
          color: _navy,
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 46,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.add_a_photo_outlined,
                    size: 34,
                    color: _teal,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'kambale Kithi Lucien',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Étudiant(e) en informatique • Débutant(e) Flutter',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Photo à ajouter : remplace cette icône par ton portrait.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
        const _SectionCard(
          title: 'Formation',
          icon: Icons.school_outlined,
          children: [
            _InfoLine(
              title: 'Diplôme ou formation à renseigner',
              subtitle: 'ISIG • GOMA• 2025-2026',
              icon: Icons.menu_book_outlined,
            ),
          ],
        ),
        const _SectionCard(
          title: 'Expériences et projets',
          icon: Icons.work_outline,
          children: [
            _InfoLine(
              title: 'Projet de CV avec Flutter',
              subtitle:
                  'Application mobile en cours d’apprentissage : écrans, '
                  'formulaires et navigation.',
              icon: Icons.phone_android,
            ),
            Divider(height: 20),
            _InfoLine(
              title: 'Stage ou emploi à compléter',
              subtitle: 'Organisation • Rôle • Période',
              icon: Icons.business_center_outlined,
            ),
          ],
        ),
        const _SectionCard(
          title: 'Compétences',
          icon: Icons.code,
          children: [
            _InfoLine(
              title: 'Techniques',
              subtitle: 'Flutter, Dart, Git, HTML/CSS (exemples à adapter)',
              icon: Icons.terminal,
            ),
            Divider(height: 20),
            _InfoLine(
              title: 'Langues',
              subtitle: 'Français • Anglais • Swahili (exemples à adapter)',
              icon: Icons.language,
            ),
          ],
        ),
        const _SectionCard(
          title: 'Centres d’intérêt',
          icon: Icons.favorite_border,
          children: [
            _InfoLine(
              title: 'loisirs et passions',
              subtitle: 'Sport, musique, lecture, technologie…',
              icon: Icons.interests_outlined,
            ),
          ],
        ),
      ],
    );
  }
}

class _FamilyTab extends StatelessWidget {
  const _FamilyTab();

  static const _members = [
    _FamilyMember(
      'Nom à renseigner',
      'Muhindo justin',
      'comptable',
      Color(0xFFE2F1EE),
    ),
    _FamilyMember(
      'Nom à renseigner',
      'kabuo odile',
      'menager',
      Color(0xFFFFEBD8),
    ),
    _FamilyMember(
      'Nom à renseigner',
      'eddy / jissy',
      'etudiant(e)',
      Color(0xFFE7E9F7),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
      children: [
        Text(
          'Les personnes qui comptent pour moi.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 12),
        ..._members.map(
          (member) => Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              leading: CircleAvatar(
                radius: 28,
                backgroundColor: member.color,
                child: const Icon(Icons.add_a_photo_outlined, color: _navy),
              ),
              title: Text(
                member.name,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Text('${member.relationship} • ${member.profession}'),
              ),
              trailing: const Icon(Icons.edit_outlined, color: _teal),
            ),
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Ajoute une photo et remplace les exemples par les informations '
          'que ta famille accepte de partager.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.black54),
        ),
      ],
    );
  }
}

class _FamilyMember {
  const _FamilyMember(
    this.name,
    this.relationship,
    this.profession,
    this.color,
  );

  final String name;
  final String relationship;
  final String profession;
  final Color color;
}

class _ContactTab extends StatelessWidget {
  const _ContactTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
      children: [
        Text(
          'Un projet en tête ? Écris-moi !',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 12),
        _ContactCard(
          icon: Icons.call_outlined,
          title: 'Téléphone',
          value: '+243 974301315',
        ),
        _ContactCard(
          icon: Icons.email_outlined,
          title: 'E-mail',
          value: 'LUCIEN.KIMUHA23@GMAIL.COM',
        ),
        _ContactCard(
          icon: Icons.location_on_outlined,
          title: 'adresse,ville',
          value: 'goma, RDC',
        ),
        _ContactCard(
          icon: Icons.link,
          title: 'GitHub',
          value: 'github.com/lucienkimuha23-sketch',
        ),
        const SizedBox(height: 8),
        const Text(
          'Les coordonnées sont des exemples. Appuie sur une ligne pour la '
          'copier, puis remplace-la par tes vraies informations.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.black54),
        ),
      ],
    );
  }
}

class _ContactCard extends StatelessWidget {
  const _ContactCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  Future<void> _copyValue(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: value));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$title copié dans le presse-papiers')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        onTap: () => _copyValue(context),
        leading: Icon(icon, color: _teal),
        title: Text(title),
        subtitle: Text(value),
        trailing: const Icon(Icons.copy_outlined, size: 18),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(top: 12),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: _teal),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: _navy,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: _teal),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(subtitle, style: const TextStyle(color: Colors.black54)),
            ],
          ),
        ),
      ],
    );
  }
}

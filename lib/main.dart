import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import 'api_service.dart';
import 'family_member.dart';

void main() {
  runApp(const CvApp());
}

const _navy = Color(0xFF17243C);
const _teal = Color(0xFF1F7A78);
const _cream = Color(0xFFF4F7FB);
const _blue = Color(0xFF3563E9);

class CvApp extends StatelessWidget {
  const CvApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mon CV Flutter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _blue,
          surface: _cream,
          primary: _blue,
        ),
        scaffoldBackgroundColor: _cream,
        appBarTheme: const AppBarTheme(
          backgroundColor: _cream,
          foregroundColor: _navy,
          centerTitle: false,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFDDE3EC)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFDDE3EC)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _blue, width: 1.5),
          ),
        ),
        cardTheme: const CardThemeData(
          color: Colors.white,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(18)),
            side: BorderSide(color: Color(0xFFE8EDF4)),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: _navy,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          height: 72,
          backgroundColor: Colors.white,
          indicatorColor: _blue.withValues(alpha: 0.12),
          elevation: 8,
          surfaceTintColor: Colors.transparent,
          labelTextStyle: WidgetStateProperty.resolveWith(
            (states) => TextStyle(
              color: states.contains(WidgetState.selected)
                  ? _blue
                  : const Color(0xFF7A8495),
              fontWeight: states.contains(WidgetState.selected)
                  ? FontWeight.w700
                  : FontWeight.w500,
              fontSize: 12,
            ),
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
  final _api = ApiService();
  bool _hidePassword = true;
  bool _isRegistering = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      if (_isRegistering) {
        await _api.register(
          email: _usernameController.text.trim(),
          password: _passwordController.text,
        );
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Compte créé. Vous pouvez vous connecter.'),
          ),
        );
        setState(() => _isRegistering = false);
      } else {
        await _api.login(
          email: _usernameController.text.trim(),
          password: _passwordController.text,
        );
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(
            builder: (_) =>
                PortfolioPage(email: _usernameController.text.trim()),
          ),
        );
      }
    } on ApiException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Impossible de joindre l’API. Vérifiez XAMPP et l’URL API.',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final form = Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 88,
            decoration: BoxDecoration(
              color: _blue.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: ClipOval(
                child: Image.asset(
                  'assets/profile_photo.jpg',
                  width: 72,
                  height: 72,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(height: 22),
          Text(
            _isRegistering ? 'Créer votre espace' : 'Bienvenue',
            style: const TextStyle(
              color: _navy,
              fontSize: 32,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _isRegistering
                ? 'Enregistrez un compte pour accéder à votre CV.'
                : 'Connectez-vous pour consulter votre portefeuille professionnel.',
            style: const TextStyle(
              color: Color(0xFF707B8C),
              fontSize: 15,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 28),
          TextFormField(
            controller: _usernameController,
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Adresse e-mail',
              prefixIcon: Icon(Icons.mail_outline),
            ),
            validator: (value) => value == null || value.trim().isEmpty
                ? 'Entre ton adresse e-mail.'
                : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passwordController,
            obscureText: _hidePassword,
            onFieldSubmitted: (_) => _submit(),
            decoration: InputDecoration(
              labelText: 'Mot de passe',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                tooltip: _hidePassword
                    ? 'Afficher le mot de passe'
                    : 'Masquer le mot de passe',
                onPressed: () => setState(() => _hidePassword = !_hidePassword),
                icon: Icon(
                  _hidePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
              ),
            ),
            validator: (value) => value == null || value.isEmpty
                ? 'Entre ton mot de passe.'
                : value.length < 6
                ? 'Le mot de passe doit contenir au moins 6 caractères.'
                : null,
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _isLoading ? null : _submit,
            icon: _isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Icon(_isRegistering ? Icons.person_add : Icons.arrow_forward),
            label: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Text(_isRegistering ? 'Créer le compte' : 'Se connecter'),
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: _isLoading
                ? null
                : () => setState(() => _isRegistering = !_isRegistering),
            child: Text(
              _isRegistering
                  ? 'Déjà un compte ? Se connecter'
                  : 'Pas de compte ? Créer un compte',
            ),
          ),
        ],
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFEEF2F8),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 900;
            final panel = Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: wide ? 52 : 24,
                  vertical: 28,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: form,
                ),
              ),
            );

            if (!wide) return panel;

            return Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Expanded(
                    flex: 6,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF17243C), Color(0xFF274F78)],
                        ),
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            right: -80,
                            top: -80,
                            child: Container(
                              width: 240,
                              height: 240,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withValues(alpha: 0.05),
                              ),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.all(52),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.work_outline,
                                  color: Colors.white,
                                  size: 44,
                                ),
                                SizedBox(height: 28),
                                Text(
                                  'Profil professionnel et famille',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 38,
                                    height: 1.15,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'CV • Expérience • Famille • Contact',
                                  style: TextStyle(
                                    color: Color(0xFFC8D5E6),
                                    fontSize: 17,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 5,
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(24, 0, 0, 0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: const Color(0xFFE5EBF3)),
                      ),
                      child: panel,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class PortfolioPage extends StatefulWidget {
  const PortfolioPage({super.key, this.email = ''});

  final String email;

  @override
  State<PortfolioPage> createState() => _PortfolioPageState();
}

class _PortfolioPageState extends State<PortfolioPage> {
  int _selectedIndex = 0;

  static const _titles = [
    'Accueil',
    'Ma famille',
    'Mon profil',
    'Me contacter',
  ];

  @override
  Widget build(BuildContext context) {
    final pages = [
      _DashboardTab(
        email: widget.email,
        onNavigate: (index) => setState(() => _selectedIndex = index),
      ),
      const _FamilyTab(),
      const _CvTab(),
      const _ContactTab(),
    ];

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 68,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Kambale Kithi Lucien',
              style: TextStyle(
                color: _navy,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              _titles[_selectedIndex],
              style: const TextStyle(color: Color(0xFF8590A1), fontSize: 12),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Se déconnecter',
            onPressed: () => Navigator.of(context).pushReplacement(
              MaterialPageRoute<void>(builder: (_) => const LoginPage()),
            ),
            icon: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE3E8F0)),
              ),
              child: const Icon(Icons.logout, size: 19),
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: SafeArea(
        child: IndexedStack(index: _selectedIndex, children: pages),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) =>
            setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Accueil',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: 'Famille',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profil',
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

class _DashboardTab extends StatefulWidget {
  const _DashboardTab({required this.email, required this.onNavigate});

  final String email;
  final ValueChanged<int> onNavigate;

  @override
  State<_DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<_DashboardTab> {
  final _api = ApiService();
  Future<_DashboardCounts>? _counts;

  @override
  void initState() {
    super.initState();
    _counts = _loadCounts();
  }

  Future<_DashboardCounts> _loadCounts() async {
    final members = await _api.getFamilyMembers();
    return _DashboardCounts(familyCount: members.length);
  }

  @override
  Widget build(BuildContext context) {
    final displayName = widget.email.isEmpty
        ? 'Kambale Kithi Lucien'
        : widget.email.split('@').first;

    return FutureBuilder<_DashboardCounts>(
      future: _counts,
      builder: (context, snapshot) {
        final counts = snapshot.data;

        return RefreshIndicator(
          onRefresh: () async {
            final future = _loadCounts();
            setState(() {
              _counts = future;
            });
            await future;
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [_navy, Color(0xFF285A78)],
                  ),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.65),
                        ),
                      ),
                      child: const CircleAvatar(
                        radius: 31,
                        backgroundImage: AssetImage(
                          'assets/profile_photo.jpg',
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'VOTRE ESPACE PERSONNEL',
                            style: TextStyle(
                              color: Color(0xFFD4E3EF),
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Bonjour, $displayName',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          if (widget.email.isNotEmpty)
                            Text(
                              widget.email,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFFD4E3EF),
                                fontSize: 11,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              const _DashboardSectionTitle(
                title: 'Vue d’ensemble',
                subtitle: 'Votre espace en quelques chiffres',
              ),
              const SizedBox(height: 10),
              _DashboardMetric(
                icon: Icons.people_outline,
                label: 'Membres de la famille',
                value: counts?.familyCount ?? 0,
                color: _teal,
              ),
              const SizedBox(height: 22),
              const _DashboardSectionTitle(
                title: 'Accès rapide',
                subtitle: 'Retrouvez facilement vos rubriques',
              ),
              const SizedBox(height: 10),
              _DashboardLink(
                icon: Icons.badge_outlined,
                iconColor: _blue,
                title: 'Mon profil',
                subtitle: 'Formation, expériences et compétences',
                onTap: () => widget.onNavigate(2),
              ),
              _DashboardLink(
                icon: Icons.people_outline,
                iconColor: _teal,
                title: 'Ma famille',
                subtitle: 'Consulter les membres de la famille',
                onTap: () => widget.onNavigate(1),
              ),
              _DashboardLink(
                icon: Icons.contact_mail_outlined,
                iconColor: const Color(0xFF54738A),
                title: 'Me contacter',
                subtitle: 'Téléphone, e-mail et adresse',
                onTap: () => widget.onNavigate(3),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DashboardCounts {
  const _DashboardCounts({required this.familyCount});

  final int familyCount;
}

class _DashboardSectionTitle extends StatelessWidget {
  const _DashboardSectionTitle({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: _navy,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          subtitle,
          style: const TextStyle(color: Color(0xFF7A8495), fontSize: 12),
        ),
      ],
    );
  }
}

class _DashboardMetric extends StatelessWidget {
  const _DashboardMetric({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 23),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF687487),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              '$value',
              style: const TextStyle(
                color: _navy,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardLink extends StatelessWidget {
  const _DashboardLink({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(color: _navy, fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: Color(0xFF8A94A5), fontSize: 12),
        ),
        trailing: const Icon(Icons.chevron_right, color: Color(0xFFADB6C4)),
      ),
    );
  }
}

class _ContactTab extends StatelessWidget {
  const _ContactTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
      children: [
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_navy, Color(0xFF285A78)],
            ),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.chat_bubble_outline,
                  color: Colors.white,
                  size: 26,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Parlons de votre projet',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Mes coordonnées, en un seul endroit.',
                      style: TextStyle(
                        color: Color(0xFFD4E3EF),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            'ME CONTACTER',
            style: TextStyle(
              color: Color(0xFF7A8495),
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
            ),
          ),
        ),
        const _ContactCard(
          icon: Icons.call_outlined,
          title: 'Téléphone',
          value: '+243 974301315',
        ),
        const _ContactCard(
          icon: Icons.email_outlined,
          title: 'E-mail',
          value: 'LUCIEN.KIMUHA23@GMAIL.COM',
        ),
        const _ContactCard(
          icon: Icons.location_on_outlined,
          title: 'Adresse',
          value: 'Goma, RDC, Keshero',
        ),
        const _ContactCard(
          icon: Icons.link,
          title: 'GitHub',
          value: 'github.com/lucienkimuha23-sketch',
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
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        onTap: () => _copyValue(context),
        leading: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: _teal.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: _teal, size: 22),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: _navy,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            value,
            style: const TextStyle(
              color: Color(0xFF687487),
              fontSize: 14,
            ),
          ),
        ),
        trailing: const Icon(
          Icons.content_copy_outlined,
          color: Color(0xFF8A94A5),
          size: 18,
        ),
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
        LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 520;
            final portrait = Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.6),
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(23),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(19),
                child: Image.asset(
                  'assets/profile_photo.jpg',
                  width: 92,
                  height: 104,
                  fit: BoxFit.cover,
                ),
              ),
            );
            final details = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Kambale Kithi Lucien',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    height: 1.15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 9),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.13),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Étudiant en informatique',
                    style: TextStyle(
                      color: Color(0xFFE0EDF5),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Flutter  •  Dart  •  Développement web',
                  style: TextStyle(
                    color: Color(0xFFD4E3EF),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            );

            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [_navy, Color(0xFF285A78)],
                ),
                borderRadius: BorderRadius.circular(22),
              ),
              child: compact
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        portrait,
                        const SizedBox(height: 18),
                        details,
                      ],
                    )
                  : Row(
                      children: [
                        portrait,
                        const SizedBox(width: 20),
                        Expanded(child: details),
                      ],
                    ),
            );
          },
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
              subtitle: 'Flutter, Dart, Git, HTML/CSS ',
              icon: Icons.terminal,
            ),
            Divider(height: 20),
            _InfoLine(
              title: 'Langues',
              subtitle: 'Français • Anglais • Swahili • Lingala',
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

class _FamilyTab extends StatefulWidget {
  const _FamilyTab();

  @override
  State<_FamilyTab> createState() => _FamilyTabState();
}

class _FamilyTabState extends State<_FamilyTab> {
  final _api = ApiService();
  Future<List<FamilyMember>>? _membersFuture;

  @override
  void initState() {
    super.initState();
    _membersFuture = _api.getFamilyMembers();
  }

  Future<void> _refresh() async {
    final future = _api.getFamilyMembers();
    setState(() {
      _membersFuture = future;
    });
    await future;
  }

  Future<void> _deleteMember(FamilyMember member) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer ce membre ?'),
        content: Text(member.fullName),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await _api.deleteFamilyMember(member.id);
      await _refresh();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Membre supprimé.')));
    } on ApiException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  Future<void> _openMemberForm({FamilyMember? member}) async {
    await showDialog<void>(
      context: context,
      builder: (context) =>
          _FamilyMemberDialog(api: _api, member: member, onSaved: _refresh),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openMemberForm(),
        icon: const Icon(Icons.person_add),
        label: const Text('Ajouter'),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<FamilyMember>>(
          future: _membersFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  const Icon(Icons.cloud_off, size: 48, color: _teal),
                  const SizedBox(height: 12),
                  Text(
                    snapshot.error is ApiException
                        ? snapshot.error.toString()
                        : 'Impossible de charger les membres.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Démarrez XAMPP, importez api.sql et vérifiez '
                    'http://127.0.0.1/api-test/public.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black54),
                  ),
                ],
              );
            }

            final members = snapshot.data ?? <FamilyMember>[];
            if (members.isEmpty) {
              return ListView(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 100),
                children: [
                  _FamilyOverview(count: members.length),
                  const SizedBox(height: 22),
                  Container(
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE6EBF2)),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 68,
                          height: 68,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEAF5F2),
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: const Icon(
                            Icons.family_restroom,
                            color: _teal,
                            size: 34,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Votre histoire commence ici',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _navy,
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 7),
                        const Text(
                          'Ajoutez un membre pour créer votre espace familial.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF7A8495),
                            height: 1.45,
                          ),
                        ),
                        const SizedBox(height: 18),
                        OutlinedButton.icon(
                          onPressed: () => _openMemberForm(),
                          icon: const Icon(Icons.person_add_alt_1),
                          label: const Text('Ajouter un premier membre'),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }

            return ListView(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 100),
              children: [
                _FamilyOverview(count: members.length),
                const SizedBox(height: 20),
                const Padding(
                  padding: EdgeInsets.only(left: 4, bottom: 10),
                  child: Text(
                    'VOTRE CERCLE',
                    style: TextStyle(
                      color: Color(0xFF7A8495),
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
                ...members.map(
                  (member) => Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(14, 14, 8, 14),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: const Color(0xFFE2F1EE),
                            backgroundImage: member.imageUrl == null
                                ? null
                                : NetworkImage(member.imageUrl!),
                            child: member.imageUrl == null
                                ? const Icon(Icons.person, color: _teal)
                                : null,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  member.fullName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: _navy,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 7),
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 6,
                                  crossAxisAlignment:
                                      WrapCrossAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 9,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEAF5F2),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        member.parente,
                                        style: const TextStyle(
                                          color: _teal,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      member.lieuNaissance,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Color(0xFF7A8495),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  'Né(e) le ${member.dateNaissance}',
                                  style: const TextStyle(
                                    color: Color(0xFF7A8495),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          PopupMenuButton<String>(
                            tooltip: 'Actions sur ${member.fullName}',
                            onSelected: (value) {
                              if (value == 'edit') {
                                _openMemberForm(member: member);
                              } else if (value == 'delete') {
                                _deleteMember(member);
                              }
                            },
                            itemBuilder: (context) => const [
                              PopupMenuItem(
                                value: 'edit',
                                child: Text('Modifier'),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: Text('Supprimer'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _FamilyOverview extends StatelessWidget {
  const _FamilyOverview({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_teal, Color(0xFF17615F)],
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.diversity_3_outlined,
              color: Colors.white,
              size: 27,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ma famille',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Gardez vos proches à portée de main.',
                  style: TextStyle(
                    color: Color(0xFFD9EFEB),
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                Text(
                  '$count',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Text(
                  'MEMBRES',
                  style: TextStyle(
                    color: Color(0xFFD9EFEB),
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
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

class _FamilyMemberDialog extends StatefulWidget {
  const _FamilyMemberDialog({
    required this.api,
    required this.onSaved,
    this.member,
  });

  final ApiService api;
  final FamilyMember? member;
  final Future<void> Function() onSaved;

  @override
  State<_FamilyMemberDialog> createState() => _FamilyMemberDialogState();
}

class _FamilyMemberDialogState extends State<_FamilyMemberDialog> {
  final _formKey = GlobalKey<FormState>();
  final _imagePicker = ImagePicker();
  XFile? _selectedImage;
  late final TextEditingController _nom;
  late final TextEditingController _postnom;
  late final TextEditingController _prenom;
  late final TextEditingController _lieuNaissance;
  late final TextEditingController _dateNaissance;
  late final TextEditingController _parente;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final member = widget.member;
    _nom = TextEditingController(text: member?.nom);
    _postnom = TextEditingController(text: member?.postnom);
    _prenom = TextEditingController(text: member?.prenom);
    _lieuNaissance = TextEditingController(text: member?.lieuNaissance);
    _dateNaissance = TextEditingController(text: member?.dateNaissance);
    _parente = TextEditingController(text: member?.parente);
  }

  @override
  void dispose() {
    _nom.dispose();
    _postnom.dispose();
    _prenom.dispose();
    _lieuNaissance.dispose();
    _dateNaissance.dispose();
    _parente.dispose();
    super.dispose();
  }

  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'Champ obligatoire.' : null;

  Future<void> _chooseDate() async {
    final initial = DateTime.tryParse(_dateNaissance.text);
    final date = await showDatePicker(
      context: context,
      initialDate: initial ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      _dateNaissance.text =
          '${date.year.toString().padLeft(4, '0')}-'
          '${date.month.toString().padLeft(2, '0')}-'
          '${date.day.toString().padLeft(2, '0')}';
    }
  }

  Future<void> _chooseImage() async {
    final image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1600,
      maxHeight: 1600,
      imageQuality: 85,
    );
    if (image != null) setState(() => _selectedImage = image);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final member = FamilyMember(
      id: widget.member?.id ?? 0,
      nom: _nom.text.trim(),
      postnom: _postnom.text.trim(),
      prenom: _prenom.text.trim(),
      lieuNaissance: _lieuNaissance.text.trim(),
      dateNaissance: _dateNaissance.text.trim(),
      parente: _parente.text.trim(),
      imageUrl: widget.member?.imageUrl,
    );

    try {
      if (widget.member == null) {
        await widget.api.createFamilyMember(member, image: _selectedImage);
      } else {
        await widget.api.updateFamilyMember(member, image: _selectedImage);
      }
      await widget.onSaved();
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.member == null ? 'Membre ajouté.' : 'Membre modifié.',
          ),
        ),
      );
    } on ApiException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.member == null ? 'Ajouter un membre' : 'Modifier le membre',
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 38,
                      backgroundColor: const Color(0xFFE2F1EE),
                      backgroundImage:
                          _selectedImage == null
                              ? (widget.member?.imageUrl == null
                                    ? null
                                    : NetworkImage(widget.member!.imageUrl!))
                              : null,
                      child: _selectedImage == null
                          ? (widget.member?.imageUrl == null
                                ? const Icon(
                                    Icons.person,
                                    size: 38,
                                    color: _navy,
                                  )
                                : null)
                          : FutureBuilder<Uint8List>(
                              future: _selectedImage!.readAsBytes(),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return const CircularProgressIndicator();
                                }
                                return ClipOval(
                                  child: Image.memory(
                                    snapshot.data!,
                                    fit: BoxFit.cover,
                                    width: 76,
                                    height: 76,
                                  ),
                                );
                              },
                            ),
                    ),
                    const SizedBox(height: 6),
                    TextButton.icon(
                      onPressed: _chooseImage,
                      icon: const Icon(Icons.photo_camera),
                      label: const Text('Choisir une photo'),
                    ),
                  ],
                ),
              ),
              TextFormField(
                controller: _nom,
                decoration: const InputDecoration(labelText: 'Nom'),
                validator: _required,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _postnom,
                decoration: const InputDecoration(labelText: 'Postnom'),
                validator: _required,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _prenom,
                decoration: const InputDecoration(labelText: 'Prénom'),
                validator: _required,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _lieuNaissance,
                decoration: const InputDecoration(
                  labelText: 'Lieu de naissance',
                ),
                validator: _required,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _dateNaissance,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Date de naissance',
                  suffixIcon: IconButton(
                    onPressed: _chooseDate,
                    icon: const Icon(Icons.calendar_today),
                  ),
                ),
                onTap: _chooseDate,
                validator: _required,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _parente,
                decoration: const InputDecoration(
                  labelText: 'Lien de parenté',
                  hintText: 'Père, Mère, Frère...',
                ),
                validator: _required,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _save,
          child: _isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Enregistrer'),
        ),
      ],
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
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: _teal.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: _teal, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: _navy,
                    fontWeight: FontWeight.w800,
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

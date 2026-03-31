import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/custom_widgets.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _fadeCtrl;
  late AnimationController _cardCtrl;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))..forward();
    _cardCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..forward();
  }

  @override
  void dispose() { _fadeCtrl.dispose(); _cardCtrl.dispose(); super.dispose(); }

  Future<void> _handleLogout() async {
    final yes = await showDialog<bool>(
      context: context, barrierColor: Colors.black54,
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: AlertDialog(
          backgroundColor: AppTheme.secondaryDark,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
          title: const Text('Logout', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w700)),
          content: Text('Are you sure you want to logout?', style: TextStyle(color: Colors.white.withValues(alpha: 0.6))),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Cancel', style: TextStyle(color: Colors.white.withValues(alpha: 0.5)))),
            Container(
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), gradient: AppTheme.primaryGradient),
              child: TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Logout', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600))),
            ),
          ],
        ),
      ),
    );
    if (yes == true && mounted) {
      await Provider.of<AuthProvider>(context, listen: false).logout();
      if (!mounted) return;
      Navigator.pushReplacement(context, PageRouteBuilder(
        pageBuilder: (_, _, _) => const LoginScreen(),
        transitionDuration: const Duration(milliseconds: 600),
        transitionsBuilder: (_, a, _, c) => FadeTransition(opacity: a, child: c),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity, height: double.infinity,
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: Stack(children: [
          const Positioned(top: -80, right: -50, child: FloatingOrb(size: 200, color: AppTheme.accentPurple)),
          const Positioned(bottom: 100, left: -60, child: FloatingOrb(size: 180, color: AppTheme.accentBlue)),
          SafeArea(child: FadeTransition(opacity: CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeIn),
            child: Consumer<AuthProvider>(builder: (context, auth, _) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(), padding: const EdgeInsets.all(24),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _topBar(), const SizedBox(height: 32),
                  _welcomeSection(auth), const SizedBox(height: 32),
                  _animCard(0.0, _tokenCard(auth)), const SizedBox(height: 20),
                  if (auth.user != null) _animCard(0.15, _profileCard(auth)),
                  if (auth.user != null) const SizedBox(height: 20),
                  _animCard(0.3, _securityCard()), const SizedBox(height: 20),
                  _animCard(0.45, _archCard()), const SizedBox(height: 32),
                  SizedBox(width: double.infinity, child: GradientButton(text: 'LOGOUT', onPressed: _handleLogout)),
                  const SizedBox(height: 24),
                ]),
              );
            }),
          )),
        ]),
      ),
    );
  }

  Widget _topBar() => Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
    Row(children: [
      Container(width: 44, height: 44, decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), gradient: AppTheme.primaryGradient, boxShadow: [BoxShadow(color: AppTheme.accentPurple.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))]),
        child: const Icon(Icons.shield_rounded, color: Colors.white, size: 22)),
      const SizedBox(width: 12),
      ShaderMask(shaderCallback: (b) => AppTheme.primaryGradient.createShader(b), child: const Text('SecureAuth', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white))),
    ]),
    Container(width: 44, height: 44, decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), color: Colors.white.withValues(alpha: 0.05), border: Border.all(color: Colors.white.withValues(alpha: 0.1))),
      child: Icon(Icons.notifications_outlined, color: Colors.white.withValues(alpha: 0.6), size: 22)),
  ]);

  Widget _welcomeSection(AuthProvider auth) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text('Welcome back,', style: TextStyle(fontSize: 16, color: Colors.white.withValues(alpha: 0.5))),
    const SizedBox(height: 4),
    Text(auth.user?.fullName ?? auth.email ?? 'User', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
    const SizedBox(height: 8),
    Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: AppTheme.successColor.withValues(alpha: 0.15), border: Border.all(color: AppTheme.successColor.withValues(alpha: 0.3))),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 8, height: 8, decoration: const BoxDecoration(shape: BoxShape.circle, color: AppTheme.successColor)),
        const SizedBox(width: 8),
        const Text('Authenticated', style: TextStyle(fontSize: 12, color: AppTheme.successColor, fontWeight: FontWeight.w600)),
      ])),
  ]);

  Widget _tokenCard(AuthProvider auth) => GlassContainer(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Row(children: [
      Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: AppTheme.accentPurple.withValues(alpha: 0.15)),
        child: const Icon(Icons.vpn_key_rounded, color: AppTheme.accentPurple, size: 22)),
      const SizedBox(width: 14),
      const Text('Auth Token', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
      const Spacer(),
      Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: AppTheme.successColor.withValues(alpha: 0.15)),
        child: const Text('ACTIVE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.successColor, letterSpacing: 1))),
    ]),
    const SizedBox(height: 20),
    Container(width: double.infinity, padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Colors.black.withValues(alpha: 0.3), border: Border.all(color: AppTheme.accentPurple.withValues(alpha: 0.2))),
      child: Row(children: [
        Icon(Icons.code_rounded, size: 16, color: AppTheme.accentBlue.withValues(alpha: 0.7)),
        const SizedBox(width: 10),
        Expanded(child: Text(auth.token ?? 'N/A', style: TextStyle(fontSize: 14, fontFamily: 'monospace', color: AppTheme.accentBlue.withValues(alpha: 0.9), fontWeight: FontWeight.w600, letterSpacing: 1))),
      ])),
    const SizedBox(height: 12),
    Text('Token received from reqres.in API after successful authentication.', style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.4), height: 1.5)),
  ]));

  Widget _profileCard(AuthProvider auth) {
    final u = auth.user!;
    return GlassContainer(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: AppTheme.accentBlue.withValues(alpha: 0.15)),
          child: const Icon(Icons.person_rounded, color: AppTheme.accentBlue, size: 22)),
        const SizedBox(width: 14),
        const Text('User Profile', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
      ]),
      const SizedBox(height: 20),
      Row(children: [
        Container(width: 70, height: 70, decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), gradient: AppTheme.primaryGradient, boxShadow: [BoxShadow(color: AppTheme.accentPurple.withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 5))]),
          child: ClipRRect(borderRadius: BorderRadius.circular(20), child: Image.network(u.avatar, fit: BoxFit.cover, errorBuilder: (_, _, _) => const Icon(Icons.person, color: Colors.white, size: 35)))),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(u.fullName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
          const SizedBox(height: 4),
          Text(u.email, style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.5))),
          const SizedBox(height: 6),
          Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(borderRadius: BorderRadius.circular(6), color: AppTheme.accentPurple.withValues(alpha: 0.15)),
            child: Text('ID: ${u.id}', style: TextStyle(fontSize: 11, color: AppTheme.accentPurple.withValues(alpha: 0.8), fontWeight: FontWeight.w600))),
        ])),
      ]),
    ]));
  }

  Widget _securityCard() => GlassContainer(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Row(children: [
      Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: AppTheme.successColor.withValues(alpha: 0.15)),
        child: const Icon(Icons.security_rounded, color: AppTheme.successColor, size: 22)),
      const SizedBox(width: 14),
      const Text('Security Info', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
    ]),
    const SizedBox(height: 20),
    _infoRow(Icons.storage_rounded, 'Token Storage', 'Secure Storage'),
    const SizedBox(height: 12),
    _infoRow(Icons.http_rounded, 'API Endpoint', 'reqres.in/api/login'),
    const SizedBox(height: 12),
    _infoRow(Icons.send_rounded, 'Method', 'POST + JSON'),
    const SizedBox(height: 12),
    _infoRow(Icons.lock_clock_rounded, 'Session', 'Persistent'),
  ]));

  Widget _archCard() => GlassContainer(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Row(children: [
      Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: AppTheme.accentPink.withValues(alpha: 0.15)),
        child: const Icon(Icons.architecture_rounded, color: AppTheme.accentPink, size: 22)),
      const SizedBox(width: 14),
      const Text('Architecture', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
    ]),
    const SizedBox(height: 20),
    _archRow('Provider', 'AuthProvider (ChangeNotifier)', AppTheme.accentPurple),
    const SizedBox(height: 10),
    _archRow('Repository', 'AuthRepository', AppTheme.accentBlue),
    const SizedBox(height: 10),
    _archRow('Service', 'ApiService + StorageService', AppTheme.successColor),
    const SizedBox(height: 10),
    _archRow('Model', 'LoginRequest/Response + User', AppTheme.accentPink),
  ]));

  Widget _infoRow(IconData ic, String label, String val) => Row(children: [
    Icon(ic, size: 18, color: Colors.white.withValues(alpha: 0.4)), const SizedBox(width: 12),
    Expanded(child: Text(label, style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.5)))),
    Text(val, style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary, fontWeight: FontWeight.w600)),
  ]);

  Widget _archRow(String layer, String detail, Color c) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: c.withValues(alpha: 0.08), border: Border.all(color: c.withValues(alpha: 0.15))),
    child: Row(children: [
      Container(width: 4, height: 30, decoration: BoxDecoration(borderRadius: BorderRadius.circular(2), color: c)),
      const SizedBox(width: 12),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(layer, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: c)),
        const SizedBox(height: 2),
        Text(detail, style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.5))),
      ]),
    ]),
  );

  Widget _animCard(double delay, Widget child) {
    final anim = CurvedAnimation(parent: _cardCtrl, curve: Interval(delay, delay + 0.4, curve: Curves.easeOutCubic));
    return AnimatedBuilder(animation: anim, builder: (_, _) => Opacity(opacity: anim.value,
      child: Transform.translate(offset: Offset(0, 30 * (1 - anim.value)), child: child)));
  }
}

import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../state/app_store.dart';
import '../../widgets/brand.dart';
import '../home/home_screen.dart';
import '../admin/admin_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, this.destinationPage = 0});
  final int destinationPage;
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final form = GlobalKey<FormState>();
  final email = TextEditingController();
  final password = TextEditingController();
  final name = TextEditingController();
  bool register = false, hidden = true, success = false;
  String? message;
  @override
  void dispose() {
    email.dispose();
    password.dispose();
    name.dispose();
    super.dispose();
  }

  void submit() {
    if (!form.currentState!.validate()) return;
    if (register) {
      final error = store.register(name.text, email.text, password.text);
      setState(() {
        success = error == null;
        message = error ?? 'Тіркелу сәтті өтті. Енді кіріңіз.';
        if (error == null) {
          register = false;
          password.clear();
        }
      });
      return;
    }
    final error = store.login(email.text, password.text);
    if (error != null) {
      setState(() {
        success = false;
        message = error;
      });
      return;
    }
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (_) => store.isAdmin
            ? const AdminScreen()
            : HomeScreen(initialPage: widget.destinationPage),
      ),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final auth = Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(26),
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant
                    .withValues(alpha: 0.45),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.035),
                  blurRadius: 32,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Form(
              key: form,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Center(child: AuthLogo()),
                  const SizedBox(height: 20),
                  Text(
                    register ? 'Тіркелу' : 'Жүйеге кіру',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontFamily: 'Montserrat',
                      letterSpacing: -0.6,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    register
                        ? 'Аты-жөніңізді, электрондық поштаңызды және кемінде 6 таңбадан тұратын құпиясөзді енгізіңіз.'
                        : 'Электрондық поштаңыз бен құпиясөзіңізді енгізіңіз.',
                    style: const TextStyle(color: muted, height: 1.5),
                  ),
                  const SizedBox(height: 28),
                  if (register) ...[
                    TextFormField(
                      key: const ValueKey('name-field'),
                      controller: name,
                      decoration: const InputDecoration(
                        labelText: 'Аты-жөніңіз',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Аты-жөніңізді енгізіңіз'
                          : null,
                    ),
                    const SizedBox(height: 14),
                  ],
                  TextFormField(
                    key: const ValueKey('email-field'),
                    controller: email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Электрондық пошта',
                      prefixIcon: Icon(Icons.mail_outline),
                    ),
                    validator: (v) =>
                        v == null ||
                            !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$')
                                .hasMatch(v.trim())
                        ? 'Электрондық поштаңызды тексеріңіз'
                        : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    key: const ValueKey('password-field'),
                    controller: password,
                    obscureText: hidden,
                    onFieldSubmitted: (_) => submit(),
                    decoration: InputDecoration(
                      labelText: 'Құпиясөз',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        tooltip: hidden
                            ? 'Құпиясөзді көрсету'
                            : 'Құпиясөзді жасыру',
                        onPressed: () => setState(() => hidden = !hidden),
                        icon: Icon(
                          hidden
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                      ),
                    ),
                    validator: (v) => v == null || v.length < 6
                        ? 'Құпиясөз кемінде 6 таңба болуы керек'
                        : null,
                  ),
                  const SizedBox(height: 20),
                  if (message != null) ...[
                    Text(
                      message!,
                      key: const ValueKey('auth-message'),
                      style: TextStyle(
                        color: success ? Colors.green.shade700 : red,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  FilledButton(
                    key: const ValueKey('submit-auth'),
                    onPressed: submit,
                    child: Text(register ? 'Тіркелу' : 'Кіру'),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () => setState(() {
                      register = !register;
                      message = null;
                      form.currentState?.reset();
                    }),
                    child: Text(
                      register
                          ? 'Аккаунтыңыз бар ма? Кіру'
                          : 'Аккаунтыңыз жоқ па? Тіркелу',
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      store.logout();
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute<void>(
                          builder: (_) => const HomeScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'Тіркелмей қарау',
                      style: TextStyle(color: muted),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      email.text = AppStore.adminEmail;
                      password.text = AppStore.adminPassword;
                      setState(() {
                        register = false;
                        message = 'Демо әкімші деректері толтырылды. Кіру батырмасын басыңыз.';
                        success = true;
                      });
                    },
                    icon: const Icon(
                      Icons.admin_panel_settings_outlined,
                      size: 18,
                    ),
                    label: const Text('Демо әкімші'),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Демо нұсқа. Деректер осы құрылғыда сақталады; басқа құрылғылармен синхрондалмайды.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11, color: muted),
                  ),
                ],
              ),
            ),
          );
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: (constraints.maxHeight - 32).clamp(
                  0.0,
                  double.infinity,
                ),
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 460),
                  child: auth,
                ),
              ),
            ),
          );
        },
      ),
    ),
  );
}

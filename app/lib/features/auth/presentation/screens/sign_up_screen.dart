import 'package:bb_ui/bb_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/l10n/app_localizations.dart';
import '../../../../app/router.dart';
import '../controllers/auth_controller.dart';
import '../widgets/auth_layout.dart';
import '../widgets/auth_messages.dart';
import '../widgets/validators.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  var _remember = true;
  String? _nameError, _emailError, _passwordError;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit(AppLocalizations l10n) async {
    setState(() {
      _nameError = _name.text.trim().isEmpty ? l10n.errorNameRequired : null;
      _emailError = validateEmail(l10n, _email.text);
      _passwordError = validatePassword(l10n, _password.text);
    });
    if (_nameError != null || _emailError != null || _passwordError != null) {
      return;
    }
    await ref
        .read(authControllerProvider.notifier)
        .signUp(
          name: _name.text,
          email: _email.text,
          password: _password.text,
          rememberMe: _remember,
        );
  }

  void _toLogin() {
    ref.read(authControllerProvider.notifier).clearMessages();
    context.go(Routes.login);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(authControllerProvider);
    final failure = state.failure;

    return AuthScaffold(
      title: l10n.signUpTitle,
      children: [
        if (failure != null) ...[
          BbBanner(
            tone: BbBannerTone.warning,
            message: authErrorText(l10n, failure),
          ),
          const BbGap.lg(),
        ],
        AutofillGroup(
          child: Column(
            children: [
              BbTextField(
                label: l10n.nameHint,
                pill: true,
                prefixIcon: BbIcons.person,
                controller: _name,
                errorText: _nameError,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.name],
              ),
              const BbGap.md(),
              BbTextField(
                label: l10n.emailHint,
                pill: true,
                prefixIcon: BbIcons.email,
                controller: _email,
                errorText: _emailError,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.email],
              ),
              const BbGap.md(),
              BbTextField(
                label: l10n.passwordHint,
                pill: true,
                prefixIcon: BbIcons.lock,
                controller: _password,
                errorText: _passwordError,
                obscure: true,
                showPasswordLabel: l10n.showPassword,
                hidePasswordLabel: l10n.hidePassword,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.newPassword],
                onSubmitted: (_) => _submit(l10n),
              ),
            ],
          ),
        ),
        if (kIsWeb)
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: RememberMe(
              label: l10n.rememberMe,
              value: _remember,
              onChanged: (v) => setState(() => _remember = v),
            ),
          ),
        const BbGap.xl(),
        BbButton(
          label: l10n.signUp,
          loadingLabel: l10n.signingUp,
          loading: state.busy,
          size: BbButtonSize.lg,
          expand: true,
          onPressed: () => _submit(l10n),
        ),
        const BbGap.xl(),
        OrDivider(label: l10n.orDivider),
        const BbGap.xl(),
        BbGoogleButton(
          label: l10n.continueWithGoogle,
          onPressed: state.busy
              ? null
              : ref.read(authControllerProvider.notifier).continueWithGoogle,
        ),
        const BbGap.xl(),
        AccountPrompt(
          question: l10n.haveAccountQuestion,
          action: l10n.login,
          onPressed: state.busy ? null : _toLogin,
        ),
      ],
    );
  }
}

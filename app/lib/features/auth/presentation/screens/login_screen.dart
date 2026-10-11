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

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  var _remember = true;
  String? _emailError, _passwordError;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit(AppLocalizations l10n) async {
    setState(() {
      _emailError = validateEmail(l10n, _email.text);
      _passwordError = validatePassword(l10n, _password.text);
    });
    if (_emailError != null || _passwordError != null) return;
    await ref
        .read(authControllerProvider.notifier)
        .login(_email.text, _password.text, rememberMe: _remember);
  }

  Future<void> _forgot(AppLocalizations l10n) async {
    setState(() {
      _emailError = validateEmail(l10n, _email.text);
      _passwordError = null;
    });
    if (_emailError != null) return;
    await ref
        .read(authControllerProvider.notifier)
        .sendPasswordReset(_email.text);
  }

  void _toSignUp() {
    ref.read(authControllerProvider.notifier).clearMessages();
    context.go(Routes.signUp);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(authControllerProvider);
    final failure = state.failure;
    final resetSentTo = state.resetSentTo;

    return AuthScaffold(
      title: l10n.loginTitle,
      children: [
        if (failure != null) ...[
          BbBanner(
            tone: BbBannerTone.warning,
            message: authErrorText(l10n, failure),
          ),
          const BbGap.lg(),
        ],
        if (resetSentTo != null) ...[
          BbBanner(
            tone: BbBannerTone.success,
            message: l10n.resetSent(resetSentTo),
          ),
          const BbGap.lg(),
        ],
        AutofillGroup(
          child: Column(
            children: [
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
                autofillHints: const [AutofillHints.password],
                onSubmitted: (_) => _submit(l10n),
              ),
            ],
          ),
        ),
        Row(
          children: [
            if (kIsWeb)
              RememberMe(
                label: l10n.rememberMe,
                value: _remember,
                onChanged: (v) => setState(() => _remember = v),
              ),
            const Spacer(),
            BbButton.ghost(
              label: l10n.forgotPassword,
              size: BbButtonSize.sm,
              onPressed: state.busy ? null : () => _forgot(l10n),
            ),
          ],
        ),
        const BbGap.lg(),
        BbButton(
          label: l10n.login,
          loadingLabel: l10n.loggingIn,
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
          question: l10n.noAccountQuestion,
          action: l10n.createAnAccount,
          onPressed: state.busy ? null : _toSignUp,
        ),
      ],
    );
  }
}

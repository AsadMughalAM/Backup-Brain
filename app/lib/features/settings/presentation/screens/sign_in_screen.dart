import 'package:bb_ui/bb_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/l10n/app_localizations.dart';
import '../../../../app/router.dart';
import '../controllers/account_controller.dart';
import '../widgets/auth_messages.dart';

enum SignInMode { create, signIn }

/// Google or email. From Settings it links the anonymous account (same uid,
/// data kept); from Welcome it signs a returning user in.
class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key, this.initialMode = SignInMode.create});

  final SignInMode initialMode;

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  late var _mode = widget.initialMode;
  final _email = TextEditingController();
  final _password = TextEditingController();
  String? _emailError;
  String? _passwordError;

  static const _minPassword = 6;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  bool _validate(AppLocalizations l10n, {bool emailOnly = false}) {
    final email = _email.text.trim();
    setState(() {
      _emailError = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)
          ? null
          : l10n.errorInvalidEmail;
      _passwordError = emailOnly || _password.text.length >= _minPassword
          ? null
          : l10n.errorPasswordShort;
    });
    return _emailError == null && _passwordError == null;
  }

  void _done() => context.canPop() ? context.pop() : context.go(Routes.home);

  Future<void> _submit(AppLocalizations l10n) async {
    if (!_validate(l10n)) return;
    final controller = ref.read(accountControllerProvider.notifier);
    final ok = _mode == SignInMode.create
        ? await controller.createWithEmail(_email.text, _password.text)
        : await controller.signInWithEmail(_email.text, _password.text);
    if (ok && mounted) _done();
  }

  Future<void> _google() async {
    final ok = await ref
        .read(accountControllerProvider.notifier)
        .continueWithGoogle();
    if (ok && mounted) _done();
  }

  Future<void> _forgot(AppLocalizations l10n) async {
    if (!_validate(l10n, emailOnly: true)) return;
    await ref
        .read(accountControllerProvider.notifier)
        .sendPasswordReset(_email.text);
  }

  void _switchMode() {
    ref.read(accountControllerProvider.notifier).clearMessages();
    setState(() {
      _mode = _mode == SignInMode.create
          ? SignInMode.signIn
          : SignInMode.create;
      _passwordError = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(accountControllerProvider);
    final creating = _mode == SignInMode.create;
    final failure = state.failure;
    final resetSentTo = state.resetSentTo;

    return BbScaffold(
      title: creating ? l10n.createAccountTitle : l10n.signInTitle,
      body: AutofillGroup(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
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
            BbButton.secondary(
              label: l10n.continueWithGoogle,
              icon: BbIcons.google,
              expand: true,
              onPressed: state.busy ? null : _google,
            ),
            const BbGap.xl(),
            Row(
              children: [
                const Expanded(child: Divider()),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  child: Text(
                    l10n.orDivider,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colors.textMuted,
                    ),
                  ),
                ),
                const Expanded(child: Divider()),
              ],
            ),
            const BbGap.xl(),
            BbTextField(
              label: l10n.email,
              controller: _email,
              errorText: _emailError,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
            ),
            const BbGap.lg(),
            BbTextField(
              label: l10n.password,
              controller: _password,
              errorText: _passwordError,
              obscure: true,
              showPasswordLabel: l10n.showPassword,
              hidePasswordLabel: l10n.hidePassword,
              textInputAction: TextInputAction.done,
              autofillHints: [
                creating ? AutofillHints.newPassword : AutofillHints.password,
              ],
              onSubmitted: (_) => _submit(l10n),
            ),
            if (!creating)
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: BbButton.ghost(
                  label: l10n.forgotPassword,
                  size: BbButtonSize.sm,
                  onPressed: state.busy ? null : () => _forgot(l10n),
                ),
              ),
            const BbGap.xl(),
            BbButton(
              label: creating ? l10n.createAccount : l10n.signIn,
              loadingLabel: creating ? l10n.creatingAccount : l10n.signingIn,
              loading: state.busy,
              size: BbButtonSize.lg,
              expand: true,
              onPressed: () => _submit(l10n),
            ),
            const BbGap.md(),
            Center(
              child: BbButton.ghost(
                label: creating ? l10n.switchToSignIn : l10n.switchToCreate,
                onPressed: state.busy ? null : _switchMode,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

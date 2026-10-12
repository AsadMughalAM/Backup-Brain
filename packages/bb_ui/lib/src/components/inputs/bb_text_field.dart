import 'package:flutter/material.dart';

import '../../foundations/icons.dart';
import '../../foundations/tokens/radius.dart';
import '../../foundations/tokens/sizes.dart';
import '../../foundations/tokens/spacing.dart';
import '../../theme/context_extensions.dart';
import '../buttons/bb_icon_button.dart';

/// Text input (DESIGN.md §10.2): label above, 52 px field with a 1 px
/// outline (the one place a boundary is allowed), helper or error below.
/// An error changes the fill and adds a warning icon — never just the
/// border color.
///
/// ```dart
/// BbTextField(
///   label: l10n.email,
///   controller: emailController,
///   keyboardType: TextInputType.emailAddress,
///   autofillHints: const [AutofillHints.email],
///   errorText: emailError,
/// )
/// BbTextField(label: l10n.password, controller: pw, obscure: true,
///   showPasswordLabel: l10n.showPassword, hidePasswordLabel: l10n.hidePassword)
/// ```
class BbTextField extends StatefulWidget {
  const BbTextField({
    super.key,
    required this.label,
    this.controller,
    this.hint,
    this.helper,
    this.errorText,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.onSubmitted,
    this.onChanged,
    this.enabled = true,
    this.autofocus = false,
    this.obscure = false,
    this.showPasswordLabel,
    this.hidePasswordLabel,
    this.prefixIcon,
    this.suffixText,
    this.pill = false,
  }) : assert(
         !obscure || (showPasswordLabel != null && hidePasswordLabel != null),
         'Password fields need labels for the visibility toggle.',
       );

  final String label;
  final TextEditingController? controller;
  final String? hint;
  final String? helper;

  /// Shown instead of [helper]; also switches the field to its error look.
  final String? errorText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;
  final bool enabled;
  final bool autofocus;

  /// Hides the text and adds a show/hide toggle (passwords).
  final bool obscure;
  final String? showPasswordLabel;
  final String? hidePasswordLabel;

  /// Leading glyph inside the field, e.g. `BbIcons.email`.
  final IconData? prefixIcon;

  /// A unit after the value, e.g. "W" in a watts field.
  final String? suffixText;

  /// Sign-in style: pill shape, no label above. The [label] becomes the
  /// placeholder (unless [hint] is set) and is still read by screen readers.
  final bool pill;

  @override
  State<BbTextField> createState() => _BbTextFieldState();
}

class _BbTextFieldState extends State<BbTextField> {
  late bool _hidden = widget.obscure;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.textTheme;
    final error = widget.errorText;
    final hasError = error != null;
    final below = error ?? widget.helper;
    final pillBorder = widget.pill
        ? OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            borderSide: BorderSide(color: c.outlineVariant),
          )
        : null;
    final prefix = widget.prefixIcon;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!widget.pill) ...[
          Text(
            widget.label,
            style: t.labelLarge?.copyWith(color: c.textPrimary),
          ),
          const SizedBox(height: AppSpacing.xs),
        ],
        TextField(
          controller: widget.controller,
          enabled: widget.enabled,
          obscureText: _hidden,
          autocorrect: !widget.obscure,
          enableSuggestions: !widget.obscure,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          autofillHints: widget.autofillHints,
          onSubmitted: widget.onSubmitted,
          onChanged: widget.onChanged,
          autofocus: widget.autofocus,
          style: t.bodyLarge?.copyWith(color: c.textPrimary),
          decoration: InputDecoration(
            hintText: widget.hint,
            // Pill: the label sits inside as the placeholder and stays the
            // field's accessible name; it never floats above.
            labelText: widget.pill ? widget.label : null,
            floatingLabelBehavior: widget.pill
                ? FloatingLabelBehavior.never
                : null,
            labelStyle: t.bodyLarge?.copyWith(color: c.textMuted),
            suffixText: widget.suffixText,
            suffixStyle: t.bodyLarge?.copyWith(color: c.textMuted),
            prefixIcon: prefix == null
                ? null
                : Icon(prefix, size: AppSizes.iconSm, color: c.textMuted),
            contentPadding: widget.pill
                ? const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                    vertical: 14,
                  )
                : null,
            enabledBorder: pillBorder,
            border: pillBorder,
            errorBorder: pillBorder,
            focusedBorder: pillBorder?.copyWith(
              borderSide: BorderSide(color: c.focusRing, width: 2),
            ),
            // Fill, not border, carries the error state.
            fillColor: hasError ? c.dangerContainer : c.surface,
            constraints: const BoxConstraints(minHeight: 52),
            suffixIcon: widget.obscure
                ? BbIconButton(
                    icon: _hidden ? BbIcons.showPassword : BbIcons.hidePassword,
                    tooltip: _hidden
                        ? widget.showPasswordLabel!
                        : widget.hidePasswordLabel!,
                    onPressed: () => setState(() => _hidden = !_hidden),
                  )
                : null,
          ),
        ),
        if (below != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Semantics(
            liveRegion: hasError,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (hasError) ...[
                  Icon(BbIcons.warning, size: AppSizes.iconXs, color: c.danger),
                  const SizedBox(width: AppSpacing.xs),
                ],
                Expanded(
                  child: Text(
                    below,
                    style: t.bodySmall?.copyWith(
                      color: hasError ? c.danger : c.textMuted,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

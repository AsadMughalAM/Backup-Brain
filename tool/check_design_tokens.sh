#!/usr/bin/env bash
# Fails if Dart code outside the design system's foundations/ and theme/
# uses raw colors, font sizes, text styles, non-Bb icons or stock spinners.
# Rules: TECH_STACK.md §6.8 and DESIGN.md §14.3.
set -euo pipefail
cd "$(dirname "$0")/.."

# Whole-identifier matches (\b) so AppColors./EnergyColors./BbIcons. pass.
patterns=(
  'Color\(0x'
  '\bColors\.'
  'fontSize:'
  '\bTextStyle\('
  'fontFamily:'
  'google_fonts'
  '\bIcons\.'
  '\bCupertinoIcons\.'
  'PhosphorIcons'
  'lucide'
  '\bCircularProgressIndicator\('
  '\bLinearProgressIndicator\('
)
regex=$(IFS='|'; echo "${patterns[*]}")

roots=()
for dir in app/lib packages/bb_ui/lib packages/bb_ui/example/lib; do
  [[ -d $dir ]] && roots+=("$dir")
done

violations=$(grep -rnE --include='*.dart' "$regex" "${roots[@]}" \
  | grep -vE '^packages/bb_ui/lib/src/(foundations|theme)/' \
  | grep -vE '\.(g|freezed)\.dart:' \
  | grep -vE '^app/lib/firebase_options\.dart:' \
  || true)

if [[ -n $violations ]]; then
  echo "Design token check failed. Use bb_ui tokens, BbIcons and Bb components instead:"
  echo "$violations"
  exit 1
fi
echo "Design token check passed."

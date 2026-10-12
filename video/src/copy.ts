import en from '@app/lib/app/l10n/app_en.arb';

/**
 * Every app label in the video comes from the app's own English strings, so
 * the ad can't show copy the product doesn't have.
 */
export function t(key: string, params: Record<string, string | number> = {}): string {
  const template = (en as Record<string, unknown>)[key];
  if (typeof template !== 'string') throw new Error(`No string "${key}" in app_en.arb`);
  return template.replace(/\{(\w+)\}/g, (_, name: string) => {
    if (!(name in params)) throw new Error(`String "${key}" needs {${name}}`);
    return String(params[name]);
  });
}

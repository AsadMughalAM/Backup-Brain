import path from 'node:path';
import type { WebpackOverrideFn } from '@remotion/bundler';

/**
 * The video reads the app's own strings (app_en.arb) and demo household, so it
 * can never say something the product does not. Shared by the CLI config and
 * the stills script so both bundle the same way.
 */
export const webpackOverride: WebpackOverrideFn = (config) => ({
  ...config,
  resolve: {
    ...config.resolve,
    alias: {
      ...(config.resolve?.alias ?? {}),
      '@app': path.resolve(process.cwd(), '../app'),
    },
  },
  module: {
    ...config.module,
    rules: [...(config.module?.rules ?? []), { test: /\.arb$/, type: 'json' }],
  },
});

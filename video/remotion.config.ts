import { Config } from '@remotion/cli/config';
import { webpackOverride } from './remotion.webpack';

Config.setVideoImageFormat('jpeg');
Config.setJpegQuality(92);
Config.overrideWebpackConfig(webpackOverride);

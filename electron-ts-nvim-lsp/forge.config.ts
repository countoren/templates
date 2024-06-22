import type { ForgeConfig } from '@electron-forge/shared-types';
import { MakerSquirrel } from '@electron-forge/maker-squirrel';
import { MakerZIP } from '@electron-forge/maker-zip';
import { MakerDeb } from '@electron-forge/maker-deb';
import { MakerRpm } from '@electron-forge/maker-rpm';
import { AutoUnpackNativesPlugin } from '@electron-forge/plugin-auto-unpack-natives';
import { WebpackPlugin } from '@electron-forge/plugin-webpack';
import { FusesPlugin } from '@electron-forge/plugin-fuses';
import { FuseV1Options, FuseVersion } from '@electron/fuses';

import { mainConfig } from './webpack.main.config';
import { rendererConfig } from './webpack.renderer.config';
import { WebpackConfiguration } from '@electron-forge/plugin-webpack/dist/Config';

const config: ForgeConfig = {
  packagerConfig: {
    electronZipDir: process.env.electron_zip_dir,
  },
  rebuildConfig: {},
  makers: [
      new MakerSquirrel({}), new MakerZIP({}, ['darwin']), new MakerRpm({}), new MakerDeb({})
    // {
    //   name: '@electron-forge/maker-squirrel',
    //   config: {
    //     icon: './public/icon.png',
    //   },
    // },
    // {
    //   name: '@electron-forge/maker-zip',
    //   platforms: [
    //     'darwin',
    //     'win32',
    //     'linux',
    //   ],
    //   icon: './public/icon',
    // },
    // {
    //   name: '@electron-forge/maker-deb',
    //   config: {
    //     icon: './public/icon.png',
    //   },
    // },
    // {
    //   name: '@electron-forge/maker-rpm',
    //   config: {
    //     icon: './public/icon.png',
    //   },
    // },

  ],
  plugins: [
    // new AutoUnpackNativesPlugin({}),
    new WebpackPlugin({
      mainConfig: mainConfig as WebpackConfiguration,
      renderer: {
        config:rendererConfig as WebpackConfiguration,
        entryPoints: [
          {
            html: './src/index.html',
            js: './src/index.tsx',
            name: 'main_window',
            preload: {
              js: './src/preload.ts',
            },
          },
        ],
      },
    }),
    // Fuses are used to enable/disable various Electron functionality
    // at package time, before code signing the application
    new FusesPlugin({
      version: FuseVersion.V1,
      [FuseV1Options.RunAsNode]: false,
      [FuseV1Options.EnableCookieEncryption]: true,
      [FuseV1Options.EnableNodeOptionsEnvironmentVariable]: false,
      [FuseV1Options.EnableNodeCliInspectArguments]: false,
      [FuseV1Options.EnableEmbeddedAsarIntegrityValidation]: true,
      [FuseV1Options.OnlyLoadAppFromAsar]: true,
    }),
  ],
};

export default config;

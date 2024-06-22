import type { ModuleOptions } from 'webpack';

export const rules: Required<ModuleOptions>['rules'] = [
    // Add support for native node modules
    {
        // We're specifying native_modules in the test because the asset relocator loader generates a
        // "fake" .node file which is really a cjs file.
        test: /native_modules[/\\].+\.node$/,
        use: 'node-loader',
    },
    {
        test: /[/\\]node_modules[/\\].+\.(m?js|node)$/,
        parser: { amd: false },
        use: {
            loader: '@vercel/webpack-asset-relocator-loader',
            options: {
                outputAssetBase: 'native_modules',
            },
        },
    },
    {
        test: /\.s[ac]ss$/i,
        use: [
            { loader: "style-loader" },  // to inject the result into the DOM as a style block
            { loader: "css-loader", options: { modules: true } },  // to convert the resulting CSS to Javascript to be bundled (modules:true to rename CSS classes in output to cryptic identifiers, except if wrapped in a :global(...) pseudo class)
            { loader: "sass-loader" },  // to convert SASS to CSS
        ],
    },
    {
        test: /\.tsx?$/,
        exclude: /(node_modules|\.webpack)/,
        use: [
            {
                loader: 'babel-loader', // Add babel-loader here
                options: {
                    presets: ['@babel/preset-env', '@babel/preset-react', '@babel/preset-typescript'],
                },
            },
            {
                loader: 'ts-loader',
                options: {
                    transpileOnly: true,
                },
            }]
    },
];

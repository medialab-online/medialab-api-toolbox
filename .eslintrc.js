module.exports = {
    extends: 'airbnb-base',
    env: {
        browser: true,
    },
    rules: {
        indent: [
            'error',
            4,
            {
                SwitchCase: 1,
            },
        ],
        'no-use-before-define': [
            'error',
            {
                functions: false,
            },
        ],
        'max-len': [
            'error',
            {
                code: 110,
                ignoreComments: true,
            },
        ],
        'import/extensions': 'off',
        'object-curly-spacing': [
            'error',
            'never',
        ],
        'consistent-return': 'off',
    },
};

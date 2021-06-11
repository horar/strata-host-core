var _monaco = (typeof monaco === 'undefined' ? self.monaco : monaco);
export var conf = {
    wordPattern: /(-?\d*\.\d\w*)|([^\`\~\!\@\#\%\^\&\*\(\)\-\=\+\[\{\]\}\\\|\;\:\'\"\,\.\<\>\/\?\s]+)/g,
    comments: {
        lineComment: '//',
        blockComment: ['/*', '*/']
    },
    brackets: [
        ['{', '}'],
        ['[', ']'],
        ['(', ')']
    ],
    onEnterRules: [
        {
            // e.g. /** | */
            beforeText: /^\s*\/\*\*(?!\/)([^\*]|\*(?!\/))*$/,
            afterText: /^\s*\*\/$/,
            action: { indentAction: _monaco.languages.IndentAction.IndentOutdent, appendText: ' * ' }
        },
        {
            // e.g. /** ...|
            beforeText: /^\s*\/\*\*(?!\/)([^\*]|\*(?!\/))*$/,
            action: { indentAction: _monaco.languages.IndentAction.None, appendText: ' * ' }
        },
        {
            // e.g.  * ...|
            beforeText: /^(\t|(\ \ ))*\ \*(\ ([^\*]|\*(?!\/))*)?$/,
            action: { indentAction: _monaco.languages.IndentAction.None, appendText: '* ' }
        },
        {
            // e.g.  */|
            beforeText: /^(\t|(\ \ ))*\ \*\/\s*$/,
            action: { indentAction: _monaco.languages.IndentAction.None, removeText: 1 }
        },
        {
            beforeText: /^\s(?:readonly|property|for|if|else|do|while|try|int|real|var|string|color|url|alias|bool|double).*?:\s*$/,
            action: {indentAction: _monaco.languages.IndentAction.IndentOutdent}
        }
    ],
    autoClosingPairs: [
        { open: '{', close: '}' },
        { open: '[', close: ']' },
        { open: '(', close: ')' },
        { open: '"', close: '"', notIn: ['string'] },
        { open: '\'', close: '\'', notIn: ['string', 'comment'] },
        { open: '`', close: '`', notIn: ['string', 'comment'] },
        { open: "/*", close: " */", notIn: ["string"] }
    ],
    autoCloseBefore: ";:.,=})>`\n\t",
    folding: {
        markers: {
            start: new RegExp("^\\s*//\\s*#?region\\b"),
            end: new RegExp("^\\s*//\\s*#?endregion\\b")
        }
    },
    indentationRules: {
        increaseIndentPattern: /^((?!\/\/).)*(\{[^}\"'`]*|\([^)\"'`]*|\[[^\]\"'`]*)$/,
        decreaseIndentPattern: /^((?!.*?\/\*).*\*\/)?\s*[\}\]].*$/,
    }
}
export var language = {
    keywords: ['readonly', 'property', 'for', 'if', 'else', 'do', 'while', 'true', 'false', 'signal', 'const', 'switch', 'import', 'as', "on", 'async', 'console', "let", "default", "function","case","break"],
    typeKeywords: ['int', 'real', 'var', 'string', 'color', 'url', 'alias', 'bool', 'double'],
    operators: [
        '=', '>', '<', '!', '~', '?', ':', '==', '<=', '>=', '!=', '===', '<==', '>==', '!==',
        '&&', '||', '++', '--', '+', '-', '*', '/', '&', '|', '^', '%',
        '<<', '>>', '>>>', '+=', '-=', '*=', '/=', '&=', '|=', '^=',
        '%=', '<<=', '>>=', '>>>='
    ],
    digits: /\d+(_+\d+)*/,
    symbols: /[=><!~?:&|+\-*\/\^%]+/,
    escapes: /\\(?:[abfnrtv\\"']|x[0-9A-Fa-f]{1,4}|u[0-9A-Fa-f]{4}|U[0-9A-Fa-f]{8})/,
    regexpctl: /[(){}\[\]\$\^|\-*+?\.]/,
    regexpesc: /\\(?:[bBdDfnrstvwWn0\\\/]|@regexpctl|c[A-Z]|x[0-9a-fA-F]{2}|u[0-9a-fA-F]{4})/,
    tokenizer: {
        root: [
            [/[{}]/, 'delimiter.bracket'],
            [/^[A-Z0-9]{(.|\n)(?!})$/, 'delimiter.bracket.error'],
            [/[a-z_$][\w$]*/, {
                cases: {
                    '@typeKeywords': 'keyword',
                    '@keywords': 'keyword',

                }
            }
            ],
            [/[A-Z][\w\$]*/, 'type.identifier'],
            [/(?:^|\{|;)\s*[a-z][\w\.]*\s*(?=\:|\{)/, "property.defs"],
            [/^id:\t[a-z0-9_]*$/, "type.id"],
            { include: '@whitespace' },
            [/\/(?=([^\\\/]|\\.)+\/([gimsuy]*)(\s*)(\.|;|\/|,|\)|\]|\}|$))/, { token: 'regexp', bracket: '@open', next: '@regexp' }],
            [/[()\[\]]/, '@brackets'],
            [/[<>](?!@symbols)/, '@brackets'],
            [/@symbols/, {
                cases: {
                    '@operators': 'delimiter',
                    '@default': ''
                }
            }
            ],
            [/(@digits)[eE]([\-+]?(@digits))?/, 'number.float'],
            [/(@digits)\.(@digits)([eE][\-+]?(@digits))?/, 'number.float'],
            [/(@digits)/, 'number'],
            [/[;,.]/, 'delimiter'],
            [/"([^"\\]|\\.)*$/, 'string.invalid'],  // non-teminated string
            [/'([^'\\]|\\.)*$/, 'string.invalid'],  // non-teminated string
            [/"/, 'string', '@string_double'],
            [/'/, 'string', '@string_single'],
            [/`/, 'string', '@string_backtick'],

        ],
        whitespace: [
            [/[ \t\r\n]+/, ''],
            [/\/\*\*(?!\/)/, 'comment.doc', '@jsdoc'],
            [/\/\*/, 'comment', '@comment'],
            [/\/\/.*$/, 'comment'],
        ],
        comment: [
            [/[^\/*]+/, 'comment'],
            [/\*\//, 'comment', '@pop'],
            [/[\/*]/, 'comment']
        ],

        jsdoc: [
            [/[^\/*]+/, 'comment.doc'],
            [/\*\//, 'comment.doc', '@pop'],
            [/[\/*]/, 'comment.doc']
        ],

        // We match regular expression quite precisely
        regexp: [
            [/(\{)(\d+(?:,\d*)?)(\})/, ['regexp.escape.control', 'regexp.escape.control', 'regexp.escape.control']],
            [/(\[)(\^?)(?=(?:[^\]\\\/]|\\.)+)/, ['regexp.escape.control', { token: 'regexp.escape.control', next: '@regexrange' }]],
            [/(\()(\?:|\?=|\?!)/, ['regexp.escape.control', 'regexp.escape.control']],
            [/[()]/, 'regexp.escape.control'],
            [/@regexpctl/, 'regexp.escape.control'],
            [/[^\\\/]/, 'regexp'],
            [/@regexpesc/, 'regexp.escape'],
            [/\\\./, 'regexp.invalid'],
            [/(\/)([gimsuy]*)/, [{ token: 'regexp', bracket: '@close', next: '@pop' }, 'keyword.other']],
        ],

        regexrange: [
            [/-/, 'regexp.escape.control'],
            [/\^/, 'regexp.invalid'],
            [/@regexpesc/, 'regexp.escape'],
            [/[^\]]/, 'regexp'],
            [/\]/, { token: 'regexp.escape.control', next: '@pop', bracket: '@close' }],
        ],

        string_double: [
            [/[^\\"]+/, 'string'],
            [/@escapes/, 'string.escape'],
            [/\\./, 'string.escape.invalid'],
            [/"/, 'string', '@pop']
        ],

        string_single: [
            [/[^\\']+/, 'string'],
            [/@escapes/, 'string.escape'],
            [/\\./, 'string.escape.invalid'],
            [/'/, 'string', '@pop']
        ],

        string_backtick: [
            [/\$\{/, { token: 'delimiter.bracket' }],
            [/[^\\`$]+/, 'string'],
            [/@escapes/, 'string.escape'],
            [/\\./, 'string.escape.invalid'],
            [/`/, 'string', '@pop']
        ],
    }

}
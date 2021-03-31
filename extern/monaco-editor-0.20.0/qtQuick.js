/* 
    This File is the base for mapping the auto complete, For CVC purposes this files auto complete will be limited in the number of QtQuick Objects but 
    detailed in the properties
*/
var qtObjectSuggestions = {}
const qtObjectKeyValues = {}
const qtIdPairs = {}
const qtObjectPropertyValues = {}
const qtObjectMetaPropertyValues = {}
var isInitialized = false
var searchedIds = false
var suggestions = {}
var functionSuggestions = {}
const currentItems = {}
var editor = null

var bottomOfFile = null;
var topOfFile = null;
var fullRange = null;

var qtImports = [];

var propRange = {};

// return an object from a string with definable properties
function createDynamicProperty(property, isFunction = false) {
    return {
        "label": property,
        "kind": !isFunction ? monaco.languages.CompletionItemKind.KeyWord : monaco.languages.CompletionItemKind.Function,
        "insertTextRules": monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet,
        "insertText": property,
        "range": null
    }
}
// filter out duplicate lines
function removeDuplicates(propertySuggestions) {
    return propertySuggestions.sort().filter(function (itm, idx, arr) {
        return !idx || itm !== arr[idx - 1];
    })
}

function removeOnCalls(properties) {
    return properties.filter(function (itm) {
        return !itm.includes("on")
    })
}

// This is the properties string array conversion to an object array, this has to be done in real time due to the limitations of the monaco editor suggestions
function convertStrArrayToObjArray(key, properties, isProperty = false, isIdReference = false, metaParent = "") {
    var propertySuggestions = []
    qtObjectPropertyValues[key] = []
    for (var i = 0; i < properties.length; i++) {
        if (properties[i].includes("()")) {
            propertySuggestions.push(createDynamicProperty(properties[i], true))
        } else {
            if (isIdReference || (qtObjectMetaPropertyValues.hasOwnProperty(metaParent) && qtObjectMetaPropertyValues[metaParent].hasOwnProperty(properties[i]) && qtObjectMetaPropertyValues[metaParent][properties[i]].length > 0)) {
                propertySuggestions.push(createDynamicProperty(properties[i], false))
            } else {
                propertySuggestions.push(createDynamicProperty(properties[i] + ": ", false))
            }
        }
    }
    if (!isProperty) {
        qtObjectPropertyValues[key] = propertySuggestions.concat(Object.values(suggestions))
    } else {
        qtObjectPropertyValues[key] = propertySuggestions
    }
}
// setting each key val pair for the object
function createQtObjectValPairs(key, val) {
    qtObjectKeyValues[key] = val
}

// This is a register for when an Id of a type is read and/or created. Allowing us to instantiate from the id caller
function addCustomIdAndTypes(idText, position, type = "Item") {
    if (!qtIdPairs.hasOwnProperty(position.lineNumber)) {
        qtIdPairs[position.lineNumber] = {}
        qtIdPairs[position.lineNumber][idText] = type
        if (!qtObjectKeyValues.hasOwnProperty(type)) {
            type = "Item"
        }
        var arr = []
        arr = arr.concat(removeDuplicates(removeOnCalls(qtObjectKeyValues[type].properties)))
        arr = arr.concat(removeDuplicates(qtObjectSuggestions[type].functions))
        arr = arr.concat(qtObjectSuggestions[type].signals)
        createQtObjectValPairs(idText, { label: idText, insertText: idText, properties: arr, flag: true, isId: true })
        functionSuggestions[idText] = {
            label: qtObjectKeyValues[idText].label,
            kind: monaco.languages.CompletionItemKind.Function,
            insertTextRules: monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet,
            insertText: qtObjectKeyValues[idText].insertText,
            range: null,
        }
    } else {
        if (!qtIdPairs[position.lineNumber].hasOwnProperty(idText)) {
            var keys = Object.keys(qtIdPairs[position.lineNumber])
            delete functionSuggestions[keys[0]]
            delete qtObjectKeyValues[keys[0]]
            delete qtIdPairs[position.lineNumber]
            qtIdPairs[position.lineNumber] = {}
            qtIdPairs[position.lineNumber][idText] = type
            if (!qtObjectKeyValues.hasOwnProperty(type)) {
                type = "Item"
            }
            var arr = []
            arr = arr.concat(removeDuplicates(removeOnCalls(qtObjectKeyValues[type].properties)))
            arr = arr.concat(removeDuplicates(qtObjectSuggestions[type].functions))
            arr = arr.concat(qtObjectSuggestions[type].signals)
            createQtObjectValPairs(idText, { label: idText, insertText: idText, properties: arr, flag: true, isId: true })
            functionSuggestions[idText] = {
                label: qtObjectKeyValues[idText].label,
                kind: monaco.languages.CompletionItemKind.Function,
                insertTextRules: monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet,
                insertText: qtObjectKeyValues[idText].insertText,
                range: null,
            }
        } else if (qtIdPairs[position.lineNumber][idText] !== type) {
            qtIdPairs[position.lineNumber][idText] = type
            var keys = Object.keys(qtIdPairs[position.lineNumber])
            delete functionSuggestions[keys[0]]
            delete qtObjectKeyValues[keys[0]]
            if (!qtObjectKeyValues.hasOwnProperty(type)) {
                type = "Item"
            }
            var arr = []
            arr = arr.concat(removeDuplicates(removeOnCalls(qtObjectKeyValues[type].properties)))
            arr = arr.concat(removeDuplicates(qtObjectSuggestions[type].functions))
            arr = arr.concat(qtObjectSuggestions[type].signals)
            createQtObjectValPairs(idText, { label: idText, insertText: idText, properties: arr, flag: true, isId: true })
            functionSuggestions[idText] = {
                label: qtObjectKeyValues[idText].label,
                kind: monaco.languages.CompletionItemKind.Function,
                insertTextRules: monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet,
                insertText: qtObjectKeyValues[idText].insertText,
                range: null,
            }
        }
    }
}

/*
    This the global registration for the monaco editor this creates the syntax and linguistics of the qml language, as well as defining the theme of the qml language
*/
function registerQmlAsLanguage() {
    monaco.languages.register({ id: 'qml' })
    monaco.languages.setMonarchTokensProvider('qml', {
        keywords: ['readonly', 'property', 'for', 'if', 'else', 'do', 'while', 'true', 'false', 'signal', 'const', 'switch', 'import', 'as', "on", 'async', 'console', "let", "default", "function"],
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

    })
    monaco.editor.defineTheme('qmlTheme', {
        base: 'vs',
        inherit: false,
        rules: [
            { token: "comment", foreground: "#32C132" },
            { token: "delimiter.bracket", foreground: "#000000" },
            { token: "keyword", foreground: "#829356" },
            { token: "type.identifier", foreground: "#DF00FF" },
            { token: "string", foreground: "#32C132" },
            { token: "property.defs", foreground: "#BA262B" },
            { token: "type.id", fontStyle: 'italic' },
            { token: "string.escape.invalid", foreground: "#FF0000", fontStyle: 'italic underline' },
            { token: "regexp.invalid", foreground: "#FF0000", fontStyle: 'italic underline' },
            { token: "string.invalid", foreground: "#FF0000", fontStyle: 'italic underline' },
            { token: "regexp.escape.control", foreground: "#FF0000", fontStyle: 'italic' },
            { token: "regexp", foreground: "#FF0000", fontStyle: 'italic' },
            { token: "delimiter.bracket.error", foreground: "#FF0000" }
        ]
    })
    runQmlProvider()
    editor = monaco.editor.create(document.getElementById('container'), {
        value: "",
        language: 'qml',
        theme: "qmlTheme",
        insertSpaces: true,
        detectIndentation: true,
        tabCompletion: "on",
        formatOnPaste: true,
    });

    function getValue() {
        return editor.getValue();
    }

    function setValue(value) {
        editor.setValue(value)
    }

    isInitialized = true
    // This searches and determines where the position lies within each child Item, so that the correct Qt file class is returned
    function searchForChildBrackets(model, position) {
        var prevMatch = model.findPreviousMatch("{", position, false, false)
        var nextBracketMatch = model.findNextMatch("{", position, false, false)
        var prevBracketMatch = model.findPreviousMatch("}", position, false, false)
        var nextMatch = model.findNextMatch("}", position, false, false)
        var nextnextMatch = model.findNextMatch("}", { lineNumber: nextMatch.range.startLineNumber, column: nextMatch.range.endColumn }, false, false)
        var prevprevMatch = model.findPreviousMatch("{", { lineNumber: prevMatch.range.startLineNumber, column: prevMatch.range.startColumn }, false, false)

        //Edge Case 4: this is when there is only one QtItem, most common is when we create a new file
        if (prevMatch.range.startLineNumber === topOfFile.range.startLineNumber && nextMatch.range.startLineNumber === bottomOfFile.range.startLineNumber) {

            propRange = {
                startLineNumber: prevMatch.range.startLineNumber,
                endLineNumber: nextMatch.range.startLineNumber,
                startColumn: prevMatch.range.startColumn,
                endColumn: nextMatch.range.endColumn
            }
            return retrieveType(model, propRange)
        }
        //Edge Case 3: this is to ensure that editing the top of the file does not allow a child item to read in its parent data i.e Item and anchors dont mix
        if (prevMatch.range.startLineNumber === topOfFile.range.startLineNumber || prevprevMatch.range.startLineNumber === topOfFile.range.startLineNumber) {
            if (position.lineNumber >= prevMatch.range.startLineNumber && position.lineNumber <= nextMatch.range.startLineNumber && (nextMatch.range.startLineNumber <= nextnextMatch.range.startLineNumber && prevBracketMatch.range.startLineNumber >= nextnextMatch.range.startLineNumber)) {

                propRange = {
                    startLineNumber: prevMatch.range.startLineNumber,
                    endLineNumber: nextMatch.range.startLineNumber,
                    startColumn: prevMatch.range.startColumn,
                    endColumn: nextMatch.range.endColumn
                }
                return retrieveType(model, propRange)
            }
        }
        //Edge Case 5: same as 3, just inveresed for the end of the file
        if (nextMatch.range.startLineNumber === bottomOfFile.range.startLineNumber || nextnextMatch.range.startLineNumber === bottomOfFile.range.startLineNumber) {
            if (position.lineNumber >= prevMatch.range.startLineNumber && position.lineNumber <= nextMatch.range.startLineNumber && prevMatch.range.startLineNumber > prevBracketMatch.range.startLineNumber) {

                propRange = {
                    startLineNumber: prevMatch.range.startLineNumber,
                    endLineNumber: nextMatch.range.startLineNumber,
                    startColumn: prevMatch.range.startColumn,
                    endColumn: nextMatch.range.endColumn
                }
                return retrieveType(model, propRange)
            }
        }
        //Normal case: the child is independent and returns the type
        if (position.lineNumber >= prevMatch.range.startLineNumber && (prevMatch.range.startLineNumber > prevBracketMatch.range.startLineNumber)) {
            if (position.lineNumber <= nextMatch.range.startLineNumber && nextMatch.range.startLineNumber < nextBracketMatch.range.startLineNumber) {
                propRange = {
                    startLineNumber: prevMatch.range.startLineNumber,
                    endLineNumber: nextMatch.range.startLineNumber,
                    startColumn: prevMatch.range.startColumn,
                    endColumn: nextMatch.range.endColumn
                }
                return retrieveType(model, propRange)
                // Edge Case 1: A rare case where if there is no first child of an item on loaded the properties will not propagate
            } else if (nextMatch.range.startLineNumber > nextBracketMatch.range.startLineNumber) {
                propRange = {
                    startLineNumber: position.lineNumber,
                    endLineNumber: nextBracketMatch.range.startLineNumber,
                    startColumn: position.column,
                    endColumn: nextBracketMatch.range.endColumn,
                }
                return retrieveType(model, propRange)
            }
            //Edge case 2: this is the most common edge case hit where the properties between sibling items are intermingled this determines what the parent item is
        } else if (prevMatch.range.startLineNumber < prevBracketMatch.range.startLineNumber && position.lineNumber <= nextMatch.range.startLineNumber) {
            var prevParent = findPreviousBracketParent(model, position)
            if (qtObjectKeyValues.hasOwnProperty(prevParent)) {
                propRange = {
                    startLineNumber: prevMatch.range.startLineNumber,
                    endLineNumber: prevBracketMatch.range.startLineNumber,
                    startColumn: prevMatch.range.startColumn,
                    endColumn: prevBracketMatch.range.endColumn,
                }
                convertStrArrayToObjArray(prevParent, qtObjectKeyValues[prevParent].properties, qtObjectKeyValues[prevParent].flag, false, prevParent)
                if (currentItems[prevParent] === undefined) {
                    currentItems[prevParent] = {}
                }
                currentItems[prevParent][propRange] = qtObjectPropertyValues[prevParent]
                return currentItems[prevParent][propRange]
            } else if (qtObjectMetaPropertyValues.hasOwnProperty(prevParent)) {
                return retrieveType(model, propRange)
            }
        } else if(position.lineNumber > prevMatch.range.startLineNumber && position.lineNumber > prevBracketMatch.range.startLineNumber){
            var prevParent = findPreviousBracketParent(model, position)
            if(qtObjectKeyValues.hasOwnProperty(prevParent)){
                propRange = {
                    startLineNumber: position.lineNumber,
                    endLineNumber: nextMatch.range.startLineNumber,
                    startColumn: position.column,
                    endColumn: nextMatch.range.endColumn,
                }
                convertStrArrayToObjArray(prevParent, qtObjectKeyValues[prevParent].properties, qtObjectKeyValues[prevParent].flag, false, prevParent)
                if (currentItems[prevParent] === undefined) {
                    currentItems[prevParent] = {}
                }
                currentItems[prevParent][propRange] = qtObjectPropertyValues[prevParent]
                return currentItems[prevParent][propRange]
            }
        } 
        if(position.lineNumber >= prevMatch.range.startLineNumber && position.lineNumber <= nextMatch.range.startLineNumber){
            var getContent = model.getLineContent(prevMatch.range.startLineNumber)
            var content = getContent.replace("\t", "").split(/\{|\t/)[0].trim()
            var currentProperty = content.split(":")[1].trim()
            if(qtObjectKeyValues.hasOwnProperty(currentProperty)){
                propRange = {
                    startLineNumber: prevMatch.range.startLineNumber,
                    endLineNumber: nextMatch.range.startLineNumber,
                    startColumn: prevMatch.range.startColumn,
                    endColumn: nextMatch.range.endColumn,
                }
            }
            convertStrArrayToObjArray(currentProperty, qtObjectKeyValues[currentProperty].properties, qtObjectKeyValues[currentProperty].flag, false, currentProperty)
                if (currentItems[currentProperty] === undefined) {
                    currentItems[currentProperty] = {}
                }
                currentItems[currentProperty][propRange] = qtObjectPropertyValues[currentProperty]
                return currentItems[currentProperty][propRange]
        }
        return Object.values(suggestions)
    }

    // Initializes the library to become an Object array to be feed into suggestions
    function initializeQtQuick(model) {
        suggestions = {}
        qtObjectSuggestions = {}
        qtImports = []
        const firstLine = { lineNumber: fullRange.startLineNumber, column: fullRange.startColumn }
        var line = { lineNumber: firstLine.lineNumber, column: firstLine.startColumn }
        while (line.lineNumber >= firstLine.lineNumber) {
            var getNextPosition = model.findNextMatch("import", line)
            if (getNextPosition.range.startLineNumber < line.lineNumber) {
                break;
            }
            var lineContent = model.getLineContent(getNextPosition.range.startLineNumber)
            var content = lineContent.replace("\t", "").split("import")[1].trim()
            line = { lineNumber: getNextPosition.range.startLineNumber + 1, column: getNextPosition.range.startColumn }
            qtImports.push(content)
        }
        createSuggestionsBasedOffImports()
    }

    function createSuggestionsBasedOffImports() {
        for (const qtType in qtTypeJson["sources"]) {
            var flag = false
            const qtValues = qtTypeJson['sources'][qtType]
            for (var i = 0; i < qtImports.length; i++) {
                if (qtValues.source !== "" && qtImports[i].includes(qtValues.source)) {
                    flag = true
                } else if (qtValues.source === "") {
                    flag = true
                }
            }
            if (flag) {
                appendInherited(qtType, qtValues)
            }
        }
        updateObjectFormat()
    }

    function updateObjectFormat() {
        for (const key in qtObjectSuggestions) {
            for (const values in qtObjectSuggestions[key]["meta"]) {
                if (qtObjectSuggestions[key]["meta"][values].length > 0) {
                    if (qtObjectMetaPropertyValues[key] === undefined) {
                        qtObjectMetaPropertyValues[key] = {}
                    }

                    qtObjectMetaPropertyValues[key][values] = qtObjectSuggestions[key]["meta"][values]
                }
            }
            var arr = []
            for (var j = 0; j < qtObjectSuggestions[key].properties.length; j++) {
                arr.push(qtObjectSuggestions[key].properties[j])
            }
            arr = removeDuplicates(arr)
            createQtObjectValPairs(key, { label: key, insertText: key, properties: arr, flag: false, isId: false })
        }
        createSuggestions()
    }

    function createSuggestions() {
        for (const key in qtObjectKeyValues) {
            if (!qtObjectKeyValues[key].isId && !qtTypeJson["sources"][key].nonInstantiable) {
                suggestions[key] = {
                    label: qtObjectKeyValues[key].label.trim(),
                    kind: monaco.languages.CompletionItemKind.Class,
                    insertTextRules: monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet,
                    insertText: qtObjectKeyValues[key].insertText,
                    range: null,
                }
            }
        }
    }
    // recursive traversal of Inherited Types
    function appendInherited(masterItem, item) {
        //does not inherit from other Items
        if (qtObjectSuggestions[masterItem] === undefined) {
            qtObjectSuggestions[masterItem] = {}
            qtObjectSuggestions[masterItem]["functions"] = []
            qtObjectSuggestions[masterItem]["signals"] = []
            qtObjectSuggestions[masterItem]["properties"] = []
            qtObjectSuggestions[masterItem]["meta"] = {}
        }
        if (item.inherits.length === 0) {
            qtObjectSuggestions[masterItem].functions = qtObjectSuggestions[masterItem].functions.concat(item.functions)
            qtObjectSuggestions[masterItem].signals = qtObjectSuggestions[masterItem].signals.concat(item.signals)
            if (item.signals.length > 0 && !qtTypeJson["sources"][masterItem].nonInstantiable) {
                for (var i = 0; i < item.signals.length; i++) {
                    var signalCall = item.signals[i]
                    var onCall = "on" + signalCall[0].toUpperCase() + signalCall.substring(1)
                    onCall = onCall.split("()")[0]
                    qtObjectSuggestions[masterItem].properties.push(onCall)
                }
            }
            for (const key in item.properties) {
            
                qtObjectSuggestions[masterItem].properties.push(key)
                if(!qtTypeJson["sources"][masterItem].nonInstantiable){
                    var onCall = "on" + key[0].toUpperCase() + key.substring(1) + "Changed"
                    qtObjectSuggestions[masterItem].properties.push(onCall)
                }   
                qtObjectSuggestions[masterItem].meta[key] = item.properties[key].meta_properties
            }
            return;
        } else if (qtTypeJson["sources"].hasOwnProperty(item.inherits)) {
            appendInherited(masterItem, qtTypeJson["sources"][item.inherits])
            qtObjectSuggestions[masterItem].functions = qtObjectSuggestions[masterItem].functions.concat(item.functions)
            qtObjectSuggestions[masterItem].signals = qtObjectSuggestions[masterItem].signals.concat(item.signals)
            if (item.signals.length > 0 && !qtTypeJson["sources"][masterItem].nonInstantiable) {
                for (var i = 0; i < item.signals.length; i++) {
                    var signalCall = item.signals[i]
                    var onCall = "on" + signalCall[0].toUpperCase() + signalCall.substring(1)
                    onCall = onCall.split("()")[0]
                    qtObjectSuggestions[masterItem].properties.push(onCall)
                }
            }
            for (const key in item.properties) {
                qtObjectSuggestions[masterItem].properties.push(key)
                if(!qtTypeJson["sources"][masterItem].nonInstantiable){
                    var onCall = "on" + key[0].toUpperCase() + key.substring(1) + "Changed"
                    qtObjectSuggestions[masterItem].properties.push(onCall)
                }
                qtObjectSuggestions[masterItem].meta[key] = item.properties[key].meta_properties
            }
            return;
        }
    }
    // This creates the suggestions widgets and suggestion items, returning the determined suggestions, reads the files ids, updates editor settings per initial conditions
    function runQmlProvider() {
        monaco.languages.registerCompletionItemProvider('qml', {
            triggerCharacters: ['.', ':'],
            provideCompletionItems: (model, position) => {

                var currText = model.getLineContent(position.lineNumber)
                var currWords = currText.replace("\t", "").split(" ");
                var active = currWords[currWords.length - 1]
                fullRange = model.getFullModelRange()
                topOfFile = model.findNextMatch("{", { lineNumber: fullRange.startLineNumber, column: fullRange.startColumn })
                bottomOfFile = model.findPreviousMatch("}", { lineNumber: fullRange.endLineNumber, column: fullRange.endColumn })
                var getId = model.findNextMatch("id:", { lineNumber: fullRange.startLineNumber, column: fullRange.startColumn })
                if(topOfFile !== null && bottomOfFile !== null){
                    var getLineContent = model.getLineContent(topOfFile.range.startLineNumber)
                    var checkLine = getLineContent.replace("\t", "").split(/\{|\t/)[0].trim()
                    if(qtTypeJson["sources"].hasOwnProperty(checkLine)){
                        initializeQtQuick(model)
                    } else {
                        return {suggestions: []}
                    }
                }

                if (getId !== null) {
                    var nextCheck = model.findNextMatch("}", { lineNumber: getId.range.endLineNumber, column: getId.range.endColumn })
                    var prevCheck = model.findPreviousMatch("{", { lineNumber: getId.range.startLineNumber, column: getId.range.startcolumn })
                    if (!(nextCheck.range.startLineNumber === bottomOfFile.range.startLineNumber && prevCheck.range.startLineNumber === topOfFile.range.startLineNumber)) {
                        getTypeID(model)
                    }
                }
                if ((position.lineNumber < topOfFile.range.startLineNumber || position.lineNumber > bottomOfFile.range.startLineNumber)) {
                    return {suggestions: []}
                } else if(topOfFile === null && bottomOfFile === null){
                    return {suggestions: []}
                }
                if (active.includes(".")) {
                    const activeWord = active.substring(0, active.length - 1).split('.')[0]
                    const prevParent = findPreviousBracketParent(model, position)
                    if (qtObjectKeyValues.hasOwnProperty(activeWord)) {
                        convertStrArrayToObjArray(activeWord, qtObjectKeyValues[activeWord].properties, true, qtObjectKeyValues[activeWord].isId)
                        return { suggestions: qtObjectPropertyValues[activeWord] }
                    } else if (qtObjectMetaPropertyValues.hasOwnProperty(prevParent) && qtObjectMetaPropertyValues[prevParent].hasOwnProperty(activeWord)) {
                        convertStrArrayToObjArray(activeWord, qtObjectMetaPropertyValues[prevParent][activeWord], true, true, null)
                        return { suggestions: qtObjectPropertyValues[activeWord] }
                    }
                }
                if (active.includes(":")) {
                    return { suggestions: Object.values(functionSuggestions) }
                }
                var fetchedSuggestions = searchForChildBrackets(model, position)
                return { suggestions: fetchedSuggestions }
            }
        })
    }
    // Searches for the parent Item based off of the end column of a sibling item, this searches up and checks for time where the current line number is a child of the item
    function findPreviousBracketParent(model, position) {
        var startPosition = position
        var endPosition = position

        var stopped = false
        var parent = null
        var next = null
        var prev = null
        while (!stopped) {
            prev = getPrev(model, startPosition)
            startPosition = { lineNumber: prev.range.startLineNumber, column: prev.range.startColumn }
            next = getNext(model, endPosition)
            endPosition = { lineNumber: next.range.startLineNumber, column: next.range.endColumn }

            var prevContent = model.getLineContent(prev.range.startLineNumber)
            var content = prevContent.replace("\t", "").split(/\{|\t/)[0].trim()
            var getPrevContent = model.findPreviousMatch(content, startPosition)
            endPosition = { lineNumber: getPrevContent.range.startLineNumber, column: prev.range.endColumn }
            next = getNext(model, endPosition)
            while (true) {
                next = getNext(model, endPosition)
                endPosition = { lineNumber: next.range.startLineNumber, column: next.range.startColumn }
                if (getPrevContent.range.startColumn === next.range.startColumn) {
                    break
                }
            }
            var checkNext = getNext(model, endPosition)
            if(checkNext.range.startColumn >= next.range.startColumn){
                prev = getPrev(model, startPosition)
                var content = model.getLineContent(prev.range.startLineNumber)
                var bracket = content.replace("\t","").split(/\{|\t/)[0].trim()
                parent = bracket
                stopped = true
            }
            
            if (getPrevContent.range.startLineNumber < position.lineNumber && next.range.startLineNumber > position.lineNumber) {
                parent = content
                stopped = true
            }
        }
        return parent
    }

    function getNext(model, position) {
        return model.findNextMatch("}", position)
    }

    function getPrev(model, position) {
        return model.findPreviousMatch("{", position)
    }

    // Searches and initializes all id types to the suggestions object as well as allow updates to each item
    function getTypeID(model, position) {
        var position = { lineNumber: fullRange.endLineNumber, column: fullRange.endColumn }
        while (position.lineNumber > fullRange.startLineNumber && !searchedIds) {
            var getPrevIDPosition = model.findPreviousMatch("id:", position, false, false)
            if (position.lineNumber < getPrevIDPosition.range.startLineNumber) {
                break;
            }

            if(getPrevIDPosition === null || getPrevIDPosition === undefined){
                break;
            }

            var prevIdLine = model.getLineContent(getPrevIDPosition.range.startLineNumber)
            var prevId = prevIdLine.replace("\t", "").split(":")[1].trim()

            var getIdType = model.findPreviousMatch("{", { lineNumber: getPrevIDPosition.range.startLineNumber, column: getPrevIDPosition.range.startColumn })
            position = { lineNumber: getIdType.range.startLineNumber, column: getIdType.range.startColumn }
            var content = model.getValueInRange({ startLineNumber: getIdType.range.startLineNumber, startColumn: 0, endLineNumber: getIdType.range.startLineNumber, endColumn: getIdType.range.endColumn })
            var type = content.replace("\t", "").split(/\{|\t/)[0].trim()
            addCustomIdAndTypes(prevId, position, type)
        }
        searchedIds = true
    }
    // This grabs the Item type from the parent bracket and returns the suggestions
    function retrieveType(model, propRange) {
        var content = model.getLineContent(propRange.startLineNumber)
        var splitContent = content.replace("\t", "").split(/\{|\t/)
        var bracketWord = splitContent[0].trim()
        if (qtObjectKeyValues.hasOwnProperty(bracketWord)) {
            convertStrArrayToObjArray(bracketWord, qtObjectKeyValues[bracketWord].properties, qtObjectKeyValues[bracketWord].flag, qtObjectKeyValues[bracketWord].isId, bracketWord)
            if (currentItems[bracketWord] === undefined) {
                currentItems[bracketWord] = {}
            }
            currentItems[bracketWord][propRange] = qtObjectPropertyValues[bracketWord]
            return currentItems[bracketWord][propRange]
        } else if (bracketWord.includes("function") || bracketWord.substring(0,2) === "on" || bracketWord.includes("if")) {
            //display signal Calls, function Calls, ids properties and function,signal, calls
            return Object.values(functionSuggestions)
        } else {

            const prevParent = findPreviousBracketParent(model, { lineNumber: propRange.startLineNumber, column: propRange.startColumn })
            if (qtObjectMetaPropertyValues.hasOwnProperty(prevParent) && qtObjectMetaPropertyValues[prevParent].hasOwnProperty(bracketWord)) {
                convertStrArrayToObjArray(bracketWord, qtObjectMetaPropertyValues[prevParent][bracketWord], true, true)
                if (currentItems[bracketWord] === undefined) {
                    currentItems[bracketWord] = {}
                }
                currentItems[bracketWord][propRange] = qtObjectPropertyValues[bracketWord]
                return currentItems[bracketWord][propRange]
            } else {
                const prevParent = findPreviousBracketParent(model, { lineNumber: propRange.startLineNumber, column: propRange.startColumn })
                if(prevParent.includes("functions") || prevParent.substring(0,2) === "on"|| prevParent.includes("if")){
                    return Object.values(functionSuggestions)
                }
                if(bracketWord.includes(":")){
                    var propertyItem = bracketWord.split(":")[1].trim()
                    if(qtObjectKeyValues.hasOwnProperty(propertyItem)){
                        convertStrArrayToObjArray(propertyItem, qtObjectKeyValues[propertyItem].properties, qtObjectKeyValues[propertyItem].flag, qtObjectKeyValues[propertyItem].isId, propertyItem)
                        if (currentItems[propertyItem] === undefined) {
                            currentItems[propertyItem] = {}
                        }
                        currentItems[propertyItem][propRange] = qtObjectPropertyValues[propertyItem]
                        return currentItems[propertyItem][propRange]
                    } else {
                        return []
                    }
                }
                const newParent = findPreviousBracketParent(model,{ lineNumber: propRange.startLineNumber, column: propRange.startColumn })
                if(qtObjectKeyValues.hasOwnProperty(newParent)){
                    convertStrArrayToObjArray(newParent, qtObjectKeyValues[newParent].properties, qtObjectKeyValues[newParent].flag, qtObjectKeyValues[newParent].isId, newParent)
                    if (currentItems[newParent] === undefined) {
                        currentItems[newParent] = {}
                    }
                    currentItems[newParent][propRange] = qtObjectPropertyValues[newParent]
                    return currentItems[newParent][propRange]
                }
                return Object.values(suggestions)
            }
        }
    }

    editor.getModel().onDidChangeContent((event) => {
        var getId = editor.getModel().getLineContent(event.changes[0].range.startLineNumber);
        var position = { lineNumber: event.changes[0].range.startLineNumber, column: event.changes[0].range.startColumn }
        if (getId.includes("id:")) {
            var word = getId.replace("\t", "").split(":")[1].trim()
            var getIdType = editor.getModel().findPreviousMatch("{", position, false, false)
            var content = editor.getModel().getLineContent({ lineNumber: getIdType.range.startLineNumber, column: getIdType.range.startColumn })
            var type = content.replace("\t", "").split(/\{|\t/)[0].trim()
            addCustomIdAndTypes(word, position, type)
        }
    })
}


/* 
    This File contains portions of snippets.json that exists in https://github.com/ThomasVogelpohl/vsc-qml-snippets/blob/master/snippets/snippets.json
    This File is the base for mapping the auto complete, For CVC purposes this files auto complete will be limited in the number of QtQuick Objects but 
    detailed in the properties

    If we need to add more QtQuick Objects the format will be
    {
        "body": "{\n //id:  \n}",
        "description": "",
        "prefix": "",
        "scope": "source.qml",
        "properties": [""]
    }
*/

const qtObjectKeyValues = {}
const qtIdPairs = {}
const qtObjectPropertyValues = {}
var isInitialized = false
var searchedIds = false
var flags = { sgwidgetsFlag: false, qtQuickFlag: false }
const suggestions = {}
const currentItems = {}
var editor = null

var bottomOfFile = null;
var topOfFile = null;
var fullRange = null;

var propRange = {};

// return an object from a string with definable properties
function createDynamicProperty(property) {
    return {
        "label": property,
        "kind": monaco.languages.CompletionItemKind.KeyWord,
        "insertTextRules": monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet,
        "insertText": property,
        "range": null
    }
}
// filter out duplicate lines
function removeDuplicates(propertySuggestions) {
    return propertySuggestions.sort().filter(function (itm, idx, arr) {
        return !idx || itm.label !== arr[idx - 1].label;
    })
}
// This is the properties string array conversion to an object array, this has to be done in real time due to the limitations of the monaco editor suggestions
function convertStrArrayToObjArray(key, properties, isProperty = false, isIdReference = false) {
    var propertySuggestions = []
    qtObjectPropertyValues[key] = []
    for (var i = 0; i < properties.length; i++) {
        if (!isIdReference) {
            propertySuggestions.push(createDynamicProperty(properties[i]))
        } else {
            propertySuggestions.push(createDynamicProperty(properties[i].split(":")[0]))
        }
    }
    if (propertySuggestions.length !== 0) {
        propertySuggestions = removeDuplicates(propertySuggestions)
    }
    if (isProperty) {
        qtObjectPropertyValues[key] = propertySuggestions
    } else {
        qtObjectPropertyValues[key] = propertySuggestions.concat(Object.values(suggestions));
    }
}
// setting each key val pair for the object
function createQtObjectValPairs(key, val) {
    qtObjectKeyValues[key] = val
}
// creating the qtObjectKeyValues array
function convertQtQuickToObject(objArray, isProperty = false) {

    for(var j = 0; j < objArray.length; j++){
        if(!isProperty && QtQuickTypeJson.hasOwnProperty(objArray[j].type)){
            objArray[j].properties = objArray[j].properties.concat(QtQuickTypeJson[objArray[j].type])
        } 
    }
    for (var i = 0; i < objArray.length; i++) {
        createQtObjectValPairs(objArray[i].prefix, { label: objArray[i].prefix, insertText: objArray[i].body, properties: objArray[i].properties, flag: isProperty, isId: false })
    }
}
// Initializes the library to become an Object array to be feed into suggestions
function initializeQtQuick(flags) {
    if (flags.qtQuickFlag) {
        convertQtQuickToObject(qtQuick)
    }
    if (flags.sgwidgetsFlag) {
        convertQtQuickToObject(SGWidgets)
    }
}
// This is a register for when an Id of a type is read and/or created. Allowing us to instantiate from the id caller
function addCustomIdAndTypes(idText, position, type = "Item") {
    if (!qtIdPairs.hasOwnProperty(position.lineNumber)) {
        qtIdPairs[position.lineNumber] = {}
        qtIdPairs[position.lineNumber][idText] = type
        if (!qtObjectKeyValues.hasOwnProperty(type)) {
            type = "Item"
        }
        createQtObjectValPairs(idText, { label: idText, insertText: idText, properties: qtObjectKeyValues[type].properties, flag: true, isId: true })
        suggestions[idText] = {
            label: qtObjectKeyValues[idText].label,
            kind: monaco.languages.CompletionItemKind.Function,
            insertTextRules: monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet,
            insertText: qtObjectKeyValues[idText].insertText,
            range: null,
        }
    } else {
        if (!qtIdPairs[position.lineNumber].hasOwnProperty(idText)) {
            var keys = Object.keys(qtIdPairs[position.lineNumber])
            delete suggestions[keys[0]]
            delete qtObjectKeyValues[keys[0]]
            delete qtIdPairs[position.lineNumber]
            qtIdPairs[position.lineNumber] = {}
            qtIdPairs[position.lineNumber][idText] = type
            if (!qtObjectKeyValues.hasOwnProperty(type)) {
                type = "Item"
            }
            createQtObjectValPairs(idText, { label: idText, insertText: idText, properties: qtObjectKeyValues[type].properties, flag: true, isId: true})
            suggestions[idText] = {
                label: qtObjectKeyValues[idText].label,
                kind: monaco.languages.CompletionItemKind.Function,
                insertTextRules: monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet,
                insertText: qtObjectKeyValues[idText].insertText,
                range: null,
            }
        } else if (qtIdPairs[position.lineNumber][idText] !== type) {
            qtIdPairs[position.lineNumber][idText] = type
            var keys = Object.keys(qtIdPairs[position.lineNumber])
            delete suggestions[keys[0]]
            delete qtObjectKeyValues[keys[0]]
            if (!qtObjectKeyValues.hasOwnProperty(type)) {
                type = "Item"
            }
            createQtObjectValPairs(idText, { label: idText, insertText: idText, properties: qtObjectKeyValues[type].properties, flag: true, isId: true })
            suggestions[idText] = {
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
                [/^[A_Z0_9]{(.|\n)(?!})$/, 'delimiter.bracket.error'],
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
                var nextPosition = { lineNumber: nextBracketMatch.range.startLineNumber, column: nextBracketMatch.range.startColumn }
                var prevParent = findPreviousBracketParent(model, nextPosition)
                if (qtObjectKeyValues.hasOwnProperty(prevParent)) {
                    propRange = {
                        startLineNumber: nextMatch.range.startLineNumber,
                        endLineNumber: nextBracketMatch.range.startLineNumber,
                        startColumn: nextMatch.range.startColumn,
                        endColumn: nextBracketMatch.range.endColumn,
                    }
                    convertStrArrayToObjArray(prevParent, qtObjectKeyValues[prevParent].properties, qtObjectKeyValues[prevParent].flag)
                    if (currentItems[prevParent] === undefined) {
                        currentItems[prevParent] = {}
                    }
                    currentItems[prevParent][propRange] = qtObjectPropertyValues[prevParent]
                    return currentItems[prevParent][propRange]
                }
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
                convertStrArrayToObjArray(prevParent, qtObjectKeyValues[prevParent].properties, qtObjectKeyValues[prevParent].flag)
                if (currentItems[prevParent] === undefined) {
                    currentItems[prevParent] = {}
                }
                currentItems[prevParent][propRange] = qtObjectPropertyValues[prevParent]
                return currentItems[prevParent][propRange]
            }
        }
    }
    // This creates the suggestions widgets and suggestion items, returning the determined suggestions, reads the files ids, updates editor settings per initial conditions
    function runQmlProvider() {
        monaco.languages.registerCompletionItemProvider('qml', {
            triggerCharacters: ['.'],
            provideCompletionItems: (model, position) => {
                var currText = model.getValueInRange({ startLineNumber: position.lineNumber, startColumn: 0, endLineNumber: position.lineNumber, endColumn: position.column });
                var currWords = currText.replace("\t", "").split(" ");
                var active = currWords[currWords.length - 1]
                fullRange = model.getFullModelRange()
                topOfFile = model.findNextMatch("{", { lineNumber: fullRange.startLineNumber, column: fullRange.startColumn })
                bottomOfFile = model.findPreviousMatch("}", { lineNumber: fullRange.endLineNumber, column: fullRange.endColumn })
                var getId = model.findNextMatch("id:", { lineNumber: fullRange.startLineNumber, column: fullRange.startColumn })
                if (getId !== null && getId !== undefined) {
                    var nextCheck = model.findNextMatch("}", { lineNumber: getId.range.endLineNumber, column: getId.range.endColumn })
                    var prevCheck = model.findPreviousMatch("{", { lineNumber: getId.range.startLineNumber, column: getId.range.startcolumn })
                    if (!(nextCheck.range.startLineNumber === bottomOfFile.range.startLineNumber && prevCheck.range.startLineNumber === topOfFile.range.startLineNumber)) {
                        getTypeID(model)
                    }
                }
                if (topOfFile === null && bottomOfFile === null) {
                    return { suggestions: suggestions }
                }
                if ((position.lineNumber < topOfFile.range.startLineNumber || position.lineNumber > bottomOfFile.range.startLineNumber) || (bottomOfFile === null && topOfFile === null)) {
                    editor.updateOptions({
                        suggest: {
                            showFunctions: false,
                            showClasses: true,
                            showKeyWords: false,
                            showProperties: false,
                        }
                    })
                } else {
                    editor.updateOptions({
                        suggest: {
                            showFunctions: true,
                            showClasses: true,
                            showKeyWords: true,
                            showProperties: true,
                        }
                    })
                }
                if (active.includes(".")) {
                    const activeWord = active.substring(0, active.length - 1).split('.')[0]
                    if (qtObjectKeyValues.hasOwnProperty(activeWord)) {
                        convertStrArrayToObjArray(activeWord, qtObjectKeyValues[activeWord].properties, qtObjectKeyValues[activeWord].flag, qtObjectKeyValues[activeWord].isId)
                        return { suggestions: qtObjectPropertyValues[activeWord] }
                    }
                }
                var fetchedSuggestions = searchForChildBrackets(model, position)
                return { suggestions: fetchedSuggestions === undefined || fetchedSuggestions === null ? Object.values(suggestions) : fetchedSuggestions }
            }
        })
    }
    // Searches for the parent Item based off of the end column of a sibling item, this searches up and checks for time where the current line number is a child of the item
    function findPreviousBracketParent(model, position) {
        var currentPosition = position;
        var parent = null
        while (currentPosition.lineNumber <= position.lineNumber) {
            var getPrev = model.findPreviousMatch("{", currentPosition)
            var getPrevNext = model.findNextMatch("}",{lineNumber: getPrev.range.startLineNumber, column: getPrev.range.startColumn})
            if (currentPosition.lineNumber < getPrev.range.startLineNumber) {
                return suggestions
            }

            if(currentPosition.lineNumber < getPrevNext.range.startLineNumber){
                var content = model.getLineContent(getPrev.range.startLineNumber)
                var splitContent = content.replace("\t", "").split(/\{|\t/)
                var bracketWord = splitContent[0].trim()
                parent = bracketWord
                return parent
            }

            currentPosition = { lineNumber: getPrev.range.startLineNumber, column: getPrev.range.startColumn }

        }
    }
    // Searches and initializes all id types to the suggestions object as well as allow updates to each item
    function getTypeID(model, position) {
        var position = { lineNumber: fullRange.endLineNumber, column: fullRange.endColumn }
        while (position.lineNumber > fullRange.startLineNumber && !searchedIds) {
            var getPrevIDPosition = model.findPreviousMatch("id:", position, false, false)
            if (position.lineNumber < getPrevIDPosition.range.startLineNumber) {
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
            convertStrArrayToObjArray(bracketWord, qtObjectKeyValues[bracketWord].properties, qtObjectKeyValues[bracketWord].flag)
            if (currentItems[bracketWord] === undefined) {
                currentItems[bracketWord] = {}
            }
            currentItems[bracketWord][propRange] = qtObjectPropertyValues[bracketWord]
            return currentItems[bracketWord][propRange]
        } else if(qtQuickBody.hasOwnProperty(bracketWord)){
            convertStrArrayToObjArray(bracketWord, qtQuickBody[bracketWord].properties, true)
            currentItems[bracketWord][propRange] = qtObjectPropertyValues[bracketWord];
            return currentItems[bracketWord][propRange]
        } else {
            return Object.values(suggestions)
        }
    }

    editor.getModel().onDidChangeContent((event) => {
        var getId =  editor.getModel().getLineContent(event.changes[0].range.startLineNumber);
        var position = {lineNumber: event.changes[0].range.startLineNumber, column: event.changes[0].range.startColumn}
        if (getId.includes("id:")) {
            var word = getId.replace("\t", "").split(":")[1].trim()
            var getIdType =  editor.getModel().findPreviousMatch("{", position, false, false)
            var content =  editor.getModel().getLineContent({ lineNumber: getIdType.range.startLineNumber, column: getIdType.range.startColumn })
            var type = content.replace("\t", "").split(/\{|\t/)[0].trim()
            addCustomIdAndTypes(word, position, type)
        }
    })
}

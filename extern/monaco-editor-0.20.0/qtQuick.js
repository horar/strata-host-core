/* 
    This File is the base for mapping the auto complete, For CVC purposes this files auto complete will be limited in the number of QtQuick Objects but 
    detailed in the properties
*/
var qtObjectSuggestions = {}
const qtObjectKeyValues = {}
var qtIdPairs = {}
const qtPropertyPairs = {}
const qtObjectPropertyValues = {}
const qtObjectMetaPropertyValues = {}
var isInitialized = false
var functionsAdded = false
var suggestions = {}
var functionSuggestions = {}
var customProperties = []
const currentItems = {}
var editor = null

var otherProperties = {}

var bottomOfFile = null;
var topOfFile = null;
var fullRange = null;

var qtImports = [];

var propRange = {};

var matchingBrackets = []
var ids = []

/*
    This the global registration for the monaco editor this creates the syntax and linguistics of the qml language, as well as defining the theme of the qml language
*/
function registerQmlProvider() {

    // This creates the suggestions widgets and suggestion items, returning the determined suggestions, reads the files ids, updates editor settings per initial conditions
    function runQmlProvider() {
        monaco.languages.registerCompletionItemProvider('qml', {
            triggerCharacters: ['.', ':', '\v'],
            provideCompletionItems: (model, position) => {
                var currText = model.getLineContent(position.lineNumber)
                var currWords = currText.replace("\t", "").split(" ");
                var active = currWords[currWords.length - 1]
                var getId = model.findNextMatch("id:", { lineNumber: fullRange.startLineNumber, column: fullRange.startColumn })
                if (topOfFile !== null && bottomOfFile !== null) {
                    var getLineContent = model.getLineContent(topOfFile.range.startLineNumber)
                    var checkLine = getLineContent.replace("\t", "").split(/\{|\t/)[0].trim()
                    if (!qtTypeJson["sources"].hasOwnProperty(checkLine)) {
                        return { suggestions: [] }
                    }
                }
                if (getId !== null) {
                    var nextCheck = model.findNextMatch("}", { lineNumber: getId.range.endLineNumber, column: getId.range.endColumn })
                    var prevCheck = model.findPreviousMatch("{", { lineNumber: getId.range.startLineNumber, column: getId.range.startcolumn })
                    if (!(nextCheck.range.startLineNumber === bottomOfFile.range.startLineNumber && prevCheck.range.startLineNumber === topOfFile.range.startLineNumber)) {
                        getTypeID(model)
                        getPropertyType(model)
                    }
                }
                if ((position.lineNumber < topOfFile.range.startLineNumber || position.lineNumber > bottomOfFile.range.startLineNumber)) {
                    return { suggestions: [] }
                } else if (topOfFile === null && bottomOfFile === null) {
                    return { suggestions: [] }
                }
                if (active.includes(".")) {
                    var activeWord = active.substring(0, active.length - 1).split('.')[0]
                    if (activeWord.includes("switch(")) {
                        activeWord = activeWord.replace("switch(", "")
                    }
                    const prevParent = findPreviousBracketParent(model, position)
                    if (qtObjectKeyValues.hasOwnProperty(activeWord)) {
                        var others = []
                        if (otherProperties.hasOwnProperty(activeWord)) {
                            others = otherProperties[activeWord]
                        }
                        convertStrArrayToObjArray(activeWord, qtObjectKeyValues[activeWord].properties.concat(others), true, qtObjectKeyValues[activeWord].isId)
                        return { suggestions: qtObjectPropertyValues[activeWord] }
                    } else if (qtObjectMetaPropertyValues.hasOwnProperty(prevParent) && qtObjectMetaPropertyValues[prevParent].hasOwnProperty(activeWord)) {
                        convertStrArrayToObjArray(activeWord, qtObjectMetaPropertyValues[prevParent][activeWord], true, true, null)
                        return { suggestions: qtObjectPropertyValues[activeWord] }
                    }
                }
                if (active.includes(":")) {
                    var idsSuggestions = []
                    for (var i = 0; i < ids.length; i++) {
                        idsSuggestions.push(functionSuggestions[ids[i]])
                    }
                    return { suggestions: idsSuggestions }
                }
                determineCustomPropertyParents(model, position)
                var fetchedSuggestions = searchForChildBrackets(model, position)
                return { suggestions: fetchedSuggestions }
            }
        })
    }

    runQmlProvider()

    // Component did update
    editor.getModel().onDidChangeContent((event) => {
        const model = editor.getModel()
        fullRange = model.getFullModelRange()
        topOfFile = model.findNextMatch("{", { lineNumber: fullRange.startLineNumber, column: fullRange.startColumn })
        bottomOfFile = model.findPreviousMatch("}", { lineNumber: fullRange.endLineNumber, column: fullRange.endColumn })
        // This is where the speed goes down
        //createMatchingPairs(model)
        //initializeQtQuick(model)

        var getLine = model.getLineContent(event.changes[0].range.startLineNumber);
        var position = { lineNumber: event.changes[0].range.startLineNumber, column: event.changes[0].range.startColumn }
        if (getLine.includes("id:")) {
            var word = getLine.replace("\t", "").split(":")[1].trim()
            if (word.includes("//")) {
                word = word.split("//")[0]
            }
            var getIdType = model.findPreviousMatch("{", position, false, false)
            var content = model.getLineContent(getIdType.range.startLineNumber)
            var type = content.replace("\t", "").split(/\{|\t/)[0].trim()
            addCustomIdAndTypes(word, position, type)
        } else if (getLine.includes("property") && !getLine.includes("import")) {
            if (getLine.replace("\t", "").split(" ")[1] !== "" && getLine.replace("\t", "").split(" ")[1] !== undefined) {
                if (getLine.replace("\t", "").split(" ")[2] !== "" && getLine.replace("\t", "").split(" ")[2] !== undefined) {
                    if (getLine.replace("\t", "").split(" ")[2].includes(":")) {
                        var word = getLine.replace("\t", "").split(" ")[2].trim()
                        if (word.includes(":")) {
                            word.split(":")[0].trim()
                        }
                        if (word !== undefined || word !== "") {
                            var getPropertyType = model.findPreviousMatch("{", position, false, false)
                            var content = model.getLineContent(getPropertyType.range.startLineNumber)
                            var type = content.replace("\t", "").split(/\{|\t/)[0].trim()
                            addCustomProperties(event.changes[0].range.startLineNumber, type, word)
                        }
                    }
                }
            }
        }
    })

    // Component will unmount
    editor.getModel().onWillDispose(() => {
        editor.dispose()
    })
}

// Component will mount
function initEditor() {
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

    editor = monaco.editor.create(document.getElementById('container'), {
        value: "",
        language: 'qml',
        theme: 'qmlTheme',
        formatOnPaste: true,
        formatOnType: true,
        formatOnSave: true,
        autoIndent: 'full',
        scrollbar: {
            useShadows: false,
            vertical: 'visible',
            horizontal: 'visible',
            horizontalScrollbarSize: 15,
            verticalScrollbarSize: 15,
        }
    });

    editor.addAction({
        id: 'commentSelection',
        label: "Comment selection",
        contextMenuGroupId: "navigation",
        keybindings: [monaco.KeyMod.CtrlCmd | monaco.KeyCode.US_SLASH],
        run: (editor) => {
            editor.getAction('editor.action.commentLine').run()
        }
    })

    registerQmlProvider()

    isInitialized = true
}

function printCircularJSON(json) {
    var cache = [];
   var retVal = JSON.stringify(json, (key, value) => {
        if (typeof value === 'object' && value !== null) {
            // Duplicate reference found, discard key
            if (cache.includes(value)) return;

            // Store value in our collection
            cache.push(value);
        }
    return value;
    });
    cache = null; // Enable garbage collection
    return retVal;
}
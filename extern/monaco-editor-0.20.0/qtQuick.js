/* 
    This File is the base for mapping the auto complete, For CVC purposes this files auto complete will be limited in the number of QtQuick Objects but 
    detailed in the properties
*/

var isInitialized = false
var editor = null
var qtSuggestions = null;
var qtSearch = null;
var qtProperties = null;
var qtIds = null;
var qtHelper = null;
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
                var getId = model.findNextMatch("id:", { lineNumber: qtSearch.fullRange.startLineNumber, column: qtSearch.fullRange.startColumn })
                if (qtSearch.topOfFile !== null && qtSearch.bottomOfFile !== null) {
                    var getLineContent = model.getLineContent(qtSearch.topOfFile.range.startLineNumber)
                    var checkLine = getLineContent.replace("\t", "").split(/\{|\t/)[0].trim()
                    if (!qtTypeJson["sources"].hasOwnProperty(checkLine)) {
                        return { suggestions: [] }
                    }
                }
                if (getId !== null) {
                    var nextCheck = model.findNextMatch("}", { lineNumber: getId.range.endLineNumber, column: getId.range.endColumn })
                    var prevCheck = model.findPreviousMatch("{", { lineNumber: getId.range.startLineNumber, column: getId.range.startcolumn })
                    if (!(nextCheck.range.startLineNumber === qtSearch.bottomOfFile.range.startLineNumber && prevCheck.range.startLineNumber === qtSearch.topOfFile.range.startLineNumber)) {
                        qtIds.getTypeID(model)
                        qtProperties.getPropertyType(model)
                    }
                }
                if ((position.lineNumber < qtSearch.topOfFile.range.startLineNumber || position.lineNumber > qtSearch.bottomOfFile.range.startLineNumber)) {
                    return { suggestions: [] }
                } else if (qtSearch.topOfFile === null && qtSearch.bottomOfFile === null) {
                    return { suggestions: [] }
                }
                if (active.includes(".")) {
                    var activeWord = active.substring(0, active.length - 1).split('.')[0]
                    if (activeWord.includes("switch(")) {
                        activeWord = activeWord.replace("switch(", "")
                    }
                    const prevParent = qtSearch.findPreviousBracketParent(position)
                    if (qtSuggestions.qtObjectKeyValues.hasOwnProperty(activeWord)) {
                        var others = []
                        if (qtIds.otherProperties.hasOwnProperty(activeWord)) {
                            others = qtIds.otherProperties[activeWord]
                        }
                        qtSuggestions.convertStrArrayToObjArray(activeWord, qtSuggestions.qtObjectKeyValues[activeWord].properties.concat(others), true, qtSuggestions.qtObjectKeyValues[activeWord].isId)
                        return { suggestions: qtSuggestions.qtObjectPropertyValues[activeWord] }
                    } else if (qtSuggestions.qtObjectMetaPropertyValues.hasOwnProperty(prevParent) && qtSuggestions.qtObjectMetaPropertyValues[prevParent].hasOwnProperty(activeWord)) {
                        qtSuggestions.convertStrArrayToObjArray(activeWord, qtSuggestions.qtObjectMetaPropertyValues[prevParent][activeWord], true, true, null)
                        return { suggestions: qtSuggestions.qtObjectPropertyValues[activeWord] }
                    }
                }
                if (active.includes(":")) {
                    var idsSuggestions = []
                    for (var i = 0; i < qtIds.ids.length; i++) {
                        idsSuggestions.push(qtSuggestions.functionSuggestions[qtIds.ids[i]])
                    }
                    return { suggestions: idsSuggestions }
                }
                qtProperties.determineCustomPropertyParents(model, position)
                var fetchedSuggestions = searchForChildBrackets(model, position)
                return { suggestions: fetchedSuggestions }
            }
        })
    }

    function searchForChildBrackets(model, position) {
        var propRange = {};
        var prevMatch = model.findPreviousMatch("{", position, false, false)
        var nextBracketMatch = model.findNextMatch("{", position, false, false)
        var prevBracketMatch = model.findPreviousMatch("}", position, false, false)
        var nextMatch = model.findNextMatch("}", position, false, false)
        var nextnextMatch = model.findNextMatch("}", { lineNumber: nextMatch.range.startLineNumber, column: nextMatch.range.endColumn }, false, false)
        var prevprevMatch = model.findPreviousMatch("{", { lineNumber: prevMatch.range.startLineNumber, column: prevMatch.range.startColumn }, false, false)
    
        //Handles the : after issue
        var line = model.getLineContent(position.lineNumber)
        if (line.includes(":") && line.substring(0, 2) !== "on" && !line.includes("property")) {
            var idsSuggestions = []
            for (var i = 0; i < qtIds.ids.length; i++) {
                idsSuggestions.push(qtSuggestions.functionSuggestions[qtIds.ids[i]])
            }
            return idsSuggestions
        }
    
        //Edge Case 4: this is when there is only one QtItem, most common is when we create a new file
        if (prevMatch.range.startLineNumber === qtSearch.topOfFile.range.startLineNumber && nextMatch.range.startLineNumber === qtSearch.bottomOfFile.range.startLineNumber) {
            propRange = {
                startLineNumber: prevMatch.range.startLineNumber,
                endLineNumber: nextMatch.range.startLineNumber,
                startColumn: prevMatch.range.startColumn,
                endColumn: nextMatch.range.endColumn
            }
            return qtSuggestions.retrieveType(model, propRange)
        }
        //Edge Case 3: this is to ensure that editing the top of the file does not allow a child item to read in its parent data i.e Item and anchors dont mix
        if (prevMatch.range.startLineNumber === qtSearch.topOfFile.range.startLineNumber || prevprevMatch.range.startLineNumber === qtSearch.topOfFile.range.startLineNumber) {
            if (position.lineNumber >= prevMatch.range.startLineNumber && position.lineNumber <= nextMatch.range.startLineNumber && (nextMatch.range.startLineNumber <= nextnextMatch.range.startLineNumber && prevBracketMatch.range.startLineNumber >= nextnextMatch.range.startLineNumber)) {
                propRange = {
                    startLineNumber: prevMatch.range.startLineNumber,
                    endLineNumber: nextMatch.range.startLineNumber,
                    startColumn: prevMatch.range.startColumn,
                    endColumn: nextMatch.range.endColumn
                }
                return qtSuggestions.retrieveType(model, propRange)
            }
        }
        //Edge Case 5: same as 3, just inveresed for the end of the file
        if (nextMatch.range.startLineNumber === qtSearch.bottomOfFile.range.startLineNumber || nextnextMatch.range.startLineNumber === qtSearch.bottomOfFile.range.startLineNumber) {
            if (position.lineNumber >= prevMatch.range.startLineNumber && position.lineNumber <= nextMatch.range.startLineNumber && prevMatch.range.startLineNumber > prevBracketMatch.range.startLineNumber) {
                propRange = {
                    startLineNumber: prevMatch.range.startLineNumber,
                    endLineNumber: nextMatch.range.startLineNumber,
                    startColumn: prevMatch.range.startColumn,
                    endColumn: nextMatch.range.endColumn
                }
                return qtSuggestions.retrieveType(model, propRange)
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
                return qtSuggestions.retrieveType(model, propRange)
                // Edge Case 1: A rare case where if there is no first child of an item on loaded the properties will not propagate
            } else if (nextMatch.range.startLineNumber > nextBracketMatch.range.startLineNumber) {
                propRange = {
                    startLineNumber: prevMatch.range.startLineNumber,
                    endLineNumber: nextBracketMatch.range.startLineNumber,
                    startColumn: prevMatch.range.startColumn,
                    endColumn: nextBracketMatch.range.endColumn,
                }
                return qtSuggestions.retrieveType(model, propRange)
            }
            //Edge case 2: this is the most common edge case hit where the properties between sibling items are intermingled this determines what the parent item is
        } else if (prevMatch.range.startLineNumber < prevBracketMatch.range.startLineNumber && position.lineNumber <= nextMatch.range.startLineNumber) {
            var prevParent = qtSearch.findPreviousBracketParent(position).trim()
            var prevBrack = model.findPreviousMatch(prevParent, position)
            var bracket = model.findPreviousMatch("{", { lineNumber: prevBrack.range.startLineNumber, column: prevBrack.range.startColumn })
            var getWord = model.getLineContent(bracket.range.startLineNumber).replace("\t", "").split(/\{|\t/)[0].trim()
            if (qtSuggestions.qtObjectKeyValues.hasOwnProperty(prevParent)) {
                propRange = {
                    startLineNumber: prevMatch.range.startLineNumber,
                    endLineNumber: prevBracketMatch.range.startLineNumber,
                    startColumn: prevMatch.range.startColumn,
                    endColumn: prevBracketMatch.range.endColumn,
                }
                qtSuggestions.convertStrArrayToObjArray(prevParent, qtSuggestions.qtObjectKeyValues[prevParent].properties.concat(qtProperties.customProperties), qtSuggestions.qtObjectKeyValues[prevParent].flag, false, prevParent)
                if (qtSuggestions.currentItems[prevParent] === undefined) {
                    qtSuggestions.currentItems[prevParent] = {}
                }
                qtSuggestions.currentItems[prevParent][propRange] = qtSuggestions.qtObjectPropertyValues[prevParent]
                return qtSuggestions.currentItems[prevParent][propRange]
            } else if (qtSuggestions.qtObjectMetaPropertyValues[getWord].hasOwnProperty(prevParent)) {
                qtSuggestions.convertStrArrayToObjArray(prevParent, qtSuggestions.qtObjectMetaPropertyValues[getWord][prevParent], true, true, null)
                return qtSuggestions.qtObjectPropertyValues[prevParent]
            } else if (prevParent.includes(":") && prevParent.substring(0, 2) !== "on") {
                const propertyItem = prevParent.trim().replace("\t", "").split(":")[1].trim()
                propRange = {
                    startLineNumber: prevMatch.range.startLineNumber,
                    endLineNumber: nextMatch.range.startLineNumber,
                    startColumn: prevMatch.range.startColumn,
                    endColumn: nextMatch.range.endColumn,
                }
    
                qtSuggestions.convertStrArrayToObjArray(propertyItem, qtSuggestions.qtObjectKeyValues[propertyItem].properties, qtSuggestions.qtObjectKeyValues[propertyItem].flag, false, propertyItem)
                if (qtSuggestions.currentItems[propertyItem] === undefined) {
                    qtSuggestions.currentItems[propertyItem] = {}
                }
                qtSuggestions.currentItems[propertyItem][propRange] = qtSuggestions.qtObjectPropertyValues[propertyItem]
                return qtSuggestions.currentItems[propertyItem][propRange]
    
            } else {
                return Object.values(qtSuggestions.functionSuggestions)
            }
        }
        if (position.lineNumber > prevMatch.range.startLineNumber && position.lineNumber > prevBracketMatch.range.startLineNumber) {
            var prevParent = qtSearch.findPreviousBracketParent(position)
            if (qtSuggestions.qtObjectKeyValues.hasOwnProperty(prevParent)) {
                propRange = {
                    startLineNumber: prevMatch.range.startLineNumber,
                    endLineNumber: nextMatch.range.startLineNumber,
                    startColumn: prevMatch.range.startColumn,
                    endColumn: nextMatch.range.endColumn,
                }
                qtSuggestions.convertStrArrayToObjArray(prevParent, qtSuggestions.qtObjectKeyValues[prevParent].properties, qtSuggestions.qtObjectKeyValues[prevParent].flag, false, prevParent)
                if (qtSuggestions.currentItems[prevParent] === undefined) {
                    qtSuggestions.currentItems[prevParent] = {}
                }
                qtSuggestions.currentItems[prevParent][propRange] = qtSuggestions.qtObjectPropertyValues[prevParent]
                return qtSuggestions.currentItems[prevParent][propRange]
            }
        }
        if (position.lineNumber >= prevMatch.range.startLineNumber && position.lineNumber <= nextMatch.range.startLineNumber) {
            var getContent = model.getLineContent(prevMatch.range.startLineNumber)
            if (getContent.includes(":")) {
                var content = getContent.replace("\t", "").split(/\{|\t/)[0].trim()
                var currentProperty = content.split(":")[1].trim()
                if (qtSuggestions.qtObjectKeyValues.hasOwnProperty(currentProperty)) {
                    propRange = {
                        startLineNumber: prevMatch.range.startLineNumber,
                        endLineNumber: nextMatch.range.startLineNumber,
                        startColumn: prevMatch.range.startColumn,
                        endColumn: nextMatch.range.endColumn,
                    }
    
                    qtSuggestions.convertStrArrayToObjArray(currentProperty, qtSuggestions.qtObjectKeyValues[currentProperty].properties, qtSuggestions.qtObjectKeyValues[currentProperty].flag, false, currentProperty)
                    if (qtSuggestions.currentItems[currentProperty] === undefined) {
                        qtSuggestions.currentItems[currentProperty] = {}
                    }
                    qtSuggestions.currentItems[currentProperty][propRange] = qtSuggestions.qtObjectPropertyValues[currentProperty]
                    return qtSuggestions.currentItems[currentProperty][propRange]
                }
            } else {
                var content = getContent.replace("\t", "").split(/\{|\t/)[0].trim()
                if (qtSuggestions.qtObjectKeyValues.hasOwnProperty(content)) {
                    propRange = {
                        startLineNumber: prevMatch.range.startLineNumber,
                        endLineNumber: nextMatch.range.startLineNumber,
                        startColumn: prevMatch.range.startColumn,
                        endColumn: nextMatch.range.endColumn,
                    }
    
                    qtSuggestions.convertStrArrayToObjArray(content, qtSuggestions.qtObjectKeyValues[content].properties, qtSuggestions.qtObjectKeyValues[content].flag, false, content)
                    if (qtSuggestions.currentItems[content] === undefined) {
                        qtSuggestions.currentItems[content] = {}
                    }
                    qtSuggestions.currentItems[content][propRange] = qtObjectPropertyValues[content]
                    return qtSuggestions.currentItems[content][propRange]
                }
            }
        }
        return Object.values(qtSuggestions.suggestions)
    }

    runQmlProvider()

    // Component did mount and update
    editor.getModel().onDidChangeContent((event) => {
        window.link.fileText = editor.getValue();
        window.link.setVersionId(editor.getModel().getAlternativeVersionId());
        const model = editor.getModel()
        qtSearch.update(model)
        // Mount
        if(!isInitialized){
            if(qtSuggestions.model === null) {
                qtSuggestions.update(model,{
                    qtHelper: qtHelper,
                    qtSearch: qtSearch,
                })
            }

            if(qtIds.model === null){
                qtIds.update(model,{
                    qtHelper: qtHelper,
                    qtSearch: qtSearch,
                    qtSuggestions: qtSuggestions,
                })
            }

            if(qtProperties.model === null) {
                qtProperties.update(model, {
                    qtHelper: qtHelper,
                    qtIds: qtIds,
                    qtSearch: qtSearch,
                    qtSuggestions: qtSuggestions,
                })
            }
            isInitialized = true
        }

        var getLine = model.getLineContent(event.changes[0].range.startLineNumber);
        var position = { lineNumber: event.changes[0].range.startLineNumber, column: event.changes[0].range.startColumn }
        if (getLine.includes("import")) {
            qtSuggestions.update(model,{
                qtHelper: qtHelper,
                qtSearch: qtSearch,
            })
        } 
        
        if (getLine.includes("id:")) {
            qtIds.update(model,{
                qtHelper: qtHelper,
                qtSearch: qtSearch,
                qtSuggestions: qtSuggestions,
            })
            var word = getLine.replace("\t", "").split(":")[1].trim()
            if (word.includes("//")) {
                word = word.split("//")[0]
            }
            var getIdType = model.findPreviousMatch("{", position, false, false) // O(n)
            var content = model.getLineContent(getIdType.range.startLineNumber)
            var type = content.replace("\t", "").split(/\{|\t/)[0].trim()
            qtIds.addCustomIdAndTypes(word, position, type) // O(n)
        } else if (getLine.includes("property") && !getLine.includes("import")) {
            qtProperties.update(model, {
                qtHelper: qtHelper,
                qtIds: qtIds,
                qtSearch: qtSearch,
                qtSuggestions: qtSuggestions,
            })
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
                            qtProperties.addCustomProperties(event.changes[0].range.startLineNumber, type, word) // O(n)
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

// Initialize
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
        language: "qml",
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

    qtHelper = new QtHelper(editor)
    // base class
    qtSearch = new QtSearch()
    qtSuggestions = new QtSuggestions()
    qtIds = new QtIds()
    qtProperties = new QtProperties()

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
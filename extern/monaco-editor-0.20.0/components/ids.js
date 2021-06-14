// This is a register for when an Id of a type is read and/or created. Allowing us to instantiate from the id caller
function addCustomIdAndTypes(idText, position, type = "Item") {
    if (!qtIdPairs.hasOwnProperty(position.lineNumber)) {
        qtIdPairs[position.lineNumber] = {}
        if (!qtObjectKeyValues.hasOwnProperty(type)) {
            type = "Item"
        }
        qtIdPairs[position.lineNumber][idText] = type
        var arr = []
        arr = arr.concat(removeDuplicates(removeOnCalls(qtObjectKeyValues[qtIdPairs[position.lineNumber][idText]].properties)))
        arr = arr.concat(removeDuplicates(qtObjectSuggestions[qtIdPairs[position.lineNumber][idText]].functions))
        arr = arr.concat(qtObjectSuggestions[qtIdPairs[position.lineNumber][idText]].signals)
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
            if (!qtObjectKeyValues.hasOwnProperty(type)) {
                type = "Item"
            }
            qtIdPairs[position.lineNumber][idText] = type
            var arr = []
            arr = arr.concat(removeDuplicates(removeOnCalls(qtObjectKeyValues[qtIdPairs[position.lineNumber][idText]].properties)))
            arr = arr.concat(removeDuplicates(qtObjectSuggestions[qtIdPairs[position.lineNumber][idText]].functions))
            arr = arr.concat(qtObjectSuggestions[qtIdPairs[position.lineNumber][idText]].signals)
            createQtObjectValPairs(idText, { label: idText, insertText: idText, properties: arr, flag: true, isId: true })
            functionSuggestions[idText] = {
                label: qtObjectKeyValues[idText].label,
                kind: monaco.languages.CompletionItemKind.Function,
                insertTextRules: monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet,
                insertText: qtObjectKeyValues[idText].insertText,
                range: null,
            }
        } else if (qtIdPairs[position.lineNumber][idText] !== type) {
            var keys = Object.keys(qtIdPairs[position.lineNumber])
            delete functionSuggestions[keys[0]]
            delete qtObjectKeyValues[keys[0]]
            if (!qtObjectKeyValues.hasOwnProperty(type)) {
                type = "Item"
            }
            qtIdPairs[position.lineNumber][idText] = type
            var arr = []
            arr = arr.concat(removeDuplicates(removeOnCalls(qtObjectKeyValues[qtIdPairs[position.lineNumber][idText]].properties)))
            arr = arr.concat(removeDuplicates(qtObjectSuggestions[qtIdPairs[position.lineNumber][idText]].functions))
            arr = arr.concat(qtObjectSuggestions[qtIdPairs[position.lineNumber][idText]].signals)
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

// Searches and initializes all id types to the suggestions object as well as allow updates to each item
function getTypeID(model, position) {
    qtIdPairs = {}
    ids = []
    var position = { lineNumber: fullRange.endLineNumber, column: fullRange.endColumn }
    while (position.lineNumber > fullRange.startLineNumber) {
        var getPrevIDPosition = model.findPreviousMatch("id:", position, false, false)
        if (position.lineNumber < getPrevIDPosition.range.startLineNumber) {
            break;
        }

        if (getPrevIDPosition === null || getPrevIDPosition === undefined) {
            break;
        }

        var prevIdLine = model.getLineContent(getPrevIDPosition.range.startLineNumber)
        var prevId = prevIdLine.replace("\t", "").split(":")[1].trim()
        if(prevId.includes("//")){
            prevId = prevId.split("//")[0]
        }
        var getIdType = model.findPreviousMatch("{", { lineNumber: getPrevIDPosition.range.startLineNumber, column: getPrevIDPosition.range.startColumn })
        position = { lineNumber: getPrevIDPosition.range.startLineNumber, column: getPrevIDPosition.range.startColumn }
        var content = model.getLineContent(getIdType.range.startLineNumber)
        var type = content.replace("\t", "").split(/\{|\t/)[0].trim()
        addCustomIdAndTypes(prevId, position, type)
        ids.push(prevId)
        if (!otherProperties.hasOwnProperty(prevId)) {
            otherProperties[prevId] = []
        }
        var checkPrevIdPosition = model.findPreviousMatch("id:",position,false,false)
        if(getPrevIDPosition.range.startLineNumber === checkPrevIdPosition.range.startLineNumber){
            break;
        }
    }
}
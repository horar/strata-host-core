// This is a register for when an Id of a type is read and/or created. Allowing us to instantiate from the id caller


// Searches and initializes all id types to the suggestions object as well as allow updates to each item

class QtIds {
    constructor(){
        this.model = null
        this.qtIdPairs = {}
        this.ids = [];
        this.otherProperties = {}
    }

    update(model) {
        this.model = model
        this.qtIdPairs = {}
        this.ids = [];
        this.otherProperties = {}
        this.getTypeID(model)
    }

    getTypeID(model) {
        var position = { lineNumber: qtSearch.fullRange.endLineNumber, column: qtSearch.fullRange.endColumn }
        while (position.lineNumber > qtSearch.fullRange.startLineNumber) {
            var getPrevIDPosition = model.findPreviousMatch("id:", position, false, false)
            if (position.lineNumber < getPrevIDPosition.range.startLineNumber) {
                break;
            }
    
            if (getPrevIDPosition === null || getPrevIDPosition === undefined) {
                break;
            }
    
            var prevIdLine = model.getLineContent(getPrevIDPosition.range.startLineNumber)
            var prevId = prevIdLine.replace("\t", "").split(":")[1].trim()
            if(prevId.includes("//") || prevId.includes("/*")){
                prevId = prevId.split("//")[0]
            }
            var getIdType = model.findPreviousMatch("{", { lineNumber: getPrevIDPosition.range.startLineNumber, column: getPrevIDPosition.range.startColumn })
            position = { lineNumber: getPrevIDPosition.range.startLineNumber, column: getPrevIDPosition.range.startColumn }
            var content = model.getLineContent(getIdType.range.startLineNumber)
            var type = content.replace("\t", "").split(/\{|\t/)[0].trim()
            this.addCustomIdAndTypes(prevId, position, type)
            if(!this.ids.includes(prevId)){
                this.ids.push(prevId)
            }
            this.ids = removeDuplicates(this.ids)
            if (!this.otherProperties.hasOwnProperty(prevId)) {
                this.otherProperties[prevId] = []
            }
            var checkPrevIdPosition = model.findPreviousMatch("id:",position,false,false)
            if(getPrevIDPosition.range.startLineNumber === checkPrevIdPosition.range.startLineNumber){
                break;
            }
        }
    }

    addCustomIdAndTypes(idText, position, type = "Item") {
        if (!this.qtIdPairs.hasOwnProperty(position.lineNumber)) {
            this.qtIdPairs[position.lineNumber] = {}
            if (!qtSuggestions.qtObjectKeyValues.hasOwnProperty(type)) {
                type = "Item"
            }
            this.qtIdPairs[position.lineNumber][idText] = type
            var arr = []
            arr = arr.concat(removeDuplicates(removeOnCalls(qtSuggestions.qtObjectKeyValues[this.qtIdPairs[position.lineNumber][idText]].properties)))
            arr = arr.concat(removeDuplicates(qtSuggestions.qtObjectSuggestions[this.qtIdPairs[position.lineNumber][idText]].functions))
            arr = arr.concat(qtSuggestions.qtObjectSuggestions[this.qtIdPairs[position.lineNumber][idText]].signals)
            qtSuggestions.createQtObjectValPairs(idText, { label: idText, insertText: idText, properties: arr, flag: true, isId: true })
            qtSuggestions.functionSuggestions[idText] = {
                label: qtSuggestions.qtObjectKeyValues[idText].label,
                kind: monaco.languages.CompletionItemKind.Function,
                insertTextRules: monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet,
                insertText: qtSuggestions.qtObjectKeyValues[idText].insertText,
                range: null,
            }
        } else {
            if (!this.qtIdPairs[position.lineNumber].hasOwnProperty(idText)) {
                var keys = Object.keys(this.qtIdPairs[position.lineNumber])
                delete qtSuggestions.functionSuggestions[keys[0]]
                delete qtSuggestions.qtObjectKeyValues[keys[0]]
                delete this.qtIdPairs[position.lineNumber]
                this.qtIdPairs[position.lineNumber] = {}
                if (!qtSuggestions.qtObjectKeyValues.hasOwnProperty(type)) {
                    type = "Item"
                }
                this.qtIdPairs[position.lineNumber][idText] = type
                var arr = []
                arr = arr.concat(removeDuplicates(removeOnCalls(qtSuggestions.qtObjectKeyValues[this.qtIdPairs[position.lineNumber][idText]].properties)))
                arr = arr.concat(removeDuplicates(qtSuggestions.qtObjectSuggestions[this.qtIdPairs[position.lineNumber][idText]].functions))
                arr = arr.concat(qtSuggestions.qtObjectSuggestions[this.qtIdPairs[position.lineNumber][idText]].signals)
                qtSuggestions.createQtObjectValPairs(idText, { label: idText, insertText: idText, properties: arr, flag: true, isId: true })
                qtSuggestions.functionSuggestions[idText] = {
                    label: qtSuggestions.qtObjectKeyValues[idText].label,
                    kind: monaco.languages.CompletionItemKind.Function,
                    insertTextRules: monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet,
                    insertText: qtSuggestions.qtObjectKeyValues[idText].insertText,
                    range: null,
                }
            } else if (this.qtIdPairs[position.lineNumber][idText] !== type) {
                var keys = Object.keys(this.qtIdPairs[position.lineNumber])
                delete qtSuggestions.functionSuggestions[keys[0]]
                delete qtSuggestions.qtObjectKeyValues[keys[0]]
                if (!qtSuggestions.qtObjectKeyValues.hasOwnProperty(type)) {
                    type = "Item"
                }
                this.qtIdPairs[position.lineNumber][idText] = type
                var arr = []
                arr = arr.concat(removeDuplicates(removeOnCalls(qtSuggestions.qtObjectKeyValues[this.qtIdPairs[position.lineNumber][idText]].properties)))
                arr = arr.concat(removeDuplicates(qtSuggestions.qtObjectSuggestions[this.qtIdPairs[position.lineNumber][idText]].functions))
                arr = arr.concat(qtSuggestions.qtObjectSuggestions[this.qtIdPairs[position.lineNumber][idText]].signals)
                qtSuggestions.createQtObjectValPairs(idText, { label: idText, insertText: idText, properties: arr, flag: true, isId: true })
    
                qtSuggestions.functionSuggestions[idText] = {
                    label: qtSuggestions.qtObjectKeyValues[idText].label,
                    kind: monaco.languages.CompletionItemKind.Function,
                    insertTextRules: monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet,
                    insertText: qtSuggestions.qtObjectKeyValues[idText].insertText,
                    range: null,
                }
            }
        }
    }
}
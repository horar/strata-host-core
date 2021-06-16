// This is a register for when an Id of a type is read and/or created. Allowing us to instantiate from the id caller


// Searches and initializes all id types to the suggestions object as well as allow updates to each item

class QtIds {
    constructor(model, qtQuick){
        this.model = model
        this.qtQuick = qtQuick
        this.qtIdPairs = {}
        this.ids = [];
        this.otherProperties = []
        this.getTypeID(model)
    }

    update(model, qtQuick) {
        this.model = model
        this.qtIdPairs = {}
        this.qtQuick = qtQuick
        this.ids = [];
        this.otherProperties = []
        this.getTypeID(model)
    }

    getTypeID(model) {
        var position = { lineNumber: this.qtQuick.qtSearch.fullRange.endLineNumber, column: this.qtQuick.qtSearch.fullRange.endColumn }
        while (position.lineNumber > this.qtQuick.qtSearch.fullRange.startLineNumber) {
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
            this.addCustomIdAndTypes(prevId, position, type)
            this.ids.push(prevId)
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
            if (!this.qtQuick.qtSuggestions.qtObjectKeyValues.hasOwnProperty(type)) {
                type = "Item"
            }
            this.qtIdPairs[position.lineNumber][idText] = type
            var arr = []
            arr = arr.concat(this.qtQuick.qtHelper.removeDuplicates(this.qtQuick.qtHelper.removeOnCalls(this.qtQuick.qtSuggestions.qtObjectKeyValues[this.qtIdPairs[position.lineNumber][idText]].properties)))
            arr = arr.concat(this.qtQuick.qtHelper.removeDuplicates(this.qtQuick.qtSuggestions.qtObjectSuggestions[this.qtIdPairs[position.lineNumber][idText]].functions))
            arr = arr.concat(this.qtQuick.qtSuggestions.qtObjectSuggestions[this.qtIdPairs[position.lineNumber][idText]].signals)
            this.qtQuick.qtSuggestions.createQtObjectValPairs(idText, { label: idText, insertText: idText, properties: arr, flag: true, isId: true })
            this.qtQuick.qtSuggestions.functionSuggestions[idText] = {
                label: this.qtQuick.qtSuggestions.qtObjectKeyValues[idText].label,
                kind: monaco.languages.CompletionItemKind.Function,
                insertTextRules: monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet,
                insertText: this.qtQuick.qtSuggestions.qtObjectKeyValues[idText].insertText,
                range: null,
            }
        } else {
            if (!this.qtIdPairs[position.lineNumber].hasOwnProperty(idText)) {
                var keys = Object.keys(this.qtIdPairs[position.lineNumber])
                delete this.qtQuick.qtSuggestions.functionSuggestions[keys[0]]
                delete this.qtQuick.qtSuggestions.qtObjectKeyValues[keys[0]]
                delete this.qtIdPairs[position.lineNumber]
                this.qtIdPairs[position.lineNumber] = {}
                if (!this.qtQuick.qtSuggestions.qtObjectKeyValues.hasOwnProperty(type)) {
                    type = "Item"
                }
                this.qtIdPairs[position.lineNumber][idText] = type
                var arr = []
                arr = arr.concat(this.qtQuick.qtHelper.removeDuplicates(this.qtQuick.qtHelper.removeOnCalls(this.qtQuick.qtSuggestions.qtObjectKeyValues[this.qtIdPairs[position.lineNumber][idText]].properties)))
                arr = arr.concat(this.qtQuick.qtHelper.removeDuplicates(this.qtQuick.qtSuggestions.qtObjectSuggestions[this.qtIdPairs[position.lineNumber][idText]].functions))
                arr = arr.concat(this.qtQuick.qtSuggestions.qtObjectSuggestions[this.qtIdPairs[position.lineNumber][idText]].signals)
                this.qtQuick.qtSuggestions.createQtObjectValPairs(idText, { label: idText, insertText: idText, properties: arr, flag: true, isId: true })
                this.qtQuick.qtSuggestions.functionSuggestions[idText] = {
                    label: this.qtQuick.qtSuggestions.qtObjectKeyValues[idText].label,
                    kind: monaco.languages.CompletionItemKind.Function,
                    insertTextRules: monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet,
                    insertText: this.qtQuick.qtSuggestions.qtObjectKeyValues[idText].insertText,
                    range: null,
                }
            } else if (this.qtIdPairs[position.lineNumber][idText] !== type) {
                var keys = Object.keys(this.qtIdPairs[position.lineNumber])
                delete this.qtQuick.qtSuggestions.functionSuggestions[keys[0]]
                delete this.qtQuick.qtSuggestions.qtObjectKeyValues[keys[0]]
                if (!this.qtQuick.qtSuggestions.qtObjectKeyValues.hasOwnProperty(type)) {
                    type = "Item"
                }
                this.qtIdPairs[position.lineNumber][idText] = type
                var arr = []
                arr = arr.concat(this.qtQuick.qtHelper.removeDuplicates(this.qtQuick.qtHelper.removeOnCalls(this.qtQuick.qtSuggestions.qtObjectKeyValues[this.qtIdPairs[position.lineNumber][idText]].properties)))
                arr = arr.concat(this.qtQuick.qtHelper.removeDuplicates(this.qtQuick.qtSuggestions.qtObjectSuggestions[this.qtIdPairs[position.lineNumber][idText]].functions))
                arr = arr.concat(this.qtQuick.qtSuggestions.qtObjectSuggestions[this.qtIdPairs[position.lineNumber][idText]].signals)
                this.qtQuick.qtSuggestions.createQtObjectValPairs(idText, { label: idText, insertText: idText, properties: arr, flag: true, isId: true })
    
                this.qtQuick.qtSuggestions.functionSuggestions[idText] = {
                    label: this.qtQuick.qtSuggestions.qtObjectKeyValues[idText].label,
                    kind: monaco.languages.CompletionItemKind.Function,
                    insertTextRules: monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet,
                    insertText:this.qtQuick.qtSuggestions. qtObjectKeyValues[idText].insertText,
                    range: null,
                }
            }
        }
    }
}
class QtSuggestions {
    constructor(model, qtQuick) {
        this.model = model
        this.qtQuick = qtQuick
        this.suggestions = {}
        this.functionSuggestions = {}
        this.qtObjectSuggestions = {}
        this.qtImports = []
        this.currentItems = {}
        this.qtObjectKeyValues = {}
        this.qtObjectPropertyValues = {}
        this.qtObjectMetaPropertyValues = {}
        this.functionsAdded = false
        this.initializeQtQuick(this.model)
    }

    update(model) {
        this.model = model
        this.suggestions = {}
        this.functionSuggestions = {}
        this.qtObjectSuggestions = {}
        this.currentItems = {}
        this.qtImports = []
        this.qtObjectKeyValues = {}
        this.qtObjectPropertyValues = {}
        this.qtObjectMetaPropertyValues = {}
        this.functionsAdded = false
        this.initializeQtQuick(this.model)
    }

    // Initializes the library to become an Object array to be feed into suggestions
    initializeQtQuick(model) {
        const firstLine = { lineNumber: this.qtQuick.qtSearch.fullRange.startLineNumber, column: this.qtQuick.qtSearch.fullRange.startColumn }
        var line = { lineNumber: firstLine.lineNumber, column: firstLine.startColumn }
        while (line.lineNumber >= firstLine.lineNumber) {
            var getNextPosition = model.findNextMatch("import", line)
            if (getNextPosition.range.startLineNumber < line.lineNumber) {
                break;
            }
            var lineContent = model.getLineContent(getNextPosition.range.startLineNumber)
            var content = lineContent.replace("\t", "").split("import")[1].trim()
            line = { lineNumber: getNextPosition.range.startLineNumber + 1, column: getNextPosition.range.startColumn }
            this.qtImports.push(content)
        }
        this.createSuggestionsBasedOffImports()
    }

    createSuggestionsBasedOffImports() {
        for (const qtType in qtTypeJson["sources"]) {
            var flag = false
            const qtValues = qtTypeJson['sources'][qtType]
            for (var i = 0; i < this.qtImports.length; i++) {
                if (qtValues.source !== "" && this.qtImports[i].includes(qtValues.source)) {
                    flag = true
                } else if (qtValues.source === "") {
                    flag = true
                }
            }
            if (flag) {
                this.appendInherited(qtType, qtValues)
            }
        }
        this.updateObjectFormat()
        // js functions
        if (!this.functionsAdded) {
            for (const qtCustomProps in qtTypeJson["custom_properties"]) {
                const qtproperties = qtTypeJson["custom_properties"][qtCustomProps]
                this.createQtObjectValPairs(qtCustomProps, { label: qtCustomProps, insertText: qtCustomProps, properties: qtproperties, flag: true })
                this.functionSuggestions[qtCustomProps] = {
                    label: this.qtObjectKeyValues[qtCustomProps].label.trim(),
                    kind: monaco.languages.CompletionItemKind.Keyword,
                    insertTextRules: monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet,
                    insertText: this.qtObjectKeyValues[qtCustomProps].insertText,
                    range: null
                }
            }
            this.functionsAdded = true
        }
    }

    updateObjectFormat() {
        for (const key in this.qtObjectSuggestions) {
            for (const values in this.qtObjectSuggestions[key]["meta"]) {
                if (this.qtObjectSuggestions[key]["meta"][values].length > 0) {
                    if (this.qtObjectMetaPropertyValues[key] === undefined) {
                        this.qtObjectMetaPropertyValues[key] = {}
                    }

                    this.qtObjectMetaPropertyValues[key][values] = this.qtObjectSuggestions[key]["meta"][values]
                }
            }
            var arr = []
            for (var j = 0; j < this.qtObjectSuggestions[key].properties.length; j++) {
                arr.push(this.qtObjectSuggestions[key].properties[j])
            }
            arr = this.qtQuick.qtHelper.removeDuplicates(arr)
            this.createQtObjectValPairs(key, { label: key, insertText: key, properties: arr, flag: false, isId: false })
        }
        for (const key in qtTypeJson) {
            if (key === "property") {
                this.createQtObjectValPairs(key, { label: key, insertText: key, properties: qtTypeJson[key], flag: true, isId: false })
                this.suggestions[key] = {
                    label: this.qtObjectKeyValues[key].label.trim(),
                    kind: monaco.languages.CompletionItemKind.KeyWord,
                    insertTextRules: monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet,
                    insertText: this.qtObjectKeyValues[key].insertText,
                    range: null,
                }
            }
        }
        this.createSuggestions()
    }

    createSuggestions() {
        for (const key in this.qtObjectKeyValues) {
            if (!this.qtObjectKeyValues[key].isId && qtTypeJson["sources"].hasOwnProperty(key) && !qtTypeJson["sources"][key].nonInstantiable) {
                this.suggestions[key] = {
                    label: this.qtObjectKeyValues[key].label.trim(),
                    kind: monaco.languages.CompletionItemKind.Class,
                    insertTextRules: monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet,
                    insertText: this.qtObjectKeyValues[key].insertText,
                    range: null,
                }
            }
        }
    }
    // recursive traversal of Inherited Types
    appendInherited(masterItem, item) {
        //does not inherit from other Items
        if (this.qtObjectSuggestions[masterItem] === undefined) {
            this.qtObjectSuggestions[masterItem] = {}
            this.qtObjectSuggestions[masterItem]["functions"] = []
            this.qtObjectSuggestions[masterItem]["signals"] = []
            this.qtObjectSuggestions[masterItem]["properties"] = []
            this.qtObjectSuggestions[masterItem]["meta"] = {}
        }
        if (item.inherits.length === 0) {
            this.qtObjectSuggestions[masterItem].functions = this.qtObjectSuggestions[masterItem].functions.concat(item.functions)
            this.qtObjectSuggestions[masterItem].signals = this.qtObjectSuggestions[masterItem].signals.concat(item.signals)
            if (item.signals.length > 0 && !qtTypeJson["sources"][masterItem].nonInstantiable) {
                for (var i = 0; i < item.signals.length; i++) {
                    var signalCall = item.signals[i]
                    var onCall = "on" + signalCall[0].toUpperCase() + signalCall.substring(1)
                    onCall = onCall.split("()")[0]
                    this.qtObjectSuggestions[masterItem].properties.push(onCall)
                }
            }
            for (const key in item.properties) {

                this.qtObjectSuggestions[masterItem].properties.push(key)
                if (!qtTypeJson["sources"][masterItem].nonInstantiable) {
                    var onCall = "on" + key[0].toUpperCase() + key.substring(1) + "Changed"
                    this.qtObjectSuggestions[masterItem].properties.push(onCall)
                }
                this.qtObjectSuggestions[masterItem].meta[key] = item.properties[key].meta_properties
            }
            return;
        } else if (qtTypeJson["sources"].hasOwnProperty(item.inherits)) {
            this.appendInherited(masterItem, qtTypeJson["sources"][item.inherits])
            this.qtObjectSuggestions[masterItem].functions = this.qtObjectSuggestions[masterItem].functions.concat(item.functions)
            this.qtObjectSuggestions[masterItem].signals = this.qtObjectSuggestions[masterItem].signals.concat(item.signals)
            if (item.signals.length > 0 && !qtTypeJson["sources"][masterItem].nonInstantiable) {
                for (var i = 0; i < item.signals.length; i++) {
                    var signalCall = item.signals[i]
                    var onCall = "on" + signalCall[0].toUpperCase() + signalCall.substring(1)
                    onCall = onCall.split("()")[0]
                    this.qtObjectSuggestions[masterItem].properties.push(onCall)
                }
            }
            for (const key in item.properties) {
                this.qtObjectSuggestions[masterItem].properties.push(key)
                if (!qtTypeJson["sources"][masterItem].nonInstantiable) {
                    var onCall = "on" + key[0].toUpperCase() + key.substring(1) + "Changed"
                    this.qtObjectSuggestions[masterItem].properties.push(onCall)
                }
                this.qtObjectSuggestions[masterItem].meta[key] = item.properties[key].meta_properties
            }
            return;
        }
    }

     // This is the properties string array conversion to an object array, this has to be done in real time due to the limitations of the monaco editor suggestions
     convertStrArrayToObjArray(key, properties, isProperty = false, isIdReference = false, metaParent = "") {
        var propertySuggestions = []
        this.qtObjectPropertyValues[key] = []

        for (var i = 0; i < properties.length; i++) {
            if (properties[i].includes("()")) {
                propertySuggestions.push(this.qtQuick.qtHelper.createDynamicProperty(properties[i], true))
            } else {
                if (isIdReference || (this.qtObjectMetaPropertyValues.hasOwnProperty(metaParent) && this.qtObjectMetaPropertyValues[metaParent].hasOwnProperty(properties[i]) && this.qtObjectMetaPropertyValues[metaParent][properties[i]].length > 0)) {
                    propertySuggestions.push(this.qtQuick.qtHelper.createDynamicProperty(properties[i], false))
                } else {
                    propertySuggestions.push(this.qtQuick.qtHelper.createDynamicProperty(properties[i] + ": ", false))
                }
            }
        }
        if (!isProperty) {
            this.qtObjectPropertyValues[key] = propertySuggestions.concat(Object.values(this.suggestions))
        } else {
            this.qtObjectPropertyValues[key] = propertySuggestions
        }
    }
    // setting each key val pair for the object
    createQtObjectValPairs(key, val) {
        this.qtObjectKeyValues[key] = val
    }

    retrieveType(model, propRange) {
        var content = model.getLineContent(propRange.startLineNumber)
        var splitContent = content.replace("\t", "").split(/\{|\t/)
        var bracketWord = splitContent[0].trim()
        if (this.qtObjectKeyValues.hasOwnProperty(bracketWord)) {
            this.convertStrArrayToObjArray(bracketWord, qtObjectKeyValues[bracketWord].properties.concat(this.customProperties), qtObjectKeyValues[bracketWord].flag, qtObjectKeyValues[bracketWord].isId, bracketWord)
            if (this.currentItems[bracketWord] === undefined) {
                this.currentItems[bracketWord] = {}
            }
            this.currentItems[bracketWord][propRange] = this.qtObjectPropertyValues[bracketWord]
            return this.currentItems[bracketWord][propRange]
        } else if (bracketWord.includes("function") || bracketWord.substring(0, 2) === "on" || bracketWord.includes("if") || bracketWord.includes("switch") || bracketWord.includes(":")) {
            //display signal Calls, function Calls, ids properties and function,signal, calls
            return Object.values(this.qtQuick.qtSuggestions.functionSuggestions)
        } else {
            const prevParent = this.qtQuick.qtSearch.findPreviousBracketParent({ lineNumber: propRange.startLineNumber - 1, column: propRange.startColumn })
            if (this.qtObjectMetaPropertyValues.hasOwnProperty(prevParent)) {
                this.convertStrArrayToObjArray(bracketWord, this.qtObjectMetaPropertyValues[prevParent][bracketWord], true, true)
                if (this.currentItems[bracketWord] === undefined) {
                    this.currentItems[bracketWord] = {}
                }
                this.currentItems[bracketWord][propRange] = this.qtObjectPropertyValues[bracketWord]
                return this.currentItems[bracketWord][propRange]
            } else {
                const prevParent = this.qtQuick.qtSearch.findPreviousBracketParent({ lineNumber: propRange.startLineNumber - 1, column: propRange.startColumn })
                if (prevParent.includes("function") || prevParent.substring(0, 2) === "on" || prevParent.includes("if")) {
                    return Object.values(this.functionSuggestions)
                }
                const newParent = this.qtQuick.qtSearch.findPreviousBracketParent({ lineNumber: propRange.startLineNumber, column: propRange.startColumn })
                if (this.qtObjectKeyValues.hasOwnProperty(newParent)) {
                    this.convertStrArrayToObjArray(newParent, this.qtObjectKeyValues[newParent].properties, this.qtObjectKeyValues[newParent].flag, this.qtObjectKeyValues[newParent].isId, newParent)
                    if (this.currentItems[newParent] === undefined) {
                        this.currentItems[newParent] = {}
                    }
                    this.currentItems[newParent][propRange] = this.qtObjectPropertyValues[newParent]
                    return this.currentItems[newParent][propRange]
                }
                return Object.values(this.qtQuick.qtSuggestions.suggestions)
            }
        }
    }
}
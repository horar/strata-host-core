// return an object from a string with definable properties
function createDynamicProperty(property, isFunction = false) {
    return {
        label: property,
        kind: !isFunction ? monaco.languages.CompletionItemKind.Keyword : monaco.languages.CompletionItemKind.Function,
        insertTextRules: monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet,
        insertText: property,
        range: null
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

// Initializes the library to become an Object array to be feed into suggestions
function initializeQtQuick(model) {
    suggestions = {}
    functionSuggestions = {}
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
    // js functions
    if (!functionsAdded) {
        for (const qtCustomProps in qtTypeJson["custom_properties"]) {
            const qtproperties = qtTypeJson["custom_properties"][qtCustomProps]
            createQtObjectValPairs(qtCustomProps, { label: qtCustomProps, insertText: qtCustomProps, properties: qtproperties, flag: true })
            functionSuggestions[qtCustomProps] = {
                label: qtObjectKeyValues[qtCustomProps].label.trim(),
                kind: monaco.languages.CompletionItemKind.Keyword,
                insertTextRules: monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet,
                insertText: qtObjectKeyValues[qtCustomProps].insertText,
                range: null
            }
        }
        functionsAdded = true
    }
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
    for (const key in qtTypeJson) {
        if (key === "property") {
            createQtObjectValPairs(key, { label: key, insertText: key, properties: qtTypeJson[key], flag: true, isId: false })
            suggestions[key] = {
                label: qtObjectKeyValues[key].label.trim(),
                kind: monaco.languages.CompletionItemKind.KeyWord,
                insertTextRules: monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet,
                insertText: qtObjectKeyValues[key].insertText,
                range: null,
            }
        }
    }
    createSuggestions()
}

function createSuggestions() {
    for (const key in qtObjectKeyValues) {
        if (!qtObjectKeyValues[key].isId && qtTypeJson["sources"].hasOwnProperty(key) && !qtTypeJson["sources"][key].nonInstantiable) {
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
            if (!qtTypeJson["sources"][masterItem].nonInstantiable) {
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
            if (!qtTypeJson["sources"][masterItem].nonInstantiable) {
                var onCall = "on" + key[0].toUpperCase() + key.substring(1) + "Changed"
                qtObjectSuggestions[masterItem].properties.push(onCall)
            }
            qtObjectSuggestions[masterItem].meta[key] = item.properties[key].meta_properties
        }
        return;
    }
}

function getValue() {
    return editor.getValue();
}

function setValue(value) {
    editor.setValue(value)
}

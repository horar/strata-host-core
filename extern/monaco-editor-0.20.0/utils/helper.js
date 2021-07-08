

// return an object from a string with definable properties
function createDynamicSuggestion(suggestion, type) {
    const uuid = randomUUID()
    switch (type) {
        case "property":
            return {
                label: suggestion,
                kind: monaco.languages.CompletionItemKind.Keyword,
                insertTextRules: monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet,
                insertText: suggestion,
                range: null
            }
        case "function":
            return {
                label: suggestion,
                kind: monaco.languages.CompletionItemKind.Function,
                insertTextRules: monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet,
                insertText: suggestion,
                range: null
            }
        case "item":
            return {
                label: suggestion,
                kind: monaco.languages.CompletionItemKind.Class,
                insertTextRules: monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet,
                insertText: `${suggestion} { // start_${uuid}\n \n} // end_${uuid}`,
                range: null
            }
        case "meta-sub":
            return {
                label: suggestion,
                kind: monaco.languages.CompletionItemKind.Keyword,
                insertTextRules: monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet,
                insertText: suggestion,
                range: null
            }
        case "meta-parent":
            return {
                label: suggestion,
                kind: monaco.languages.CompletionItemKind.Keyword,
                insertTextRules: monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet,
                insertText: `${suggestion} {\n \n}`,
                range: null
            }
        case "slot":
            return {
                label: suggestion,
                kind: monaco.languages.CompletionItemKind.Keyword,
                insertTextRules: monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet,
                insertText: `${suggestion} {\n \n}`,
                range: null
            }
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

function getValue() {
    return editor.getValue();
}

function setValue(value) {
    editor.setValue(value)
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

function isEqual(obj1, obj2) {
    const keys = Object.keys(obj1)
    for (const key of keys) {
        if (obj2[key] !== obj1[key]) {
            return false;
        }
    }

    return true;
}

function addInheritedItems(masterItem, item) {

    const object = {
        properties: Object.keys(qtTypeJson.sources[masterItem].properties),
        signals: qtTypeJson.sources[masterItem].signals,
        metaPropMap: qtTypeJson.sources[masterItem].properties
    }

    object.properties = removeDuplicates(object.properties.concat(Object.keys(qtTypeJson.sources[item].properties)))
    object.signals = removeDuplicates(object.signals.concat(qtTypeJson.sources[item].signals))
    const newObject = Object.assign(object.metaPropMap, qtTypeJson.sources[item].properties)
    object.metaPropMap = newObject

    if (qtTypeJson.sources[item].inherits !== "") {
        return Object.assign(addInheritedItems(masterItem, qtTypeJson.sources[item].inherits), object);
    }

    return object;
}


function getImportedItemList() {
    const itemList = []
    const imports = qtQuickModel.imports
    for (qtObjects in qtTypeJson["sources"]) {
        for (var i = 0; i < imports.length; i++) {
            if ((qtTypeJson["sources"][qtObjects].source === "" || qtTypeJson["sources"][qtObjects].source.includes(imports[i])) && !qtTypeJson["sources"][qtObjects].nonInstantiable) {
                itemList.push(qtObjects)
                break;
            }
        }
    }

    return itemList
}

function randomUUID() {
    var dt = new Date().getTime();
    var uuid = 'xxxxx'.replace(/[xy]/g, function (c) {
        var r = (dt + Math.random() * 16) % 16 | 0;
        dt = Math.floor(dt / 16);
        return (c == 'x' ? r : (r & 0x3 | 0x8)).toString(16);
    });
    return uuid;
}

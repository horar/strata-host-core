

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
        if(obj2[key] !== obj1[key]){
            return false;
        }
    }

    return true;
}

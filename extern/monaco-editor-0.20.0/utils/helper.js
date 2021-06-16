class QtHelper {
    constructor(editor) {
        this.editor = editor
    }

    // return an object from a string with definable properties
    createDynamicProperty(property, isFunction = false) {
        return {
            label: property,
            kind: !isFunction ? monaco.languages.CompletionItemKind.Keyword : monaco.languages.CompletionItemKind.Function,
            insertTextRules: monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet,
            insertText: property,
            range: null
        }
    }
    // filter out duplicate lines
    removeDuplicates(propertySuggestions) {
        return propertySuggestions.sort().filter(function (itm, idx, arr) {
            return !idx || itm !== arr[idx - 1];
        })
    }

    removeOnCalls(properties) {
        return properties.filter(function (itm) {
            return !itm.includes("on")
        })
    }

    getValue() {
        return editor.getValue();
    }

    setValue(value) {
        editor.setValue(value)
    }
}

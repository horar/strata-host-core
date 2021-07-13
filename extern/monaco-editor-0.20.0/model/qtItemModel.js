class QtItemModel {
    constructor() {
        this.id = ""
        this.properties = Object.keys(qtTypeJson.sources["Item"].properties)
        this.signals = Object.keys(qtTypeJson.sources["Item"].signals)
        this.value = "Item"
        this.metaPropMap = qtTypeJson.sources["Item"].properties
        this.metaSignalMap = qtTypeJson.sources["Item"].signals
        this.metaFuncMap = qtTypeJson.sources["Item"].functions
        this.functions = Object.keys(qtTypeJson.sources["Item"].functions)
        this.uuid = ""
    }

    updateFunctions(newFunction, newFunctionObj = {}) {
        if(newFunction.length !== 0) {
            this.functions.push(newFunction)
            this.metaFuncMap = Object.assign(this.metaFuncMap, newFunctionObj)
        }
    }

    updateUUID(newUUID) {
        this.uuid = newUUID
    }

    get currentFunctions() {
        return this.functions
    }

    updateId(newId) {
        if(this.id !== newId){
            this.id = newId
        }
    }

    get currentId() {
        return this.id;
    }

    updateProperties(newProperty, newPropObj = {}) {
        if(newProperty.length !== 0) {
            this.properties.push(newProperty)
            this.metaPropMap = Object.assign(this.metaPropMap, newPropObj)
        }
    }

    get currentProperties() {
        return this.properties
    }

    updateSignals(newSignal, newSignalObj = {}) {
        if(newSignal.length !== 0) {
            this.signals.push(newSignal)
            this.metaSignalMap = Object.assign(this.metaSignalMap, newSignalObj)
        }
    }

    get currentSignals() {
        return this.signals
    }

    updateValue(newValue) {
        if(this.value !== newValue) {
            this.value = newValue
            if(qtTypeJson.sources[this.value] !== undefined) {
                if(qtTypeJson.sources[this.value].inherits !== "") {
                    const inheritObject = addInheritedItems(this.value, qtTypeJson.sources[this.value].inherits)
                    this.properties = inheritObject.properties
                    this.signals = inheritObject.signals
                    this.metaPropMap = inheritObject.metaPropMap
                    this.functions = inheritObject.functions
                    this.metaSignalMap = inheritObject.metaSignalMap
                    this.metaFuncMap = inheritObject.metaFuncMap
                } else {
                    this.properties = Object.keys(qtTypeJson.sources[this.value].properties)
                    this.signals =  Object.keys(qtTypeJson.sources[this.value].signals)
                    this.metaPropMap = qtTypeJson.sources[this.value].properties
                    this.functions = Object.keys(qtTypeJson.sources[this.value].functions)
                    this.metaSignalMap = qtTypeJson.sources[this.value].signals
                    this.metaFuncMap = qtTypeJson.sources[this.value].functions
                }

            } else {
                this.properties = []
                this.signals = []
                this.metaPropMap = {}
                this.metaFuncMap = {}
                this.functions = []
                this.metaSignalMap = {}
            }
        }
    }

    get currentValue() {
        return this.value
    }

    get currentMetaPropertyMap() {
        return this.metaPropMap
    }
}
class QtItemModel {
    constructor() {
        this.id = ""
        this.properties = Object.keys(qtTypeJson.sources["Item"].properties)
        this.signals = qtTypeJson.sources["Item"].signals
        this.value = "Item"
        this.metaPropMap = qtTypeJson.sources["Item"].properties
        this.functions = []
        this.uuid = ""
    }

    updateFunctions(newFunction) {
        if(newFunction.length !== 0) {
            this.functions.push(newFunction)
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

    updateProperties(newProperty) {
        if(newProperty.length !== 0) {
            this.properties.push(newProperty)
        }
    }

    get currentProperties() {
        return this.properties
    }

    updateSignals(newSignal) {
        if(newSignal.length !== 0) {
            this.signals.push(newSignal)
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
                } else {
                    this.properties = Object.keys(qtTypeJson.sources[this.value].properties)
                    this.signals = qtTypeJson.sources[this.value].signals
                    this.metaPropMap = qtTypeJson.sources[this.value].properties
                }

            } else {
                this.properties = []
                this.signals = []
                this.metaPropMap = {}
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
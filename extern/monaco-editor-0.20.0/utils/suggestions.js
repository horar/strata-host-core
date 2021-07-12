class QtSuggestions {
    constructor() {
        this.suggestions = []
    }

    update(position) {
        this.suggestions = []
        this.determineSuggestions(position)
    }

    getQtItemGlobalSuggestions(itemUUID) {
        const getOtherGlobals = getImportedItemList();
        const getItem = qtQuickModel.fetchItem(itemUUID)
        if(getItem === undefined) {
            return;
        }
        const itemProperties = getItem.properties
        const itemSignals = getItem.signals

        const regPropArr = []
        const metaPropArr = []
        const slotPropArr = []
        const slotSignalArr = []
        this.createSuggestions(getOtherGlobals,"item")
        // distinguishes the regular properties from properties that have subtypes
        for(var i = 0; i < itemProperties.length; i++) {
            if(getItem.metaPropMap[itemProperties[i]] !== undefined && getItem.metaPropMap[itemProperties[i]]["meta_properties"].length !== 0) {
                metaPropArr.push(itemProperties[i])
            } else {
                regPropArr.push(itemProperties[i])
            }
        }

        for (var i = 0; i < itemProperties.length; i++) {
            const slot = itemProperties[i].charAt(0).toUpperCase() + itemProperties[i].slice(1);
            slotPropArr.push(`on${slot}Changed:`)
        }

        for (var i = 0; i < itemSignals.length; i++) {
            const slot = itemSignals[i].charAt(0).toUpperCase() + itemSignals[i].slice(1).split("(")[0].trim();
            slotSignalArr.push(`on${slot}:`)
        }

        this.createSuggestions(removeDuplicates(regPropArr),"property")
        this.createSuggestions(metaPropArr, "meta-parent")
        this.createSuggestions(removeDuplicates(slotPropArr),"slot")
        this.createSuggestions(removeDuplicates(slotSignalArr), "slot")
    }

    getMetaPropertySuggestions(uuid,propertyName) {
        const getItem = qtQuickModel.fetchItem(uuid)
        const metaArray = getItem.metaPropMap[propertyName]["meta_properties"]
        if(metaArray !== undefined && metaArray.length !== 0) {
            this.createSuggestions(metaArray,"meta-sub")
        }
    }

    getFunctionGlobalSuggestions(uuid, which, value) {
        const idKeys = []
        let map = {}
        for(const key of Object.keys(qtQuickModel.model)) {
            const item = qtQuickModel.fetchItem(key)
            if(item.id !== ""){
                idKeys.push(item.id)
            }
        }


        const getItem = qtQuickModel.fetchItem(uuid)
        const properties = getItem.properties
        const signals = getItem.signals
        const functions = getItem.functions
        if(which === "slot") {
            map = getItem.metaSignalMap
        } else {
            map = getItem.metaFuncMap
        }

        if(map.hasOwnProperty(value) && map[value].params_name.length !== 0) {
            this.createSuggestions(map[value].params_name,"parameter")
        }

        const custom_functions = Object.keys(qtTypeJson["custom_properties"])

        this.createSuggestions(removeDuplicates(properties),"property")
        this.createSuggestions(removeDuplicates(signals), "function")
        this.createSuggestions(removeDuplicates(functions), "function")
        this.createSuggestions(removeDuplicates(idKeys), "property")
        this.createSuggestions(removeDuplicates(custom_functions), "function")
    }

    createSuggestions(arr,type="item") {
        for(let i = 0; i < arr.length; i++) {
            this.suggestions.push(createDynamicSuggestion(arr[i],type))
        }
    }

    get currentSuggestions() {
       return this.suggestions
    }

    determineSuggestions(position) {
        if(Object.keys(qtQuickModel.model).length !== 0) {
        const checkLine = qtSearch.model.getLineContent(position.lineNumber)
        const checkProperty = qtSearch.isInMetaProperty(position)
        const checkFunction = qtSearch.isInFunction(position)
        const checkSlot = qtSearch.isInSlot(position)
        const itemCheck = qtSearch.fetchParentItem(position, position)
        if(checkLine.includes(".")) {
            const checkSub = checkLine.split(".")[0].trim()
            this.determineSubProperties(checkSub)
            return;
        }
        if(checkProperty || checkFunction || checkSlot) {
            if(checkProperty) {
                const propertyLineNumber = qtSearch.findPreviousMetaPropertyParent(position)
                const propertyName = qtSearch.getMetaPropertyParent(propertyLineNumber.range.startLineNumber)
                this.getMetaPropertySuggestions(itemCheck.uuid, propertyName)
            } else if(checkFunction || checkSlot) {
                if(checkSlot) {
                    const slot = qtSearch.findPreviousSlot(position)
                    const slotName = qtSearch.getSlotName(slot.range.startLineNumber)
                    this.getFunctionGlobalSuggestions(itemCheck.uuid, "slot", slotName)
                } else {
                    const func = qtSearch.findPreviousFunction(position)
                    const funcName = qtSearch.getFunc(func.range.startLineNumber)
                    this.getFunctionGlobalSuggestions(itemCheck.uuid, "func", funcName.name)
                }
            }
            return;
        }
        this.getQtItemGlobalSuggestions(itemCheck.uuid)
        } else {
            const getOtherGlobals = getImportedItemList();
            this.createSuggestions(getOtherGlobals,"item")
        }
    }

    determineSubProperties(checkSub) {
        for(const key of Object.keys(qtQuickModel.model)) {
            const item = qtQuickModel.fetchItem(key)
            if(item.id === checkSub) {
                this.createSuggestions(item.properties,"property")
                return;
            }
            for(const property of item.properties) {
                if(item.metaPropMap.hasOwnProperty(property) && item.metaPropMap[property]["meta_properties"].length !== 0 && checkSub === property) {
                    this.createSuggestions(item.metaPropMap[property]["meta_properties"],"property")
                    return;
                }
            }
        }

        for(const customs of Object.keys(qtTypeJson["custom_properties"])) {
            if(checkSub === customs) {
                this.createSuggestions(qtTypeJson["custom_properties"][customs],"function")
                break;
            }
        }
    }
}

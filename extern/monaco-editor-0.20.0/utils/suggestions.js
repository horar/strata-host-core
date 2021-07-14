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
        if (getItem === undefined) {
            return;
        }
        const itemProperties = removeDefaults(getItem.properties, "property")
        const itemSignals = removeDefaults(getItem.signals, "signal")

        const regPropArr = []
        const metaPropArr = []
        const slotPropArr = []
        const slotSignalArr = []
        this.createSuggestions(getOtherGlobals, "item")
        // distinguishes the regular properties from properties that have subtypes
        for (var i = 0; i < itemProperties.length; i++) {
            if (getItem.metaPropMap[itemProperties[i]] !== undefined && getItem.metaPropMap[itemProperties[i]]["meta_properties"].length !== 0) {
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

        this.createSuggestions(removeDuplicates(regPropArr), "property")
        this.createSuggestions(metaPropArr, "meta-parent")
        this.createSuggestions(removeDuplicates(slotPropArr), "slot")
        this.createSuggestions(removeDuplicates(slotSignalArr), "slot")
    }

    getMetaPropertySuggestions(uuid, propertyName) {
        const getItem = qtQuickModel.fetchItem(uuid)
        const metaArray = getItem.metaPropMap[propertyName]["meta_properties"]
        if (metaArray !== undefined && metaArray.length !== 0) {
            this.createSuggestions(metaArray, "meta-sub")
        }
    }

    getFunctionGlobalSuggestions(uuid, which, value) {
        const idKeys = []
        let map = {}
        for (const key of Object.keys(qtQuickModel.model)) {
            const item = qtQuickModel.fetchItem(key)
            if (item.id !== "") {
                idKeys.push(item.id)
            }
        }


        const getItem = qtQuickModel.fetchItem(uuid)
        const properties = removeDefaults(getItem.properties, "property")
        const signals = removeDefaults(getItem.signals, "signal")
        const functions = removeDefaults(getItem.functions, "function")
        if (which === "slot") {
            map = getItem.metaSignalMap
            if (map.hasOwnProperty(value) && map[value].params_name.length !== 0) {
                this.createSuggestions(map[value].params_name, "parameter")
            }
            this.createSuggestions(removeDuplicates(signals), "function", map)
        } else {
            map = getItem.metaFuncMap
            if (map.hasOwnProperty(value) && map[value].params_name.length !== 0) {
                this.createSuggestions(map[value].params_name, "parameter")
            }
            this.createSuggestions(removeDuplicates(functions), "function", map)
        }


        const custom_functions = Object.keys(qtTypeJson["custom_properties"])

        this.createSuggestions(removeDuplicates(properties), "property")
        this.createSuggestions(removeDuplicates(idKeys), "property")
        this.createSuggestions(removeDuplicates(custom_functions), "item")
    }

    createSuggestions(arr, type = "item", map = {}) {
        for (let i = 0; i < arr.length; i++) {
            if (type === "function" && Object.keys(map).length !== 0) {
                if (map.hasOwnProperty(arr[i])) {
                    this.suggestions.push(createDynamicSuggestion(arr[i], type, map[arr[i]].params_name))
                } else {
                    this.suggestions.push(createDynamicSuggestion(arr[i], type))
                }
            } else {
                this.suggestions.push(createDynamicSuggestion(arr[i], type))
            }
        }
    }

    get currentSuggestions() {
        return this.suggestions
    }

    determineSuggestions(position) {
        if (position.lineNumber > qtSearch.topOfFile.range.startLineNumber) {
            const checkLine = qtSearch.model.getLineContent(position.lineNumber)
            const checkProperty = qtSearch.isInMetaProperty(position)
            const checkFunction = qtSearch.isInFunction(position)
            const checkSlot = qtSearch.isInSlot(position)
            const itemCheck = qtSearch.fetchParentItem(position, position)
            if (checkLine.includes(".")) {
                const checkSub = checkLine.split(".")[0].trim()
                this.determineSubProperties(checkSub)
                return;
            }
            if (checkProperty || checkFunction || checkSlot) {
                if (checkProperty) {
                    const propertyLineNumber = qtSearch.findPreviousMetaPropertyParent(position)
                    const propertyName = qtSearch.getMetaPropertyParent(propertyLineNumber.range.startLineNumber)
                    this.getMetaPropertySuggestions(itemCheck.uuid, propertyName)
                } else if (checkFunction || checkSlot) {
                    if (checkSlot) {
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
            this.createSuggestions(["import"], "property")
            const checkLine = qtSearch.model.getLineContent(position.lineNumber)
            if (checkLine.includes("import") && !checkLine.includes(".")) {
                this.createSuggestions(Object.keys(qtTypeJson["import_statements"]), "property")
            } else if (checkLine.includes("import") && checkLine.includes(".")) {
                const initialName = qtSearch.getImportName(position.lineNumber).split(".")[0].trim()
                const subNames = Object.keys(qtTypeJson["import_statements"][initialName]["subTypes"])
                const vers = qtTypeJson["import_statements"][initialName]["ver"]
                if (subNames !== undefined) {
                    this.createSuggestions(subNames, "property")
                }
                this.createSuggestions(vers, "property")
                if (subNames !== undefined) {
                    for (var i = 0; i < subNames.length; i++) {
                        if (checkLine.includes("import") && checkLine.includes(".") && checkLine.includes(subNames[i])) {
                            this.suggestions = []
                            this.createSuggestions(qtTypeJson["import_statements"][initialName]["subTypes"][subNames[i]]["ver"], "property")
                            break;
                        }
                    }
                }
            }
        }
    }

    determineSubProperties(checkSub) {
        for (const key of Object.keys(qtQuickModel.model)) {
            const item = qtQuickModel.fetchItem(key)
            if (item.id === checkSub) {
                this.createSuggestions(item.properties, "property")
                return;
            }
            for (const property of item.properties) {
                if (item.metaPropMap.hasOwnProperty(property) && item.metaPropMap[property]["meta_properties"].length !== 0 && checkSub === property) {
                    this.createSuggestions(item.metaPropMap[property]["meta_properties"], "property")
                    return;
                }
            }
        }

        for (const customs of Object.keys(qtTypeJson["custom_properties"])) {
            if (checkSub === customs) {
                this.createSuggestions(qtTypeJson["custom_properties"][customs], "property")
                break;
            }
        }
    }
}

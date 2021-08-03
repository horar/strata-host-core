// Searches for the parent Item based off of the end column of a sibling item, this searches up and checks for time where the current line number is a child of the item

// This searches and determines where the position lies within each child Item, so that the correct Qt file class is returned

class QtSearch {

    constructor() {
        this.model = null
        this.fullRange = {}
        this.topOfFile = {}
        this.bottomOfFile = {}
    }

    update(model) {
        qtQuickModel.resetModel()
        this.model = model
        this.fullRange = model.getFullModelRange()
        this.topOfFile = model.findNextMatch("{", { lineNumber: this.fullRange.startLineNumber, column: this.fullRange.startColumn })
        this.bottomOfFile = model.findPreviousMatch("}", { lineNumber: this.fullRange.endLineNumber, column: this.fullRange.endColumn })
        this.createQtModel()
    }

    get currentFullRange() {
        return this.fullRange
    }

    get currentTopOfFile() {
        return this.topOfFile
    }

    get currentBottomOfFile() {
        return this.bottomOfFile
    }

    getNextCloseBracket(position) {
        return this.model.findNextMatch("}", position)
    }

    getPrevOpenBracket(position) {
        return this.model.findPreviousMatch("{", position)
    }

    getNextOpenBracket(position) {
        return this.model.findNextMatch("{", position)
    }

    getPrevCloseBracket(position) {
        return this.model.findPreviousMatch("}", position)
    }

    comparePositions(pos1, pos2) {
        if (isEqual(pos1, pos2)) {
            return true
        } else {
            return false
        }
    }

    findPreviousQtItem(position) {
        return this.model.findPreviousMatch(/([a-zA-Z0-9_]+)[\.]*([A-Z]+[a-zA-Z0-9_]*)*\s*(\{\n*)/, position, true, true)
    }

    findNextQtItem(position) {
        return this.model.findNextMatch(/([a-zA-Z0-9_]+)[\.]*([a-zA-Z0-9_]+)*\s*(\{\n*)/, position, true, true)
    }

    findNextFunction(position) {
        return this.model.findNextMatch(/(function)+\s*/, position, true)
    }

    findPreviousFunction(position) {
        return this.model.findPreviousMatch(/(function)+\s/, position, true)
    }

    findPreviousId(position) {
        return this.model.findPreviousMatch(/\s(id)+/, position, true)
    }

    findNextId(position) {
        return this.model.findNextMatch(/\s(id)+/, position, true)
    }

    findPreviousProperty(position) {
        return this.model.findPreviousMatch(/\s(property)+\s/, position, true)
    }

    findNextProperty(position) {
        return this.model.findNextMatch(/\s(property)+\s/, position, true)
    }

    findPreviousSignal(position) {
        return this.model.findPreviousMatch(/\s(signal)+\s/, position, true)
    }

    findNextSignal(position) {
        return this.model.findNextMatch(/\s(signal)+\s/, position, true)
    }

    findPreviousSlot(position) {
        return this.model.findPreviousMatch(/(on)+([A-Z]+[a-zA-Z0-9_]*)/, position, true, true)
    }

    findNextSlot(position) {
        return this.model.findNextMatch(/(on)+([A-Z]+[a-zA-Z0-9_]*)/, position, true, true)
    }

    findNextImport(position) {
        return this.model.findNextMatch(/(import)+\s+(.*)/, position, true)
    }

    findPreviousImport(position) {
        return this.model.findPreviousMatch(/(import)+\s+(.*)/, position, true)
    }

    findPreviousStartUUID(position, uuid) {
        return this.model.findPreviousMatch(`start_${uuid}`, position)
    }

    findNextStartUUID(position, uuid) {
        return this.model.findNextMatch(`start_${uuid}`, position)
    }

    findPreviousEndUUID(position, uuid) {
        return this.model.findPreviousMatch(`end_${uuid}`, position)
    }

    findNextEndUUID(position, uuid) {
        return this.model.findNextMatch(`end_${uuid}`, position)
    }

    findPreviousMetaPropertyParent(position) {
        return this.model.findPreviousMatch(/([a-z]+\s*\{)/, position, true, true)
    }

    findNextMetaPropertyParent(position) {
        return this.model.findNextMatch(/([a-z]+\s*\{)/, position, true, true)
    }

    findPreviousExpandedProperty(position) {
        return this.model.findPreviousMatch(/([a-z]+\s*\:\s*\{)/, position, true)
    }

    findNextExpandedProperty(position) {
        return this.model.findNextMatch(/([a-z]+\s*\:\s*\{)/, position, true)
    }

    getNextQtItem(position) {
        const itemLine = this.findNextQtItem(position)
        const getItem = this.model.getLineContent(itemLine.range.startLineNumber).trim().split(/[\s*\{|\s+]/)[0].trim()
        return { item: getItem, range: itemLine.range }
    }
    getPrevQtItem(position) {
        const itemLine = this.findPreviousQtItem(position)
        const getItem = this.model.getLineContent(itemLine.range.startLineNumber).trim().split(/[\s*\{|\s+]/)[0].trim()
        return { item: getItem, range: itemLine.range }
    }

    getNextIdName(position) {
        const idLine = this.findNextId(position)
        if (idLine === null) {
            return "this";
        }
        return this.model.getLineContent(idLine.range.startLineNumber).trim().split("id:")[1].trim()
    }

    getPrevIdName(position) {
        const idLine = this.findPreviousId(position)
        return this.model.getLineContent(idLine.range.startLineNumber).trim().split("id:")[1].trim()
    }

    getPropertyName(lineNumber) {
        const propLine = this.model.getLineContent(lineNumber)
        const splitString = propLine.trim().split("property")[1].trim()
        try {
            const splitDescript = splitString.trim().split(/[a-zA-Z0-9_]+\s+/)[1].trim()
            const splitColonOrEnd = splitDescript.trim().split(/((\:|\n))/)[0].trim()
            return splitColonOrEnd
        } catch (error) {
            return ""
        }
    }

    getMetaPropertyParent(lineNumber) {
        const propLine = this.model.getLineContent(lineNumber)
        const splitString = propLine.split("{")[0].trim()
        return splitString
    }

    getSignal(lineNumber) {
        const signalLine = this.model.getLineContent(lineNumber)
        const splitString = signalLine.trim().split("signal")[1].trim()
        try {
            const removeOpen = splitString.trim().split("(")[0].trim()
            const getParams = splitString.trim().split("(")[1].trim().split(")")[0].trim()
            const params = getParams.split(" ")
            const grabParam = {}
            grabParam[removeOpen] = {
                "params_name": []
            }

            for (var i = 0; i < params.length; i++) {
                if ((i + 1) % 2 === 0) {
                    if (params[i].includes(",")) {
                        grabParam[removeOpen].params_name.push(params[i].split(",")[0].trim())
                    } else {
                        grabParam[removeOpen].params_name.push(params[i].trim())
                    }
                }
            }

            return { name: removeOpen, data: grabParam }
        } catch (error) {
            return { name: "", data: {} }
        }
    }

    getImportName(lineNumber) {
        const importLine = this.model.getLineContent(lineNumber)
        const splitString = importLine.split("import")[1]
        let asEndCheck = splitString.split("as")[0];
        if (asEndCheck !== null) {
            return asEndCheck.trim()
        }
        return splitString.trim()
    }

    getSlotName(lineNumber) {
        const slotLine = this.model.getLineContent(lineNumber)
        const splitString = slotLine.split("on")[1].split(":")[0].trim()
        const slotName = splitString.charAt(0).toLowerCase() + splitString.slice(1)
        return slotName
    }

    getFunc(lineNumber) {
        const funcLine = this.model.getLineContent(lineNumber)
        const splitString = funcLine.split("function")[1].split("(")[0].trim()
        try {
            const removeOpen = splitString.trim().split("(")[0].trim()
            const getParams = funcLine.split("(")[1].split(")")[0].trim()
            const params = getParams.split(" ")
            const grabParam = {}
            grabParam[removeOpen] = {
                "params_name": []
            }

            for (var i = 0; i < params.length; i++) {
                if (params[i].includes(",")) {
                    grabParam[removeOpen].params_name.push(params[i].split(",")[0].trim())
                } else {
                    grabParam[removeOpen].params_name.push(params[i].trim())
                }
            }

            return { name: removeOpen, data: grabParam }
        } catch (error) {
            return { name: "", data: {} }
        }
    }

    isInExpandedProperty(position) {
        const checkPrev = this.findPreviousExpandedProperty(position)
        if (checkPrev === null) {
            return false;
        }

        let nextCheck = this.getNextCloseBracket({ lineNumber: checkPrev.range.startLineNumber, column: checkPrev.range.startColumn })
        while (nextCheck.range.startColumn >= checkPrev.range.startColumn) {
            if (nextCheck.range.startColumn === checkPrev.range.startColumn) {
                break;
            }
            const check = this.getNextCloseBracket({ lineNumber: nextCheck.range.startLineNumber, column: nextCheck.range.endColumn })
            nextCheck = check
        }

        if (position.lineNumber <= nextCheck.range.startLineNumber && position.lineNumber >= checkPrev.range.startLineNumber) {
            if (position.lineNumber === nextCheck.range.startLineNumber && position.column < nextCheck.range.startColumn) {
                return true
            } else if (position.lineNumber === checkPrev.range.startLineNumber && position.column > checkPrev.range.endColumn) {
                return true
            } else if (position.lineNumber < nextCheck.range.startLineNumber && position.lineNumber > checkPrev.range.startLineNumber) {
                return true
            }
        }

        return false;
    }


    isInItem(position) {
        const checkItem = this.getPrevQtItem(position)
        const getItem = qtQuickModel.fetchItem(checkItem.range.startLineNumber)

        if (checkItem.range === null) {
            return false;
        }

        if (position.lineNumber <= getItem.range.endLineNumber) {
            return true;
        } else {
            return false;
        }
    }

    isInMetaProperty(position) {
        const checkPrev = this.findPreviousMetaPropertyParent(position)
        if (checkPrev === null) {
            return false;
        }
        const checkIfIsProperty = this.model.getLineContent(checkPrev.range.startLineNumber)
        if (/[A-Z]/.test(checkIfIsProperty)) {
            return false;
        }
        let nextCheck = this.getNextCloseBracket({ lineNumber: checkPrev.range.startLineNumber, column: checkPrev.range.startColumn })
        while (nextCheck.range.startColumn >= checkPrev.range.startColumn) {
            if (nextCheck.range.startColumn === checkPrev.range.startColumn) {
                break;
            }
            const check = this.getNextCloseBracket({ lineNumber: nextCheck.range.startLineNumber, column: nextCheck.range.endColumn })
            nextCheck = check
        }

        if (position.lineNumber <= nextCheck.range.startLineNumber && position.lineNumber >= checkPrev.range.startLineNumber) {
            if (position.lineNumber === nextCheck.range.startLineNumber && position.column < nextCheck.range.startColumn) {
                return true
            } else if (position.lineNumber === checkPrev.range.startLineNumber && position.column > checkPrev.range.endColumn) {
                return true
            } else if (position.lineNumber < nextCheck.range.startLineNumber && position.lineNumber > checkPrev.range.startLineNumber) {
                return true
            }
        }

        return false;
    }

    isInFunction(position) {
        const checkPrev = this.findPreviousFunction(position)
        if (checkPrev === null) {
            return false;
        }
        let nextCheck = this.getNextCloseBracket({ lineNumber: checkPrev.range.startLineNumber, column: checkPrev.range.startColumn })
        while (nextCheck.range.startColumn >= checkPrev.range.startColumn) {
            if (nextCheck.range.startColumn === checkPrev.range.startColumn) {
                break;
            }
            const check = this.getNextCloseBracket({ lineNumber: nextCheck.range.startLineNumber, column: nextCheck.range.endColumn })
            nextCheck = check
        }

        if (position.lineNumber <= nextCheck.range.startLineNumber && position.lineNumber >= checkPrev.range.startLineNumber) {
            if (position.lineNumber === nextCheck.range.startLineNumber && position.column < nextCheck.range.startColumn) {
                return true
            } else if (position.lineNumber === checkPrev.range.startLineNumber && position.column > checkPrev.range.endColumn) {
                return true
            } else if (position.lineNumber < nextCheck.range.startLineNumber && position.lineNumber > checkPrev.range.startLineNumber) {
                return true
            }
        }

        return false;
    }

    isInSlot(position) {
        const checkPrev = this.findPreviousSlot(position)
        if (checkPrev === null) {
            return false;
        }
        let nextCheck = this.getNextCloseBracket({ lineNumber: checkPrev.range.startLineNumber, column: checkPrev.range.startColumn })
        while (nextCheck.range.startColumn >= checkPrev.range.startColumn) {
            if (nextCheck.range.startColumn === checkPrev.range.startColumn) {
                break;
            }
            const check = this.getNextCloseBracket({ lineNumber: nextCheck.range.startLineNumber, column: nextCheck.range.endColumn })
            nextCheck = check
        }

        if (position.lineNumber <= nextCheck.range.startLineNumber && position.lineNumber >= checkPrev.range.startLineNumber) {
            if (position.lineNumber === nextCheck.range.startLineNumber && position.column < nextCheck.range.startColumn) {
                return true
            } else if (position.lineNumber === checkPrev.range.startLineNumber && position.column > checkPrev.range.endColumn) {
                return true
            } else if (position.lineNumber < nextCheck.range.startLineNumber && position.lineNumber > checkPrev.range.startLineNumber) {
                return true
            }
        }

        return false;
    }


    createQtModel() {
        try {
            if (this.topOfFile !== null && this.bottomOfFile !== null) {
                const position = { lineNumber: this.topOfFile.range.startLineNumber - 1, column: this.topOfFile.range.startColumn }
                this.getItems(position)
                this.addProperty(position)
                this.addSignal(position)
                this.addFunction(position)
            }
            this.addImports()
        } catch (error) {
            console.log(error)
        }
    }

    getItems(initialPosition) {
        let position = initialPosition

        while (position.lineNumber < this.bottomOfFile.range.startLineNumber) {
            const newItem = this.getNextQtItem(position)
            try {
                const itemModel = new QtItemModel();
                if (/[A-Z]/.test(newItem.item)) {
                    itemModel.updateValue(newItem.item);
                    const itemRange = this.findMatchingBracket({ lineNumber: newItem.range.startLineNumber, column: newItem.range.startColumn })
                    const nextId = this.getNextIdName({ lineNumber: newItem.range.startLineNumber, column: newItem.range.startColumn })
                    itemModel.updateId(nextId)
                    itemModel.updateRange(itemRange)
                    qtQuickModel.updateQtModel(newItem.range.startLineNumber, itemModel)
                }
                const checkNext = this.findNextQtItem(position)
                if (checkNext.range === null) {
                    break
                }
                if (checkNext.range.startLineNumber <= position.lineNumber) {
                    break;
                }
                position = { lineNumber: newItem.range.startLineNumber, column: newItem.range.endColumn }

            } catch (error) {
                console.log(`(search.js) function -> getItems: ${error}`)
                break;
            }
        }
    }

    addId(idPosition) {
        const nextId = this.findNextId(idPosition)
        try {
            const nextIdName = this.getIdName(nextId.range.startLineNumber)
            const checkPrev = this.getPrevQtItem({ lineNumber: nextId.range.startLineNumber, column: nextId.range.startColumn })
            const updateModel = qtQuickModel.fetchItem(checkPrev.range.startLineNumber)
            if (updateModel !== null) {
                updateModel.updateId(nextIdName)
                qtQuickModel.updateQtModel(checkPrev.range.startLineNumber, updateModel)
            }
        } catch (error) {
            console.error(`(search.js) function -> addId: ${error}`)
        }
    }

    addProperty(propertyPosition) {
        let position = propertyPosition
        while (position.lineNumber < this.bottomOfFile.range.startLineNumber) {
            const nextProperty = this.findNextProperty(position)
            try {
                const nextPropertyName = this.getPropertyName(nextProperty.range.startLineNumber)
                const checkPrev = this.fetchParentItem({ lineNumber: nextProperty.range.startLineNumber, column: nextProperty.range.startColumn }, { lineNumber: nextProperty.range.startLineNumber, column: nextProperty.range.startColumn })
                const updateModel = qtQuickModel.fetchItem(checkPrev.range.startLineNumber)
                updateModel.updateProperties(nextPropertyName)
                qtQuickModel.updateQtModel(checkPrev.range.startLineNumber, updateModel)
                const checkNext = this.findNextProperty({ lineNumber: nextProperty.range.startLineNumber, column: nextProperty.range.endColumn });

                if (checkNext.range.startLineNumber <= nextProperty.range.startLineNumber) {
                    break;
                }
                position = { lineNumber: nextProperty.range.startLineNumber, column: nextProperty.range.endColumn }
            } catch (error) {
                break;
            }
        }
    }

    addSignal(initialPosition) {
        let position = initialPosition
        while (position.lineNumber < this.bottomOfFile.range.startLineNumber) {
            const nextSignal = this.findNextSignal(position)
            try {
                const nextSignalData = this.getSignal(nextSignal.range.startLineNumber)
                const checkPrev = this.fetchParentItem({ lineNumber: nextSignal.range.startLineNumber, column: nextSignal.range.startColumn }, { lineNumber: nextSignal.range.startLineNumber, column: nextSignal.range.startColumn })
                const updateModel = qtQuickModel.fetchItem(checkPrev.range.startLineNumber)
                updateModel.updateSignals(nextSignalData.name, nextSignalData.data)
                qtQuickModel.updateQtModel(checkPrev.range.startLineNumber, updateModel)
                const checkNext = this.findNextSignal({ lineNumber: nextSignal.range.startLineNumber, column: nextSignal.range.endColumn });

                if (checkNext.range.startLineNumber <= nextSignal.range.startLineNumber) {
                    break;
                }
                position = { lineNumber: nextSignal.range.startLineNumber, column: nextSignal.range.endColumn }
            } catch (error) {
                break;
            }
        }
    }

    addFunction(initialPosition) {
        let position = initialPosition
        while (position.lineNumber < this.bottomOfFile.range.startLineNumber) {
            const nextFunction = this.findNextFunction(position)
            try {
                const nextFunctionData = this.getFunc(nextFunction.range.startLineNumber)
                const checkPrev = this.fetchParentItem({ lineNumber: nextFunction.range.startLineNumber, column: nextFunction.range.startColumn }, { lineNumber: nextFunction.range.startLineNumber, column: nextFunction.range.startColumn })
                const updateModel = qtQuickModel.fetchItem(checkPrev.range.startLineNumber)
                updateModel.updateFunctions(nextFunctionData.name, nextFunctionData.data)
                qtQuickModel.updateQtModel(checkPrev.range.startLineNumber, updateModel)
                const checkNext = this.findNextFunction({ lineNumber: nextFunction.range.startLineNumber, column: nextFunction.range.endColumn });

                if (checkNext.range.startLineNumber <= nextFunction.range.startLineNumber) {
                    break;
                }
                position = { lineNumber: nextFunction.range.startLineNumber, column: nextFunction.range.endColumn }
            } catch (error) {
                break;
            }
        }
    }

    addImports() {
        const initialImport = this.findNextImport({ lineNumber: 1, column: 1 })
        if (initialImport === null) {
            return;
        }
        const initialImportName = this.getImportName(initialImport.range.startLineNumber)
        qtQuickModel.updateImports(initialImportName)
        let position = { lineNumber: initialImport.range.startLineNumber, column: initialImport.range.endColumn }
        while (position.lineNumber < this.fullRange.endLineNumber) {
            const nextImport = this.findNextImport(position)
            try {
                const nextImportName = this.getImportName(nextImport.range.startLineNumber)
                qtQuickModel.updateImports(nextImportName)
                const checkNext = this.findNextImport(position);
                if (checkNext === null) {
                    break
                }
                if (checkNext.range.startLineNumber <= position.lineNumber) {
                    break;
                }
                position = { lineNumber: nextImport.range.startLineNumber, column: nextImport.range.endColumn }
            } catch (error) {
                console.log(`(search.js) function -> addImports: ${error}`)
                break;
            }
        }
    }

    findMatchingBracket(position) {
        let nextCloseBracket = this.getNextCloseBracket(position)

        while (position.column < nextCloseBracket.range.startColumn) {
            const check = this.getNextCloseBracket({ lineNumber: nextCloseBracket.range.startLineNumber, column: nextCloseBracket.range.endColumn })
            if (nextCloseBracket.range.startColumn === position.column) {
                break
            }
            nextCloseBracket = check
        }

        return {
            startLineNumber: position.lineNumber,
            startColumn: position.column,
            endLineNumber: nextCloseBracket.range.startLineNumber - 1,
            endColumn: nextCloseBracket.range.startColumn
        }
    }


    fetchParentItem(origPosition, newPosition) {
        const checkItem = this.getPrevQtItem(newPosition)
        const getCurrentItem = qtQuickModel.fetchItem(checkItem.range.startLineNumber)
        if (getCurrentItem === null) {
            return;
        }

        if (getCurrentItem !== undefined && (origPosition.lineNumber <= getCurrentItem.range.endLineNumber && origPosition.lineNumber >= getCurrentItem.range.startLineNumber)) {
            return checkItem;
        } else {
            return this.fetchParentItem(origPosition, { lineNumber: checkItem.range.startLineNumber, column: checkItem.range.startColumn })
        }
    }
}

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
        return this.model.findPreviousMatch(/([A-Z]+[a-zA-Z0-9_]*)[\.]*([A-Z]+[a-zA-Z0-9_]*)*\s*(\{\s*\/\/)/, position, true, true)
    }

    findNextQtItem(position) {
        return this.model.findNextMatch(/([A-Z]+[a-zA-Z0-9_]*)[\.]*([A-Z]+[a-zA-Z0-9_]*)*\s*(\{\s*\/\/)/, position, true, true)
    }

    findNextFunction(position) {
        return this.model.findNextMatch(/\s(function)+\s*/, position, true)
    }

    findPreviousFunction(position) {
        return this.model.findPreviousMatch(/\s(function)+\s/, position, true)
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
        return this.model.findPreviousMatch(`end_${uuid}`, position)
    }

    findPreviousMetaPropertyParent(position) {
        return this.model.findPreviousMatch(/([a-z]+\s*\{)/, position, true, true)
    }

    findNextMetaPropertyParent(position) {
        return this.model.findNextMatch(/([a-z]+\s*\{)/, position, true, true)
    }

    getNextQtItem(position) {
        const itemLine = this.findNextQtItem(position)
        const getItem = this.model.getLineContent(itemLine.range.startLineNumber).trim().split(/[\s*\{|\s+]/)[0].trim()
        const getTag = this.model.getLineContent(itemLine.range.startLineNumber).split("//")[1].trim().split("start_")[1].trim()
        return { item: getItem, range: itemLine.range, uuid: getTag}
    }
    getPrevQtItem(position) {
        const itemLine = this.findPreviousQtItem(position)
        const getItem = this.model.getLineContent(itemLine.range.startLineNumber).trim().split(/[\s*\{|\s+]/)[0].trim()
        const getTag = this.model.getLineContent(itemLine.range.startLineNumber).split("//")[1].trim().split("start_")[1].trim()
        return { item: getItem, range: itemLine.range, uuid: getTag}
    }

    getNextIdName(position) {
        const idLine = this.findNextId(position)
        if(idLine === null) {
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
        const splitDescript = splitString.trim().split(/[a-zA-Z0-9_]+\s+/)[1].trim()
        const splitColonOrEnd = splitDescript.trim().split(/((\:|\n))/)[0].trim()
        return splitColonOrEnd
    }

    getMetaPropertyParent(lineNumber) {
        const propLine = this.model.getLineContent(lineNumber)
        const splitString = propLine.split("{")[0].trim()
        return splitString
    }

    getSignal(lineNumber) {
        const signalLine = this.model.getLineContent(lineNumber)
        const splitString = signalLine.trim().split("signal")[1].trim()
        const removeOpen = splitString.trim().split("(")[0].trim()
        const getParams =  splitString.trim().split("(")[1].trim().split(")")[0].trim()
        const params = getParams.split(" ")
        const grabParam = {}
        grabParam[removeOpen] = {
            "params_name": []
        }

        for(var i = 0; i < params.length; i++) {
            if((i + 1) % 2 === 0) {
                if(params[i].includes(",")) {
                    grabParam[removeOpen].params_name.push(params[i].split(",")[0].trim())
                } else {
                    grabParam[removeOpen].params_name.push(params[i].trim())
                }
            }
        }
        
        return {name: removeOpen, data: grabParam }
    }

    getImportName(lineNumber) {
        const importLine = this.model.getLineContent(lineNumber)
        const splitString = importLine.split("import")[1]
        let asEndCheck = splitString.split("as")[0];
        if(asEndCheck !== null) {
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
        const removeOpen = splitString.trim().split("(")[0].trim()
        const getParams =  funcLine.trim().split("(")[1].split(")")[0].trim()
        const params = getParams.split(" ")
        const grabParam = {}
        grabParam[removeOpen] = {
            "params_name": []
        }

        for(var i = 0; i < params.length; i++) {
            if(params[i].includes(",")) {
                grabParam[removeOpen].params_name.push(params[i].split(",")[0].trim())
            } else {
                grabParam[removeOpen].params_name.push(params[i].trim())
            }
        }
        
        return {name: removeOpen, data: grabParam }
    }


    isInItem(position) {
        const checkItem = this.getPrevQtItem(position)
        if(checkItem.range === null) {
            return false;
        }
        const nextTag = this.findNextEndUUID({lineNumber: checkItem.range.startLineNumber, column: checkItem.range.startColumn}, checkItem.uuid)
        if(position.lineNumber <= nextTag.range.startLineNumber) {
            return true;
        } else {
            return false;
        }
    }

    isInMetaProperty(position) {
        const checkPrev = this.findPreviousMetaPropertyParent(position)
        if(checkPrev === null) {
            return false;
        }
        const checkIfIsProperty = this.model.getLineContent(checkPrev.range.startLineNumber)
        if(checkIfIsProperty.includes("//")) {
            return false;
        }
        let nextCheck = this.getNextCloseBracket({lineNumber: checkPrev.range.startLineNumber, column: checkPrev.range.startColumn})
        while(nextCheck.range.startColumn >= checkPrev.range.startColumn) {
            if(nextCheck.range.startColumn === checkPrev.range.startColumn) {
                break;
            }
            const check = this.getNextCloseBracket({lineNumber: nextCheck.range.startLineNumber, column: nextCheck.range.endColumn})
            nextCheck = check
        }

        if(position.lineNumber <= nextCheck.range.startLineNumber && position.lineNumber >= checkPrev.range.startLineNumber) {
            if(position.lineNumber === nextCheck.range.startLineNumber && position.column < nextCheck.range.startColumn) {
                return true
            } else if(position.lineNumber === checkPrev.range.startLineNumber && position.column > checkPrev.range.endColumn) {
                return true
            } else if(position.lineNumber < nextCheck.range.startLineNumber && position.lineNumber > checkPrev.range.startLineNumber) {
                return true
            }
        }

        return false;
    }

    isInFunction(position) {
        const checkPrev = this.findPreviousFunction(position)
        if(checkPrev === null) {
            return false;
        }
        let nextCheck = this.getNextCloseBracket({lineNumber: checkPrev.range.startLineNumber, column: checkPrev.range.startColumn})
        while(nextCheck.range.startColumn >= checkPrev.range.startColumn) {
            if(nextCheck.range.startColumn === checkPrev.range.startColumn) {
                break;
            }
            const check = this.getNextCloseBracket({lineNumber: nextCheck.range.startLineNumber, column: nextCheck.range.endColumn})
            nextCheck = check
        }

        if(position.lineNumber <= nextCheck.range.startLineNumber && position.lineNumber >= checkPrev.range.startLineNumber) {
            if(position.lineNumber === nextCheck.range.startLineNumber && position.column < nextCheck.range.startColumn) {
                return true
            } else if(position.lineNumber === checkPrev.range.startLineNumber && position.column > checkPrev.range.endColumn) {
                return true
            } else if(position.lineNumber < nextCheck.range.startLineNumber && position.lineNumber > checkPrev.range.startLineNumber) {
                return true
            }
        }

        return false;
    }

    isInSlot(position) {
        const checkPrev = this.findPreviousSlot(position)
        if(checkPrev === null) {
            return false;
        }
        let nextCheck = this.getNextCloseBracket({lineNumber: checkPrev.range.startLineNumber, column: checkPrev.range.startColumn})
        while(nextCheck.range.startColumn >= checkPrev.range.startColumn) {
            if(nextCheck.range.startColumn === checkPrev.range.startColumn) {
                break;
            }
            const check = this.getNextCloseBracket({lineNumber: nextCheck.range.startLineNumber, column: nextCheck.range.endColumn})
            nextCheck = check
        }

        if(position.lineNumber <= nextCheck.range.startLineNumber && position.lineNumber >= checkPrev.range.startLineNumber) {
            if(position.lineNumber === nextCheck.range.startLineNumber && position.column < nextCheck.range.startColumn) {
                return true
            } else if(position.lineNumber === checkPrev.range.startLineNumber && position.column > checkPrev.range.endColumn) {
                return true
            } else if(position.lineNumber < nextCheck.range.startLineNumber && position.lineNumber > checkPrev.range.startLineNumber) {
                return true
            }
        }

        return false;
    }


    createQtModel() {
        try {
            if (this.topOfFile !== null  && this.bottomOfFile !== null) {
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
                itemModel.updateValue(newItem.item);
                const nextId = this.getNextIdName({ lineNumber: newItem.range.startLineNumber, column: newItem.range.startColumn })
                itemModel.updateId(nextId)
                itemModel.updateUUID(newItem.uuid)
                qtQuickModel.updateQtModel(newItem.uuid, itemModel)
                const checkNext = this.findNextQtItem(position)
                if(checkNext.range === null) {
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

    addItem(itemPosition) {
        try {
            const itemModel = new QtItemModel();
            itemModel.updateValue(newItem.item);
            const nextId = this.getNextIdName(itemPosition)
            if(nextId !== "") {
                itemModel.updateId(nextId)
            }
            itemModel.updateUUID()
            qtQuickModel.updateQtModel(itemPosition.lineNumber, itemModel)
        } catch (error) {
            break;
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
        while(position.lineNumber < this.bottomOfFile.range.startLineNumber) {
            const nextProperty = this.findNextProperty(position)
            try {
                const nextPropertyName = this.getPropertyName(nextProperty.range.startLineNumber)
                console.log(nextPropertyName)
                const checkPrev = this.getPrevQtItem({ lineNumber: nextProperty.range.startLineNumber, nextProperty: nextProperty.range.startColumn })
                const updateModel = qtQuickModel.fetchItem(checkPrev.uuid)
                updateModel.updateProperties(nextPropertyName)
                qtQuickModel.updateQtModel(checkPrev.uuid, updateModel)
                const checkNext = this.findNextProperty(position);

                if (checkNext.range.startLineNumber <= nextProperty.range.startLineNumber) {
                    break;
                }
                position = { lineNumber: checkPrev.range.startLineNumber, column: checkPrev.range.endColumn }
            } catch (error) {
                console.error(`(search.js) function -> addProperty: ${error}`)
                break;
            }
        }
    }

    addSignal(initialPosition) {
        let position = initialPosition
        while(position.lineNumber < this.bottomOfFile.range.startLineNumber) {
            const nextSignal = this.findNextSignal(position)
            try {
                const nextSignalData = this.getSignal(nextSignal.range.startLineNumber)
                const checkPrev = this.getPrevQtItem({ lineNumber: nextSignal.range.startLineNumber, column: nextSignal.range.startColumn })
                const updateModel = qtQuickModel.fetchItem(checkPrev.uuid)
                updateModel.updateSignals(nextSignalData.name, nextSignalData.data)
                qtQuickModel.updateQtModel(checkPrev.uuid, updateModel)
                const checkNext = this.findNextSignal(position);

                if (checkNext.range.startLineNumber <= nextSignal.range.startLineNumber) {
                    break;
                }
                position = { lineNumber: nextSignal.range.startLineNumber, column: nextSignal.range.endColumn }
            } catch (error) {
                console.error(`(search.js) function -> addSignal: ${error}`)
                break;
            }
        }
    }

    addFunction(initialPosition) {
        let position = initialPosition
        while(position.lineNumber < this.bottomOfFile.range.startLineNumber) {
            const nextFunction = this.findNextFunction(position)
            try {
                const nextFunctionData = this.getFunc(nextFunction.range.startLineNumber)
                const checkPrev = this.getPrevQtItem({ lineNumber: nextFunction.range.startLineNumber, column: nextFunction.range.startColumn })
                const updateModel = qtQuickModel.fetchItem(checkPrev.uuid)
                updateModel.updateFunctions(nextFunctionData.name, nextFunctionData.data)
                qtQuickModel.updateQtModel(checkPrev.uuid, updateModel)
                const checkNext = this.findNextFunction(position);

                if (checkNext.range.startLineNumber <= nextFunction.range.startLineNumber) {
                    break;
                }
                position = { lineNumber: nextFunction.range.startLineNumber, column: nextFunction.range.endColumn }
            } catch (error) {
                console.error(`(search.js) function -> addFunction: ${error}`)
                break;
            }
        }
    }

    addImports() {
        const initialImport = this.findNextImport({lineNumber: 1, column: 1})
        if(initialImport === null) {
            return;
        } 
        let position = {lineNumber: initialImport.range.startLineNumber, column: initialImport.range.startColumn}
        while (position.lineNumber < this.fullRange.endLineNumber) {
            const nextImport = this.findNextImport(position)
            try {
                const nextImportName = this.getImportName(nextImport.range.startLineNumber)
                qtQuickModel.updateImports(nextImportName)
                const checkNext = this.findNextImport(position);
                if(checkNext === null) {
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


    fetchParentItem(origPosition, newPosition) {
        const checkItem = this.getPrevQtItem(newPosition)
        const nextTag = this.findNextEndUUID({lineNumber: checkItem.range.startLineNumber, column: checkItem.range.startColumn}, checkItem.uuid)
        if(nextTag === null) {
            return;
        }
        if(origPosition.lineNumber <= nextTag.range.startLineNumber && origPosition.lineNumber >= checkItem.range.startLineNumber) {
            return checkItem;
        } else {
            return this.fetchParentItem(origPosition, {lineNumber: checkItem.range.startLineNumber, column: checkItem.range.startColumn})
        }
    }
}

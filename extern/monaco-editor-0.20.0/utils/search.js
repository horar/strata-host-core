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
        return this.model.findNextMatch(/\s*((function)+\s*([a-zA-Z0-9]+)\s*\(([a-zA-Z0-9]*(\,)*)*)*\)\s*\{/, position, true, true)
    }

    findPreviousFunction(position) {
        return this.model.findPreviousMatch(/\s*((function)+\s*([a-zA-Z0-9]+)\s*\(([a-zA-Z0-9]*(\,)*)*)*\)\s*\{/, position, true, true)
    }

    findPreviousId(position) {
        return this.model.findPreviousMatch(/\s(id)+/, position, true, true)
    }

    findNextId(position) {
        return this.model.findNextMatch(/\s(id)+/, position, true, true)
    }

    findPreviousProperty(position) {
        return this.model.findPreviousMatch(/((readonly)[^\n]*(property)+\s*[a-zA-Z0-9_]+\s+[a-zA-Z0-9_]+)(\:)*((.*))/, position, true, true)
    }

    findNextProperty(position) {
        return this.model.findNextMatch(/((readonly)[^\n]*(property)+\s*[a-zA-Z0-9_]+\s+[a-zA-Z0-9_]+)(\:)*((.*))/, position, true, true)
    }

    findPreviousSignal(position) {
        return this.model.findPreviousMatch(/(signal)+\s+([a-zA-Z0-9_]+)+\s*(\(((([a-zA-Z0-9_]+\,*)*\s*)*)\))/, position, true, true)
    }

    findNextSignal(position) {
        return this.model.findNextMatch(/(signal)+\s+([a-zA-Z0-9_]+)+\s*(\(((([a-zA-Z0-9_]+\,*)*\s*)*)\))/, position, true, true)
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
        const splitString = propLine.trim().split(/(readonly)*[^\n]*(property)\s+[a-zA-Z0-9_]*\s*/)[1].trim()
        const splitColonOrEnd = splitString.trim().split(/((\:|\n))/)[0].trim()
        return splitColonOrEnd
    }

    getMetaPropertyParent(lineNumber) {
        const propLine = this.model.getLineContent(lineNumber)
        const splitString = propLine.split("{")[0].trim()
        return splitString
    }

    getSignalNames(lineNumber) {
        const signalLine = this.model.getLineContent(lineNumber)
        const splitString = signalLine.trim().split(/(signal)\s+/)[1].trim()
        const removeOpen = splitString.trim().split("(")[0].trim()
        return removeOpen
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
        const checkPrevNext = this.getNextCloseBracket({lineNumber: checkPrev.range.startLineNumber, column: checkPrev.range.startColumn})
        if(checkPrev.range.startLineNumber <= position.lineNumber && checkPrevNext.range.startLineNumber >= position.lineNumber) {
            if(position.lineNumber === checkPrev.range.startLineNumber) {
                return true
            } else if(position.lineNumber === checkPrevNext.range.startLineNumber) {
                if(position.column <= checkPrevNext.range.startColumn) {
                    return true
                } else {
                    return false
                }
            } else {
                return true;
            }
        } else {
            return false;
        }
    }

    isInFunction(position) {
        const checkPrev = this.findPreviousFunction(position)
        if(checkPrev === null) {
            return false;
        }
        const checkPrevNext = this.getNextCloseBracket({lineNumber: checkPrev.range.startLineNumber, column: checkPrev.range.startColumn})
        if(checkPrev.range.startLineNumber <= position.lineNumber && checkPrevNext.range.startLineNumber >= position.lineNumber) {
            if(position.lineNumber === checkPrev.range.startLineNumber) {
                return true
            } else if(position.lineNumber === checkPrevNext.range.startLineNumber) {
                if(position.column <= checkPrevNext.range.startColumn) {
                    return true
                } else {
                    return false
                }
            } else {
                return true;
            }
        } else {
            return false;
        }
    }

    isInSlot(position) {
        const checkPrev = this.findPreviousSlot(position)
        if(checkPrev === null) {
            return false;
        }
        const checkPrevNext = this.getNextCloseBracket({lineNumber: checkPrev.range.startLineNumber, column: checkPrev.range.startColumn})
        if(checkPrev.range.startLineNumber <= position.lineNumber && checkPrevNext.range.startLineNumber >= position.lineNumber) {
            if(position.lineNumber === checkPrev.range.startLineNumber) {
                return true
            } else if(position.lineNumber === checkPrevNext.range.startLineNumber) {
                if(position.column <= checkPrevNext.range.startColumn) {
                    return true
                } else {
                    return false
                }
            } else {
                return true;
            }
        } else {
            return false;
        }
    }


    createQtModel() {
        try {
            const position = { lineNumber: this.topOfFile.range.startLineNumber - 1, column: this.topOfFile.range.startColumn }
            this.getItems(position)
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
        const nextProperty = this.findNextProperty(position)
        try {
            const nextPropertyName = this.getPropertyName(nextProperty.range.startLineNumber)
            const checkPrev = this.getPrevQtItem({ lineNumber: nextProperty.range.startLineNumber, nextProperty: nextProperty.range.startColumn })
            const updateModel = qtQuickModel.fetchItem(checkPrev.range.startLineNumber)
            updateModel.updateProperties(updateModel.currentProperties.concat([nextPropertyName]))
            qtQuickModel.updateQtModel(checkPrev.range.startLineNumber, updateModel)
            const checkNext = this.findNextProperty(position);

            if (checkNext.range.startLineNumber < position.lineNumber) {
                break;
            }
            position = { lineNumber: checkPrev.range.startLineNumber, column: checkPrev.range.endColumn }
        } catch (error) {
            console.error(`(search.js) function -> addProperty: ${error}`)
        }
    }

    addSignal(initialPosition) {
        let position = initialPosition
        const nextSignal = this.findNextSignal(position)
        try {
            const nextSignalName = this.getSignalName(nextSignal.range.startLineNumber)
            const checkPrev = this.getPrevQtItem({ lineNumber: nextSignal.range.startLineNumber, column: nextSignal.range.startColumn })
            const updateModel = qtQuickModel.fetchItem(checkPrev.range.startLineNumber)
            updateModel.updateSignals(updateModel.currentSignals.concat([nextSignalName]))
            qtQuickModel.updateQtModel(checkPrev.range.startLineNumber, updateModel)
            const checkNext = this.findNextSignal(position);

            if (checkNext.range.startLineNumber < position.lineNumber) {
                break;
            }
            position = { lineNumber: checkPrev.range.startLineNumber, column: checkPrev.range.endColumn }
        } catch (error) {
            console.error(`(search.js) function -> addSignal: ${error}`)
        }
    }

    addFunction(initialPosition) {
        let position = initialPosition
        const nextFunction = this.findNextFunction(position)
        try {
            const nextFunctionName = this.getFunctionName(nextFunction.range.startLineNumber)
            const checkPrev = this.getPrevQtItem({ lineNumber: nextSignal.range.startLineNumber, column: nextSignal.range.startColumn })
            const updateModel = qtQuickModel.fetchItem(checkPrev.range.startLineNumber)
            updateModel.updateFunctions(nextFunctionName)
            qtQuickModel.updateQtModel(checkPrev.range.startLineNumber, updateModel)
            const checkNext = this.findNextFunction(position);

            if (checkNext.range.startLineNumber < position.lineNumber) {
                break;
            }
            position = { lineNumber: checkPrev.range.startLineNumber, column: checkPrev.range.endColumn }
        } catch (error) {
            console.log(`(search.js) function -> addFunction: ${error}`)
        }
    }

    addImports() {
        const initialImport = this.findNextImport({lineNumber: 1, column: 1})
        let position = {lineNumber: initialImport.range.startLineNumber, column: initialImport.range.startColumn}
        while (position.lineNumber < this.bottomOfFile.range.startLineNumber) {
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
            }
        }
    }


    fetchParentItem(position) {
        const checkItem = this.getPrevQtItem(position)
        const nextTag = this.findNextEndUUID({lineNumber: checkItem.range.startLineNumber, column: checkItem.range.startColumn}, checkItem.uuid)
        if(position.lineNumber <= nextTag.range.startLineNumber) {
            return checkItem;
        } else {
            return this.fetchParentItem({lineNumber: checkItem.range.startLineNumber, column: checkItem.range.startColumn})
        }
    }
}

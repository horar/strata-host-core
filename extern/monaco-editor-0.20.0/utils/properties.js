function addCustomProperties(lineNumber, item, property) {
    if (!qtPropertyPairs.hasOwnProperty(item)) {
        qtPropertyPairs[item] = {}
        if (!qtPropertyPairs[item].hasOwnProperty(lineNumber)) {
            qtPropertyPairs[item][lineNumber] = property
        }
    } else {
        qtPropertyPairs[item][lineNumber] = property
    }
    if (qtObjectKeyValues.hasOwnProperty(item) && property !== undefined) {
        var onCall = property
        var onCallProperty = "on" + onCall[0].toUpperCase() + onCall.substring(1) + "Changed"
       customProperties.push(onCallProperty)
    }
}

function getPropertyType(model) {
    var position = { lineNumber: fullRange.endLineNumber, column: fullRange.endColumn }
    while (position.lineNumber > fullRange.startLineNumber ) {
        var getPrevPropertyPosition = model.findPreviousMatch("property", position)
        if (getPrevPropertyPosition === null) {
            break;
        }
        if(getPrevPropertyPosition.range.startLineNumber > position.lineNumber){
            break;
        }
        var prevPropertyLine = model.getLineContent(getPrevPropertyPosition.range.startLineNumber).trim()
        if(prevPropertyLine.substring(0,2) === "on"){
            break;
        }
        var prevProperty = prevPropertyLine.split(" ")[2].trim()
        if(prevProperty.includes(":")){
            prevProperty = prevProperty.split(":")[0].trim()
        }

        var getPropertyType = model.findPreviousMatch("{", { lineNumber: getPrevPropertyPosition.range.startLineNumber, column: getPrevPropertyPosition.range.startColumn })
        if (position.lineNumber < getPropertyType.range.startLineNumber) {
            break;
        }
        position = { lineNumber: getPrevPropertyPosition.range.startLineNumber - 1, column: getPrevPropertyPosition.range.startColumn }
        var content = model.getLineContent(position.lineNumber)
        var type = content.replace("\t", "").split(/\{|\t/)[0].trim()
        addCustomProperties(getPrevPropertyPosition.range.startLineNumber, type, prevProperty)
    }
}
// This grabs the Item type from the parent bracket and returns the suggestions
function retrieveType(model, propRange) {
    var content = model.getLineContent(propRange.startLineNumber)
    var splitContent = content.replace("\t", "").split(/\{|\t/)
    var bracketWord = splitContent[0].trim()
    if (qtObjectKeyValues.hasOwnProperty(bracketWord)) {
        convertStrArrayToObjArray(bracketWord, qtObjectKeyValues[bracketWord].properties.concat(customProperties), qtObjectKeyValues[bracketWord].flag, qtObjectKeyValues[bracketWord].isId, bracketWord)
        if (currentItems[bracketWord] === undefined) {
            currentItems[bracketWord] = {}
        }
        currentItems[bracketWord][propRange] = qtObjectPropertyValues[bracketWord]
        return currentItems[bracketWord][propRange]
    } else if (bracketWord.includes("function") || bracketWord.substring(0, 2) === "on" || bracketWord.includes("if") || bracketWord.includes("switch") || bracketWord.includes(":")) {
        //display signal Calls, function Calls, ids properties and function,signal, calls
        return Object.values(functionSuggestions)
    } else {
        const prevParent = findPreviousBracketParent(model, { lineNumber: propRange.startLineNumber - 1, column: propRange.startColumn })
        if (qtObjectMetaPropertyValues.hasOwnProperty(prevParent)) {
            convertStrArrayToObjArray(bracketWord, qtObjectMetaPropertyValues[prevParent][bracketWord], true, true)
            if (currentItems[bracketWord] === undefined) {
                currentItems[bracketWord] = {}
            }
            currentItems[bracketWord][propRange] = qtObjectPropertyValues[bracketWord]
            return currentItems[bracketWord][propRange]
        } else {
            const prevParent = findPreviousBracketParent(model, { lineNumber: propRange.startLineNumber - 1, column: propRange.startColumn })
            if (prevParent.includes("function") || prevParent.substring(0, 2) === "on" || prevParent.includes("if")) {
                return Object.values(functionSuggestions)
            }
            const newParent = findPreviousBracketParent(model, { lineNumber: propRange.startLineNumber, column: propRange.startColumn })
            if (qtObjectKeyValues.hasOwnProperty(newParent)) {
                convertStrArrayToObjArray(newParent, qtObjectKeyValues[newParent].properties, qtObjectKeyValues[newParent].flag, qtObjectKeyValues[newParent].isId, newParent)
                if (currentItems[newParent] === undefined) {
                    currentItems[newParent] = {}
                }
                currentItems[newParent][propRange] = qtObjectPropertyValues[newParent]
                return currentItems[newParent][propRange]
            }
            return Object.values(suggestions)
        }
    }
}

function determineCustomPropertyParents(model, position) {
    // determine custom properties before returning
    customProperties = []
    var startPosition = position
    const previousBracket = model.findPreviousMatch("{", startPosition)
    const prevParent = findPreviousBracketParent(model, position)
    const prevParentBracket = model.findPreviousMatch(prevParent, position)
    var prevNextBracket = previousBracket
    var nextPosition = { lineNumber: prevParentBracket.range.startLineNumber, column: previousBracket.range.startColumn }
    var nextProperty = model.findNextMatch("property", nextPosition)
    var closestTop = matchingBrackets[0].top
    var closestBottom = matchingBrackets[0].bottom
    for( var i = 0; i < matchingBrackets.length; i++){
        if (position.lineNumber <= matchingBrackets[i].bottom && position.lineNumber >= matchingBrackets[i].top) {
            if (closestTop < matchingBrackets[i].top) {
                closestTop = matchingBrackets[i].top
            }
            if (closestBottom > matchingBrackets[i].bottom) {
                closestBottom = matchingBrackets[i].bottom
            }
        }
    }
    if (nextProperty === null) {
        return;
    }
    nextPosition = { lineNumber: nextProperty.range.startLineNumber, column: nextProperty.range.startColumn }
    while (previousBracket.range.startLineNumber === prevNextBracket.range.startLineNumber) {
        if (nextProperty === null) {
            break;
        }
        prevNextBracket = model.findPreviousMatch("{", { lineNumber: nextProperty.range.startLineNumber, column: nextProperty.range.startColumn })
        var getProperty = model.getLineContent(nextPosition.lineNumber)
        if (getProperty === "" || getProperty.trim().replace("\t", "").split(" ")[2] === undefined) {
            break;
        }
        var propertyWord = getProperty.trim().replace("\t", "").split(" ")[2].trim().split(":")[0].trim()
        var getPrevId = model.findPreviousMatch("id:", nextPosition)

        if (getPrevId !== null && getPrevId.range.startLineNumber > previousBracket.range.startLineNumber &&(getPrevId.range.startLineNumber >= closestTop && getPrevId.range.startLineNumber <= closestBottom)) {
            var getLine = model.getLineContent(getPrevId.range.startLineNumber)
            var id = getLine.replace("\t", "").split(":")[1].trim()
            var propertySlot = "on" + propertyWord[0].toUpperCase() + propertyWord.substring(1) + "Changed"
            qtObjectKeyValues[qtIdPairs[getPrevId.range.startLineNumber][id]].properties.push(propertySlot)
            if (otherProperties.hasOwnProperty(id)) {
                otherProperties[id].push(propertyWord)
                otherProperties[id] = removeDuplicates(otherProperties[id])
            } else {
                otherProperties[id] = []
                otherProperties[id].push(propertyWord)
            }
        } else {
            if(position.lineNumber >= closestTop && position.lineNumber <= closestBottom && (nextProperty.range.startLineNumber >= closestTop && nextProperty.range.startLineNumber <= closestBottom)){
                var propertySlot = "on" + propertyWord[0].toUpperCase() + propertyWord.substring(1) + "Changed"
                if(!customProperties.includes(propertySlot)){
                    var getLine = model.getLineContent(closestTop)
                    var getParent = getLine.replace("\t", "").split(/\{|\t/)[0].trim()
                    qtObjectKeyValues[getParent].properties = qtObjectKeyValues[getParent].properties.concat(propertySlot)
                }
            }
        }

        nextPosition = { lineNumber: nextProperty.range.startLineNumber + 1, column: nextProperty.range.startColumn }
        nextProperty = model.findNextMatch("property", nextPosition)
        var checkNextBracket = model.findNextMatch("{", nextPosition)
        if (nextProperty.range.startLineNumber >= checkNextBracket.range.startLineNumber) {
            break
        }
    }
}
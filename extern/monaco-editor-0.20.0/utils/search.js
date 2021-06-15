// Searches for the parent Item based off of the end column of a sibling item, this searches up and checks for time where the current line number is a child of the item
function createMatchingPairs(model) {
    matchingBrackets = []
    matchingBrackets.push({ top: topOfFile.range.startLineNumber, bottom: bottomOfFile.range.startLineNumber })
    var next = getNext(model, { lineNumber: topOfFile.range.startLineNumber, column: topOfFile.range.endColumn })
    var prev = getPrev(model, { lineNumber: next.range.startLineNumber, column: next.range.startColumn })
    while (next.range.startLineNumber < bottomOfFile.range.startLineNumber) {
        var checkNext = getNext(model, { lineNumber: prev.range.startLineNumber, column: prev.range.endColumn })
        if (next.range.startLineNumber === checkNext.range.startLineNumber) {
            matchingBrackets.push({ top: prev.range.startLineNumber, bottom: next.range.startLineNumber })
        } else {
            var initialPosition = { lineNumber: next.range.startLineNumber, column: next.range.startLineNumber }
            var checkPrev = getPrev(model, initialPosition)
            var getLine = model.getLineContent(checkPrev.range.startLineNumber)
            var content = getLine.replace("\t", "").split(/\{|\t/)[0].trim()
            var getWord = model.findPreviousMatch(content, initialPosition)
            while (next.range.startColumn < getWord.range.startColumn) {
                initialPosition = { lineNumber: getWord.range.startLineNumber, column: getWord.range.startColumn }
                checkPrev = getPrev(model, initialPosition)
                getLine = model.getLineContent(checkPrev.range.startLineNumber)
                content = getLine.replace("\t", "").split(/\{|\t/)[0].trim()
                getWord = model.findPreviousMatch(content, initialPosition)
            }
            matchingBrackets.push({ top: getWord.range.startLineNumber, bottom: next.range.startLineNumber })
        }
        next = getNext(model, { lineNumber: next.range.startLineNumber, column: next.range.endColumn })
        prev = getPrev(model, { lineNumber: next.range.startLineNumber, column: next.range.startColumn })
    }
}

function findPreviousBracketParent(model, position) {
    var currentClosestTop = matchingBrackets[0].top
    var currentClosestBottom = matchingBrackets[0].bottom
    for (var i = 0; i < matchingBrackets.length; i++) {
        if (position.lineNumber <= matchingBrackets[i].bottom && position.lineNumber >= matchingBrackets[i].top) {
            if (currentClosestTop < matchingBrackets[i].top) {
                currentClosestTop = matchingBrackets[i].top
            }
            if (currentClosestBottom > matchingBrackets[i].bottom) {
                currentClosestBottom = matchingBrackets[i].bottom
            }
        }
    }
    var getParent = model.getLineContent(currentClosestTop)
    var content = getParent.replace("\t", "").split(/\{|\t/)[0].trim()
    return content
}

function getNext(model, position) {
    return model.findNextMatch("}", position)
}

function getPrev(model, position) {
    return model.findPreviousMatch("{", position)
}

// This searches and determines where the position lies within each child Item, so that the correct Qt file class is returned
function searchForChildBrackets(model, position) {
    var prevMatch = model.findPreviousMatch("{", position, false, false)
    var nextBracketMatch = model.findNextMatch("{", position, false, false)
    var prevBracketMatch = model.findPreviousMatch("}", position, false, false)
    var nextMatch = model.findNextMatch("}", position, false, false)
    var nextnextMatch = model.findNextMatch("}", { lineNumber: nextMatch.range.startLineNumber, column: nextMatch.range.endColumn }, false, false)
    var prevprevMatch = model.findPreviousMatch("{", { lineNumber: prevMatch.range.startLineNumber, column: prevMatch.range.startColumn }, false, false)

    //Handles the : after issue
    var line = model.getLineContent(position.lineNumber)
    if (line.includes(":") && line.substring(0, 2) !== "on" && !line.includes("property")) {
        var idsSuggestions = []
        for (var i = 0; i < ids.length; i++) {
            idsSuggestions.push(functionSuggestions[ids[i]])
        }
        return idsSuggestions
    }

    //Edge Case 4: this is when there is only one QtItem, most common is when we create a new file
    if (prevMatch.range.startLineNumber === topOfFile.range.startLineNumber && nextMatch.range.startLineNumber === bottomOfFile.range.startLineNumber) {
        propRange = {
            startLineNumber: prevMatch.range.startLineNumber,
            endLineNumber: nextMatch.range.startLineNumber,
            startColumn: prevMatch.range.startColumn,
            endColumn: nextMatch.range.endColumn
        }
        return retrieveType(model, propRange)
    }
    //Edge Case 3: this is to ensure that editing the top of the file does not allow a child item to read in its parent data i.e Item and anchors dont mix
    if (prevMatch.range.startLineNumber === topOfFile.range.startLineNumber || prevprevMatch.range.startLineNumber === topOfFile.range.startLineNumber) {
        if (position.lineNumber >= prevMatch.range.startLineNumber && position.lineNumber <= nextMatch.range.startLineNumber && (nextMatch.range.startLineNumber <= nextnextMatch.range.startLineNumber && prevBracketMatch.range.startLineNumber >= nextnextMatch.range.startLineNumber)) {
            propRange = {
                startLineNumber: prevMatch.range.startLineNumber,
                endLineNumber: nextMatch.range.startLineNumber,
                startColumn: prevMatch.range.startColumn,
                endColumn: nextMatch.range.endColumn
            }
            return retrieveType(model, propRange)
        }
    }
    //Edge Case 5: same as 3, just inveresed for the end of the file
    if (nextMatch.range.startLineNumber === bottomOfFile.range.startLineNumber || nextnextMatch.range.startLineNumber === bottomOfFile.range.startLineNumber) {
        if (position.lineNumber >= prevMatch.range.startLineNumber && position.lineNumber <= nextMatch.range.startLineNumber && prevMatch.range.startLineNumber > prevBracketMatch.range.startLineNumber) {
            propRange = {
                startLineNumber: prevMatch.range.startLineNumber,
                endLineNumber: nextMatch.range.startLineNumber,
                startColumn: prevMatch.range.startColumn,
                endColumn: nextMatch.range.endColumn
            }
            return retrieveType(model, propRange)
        }
    }
    //Normal case: the child is independent and returns the type
    if (position.lineNumber >= prevMatch.range.startLineNumber && (prevMatch.range.startLineNumber > prevBracketMatch.range.startLineNumber)) {
        if (position.lineNumber <= nextMatch.range.startLineNumber && nextMatch.range.startLineNumber < nextBracketMatch.range.startLineNumber) {
            propRange = {
                startLineNumber: prevMatch.range.startLineNumber,
                endLineNumber: nextMatch.range.startLineNumber,
                startColumn: prevMatch.range.startColumn,
                endColumn: nextMatch.range.endColumn
            }
            return retrieveType(model, propRange)
            // Edge Case 1: A rare case where if there is no first child of an item on loaded the properties will not propagate
        } else if (nextMatch.range.startLineNumber > nextBracketMatch.range.startLineNumber) {
            propRange = {
                startLineNumber: prevMatch.range.startLineNumber,
                endLineNumber: nextBracketMatch.range.startLineNumber,
                startColumn: prevMatch.range.startColumn,
                endColumn: nextBracketMatch.range.endColumn,
            }
            return retrieveType(model, propRange)
        }
        //Edge case 2: this is the most common edge case hit where the properties between sibling items are intermingled this determines what the parent item is
    } else if (prevMatch.range.startLineNumber < prevBracketMatch.range.startLineNumber && position.lineNumber <= nextMatch.range.startLineNumber) {
        var prevParent = findPreviousBracketParent(model, position).trim()
        var prevBrack = model.findPreviousMatch(prevParent, position)
        var bracket = model.findPreviousMatch("{", { lineNumber: prevBrack.range.startLineNumber, column: prevBrack.range.startColumn })
        var getWord = model.getLineContent(bracket.range.startLineNumber).replace("\t", "").split(/\{|\t/)[0].trim()
        if (qtObjectKeyValues.hasOwnProperty(prevParent)) {
            propRange = {
                startLineNumber: prevMatch.range.startLineNumber,
                endLineNumber: prevBracketMatch.range.startLineNumber,
                startColumn: prevMatch.range.startColumn,
                endColumn: prevBracketMatch.range.endColumn,
            }
            convertStrArrayToObjArray(prevParent, qtObjectKeyValues[prevParent].properties.concat(customProperties), qtObjectKeyValues[prevParent].flag, false, prevParent)
            if (currentItems[prevParent] === undefined) {
                currentItems[prevParent] = {}
            }
            currentItems[prevParent][propRange] = qtObjectPropertyValues[prevParent]
            return currentItems[prevParent][propRange]
        } else if (qtObjectMetaPropertyValues[getWord].hasOwnProperty(prevParent)) {
            convertStrArrayToObjArray(prevParent, qtObjectMetaPropertyValues[getWord][prevParent], true, true, null)
            return qtObjectPropertyValues[prevParent]
        } else if (prevParent.includes(":") && prevParent.substring(0, 2) !== "on") {
            const propertyItem = prevParent.trim().replace("\t", "").split(":")[1].trim()
            propRange = {
                startLineNumber: prevMatch.range.startLineNumber,
                endLineNumber: nextMatch.range.startLineNumber,
                startColumn: prevMatch.range.startColumn,
                endColumn: nextMatch.range.endColumn,
            }

            convertStrArrayToObjArray(propertyItem, qtObjectKeyValues[propertyItem].properties, qtObjectKeyValues[propertyItem].flag, false, propertyItem)
            if (currentItems[propertyItem] === undefined) {
                currentItems[propertyItem] = {}
            }
            currentItems[propertyItem][propRange] = qtObjectPropertyValues[propertyItem]
            return currentItems[propertyItem][propRange]

        } else {
            return Object.values(functionSuggestions)
        }
    }
    if (position.lineNumber > prevMatch.range.startLineNumber && position.lineNumber > prevBracketMatch.range.startLineNumber) {
        var prevParent = findPreviousBracketParent(model, position)
        if (qtObjectKeyValues.hasOwnProperty(prevParent)) {
            propRange = {
                startLineNumber: prevMatch.range.startLineNumber,
                endLineNumber: nextMatch.range.startLineNumber,
                startColumn: prevMatch.range.startColumn,
                endColumn: nextMatch.range.endColumn,
            }
            convertStrArrayToObjArray(prevParent, qtObjectKeyValues[prevParent].properties, qtObjectKeyValues[prevParent].flag, false, prevParent)
            if (currentItems[prevParent] === undefined) {
                currentItems[prevParent] = {}
            }
            currentItems[prevParent][propRange] = qtObjectPropertyValues[prevParent]
            return currentItems[prevParent][propRange]
        }
    }
    if (position.lineNumber >= prevMatch.range.startLineNumber && position.lineNumber <= nextMatch.range.startLineNumber) {
        var getContent = model.getLineContent(prevMatch.range.startLineNumber)
        if (getContent.includes(":")) {
            var content = getContent.replace("\t", "").split(/\{|\t/)[0].trim()
            var currentProperty = content.split(":")[1].trim()
            if (qtObjectKeyValues.hasOwnProperty(currentProperty)) {
                propRange = {
                    startLineNumber: prevMatch.range.startLineNumber,
                    endLineNumber: nextMatch.range.startLineNumber,
                    startColumn: prevMatch.range.startColumn,
                    endColumn: nextMatch.range.endColumn,
                }

                convertStrArrayToObjArray(currentProperty, qtObjectKeyValues[currentProperty].properties, qtObjectKeyValues[currentProperty].flag, false, currentProperty)
                if (currentItems[currentProperty] === undefined) {
                    currentItems[currentProperty] = {}
                }
                currentItems[currentProperty][propRange] = qtObjectPropertyValues[currentProperty]
                return currentItems[currentProperty][propRange]
            }
        } else {
            var content = getContent.replace("\t", "").split(/\{|\t/)[0].trim()
            if (qtObjectKeyValues.hasOwnProperty(content)) {
                propRange = {
                    startLineNumber: prevMatch.range.startLineNumber,
                    endLineNumber: nextMatch.range.startLineNumber,
                    startColumn: prevMatch.range.startColumn,
                    endColumn: nextMatch.range.endColumn,
                }

                convertStrArrayToObjArray(content, qtObjectKeyValues[content].properties, qtObjectKeyValues[content].flag, false, content)
                if (currentItems[content] === undefined) {
                    currentItems[content] = {}
                }
                currentItems[content][propRange] = qtObjectPropertyValues[content]
                return currentItems[content][propRange]
            }
        }
    }

    return Object.values(suggestions)
}

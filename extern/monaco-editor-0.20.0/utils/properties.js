

class QtProperties {
    constructor(model,qtQuick) {
        this.model = model
        this.qtPropertyPairs = {}
        this.customProperties = []
        this.qtQuick = qtQuick
        this.getPropertyType(model)
    }

    update(model, qtQuick) {
        this.model = model
        this.qtQuick = qtQuick
        this.qtPropertyPairs = {}
        this.customProperties = []
        this.getPropertyType(model)
    }

    addCustomProperties(lineNumber, item, property) {
        if (!this.qtPropertyPairs.hasOwnProperty(item)) {
            this.qtPropertyPairs[item] = {}
            if (!this.qtPropertyPairs[item].hasOwnProperty(lineNumber)) {
                this.qtPropertyPairs[item][lineNumber] = property
            }
        } else {
            this.qtPropertyPairs[item][lineNumber] = property
        }
        if (this.qtQuick.qtSuggestions.qtObjectKeyValues.hasOwnProperty(item) && property !== undefined) {
            var onCall = property
            var onCallProperty = "on" + onCall[0].toUpperCase() + onCall.substring(1) + "Changed"
           this.customProperties.push(onCallProperty)
        }
    }
    
    getPropertyType(model) {
        var position = { lineNumber: this.qtQuick.qtSearch.fullRange.endLineNumber, column: this.qtQuick.qtSearch.fullRange.endColumn }
        while (position.lineNumber > this.qtQuick.qtSearch.fullRange.startLineNumber ) {
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
            this.addCustomProperties(getPrevPropertyPosition.range.startLineNumber, type, prevProperty)
        }
    }
    // This grabs the Item type from the parent bracket and returns the suggestions
    
    determineCustomPropertyParents(model, position) {
        // determine custom properties before returning
        this.customProperties = []
        var startPosition = position
        const previousBracket = model.findPreviousMatch("{", startPosition)
        const prevParent = this.qtQuick.qtSearch.findPreviousBracketParent(position)
        const prevParentBracket = model.findPreviousMatch(prevParent, position)
        var prevNextBracket = previousBracket
        var nextPosition = { lineNumber: prevParentBracket.range.startLineNumber, column: previousBracket.range.startColumn }
        var nextProperty = model.findNextMatch("property", nextPosition)
        var closestTop = this.qtQuick.qtSearch.matchingBrackets[0].top
        var closestBottom = this.qtQuick.qtSearch.matchingBrackets[0].bottom
        for( var i = 0; i < this.qtQuick.qtSearch.matchingBrackets.length; i++){
            if (position.lineNumber <= this.qtQuick.qtSearch.matchingBrackets[i].bottom && position.lineNumber >= this.qtQuick.qtSearch.matchingBrackets[i].top) {
                if (closestTop < this.qtQuick.qtSearch.matchingBrackets[i].top) {
                    closestTop = this.qtQuick.qtSearch.matchingBrackets[i].top
                }
                if (closestBottom > this.qtQuick.qtSearch.matchingBrackets[i].bottom) {
                    closestBottom = this.qtQuick.qtSearch.matchingBrackets[i].bottom
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
                this.qtQuick.qtSuggestions.qtObjectKeyValues[this.qtQuick.qtIds.qtIdPairs[getPrevId.range.startLineNumber][id]].properties.push(propertySlot)
                if (this.qtQuick.qtIds.otherProperties.hasOwnProperty(id)) {
                    this.qtQuick.qtIds.otherProperties[id].push(propertyWord)
                    this.qtQuick.qtIds.otherProperties[id] = this.qtQuick.qtHelper.removeDuplicates(this.qtQuick.qtIds.otherProperties[id])
                } else {
                    this.qtQuick.qtIds.otherProperties[id] = []
                    this.qtQuick.qtIds.otherProperties[id].push(propertyWord)
                }
            } else {
                if(position.lineNumber >= closestTop && position.lineNumber <= closestBottom && (nextProperty.range.startLineNumber >= closestTop && nextProperty.range.startLineNumber <= closestBottom)){
                    var propertySlot = "on" + propertyWord[0].toUpperCase() + propertyWord.substring(1) + "Changed"
                    if(!this.customProperties.includes(propertySlot)){
                        var getLine = model.getLineContent(closestTop)
                        var getParent = getLine.replace("\t", "").split(/\{|\t/)[0].trim()
                        this.qtQuick.qtSuggestions.qtObjectKeyValues[getParent].properties = this.qtQuick.qtSuggestions.qtObjectKeyValues[getParent].properties.concat(propertySlot)
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
}
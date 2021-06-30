// Searches for the parent Item based off of the end column of a sibling item, this searches up and checks for time where the current line number is a child of the item

// This searches and determines where the position lies within each child Item, so that the correct Qt file class is returned

class QtSearch {

    constructor() {
        this.model = null
        this.fullRange = null
        this.topOfFile = 0
        this.bottomOfFile = 0
        this.matchingBrackets = []
    }

    update(model) {
        this.model = model
        this.fullRange = model.getFullModelRange()
        this.topOfFile = model.findNextMatch("{", { lineNumber: this.fullRange.startLineNumber, column: this.fullRange.startColumn })
        this.bottomOfFile = model.findPreviousMatch("}", { lineNumber: this.fullRange.endLineNumber, column: this.fullRange.endColumn })
        this.matchingBrackets = []
        this.createMatchingPairs(model)
    }

    createMatchingPairs(model) {
        this.matchingBrackets.push({ top: this.topOfFile.range.startLineNumber, bottom: this.bottomOfFile.range.startLineNumber })
        var next = this.getNext({ lineNumber: this.topOfFile.range.startLineNumber, column: this.topOfFile.range.endColumn })
        var prev = this.getPrev({ lineNumber: next.range.startLineNumber, column: next.range.startColumn })
        while (next.range.startLineNumber < this.bottomOfFile.range.startLineNumber) {
            var checkNext = this.getNext({ lineNumber: prev.range.startLineNumber, column: prev.range.endColumn })
            if (next.range.startLineNumber === checkNext.range.startLineNumber) {
                this.matchingBrackets.push({ top: prev.range.startLineNumber, bottom: next.range.startLineNumber })
            } else {
                var initialPosition = { lineNumber: next.range.startLineNumber, column: next.range.startLineNumber }
                var checkPrev = this.getPrev(initialPosition)
                var getLine = model.getLineContent(checkPrev.range.startLineNumber)
                var content = getLine.replace("\t", "").split(/\{|\t/)[0].trim()
                var getWord = model.findPreviousMatch(content, initialPosition)
                while (getWord !== null && next.range.startColumn < getWord.range.startColumn) {
                    initialPosition = { lineNumber: getWord.range.startLineNumber, column: getWord.range.startColumn }
                    checkPrev = this.getPrev(initialPosition)
                    getLine = model.getLineContent(checkPrev.range.startLineNumber)
                    content = getLine.replace("\t", "").split(/\{|\t/)[0].trim()
                    getWord = model.findPreviousMatch(content, initialPosition)
                }
                try {
                    if (getWord !== null) {
                        this.matchingBrackets.push({ top: getWord.range.startLineNumber, bottom: next.range.startLineNumber })
                    }
                } catch(err) {
                    console.error("Invalid Placement")
                }
            }
            next = this.getNext({ lineNumber: next.range.startLineNumber, column: next.range.endColumn })
            prev = this.getPrev({ lineNumber: next.range.startLineNumber, column: next.range.startColumn })
        }
    }

    findPreviousBracketParent(position) {
        var currentClosestTop = this.matchingBrackets[0].top
        var currentClosestBottom = this.matchingBrackets[0].bottom
        for (var i = 0; i < this.matchingBrackets.length; i++) {
            if (position.lineNumber <= this.matchingBrackets[i].bottom && position.lineNumber >= this.matchingBrackets[i].top) {
                if (currentClosestTop < this.matchingBrackets[i].top) {
                    currentClosestTop = this.matchingBrackets[i].top
                }
                if (currentClosestBottom > this.matchingBrackets[i].bottom) {
                    currentClosestBottom = this.matchingBrackets[i].bottom
                }
            }
        }
        var getParent = this.model.getLineContent(currentClosestTop)
        var content = getParent.replace("\t", "").split(/\{|\t/)[0].trim()
        return content
    }
    
    getNext(position) {
        return this.model.findNextMatch("}", position)
    }
    
    getPrev(position) {
        return this.model.findPreviousMatch("{", position)
    }
    
}

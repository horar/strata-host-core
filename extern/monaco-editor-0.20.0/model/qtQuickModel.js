class QtQuickModel {
    constructor() {
        this.model = {}
        this.imports = []
    }

    updateQtModel(lineNumber, obj = new QtItemModel()){
        if(this.model[lineNumber] === undefined) {
            this.model[lineNumber] = {}
        }
        this.model[lineNumber] = obj
    }

    updateImports(newImports) {
        this.imports.push(newImports)
    }

    resetModel() {
        this.model = {}
        this.imports = []
    }

    fetchItem(lineNumber) {
        return this.model[lineNumber]
    }
}
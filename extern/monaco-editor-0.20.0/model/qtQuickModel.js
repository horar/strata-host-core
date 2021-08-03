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

    deleteModelMember(lineNumber) {
        if(this.model[lineNumber] !== undefined) {
            delete this.model[lineNumber]
        }
    }

    updateImports(newImports) {
        this.imports.push(newImports)
    }

    get currentQtModel() {
        return this.model
    }

    resetModel() {
        this.model = {}
        this.imports = []
    }

    fetchItem(lineNumber) {
        return this.model[lineNumber]
    }
}
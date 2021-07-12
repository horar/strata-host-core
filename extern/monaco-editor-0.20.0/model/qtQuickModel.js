class QtQuickModel {
    constructor() {
        this.model = {}
        this.imports = []
    }

    updateQtModel(uuid, obj = new QtItemModel()){
        if(this.model[uuid] === undefined) {
            this.model[uuid] = {}
        }
        this.model[uuid] = obj
    }

    deleteModelMember(uuid) {
        if(this.model[uuid] !== undefined) {
            delete this.model[uuid]
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
    }

    fetchItem(uuid) {
        return this.model[uuid]
    }

    get currentImports() {
       return this.currentImports
    }
}
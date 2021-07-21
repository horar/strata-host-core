.pragma library

.import "qrc:/js/template_data.js" as TemplateData

let selectedPath = TemplateData.data[0].path //default to template for the time being
const debugPath = TemplateData.debugPath //DebugMenu.qml
let dataModel = null

function createDataModel(objectModel) {
    setDataModel(objectModel)
    for (let i = 0; i < TemplateData.data.length; i++) {
        dataModel.append(TemplateData.data[i])
    }
}

function setPath(path) {
    if (path !== selectedPath) {
        selectedPath = path
    }
}

function setDataModel(objectModel) {
    if (dataModel !== objectModel) {
        dataModel = objectModel
    }
}

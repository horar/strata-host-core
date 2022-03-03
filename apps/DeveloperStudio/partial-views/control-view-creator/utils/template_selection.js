/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
.pragma library

.import "qrc:/js/template_data.js" as TemplateData

let selectedPath = TemplateData.data[0].path // default to template for the time being
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

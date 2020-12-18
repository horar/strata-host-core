import QtQuick 2.0
import tech.strata.fonts 1.0
import tech.strata.sgwidgets 0.9
import "qrc:/js/help_layout_manager.js" as Help


SGIcon {
    id: helpIcon
    source: "qrc:/sgimages/question-circle.svg"
    iconColor: helpMouse.containsMouse ? "lightgrey" : "grey"

    property var helpTour_document_list: {
        "class_id": "help_docs_demo",
        "datasheets": [{"category":"Standard Logic","datasheet":"https://www.onsemi.com/pub/Collateral/NL7SZ97-D.PDF","name":"Demo Datasheets","opn":"NL7SZ97","subcategory":"Demo"}],
        "documents": [{"category":"view","md5":"29bb28352a18b9cac24d94362646abac","name":"Demo Documents","prettyname":"Demo.pdf","uri":"HelpFakeDocument.pdf"},
                      {"category":"download","filesize":11292,"md5":"dab1c59648d209db980dedb25d5f4a3c","name":"DemoDownloads","prettyname":"DemoDownloads.pdf","uri":"qrc:/tech/strata/common/ContentView/images/HelpFakeDocument.pdf"}],

        "type":"document"
    }
    property string class_id: ""

    function clickAction() {
        Help.startHelpTour("contentViewHelp", "strataMain")
    }

    MouseArea {
        id: helpMouse
        hoverEnabled: true
        anchors {
            fill: helpIcon
        }
        onClicked: {
            view.pdfAccordionState = accordion.contentItem.children[0].open
            view.datasheetAccordionState = accordion.contentItem.children[1].open
            view.downloadAccordionState = accordion.contentItem.children[2].open
            helpIcon.clickAction()
            class_id = "help_docs_demo"
            classDocuments = sdsModel.documentManager.getClassDocuments("help_docs_demo")
            classDocuments.populateModels(helpTour_document_list)
        }
    }
}



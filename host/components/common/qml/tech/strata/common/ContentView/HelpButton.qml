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
        "datasheets": [{"category":"Standard Logic","datasheet":"https://www.onsemi.com/pub/Collateral/NL7SZ97-D.PDF","name":"Demo Datasheets","opn":"Demo","subcategory":"Demo"}],
        "documents": [{"category":"view","md5":"Demo","name":"Demo Documents","prettyname":"Demo.pdf","uri":"HelpTourDocument.pdf"},
                      {"category":"download","filesize":11292,"md5":"DemoDownloads","name":"DemoDownloads","prettyname":"DemoDownloads.pdf","uri":"qrc:/tech/strata/common/ContentView/images/HelpTourDocument.pdf"}],

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



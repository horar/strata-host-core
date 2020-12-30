import QtQuick 2.7
import tech.strata.fonts 1.0
import tech.strata.sgwidgets 0.9
import "qrc:/js/help_layout_manager.js" as Help

SGIcon {
    id: helpIcon
    source: "qrc:/sgimages/question-circle.svg"
    iconColor: helpMouse.containsMouse ? "lightgrey" : "grey"

    property var helpTour_document_list: {
        "class_id": "help_docs_demo",
        "datasheets": [{"category":"Part Category","datasheet":"https://www.onsemi.com/pub/Collateral/NL7SZ97-D.PDF","name":"Demo Datasheet","opn":"Demo","subcategory":"Demo"}],
        "documents": [{"category":"view","md5":"Demo","name":"Demo Document","prettyname":"Demo.pdf","uri":"HelpTourDocument.pdf"},
                      {"category":"download","filesize":11292,"md5":"DemoDownload","name":"DemoDownload","prettyname":"DemoDownload.pdf","uri":"qrc:/tech/strata/common/ContentView/images/HelpTourDocument.pdf"}],

        "type":"document"
    }

    property string class_id: ""

    function clickAction() {
        Help.startHelpTour("contentViewHelp", "strataMain")
    }

    Component.onCompleted: {
        fakeHelpDocuments = sdsModel.documentManager.getClassDocuments("help_docs_demo")
        fakeHelpDocuments.populateModels(helpTour_document_list)
    }

    MouseArea {
        id: helpMouse
        hoverEnabled: true
        anchors {
            fill: helpIcon
        }

        onClicked: {
            //store previously opened accordion
            view.pdfAccordionState = accordion.contentItem.children[0].open
            view.datasheetAccordionState = accordion.contentItem.children[1].open
            view.downloadAccordionState = accordion.contentItem.children[2].open
            class_id = "help_docs_demo"
            classDocuments = fakeHelpDocuments
            helpIcon.clickAction()
        }
    }
}

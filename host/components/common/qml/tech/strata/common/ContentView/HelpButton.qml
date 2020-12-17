import QtQuick 2.0
import tech.strata.fonts 1.0
import tech.strata.sgwidgets 0.9
import "qrc:/js/help_layout_manager.js" as Help


SGIcon {
    id: helpIcon
    source: "qrc:/sgimages/question-circle.svg"
    iconColor: helpMouse.containsMouse ? "lightgrey" : "grey"

    property var fake_data: {
        "class_id": "help_docs_demo",
        "datasheets": [{"category":"Standard Logic","datasheet":"https://www.onsemi.com/pub/Collateral/NL7SZ97-D.PDF","name":"NL7SZ97","opn":"NL7SZ97","subcategory":"Logic Gates"}],
        "documents": [],

    }

    function clickAction() {
        Help.startHelpTour("contentViewHelp", "strataMain")
    }


    MouseArea {
        id: helpMouse
        anchors {
            fill: helpIcon
        }
        onClicked: {
            view.accordionPdf = accordion.contentItem.children[0].open
            view.state2 = accordion.contentItem.children[1].open
            view.state3 = accordion.contentItem.children[2].open
            helpIcon.clickAction()
            //classDocuments = sdsModel.documentManager.getClassDocuments("b039e649-2713-4557-afb7-9fabeacd4290")
            classDocuments = sdsModel.documentManager.getClassDocuments("help_docs_demo")
            classDocuments.populateModels(fake_data)

        }
        hoverEnabled: true
    }
}



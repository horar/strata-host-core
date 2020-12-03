import QtQuick 2.12
import QtQuick.Controls 2.12
import tech.strata.sgwidgets 1.0 as SGWidgets
import tech.strata.theme 1.0

Item {

    property string currentPage: "PageSGWidgetsOneZero.qml"

    ListModel {
        id: pageModel

        ListElement {
            name: "SGWidgets 1.0"
            page: "widgets1_0/PageSGWidgetsOneZero.qml"
        }
    }

    StackView {
        id: stackView
        anchors.fill: parent
    }

    Component.onCompleted: {
        //select SGWidgets 1.0 by default
        stackView.push(welcomePage, "widgets1_0/PageSGWidgetsOneZero.qml")
    }

    Component {
        id: welcomePage

        Item {
            Grid {
                anchors.centerIn: parent
                spacing: 20

                Repeater {
                    id: pageRepeater
                    model: pageModel
                    delegate: SGWidgets.SGButton {
                        minimumContentHeight: 100
                        minimumContentWidth: 200
                        fontSizeMultiplier: 1.6
                        color: Theme.strataGreen
                        text: model.name
                        onClicked: {
                            stackView.push(model.page)
                        }
                    }
                }
            }
        }
    }
}

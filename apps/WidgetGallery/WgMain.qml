import QtQuick 2.12
import QtQuick.Controls 2.12
import tech.strata.sgwidgets 1.0 as SGWidgets
import tech.strata.theme 1.0

Item {

    ListModel {
        id: pageModel

        ListElement {
            name: "SGWidgets 1.0"
            page: "widgets1_0/PageSGWidgetsOneZero.qml"
        }

        ListElement {
            name: "CommonCpp 1.0"
            page: "commoncpp1_0/PageSGCommonCppOneZero.qml"
        }
    }

    StackView {
        id: stackView
        anchors.fill: parent

        initialItem: welcomePage
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
                        color: Theme.palette.green
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

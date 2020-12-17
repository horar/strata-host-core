import QtQuick 2.12
import QtQuick.Controls 2.12
import tech.strata.sgwidgets 1.0 as SGWidgets
import tech.strata.commoncpp 1.0 as CommonCPP
import tech.strata.logger 1.0


Item {

    width: contentColumn.width
    height: editEnabledCheckBox.y + editEnabledCheckBox.height

    ListModel {
        id: dataModel

        ListElement { name: "Jamie" }
        ListElement { name: "Leigh"}
        ListElement { name: "Val"}
        ListElement { name: "Gabby"}
        ListElement { name: "Blair"}
        ListElement { name: "Bubu"}
        ListElement { name: "Ray"}
        ListElement { name: "Dane"}
        ListElement { name: "Donald"}
        ListElement { name: "Hayden"}
        ListElement { name: "Lynn"}
        ListElement { name: "Maddox"}
        ListElement { name: "Denny"}
        ListElement { name: "Jesse"}
        ListElement { name: "Franky"}
    }

    CommonCPP.SGSortFilterProxyModel {
        id: sortFilterModel
        sourceModel: dataModel
        sortRole: "name"
        filterRole: "name"
        filterPatternSyntax: CommonCPP.SGSortFilterProxyModel.RegExp
        filterPattern: ".*" + suggestionTextField.text + ".*"
    }

    Column {
        id: contentColumn
        spacing: 10
        enabled: editEnabledCheckBox.checked

        Column {
            SGWidgets.SGText {
                text: "Default"
                fontSizeMultiplier: 1.3
            }
            SGWidgets.SGTextField { }

        }

        Column {
            SGWidgets.SGText {
                text: "With left icon"
                fontSizeMultiplier: 1.3
            }

            SGWidgets.SGTextField {
                leftIconSource: "qrc:/sgimages/zoom.svg"
            }
        }

        Column {
            SGWidgets.SGText {
                text: "With suggestion popup"
                fontSizeMultiplier: 1.3
            }

            SGWidgets.SGTextField {
                id: suggestionTextField
                suggestionListModel: sortFilterModel
                suggestionDelegateNumbering: true
                onSuggestionDelegateSelected: {
                    var sourceIndex = sortFilterModel.mapIndexToSource(index)
                    if (sourceIndex < 0) {
                        return
                    }

                    text = dataModel.get(sourceIndex)["name"]
                }
            }
        }

        Column {
            SGWidgets.SGText {
                text: "With busy indicator"
                fontSizeMultiplier: 1.3
            }

            Row {
                spacing: 10
                SGWidgets.SGTextField {
                    id: textFieldWithBusyInd
                    leftIconSource: "qrc:/sgimages/zoom.svg"
                }

                SGWidgets.SGButton {
                    text: "On/Off"
                    onClicked: {
                        textFieldWithBusyInd.busyIndicatorRunning = !textFieldWithBusyInd.busyIndicatorRunning
                    }
                }
            }
        }

        Column {
            SGWidgets.SGText {
                text: "With password mode"
                fontSizeMultiplier: 1.3
            }

            SGWidgets.SGTextField {
                passwordMode: true
                text: "password"
            }
        }

        Column {
            SGWidgets.SGText {
                text: "With clear option"
                fontSizeMultiplier: 1.3
            }

            SGWidgets.SGTextField {
                showClearButton: true
            }
        }
    }

    SGWidgets.SGCheckBox {
        id: editEnabledCheckBox
        anchors {
            top: contentColumn.bottom
            topMargin: 20
        }

        text: "Everything enabled"
        checked: true
    }
}

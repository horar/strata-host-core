import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import tech.strata.sgwidgets 1.0 as SGWidgets
import tech.strata.commoncpp 1.0 as CommonCPP

ColumnLayout {

    width: flickWrapper.width

    SGWidgets.SGTextEdit {
        id: noteText
        Layout.maximumWidth: flickWrapper.width - 10
        wrapMode: Text.Wrap
        textFormat: TextEdit.RichText
        enabled: false
        text: "This example demonstrates how to sort and filter list by selecting/inserting options.<br>"
        + "<b> Custom sorting: </b> sorts names by length in alphabetical order<br>"
        + "<b> Custom filtering: </b> filters out people with odd age<br>"
        + "note: to be able to test natural sort select sort role <i>identification</i><br>"
    }

    ListModel {
        id: dataModel

        ListElement {
            name: "Jamie"
            identification: "a1"
            age: 13
        }
        ListElement {
            name: "Leigh"
            identification: "b1"
            age: 52
        }
        ListElement {
            name: "Val"
            identification: "a2"
            age: 20
        }
        ListElement {
            name: "Blair"
            identification: "a111"
            age: 35
        }
        ListElement {
            name: "Bubu"
            identification: "a3"
            age: 16
        }
        ListElement { 
            name: "Ray"
            identification: "a50"
            age: 4
        }
        ListElement {
            name: "Dane"
            identification: "b2"
            age: 8
        }
        ListElement {
            name: "Donald"
            identification: "c6"
            age: 18
        }
        ListElement {
            name: "Hayden"
            identification: "a34"
            age: 29
        }
        ListElement {
            name: "Lynn"
            identification: "c3"
            age: 80
        }
    }

    CommonCPP.SGSortFilterProxyModel {
        id: sortFilterModel
        sourceModel: dataModel
        // sorting properties
        sortRole: sortComboBox.currentText
        sortEnabled: sortEnabledCheckBox.checked ? true : false
        sortAscending: sortAscendingCheckBox.checked ? true : false
        naturalSort: naturalSortCheckBox.checked ? true : false
        invokeCustomLessThan: customSortCheckBox.checked ? true : false

        // filtering properties
        filterRole: filterComboBox.currentText
        filterPatternSyntax: {
            if (regExpRadioBtn.checked) {
                return CommonCPP.SGSortFilterProxyModel.RegExp
            } else if (wildCardRadioBtn.checked) {
                return CommonCPP.SGSortFilterProxyModel.Wildcard
            } else {
                return CommonCPP.SGSortFilterProxyModel.FixedString
            }
        }
        filterPattern: suggestionTextField.text
        caseSensitive:  caseSensitiveCheckBox.checked ? true : false
        invokeCustomFilter: customFilterCheckBox.checked ? true : false

        // Custom filtering function - filters out people with odd age
        function filterAcceptsRow(index) {
            var item = sourceModel.get(index)

            if (item.age % 2 === 0) {
                return true
            }
            return false
        }

        // Custom sorting function - sorts names by length in alphabetical order
        function lessThan(index1, index2) {
            var item1 = sourceModel.get(index1)
            var item2 = sourceModel.get(index2)

            if (item1.name !== item2.name) {
                if (item1.name.length === item2.name.length) {
                    return item1.name > item2.name
                }
                return item1.name.length < item2.name.length
            }
            return item1 < item2
        }
    }

    ColumnLayout {
        id: contentColumn
        spacing: 10
        Layout.fillWidth: true

        Rectangle {
            height: 200
            color: "white"
            Layout.fillWidth: true

            ListView {
                anchors.fill: parent
                model: sortFilterModel
                interactive: false
                delegate: Item {
                    height: childrenRect.height
                    width: childrenRect.width
                    SGWidgets.SGText {
                        id: nameText
                        leftPadding: 10
                        text: name
                    }
                    SGWidgets.SGText {
                        anchors {
                            left: nameText.left
                            leftMargin: 100
                        }
                        text: age
                    }
                    SGWidgets.SGText {
                        anchors {
                            left: nameText.left
                            leftMargin: 200
                        }
                        text: identification
                    }
                }

                header: Item {
                    height: childrenRect.height
                    width: childrenRect.width
                    SGWidgets.SGText {
                        id: headerName
                        leftPadding: 10
                        text: "<b> name </b>"
                    }
                    SGWidgets.SGText {
                        anchors {
                            left: headerName.left
                            leftMargin: 100
                        }
                        text: "<b> age </b>"
                    }
                    SGWidgets.SGText {
                        anchors {
                            left: headerName.left
                            leftMargin: 200
                        }
                        text: "<b> id </b>"
                    }
                }
            }
        }

        Row {
            width: flickWrapper.width
            spacing: 20

            Column {
                spacing: 6

                SGWidgets.SGText {
                    text: "Sorting options"
                    fontSizeMultiplier: 1.3
                }

                SGWidgets.SGCheckBox {
                    id: sortEnabledCheckBox
                    text: "Sort enabled"
                    focusPolicy: Qt.NoFocus
                }

                SGWidgets.SGCheckBox {
                    id: sortAscendingCheckBox
                    text: "Sort ascending"
                    focusPolicy: Qt.NoFocus
                    enabled: sortEnabledCheckBox.checked
                }

                SGWidgets.SGCheckBox {
                    id: naturalSortCheckBox
                    text: "Natural sort"
                    focusPolicy: Qt.NoFocus
                    enabled: sortEnabledCheckBox.checked
                }

                RowLayout {
                    spacing: 10

                    SGWidgets.SGText {
                        text: "Sort role:"
                    }

                    SGWidgets.SGComboBox {
                        id: sortComboBox

                        model: ["name", "identification", "age"]
                        focusPolicy: Qt.NoFocus
                        enabled: sortEnabledCheckBox.checked
                    }
                }

                SGWidgets.SGCheckBox {
                    id: customSortCheckBox
                    text: "Custom sort"
                    focusPolicy: Qt.NoFocus
                    enabled: sortEnabledCheckBox.checked
                    onCheckedChanged: {
                        if(checked) {
                            naturalSortCheckBox.checked = false
                            sortAscendingCheckBox.checked = false
                        }
                    }
                }
            }

            Rectangle {
                Layout.alignment: Qt.AlignHCenter
                color: "#cecece"
                width: 1
                height: parent.height
            }

            Column {

                spacing: 6

                SGWidgets.SGText {
                    text: "Filtering options:"
                    fontSizeMultiplier: 1.3
                }

                SGWidgets.SGTextField {
                    id: suggestionTextField
                    enabled: customFilterCheckBox.checked === false
                }

                RowLayout {
                    spacing: 10

                    SGWidgets.SGText {
                        text: "Filter role:"
                    }

                    SGWidgets.SGComboBox {
                        id: filterComboBox

                        model: ["name", "identification", "age"]
                        focusPolicy: Qt.NoFocus
                        enabled: customFilterCheckBox.checked === false
                    }
                }

                SGWidgets.SGCheckBox {
                    id: caseSensitiveCheckBox
                    text: "Case Sensitive"
                    checked: false
                    focusPolicy: Qt.NoFocus
                    enabled: customFilterCheckBox.checked === false
                }

                Row {

                    spacing: 20
                    enabled: !customFilterCheckBox.checked
                    SGWidgets.SGRadioButton {
                        id: regExpRadioBtn
                        text: "RegExp"
                        checked: true
                        focusPolicy: Qt.NoFocus
                    }

                    SGWidgets.SGRadioButton {
                        id: wildCardRadioBtn
                        text: "WildCard"
                        focusPolicy: Qt.NoFocus
                    }

                    SGWidgets.SGRadioButton {
                        id: fixedStringRadioBtn
                        text: "FixedString"
                        focusPolicy: Qt.NoFocus
                    }
                }

                SGWidgets.SGCheckBox {
                    id: customFilterCheckBox
                    text: "Custom filter"
                    focusPolicy: Qt.NoFocus
                }
            }
        }
    }
}

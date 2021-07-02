import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import tech.strata.sgwidgets 1.0 as SGWidgets
import tech.strata.theme 1.0
import tech.strata.commoncpp 1.0 as CommonCpp
import tech.strata.logger 1.0

SGWidgets.SGDialog {
    id: dialog

    title: "Scrollback Filtering"
    headerIcon: "qrc:/sgimages/funnel.svg"
    modal: true
    focus: true
    closePolicy: Popup.CloseOnEscape

    property bool disableAllFiltering
    property variant filterSuggestionModel

    ListModel {
        id: conditionTypeModel

        ListElement {
            type: "equal"
            text: "is equal to"
        }

        ListElement {
            type: "contains"
            text: "contains"
        }

        ListElement {
            type: "startswith"
            text: "starts with"
        }

        ListElement {
            type: "endswith"
            text: "ends with"
        }
    }

    ListModel {
        id: filterConditionModel

        ListElement {
            condition: "equal"
            filter_string: ""
        }

        function addNew() {
            var item = {
                "condition": "equal",
                "filter_string": ""
            }
            append(item)
        }
    }

    Item {
        id: contentItem
        implicitHeight: contentColumn.height
        implicitWidth: contentColumn.width

        Keys.onEnterPressed: dialog.accept()
        Keys.onReturnPressed: dialog.accept()

        Column {
            id: contentColumn
            spacing: 8

            property int firstColumnCenter: 1
            property int thirdColumnCenter: 1
            property int delegateWidth: 1

            SGWidgets.SGText {
                width: conditionView.width
                text: "Filter out notifications that matches any of the following conditions:"
                wrapMode: Text.Wrap
            }

            Column {

                Item {
                    id: header
                    height: headerThirdLabel.contentHeight + 4
                    width: headerThirdLabel.x + headerThirdLabel.width

                    SGWidgets.SGText {
                        id: headerThirdLabel
                        anchors.verticalCenter: parent.verticalCenter
                        x: contentColumn.thirdColumnCenter - width / 2

                        text: "Filter String"
                    }
                }

                ListView {
                    id: conditionView
                    width: contentColumn.delegateWidth
                    height: 180

                    model: filterConditionModel
                    spacing: 8
                    clip: true
                    focus: true
                    snapMode: ListView.SnapToItem
                    boundsBehavior: Flickable.StopAtBounds
                    highlightMoveDuration: 0
                    highlightMoveVelocity: -1

                    ScrollBar.vertical: ScrollBar {
                        width: 8
                        height: conditionView.height

                        policy: ScrollBar.AlwaysOn
                        minimumSize: 0.1
                        visible: conditionView.height < conditionView.contentHeight
                    }

                    delegate: FocusScope {
                        id: delegate
                        width: contentRow.width
                        height: contentRow.height

                        enabled: disableAllFiltering === false
                        onActiveFocusChanged: {
                            if (delegate.activeFocus) {
                                conditionView.currentIndex =  index
                            }
                        }

                        Component.onCompleted: {
                            if (index === 0) {
                                contentColumn.delegateWidth = width
                                contentColumn.firstColumnCenter = nameFieldTextField.x + nameFieldTextField.width / 2
                                contentColumn.thirdColumnCenter = filterStringTextField.x + filterStringTextField.width / 2
                            }
                        }

                        ListView.onAdd: NumberAnimation {
                            target: delegate
                            property: "height"
                            duration: 100
                            easing.type: Easing.Linear
                            from: 0
                            to: contentRow.height
                        }

                        ListView.onRemove: SequentialAnimation {
                            PropertyAction {
                                target: delegate
                                property: "ListView.delayRemove";
                                value: true
                            }

                            NumberAnimation {
                                target: delegate
                                property: "height"
                                duration: 100
                                easing.type: Easing.Linear
                                to: 0
                            }

                            PropertyAction {
                                target: delegate
                                property: "ListView.delayRemove"
                                value: false
                            }
                        }

                        Row {
                            id: contentRow
                            spacing: 4

                            SGWidgets.SGText {
                                id: nameFieldTextField
                                anchors.verticalCenter: contentRow.verticalCenter
                                text: "Value\nattribute "
                                horizontalAlignment: Text.AlignHCenter
                            }

                            ComboBox {
                                id: typeComboBox
                                model: conditionTypeModel
                                textRole: "text"

                                onCurrentIndexChanged: {
                                    if (currentIndex < 0) {
                                        return
                                    }

                                    var type = conditionTypeModel.get(currentIndex).type
                                    filterConditionModel.setProperty(index, "condition", type)
                                }

                                Binding {
                                    target: typeComboBox
                                    property: "currentIndex"
                                    value: {
                                        if (index < 0) {
                                            return typeComboBox.currentIndex
                                        }

                                        var condition = filterConditionModel.get(index).condition
                                        var ll = conditionTypeModel.count
                                        for (var i = 0; i < ll; ++i) {
                                            if (conditionTypeModel.get(i).type === condition) {
                                                return i
                                            }
                                        }

                                        return 0
                                    }
                                }
                            }

                            CommonCpp.SGSortFilterProxyModel {
                                id: sortFilterModel
                                sourceModel: filterSuggestionModel
                                sortRole: "suggestion"
                                filterRole: "suggestion"
                                filterPatternSyntax: CommonCpp.SGSortFilterProxyModel.RegExp
                                filterPattern: ".*" + filterStringTextField.text + ".*"
                            }

                            SGWidgets.SGTextField {
                                id: filterStringTextField
                                contextMenuEnabled: true
                                showSuggestionButton: true
                                suggestionCloseWithArrowKey: true
                                suggestionCloseOnMouseSelection: true
                                suggestionHighlightResults: true
                                suggestionListModel: sortFilterModel
                                suggestionModelTextRole: "suggestion"
                                suggestionFilterPattern: filterStringTextField.text

                                onSuggestionDelegateSelected: {
                                   var sourceIndex = sortFilterModel.mapIndexToSource(index)
                                   if (sourceIndex < 0) {
                                        console.error(Logger.sciCategory, "Index out of scope.")
                                        return
                                    }
                                    text = filterSuggestionModel.get(sourceIndex)["suggestion"]
                                }

                                Keys.forwardTo: suggestionPopup.contentItem
                                Keys.priority: Keys.BeforeItem

                                Keys.onPressed: {
                                    if (suggestionPopup.opened === false && filterStringTextField.activeFocus) {
                                        suggestionPopup.open()
                                    }
                                }

                                onTextChanged: {
                                    filterConditionModel.setProperty(index, "filter_string", text)
                                }

                                Binding {
                                    target: filterStringTextField
                                    property: "text"
                                    value: model["filter_string"]
                                }
                            }

                            SGWidgets.SGIconButton {
                                anchors.verticalCenter: parent.verticalCenter
                                icon.source: "qrc:/sgimages/times-circle.svg"
                                iconColor: TangoTheme.palette.error
                                enabled: filterConditionModel.count > 1 || filterStringTextField.text.length > 0

                                onClicked: {
                                    if (filterConditionModel.count > 1) {
                                        filterConditionModel.remove(index)
                                    } else {
                                        filterStringTextField.text = ""
                                    }
                                }
                            }
                        }
                    }
                }
            }

            Row {
                spacing: 16

                SGWidgets.SGButton {
                    id: addButton
                    iconColor: "green"
                    icon.source: "qrc:/sgimages/plus.svg"
                    enabled: disableAllFiltering === false

                    onClicked: {
                        if(filterConditionModel.count > 10) {
                            return
                        }

                        filterConditionModel.addNew()
                        conditionView.currentIndex = filterConditionModel.count - 1
                    }
                }

                SGWidgets.SGCheckBox {
                    id: disableCheck
                    text: "Disable All Filtering"
                    leftPadding: 0

                    checked: disableAllFiltering
                    onCheckedChanged: {
                        disableAllFiltering = checked
                    }
                }
            }

            CommonCpp.SGJsonSyntaxHighlighter {
                textDocument: noteText.textDocument
            }

            SGWidgets.SGTextEdit {
                id: noteText
                width: conditionView.width
                wrapMode: Text.WordWrap
                font.family: "monospace"
                enabled: false
                text: "Example:\n"
                      + "{\n"
                      + "    \"notification\": {\n"
                      + "        \"value\": \"get_firmware_info\",\n"
                      + "        \"payload\": {...}\n"
                      + "    }\n"
                      + "}"
            }
        }
    }

    footer: Item {
        implicitHeight: buttonRow.height + 10

        Row {
            id: buttonRow
            anchors.centerIn: parent
            spacing: 16

            SGWidgets.SGButton {
                text: "Set"
                onClicked: dialog.accept()
            }

            SGWidgets.SGButton {
                text: "Cancel"
                onClicked: dialog.reject()
            }
        }
    }

    function getFilterData() {
        var list = []
        for (var i = 0; i < filterConditionModel.count; ++i) {
            var item = filterConditionModel.get(i)

            if (item["filter_string"].length > 0) {
                list.push(item)
            }
        }

        return list
    }

    function populateFilterData(list) {
        if (list.length > 0) {
            filterConditionModel.set(0, list[0])
        }

        for (var i = 1; i < list.length; ++i) {
            console.log("populateFilterData()",i, JSON.stringify(list[i]))
            filterConditionModel.append(list[i])
        }
    }
}

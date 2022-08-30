/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

import tech.strata.sgwidgets 1.0 as SGWidgets
import tech.strata.theme 1.0
import tech.strata.commoncpp 1.0 as CommonCpp
import tech.strata.logger 1.0

FocusScope {
    id: filterView

    property variant filterSuggestionModel

    property bool disableAllFiltering
    property var filterList: []
    property bool showExample
    property int baseSpacing: 16
    property int contentSpacing: 8
    property int thirdColumnCenter: 1

    signal filterDataChanged()

    Component.onCompleted: {
        populateFilterData(filterList)
    }

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

    TextMetrics {
        id: textMetricsForComboBox
        font.pixelSize: SGWidgets.SGSettings.fontPixelSize
        text: "is equal to"
    }

    FocusScope {
        id: content
        anchors {
            fill: parent
            margins: baseSpacing
        }

        focus: true

        SGWidgets.SGText {
            id: titleText
            anchors {
                top: parent.top
                left: parent.left
            }

            text: "Scrollback Filtering"
            fontSizeMultiplier: 2.0
            font.bold: true
        }

        SGWidgets.SGText {
            id: subtitleText
            anchors {
                top: titleText.bottom
                topMargin: contentSpacing
                left: parent.left
            }
            width: conditionView.width

            text: "Filter out notifications that matches any of the following conditions:"
            wrapMode: Text.Wrap
        }

        Item {
            id: header
            anchors {
                top: subtitleText.bottom
                topMargin: contentSpacing
            }
            height: headerThirdLabel.contentHeight + 4
            width: headerThirdLabel.x + headerThirdLabel.width

            SGWidgets.SGText {
                id: headerThirdLabel
                anchors.verticalCenter: parent.verticalCenter
                x: thirdColumnCenter - width / 2

                text: "Filter String"
            }
        }

        ListView {
            id: conditionView
            anchors {
                top: header.bottom
                bottom: bottomColumn.top
                bottomMargin: contentSpacing
            }
            width: content.width

            model: filterConditionModel
            spacing: contentSpacing
            clip: true
            focus: true
            boundsBehavior: Flickable.StopAtBounds
            highlightMoveDuration: 0
            highlightMoveVelocity: -1

            ScrollBar.vertical: ScrollBar {
                id: verticalScrollbar
                anchors {
                    right: conditionView.right
                    rightMargin: 0
                }
                width: visible ? contentSpacing : 0

                policy: ScrollBar.AlwaysOn
                minimumSize: 0.1
                visible: conditionView.height < conditionView.contentHeight

                Behavior on width { NumberAnimation {}}
            }

            delegate: FocusScope {
                id: delegate
                width: contentRow.width
                height: contentRow.height

                enabled: disableAllFiltering === false
                onActiveFocusChanged: {
                    if (delegate.activeFocus) {
                        conditionView.currentIndex = index
                    }
                }

                Component.onCompleted: {
                    calculateThirdColumnCenter()
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
                    width: verticalScrollbar.visible ? (content.width - verticalScrollbar.width) : content.width
                    spacing: 4

                    property int fillWidth: filterView.width - 2*baseSpacing
                                            - nameFieldTextField.width - spacing
                                            - typeComboBox.width - spacing
                                            - removeButton.width - spacing

                    SGWidgets.SGText {
                        id: nameFieldTextField
                        anchors.verticalCenter: contentRow.verticalCenter
                        text: "Value attribute "
                        horizontalAlignment: Text.AlignHCenter
                    }

                    ComboBox {
                        id: typeComboBox
                        model: conditionTypeModel
                        textRole: "text"
                        width: textMetricsForComboBox.width + indicator.width + leftPadding + rightPadding
                        font.pixelSize: SGWidgets.SGSettings.fontPixelSize

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
                        width: verticalScrollbar.visible ? (contentRow.fillWidth - verticalScrollbar.width) : contentRow.fillWidth
                        contextMenuEnabled: true
                        showSuggestionButton: true
                        suggestionCloseWithArrowKey: true
                        suggestionCloseOnMouseSelection: true
                        suggestionHighlightResults: true
                        suggestionListModel: sortFilterModel
                        suggestionModelTextRole: "suggestion"
                        suggestionFilterPattern: filterStringTextField.text
                        flickableContentY: conditionView.contentY

                        onWidthChanged: {
                            delegate.calculateThirdColumnCenter()
                        }

                        onSuggestionButtonClicked: {
                            positionViewAtCurrentIndex()
                        }

                        onSuggestionDelegateSelected: {
                            var sourceIndex = sortFilterModel.mapIndexToSource(index)
                            if (sourceIndex < 0) {
                                console.error(Logger.sciCategory, "index out of range")
                                return
                            }
                            text = filterSuggestionModel.get(sourceIndex)["suggestion"]
                        }

                        Keys.forwardTo: suggestionPopup.contentItem
                        Keys.priority: Keys.BeforeItem

                        Keys.onPressed: {
                            positionViewAtCurrentIndex()
                            if (suggestionPopup.opened === false && filterStringTextField.activeFocus) {
                                suggestionPopup.open()
                            }
                        }

                        onTextChanged: {
                            positionViewAtCurrentIndex()
                            filterConditionModel.setProperty(index, "filter_string", text)
                        }

                        Binding {
                            target: filterStringTextField
                            property: "text"
                            value: model["filter_string"]
                        }
                    }

                    SGWidgets.SGIconButton {
                        id: removeButton
                        anchors.verticalCenter: contentRow.verticalCenter
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

                function calculateThirdColumnCenter() {
                    if (index === 0) {
                        thirdColumnCenter = filterStringTextField.x + filterStringTextField.width / 2
                    }
                }
            }
        }

        Column {
            id: bottomColumn
            anchors.bottom: content.bottom
            anchors.left: content.left
            spacing: baseSpacing

            Row {
                spacing: baseSpacing

                SGWidgets.SGButton {
                    id: addButton
                    iconColor: TangoTheme.palette.chameleon2
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

            Row {
                id: buttonRow
                spacing: baseSpacing

                SGWidgets.SGButton {
                    text: "Back"
                    icon.source: "qrc:/sgimages/chevron-left.svg"
                    onClicked: {
                        closeView()
                    }
                }

                SGWidgets.SGButton {
                    text: "Set"
                    onClicked: {
                        filterDataChanged()
                        closeView()
                    }
                }
            }
        }
    }

    function closeView() {
        StackView.view.pop();
    }

    function positionViewAtCurrentIndex() {
        conditionView.positionViewAtIndex(conditionView.currentIndex, ListView.Contain)
    }

    function getFilterData() {
        var list = []
        for (var i = 0; i < filterConditionModel.count; ++i) {
            var item = filterConditionModel.get(i)

            if (item["filter_string"].length > 0) {
                list.push({
                              "condition": item["condition"],
                              "filter_string": item["filter_string"],
                          })
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

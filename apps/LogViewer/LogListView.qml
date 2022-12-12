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
import tech.strata.commoncpp 1.0 as CommonCPP
import tech.strata.logviewer.models 1.0 as LogViewModels
import tech.strata.theme 1.0
import tech.strata.logger 1.0

Item {
    id: logViewWrapper

    property alias model: logListView.model
    property alias currentIndex: logListView.currentIndex
    property int cellHeightSpacer: 6
    property int checkBoxSpacer: 60
    property int handleSpacer: 5
    property int searchResultCount: model.count
    property bool timestampColumnVisible: true
    property bool pidColumnVisible: true
    property bool tidColumnVisible: true
    property bool levelColumnVisible: true
    property bool messageColumnVisible: true
    property bool startAnimation: false
    property bool sidePanelShown: true
    property int sidePanelWidth: 150
    property bool messageWrapEnabled: true
    property bool searchTagShown: false
    property var highlightColor
    property string hoverColor: "#a6c5f5"
    property string markColor
    property alias contentX: logListView.contentX
    property alias contentY: logListView.contentY
    property int animationDuration: 500
    property bool automaticScroll: true
    property bool timestampSimpleFormat: false
    property int indexOfVisibleItem: logListView.indexAt(contentX, contentY) //Returns the index of the visible item containing the point x, y in content coordinates.
    property bool showMarks: false
    property bool searchingMode: false
    property int contentRightMargin: 12
    property int contentLeftMargin: 8

    signal delegateSelected(int index)

    function positionViewAtIndex(index, param) {
        logListView.positionViewAtIndex(index, param)
    }

    function positionViewAtEnd() {
        logListView.positionViewAtEnd();
    }

    function copyToClipboard(text) {
        CommonCPP.SGUtilsCpp.copyToClipboard(text)
    }

    //fontMetrics.boundingRect(text) does not re-evaluate itself upon changing the font size
    TextMetrics {
        id: textMetricsTs
        font: timestampHeaderText.font
        text: "9999-99-99 99:99.99.999 +UTC99:99x"
    }

    TextMetrics {
        id: textMetricsTsSimpleTime
        font: timestampHeaderText.font
        text: "99:99.99.999x"
    }

    TextMetrics {
        id: textMetricsPid
        font: timestampHeaderText.font
        text: "1234567890"
    }

    TextMetrics {
        id: textMetricsTid
        font: timestampHeaderText.font
        text: "1234567890"
    }

    TextMetrics {
        id: textMetricsLevelTag
        font: timestampHeaderText.font
        text: "DEBUGx"
    }

    TextMetrics {
        id: textMetricsTsMinimum
        font: timestampHeaderText.font
        text: "Timestamp"
    }

    TextMetrics {
        id: textMetricsPidMinimum
        font: timestampHeaderText.font
        text: "PID  "
    }

    TextMetrics {
        id: textMetricsTidMinimum
        font: timestampHeaderText.font
        text: "TID  "
    }

    TextMetrics {
        id: textMetricsLevelMinimum
        font: timestampHeaderText.font
        text: "Level"
    }

    TextMetrics {
        id: textMetricsMsgMinimum
        font: timestampHeaderText.font
        text: "Message"
    }

    TextMetrics {
        id: textMetricsMark
        font: timestampHeaderText.font
        text: "W"
    }

    Item {
        id: header
        anchors.top: parent.top
        width: parent.width
        height: headerContent.height + 8

        MouseArea {
            anchors.fill: parent
            onClicked: {
                logViewWrapper.forceActiveFocus();
            }
        }

        Rectangle {
            id: headerBg
            anchors.fill: parent
            color: "lightgray"
        }

        RowLayout {
            id: headerContent

            height: messageHeaderText.contentHeight
            anchors {
                left: parent.left
                right: parent.right
                rightMargin: contentRightMargin
            }

            spacing: 8

            Item {
                id: markHeader
                height: textMetricsMark.boundingRect.height
                width: textMetricsMark.boundingRect.width
                Layout.leftMargin: contentLeftMargin
            }

            Divider {
                color: "transparent"
            }

            Item {
                id: tsHeader

                property int preferredWidth: {
                    if (timestampSimpleFormat) {
                        return textMetricsTsSimpleTime.boundingRect.width
                    }

                    return textMetricsTs.boundingRect.width
                }

                Layout.preferredHeight: timestampHeaderText.contentHeight + cellHeightSpacer
                Layout.preferredWidth: preferredWidth
                Layout.minimumWidth: textMetricsTsMinimum.boundingRect.width
                Layout.maximumWidth: logListView.width/2
                visible: timestampColumnVisible

                SGWidgets.SGText {
                    id: timestampHeaderText
                    anchors {
                        left: tsHeader.left
                        verticalCenter: parent.verticalCenter
                    }
                    font.family: "monospace"
                    text: qsTr("Timestamp")
                    elide: Text.ElideRight
                }
            }

            Divider {
                id: tsDivider
                Layout.fillHeight: true
                visible: timestampColumnVisible

                onMouseXChanged: {
                    tsHeader.preferredWidth = tsHeader.width + mouseX
                }
            }

            Item {
                id: pidHeader
                property int preferredWidth: textMetricsPid.boundingRect.width

                Layout.preferredHeight: pidHeaderText.contentHeight + cellHeightSpacer
                Layout.preferredWidth: preferredWidth
                Layout.minimumWidth: textMetricsPidMinimum.boundingRect.width
                Layout.maximumWidth: logListView.width/4
                visible: pidColumnVisible

                SGWidgets.SGText {
                    id: pidHeaderText
                    anchors {
                        left: pidHeader.left
                        verticalCenter: parent.verticalCenter
                    }
                    font.family: "monospace"
                    elide: Text.ElideRight
                    text: qsTr("PID")
                }
            }

            Divider {
                id: pidDivider
                Layout.fillHeight: true
                visible: pidColumnVisible

                onMouseXChanged: {
                    pidHeader.preferredWidth = pidHeader.width + mouseX
                }
            }

            Item {
                id: tidHeader

                property int preferredWidth: textMetricsTid.boundingRect.width

                Layout.preferredHeight: tidHeaderText.contentHeight + cellHeightSpacer
                Layout.preferredWidth: preferredWidth
                Layout.minimumWidth: textMetricsTidMinimum.boundingRect.width
                Layout.maximumWidth: logListView.width/4
                visible: tidColumnVisible

                SGWidgets.SGText {
                    id: tidHeaderText
                    anchors {
                        left: tidHeader.left
                        verticalCenter: parent.verticalCenter
                    }
                    font.family: "monospace"
                    elide: Text.ElideRight
                    text: qsTr("TID")
                }
            }

            Divider {
                id: tidDivider
                Layout.fillHeight: true
                visible: tidColumnVisible

                onMouseXChanged: {
                    tidHeader.preferredWidth = tidHeader.width + mouseX
                }
            }

            Item {
                id: levelHeader

                property int preferredWidth: textMetricsLevelTag.boundingRect.width

                Layout.preferredHeight: levelHeaderText.contentHeight + cellHeightSpacer
                Layout.preferredWidth: preferredWidth
                Layout.minimumWidth: textMetricsLevelMinimum.boundingRect.width
                Layout.maximumWidth: logListView.width/4
                visible: levelColumnVisible

                SGWidgets.SGText {
                    id: levelHeaderText
                    anchors {
                        left: levelHeader.left
                        verticalCenter: parent.verticalCenter
                    }
                    font.family: "monospace"
                    text: qsTr("Level")
                }
            }

            Divider {
                id: levelDivider
                Layout.fillHeight: true
                visible: levelColumnVisible

                onMouseXChanged: {
                    levelHeader.preferredWidth = levelHeader.width + mouseX
                }
            }

            Item {
                id: msgHeader

                Layout.preferredHeight: messageHeaderText.contentHeight + cellHeightSpacer
                Layout.minimumWidth: textMetricsMsgMinimum.boundingRect.width
                Layout.fillWidth: true
                visible: messageColumnVisible

                SGWidgets.SGText {
                    id: messageHeaderText
                    anchors {
                        left: msgHeader.left
                        verticalCenter: parent.verticalCenter
                    }
                    font.family: "monospace"
                    text: qsTr("Message")

                    onFontInfoChanged: {
                        logViewWrapper.contentX = 0
                    }
                }
            }
        }
    }

    SGWidgets.SGTag {
        id: searchTag
        anchors {
            right: logListView.right
            verticalCenter: header.verticalCenter
            rightMargin: 5
        }
        visible: searchTagShown
        text: {
            if (showMarks) {
                if (searchResultCount == 1) {
                    return "Mark Search Result: " + searchResultCount
                }
                return "Mark Search Results: " + searchResultCount
            } else {
                if (searchResultCount == 1) {
                    return "Search Result: " + searchResultCount
                }
                return "Search Results: " + searchResultCount
            }

        }
    }

    ListView {
        id: logListView
        anchors.top: header.bottom
        anchors.bottom: parent.bottom
        anchors.left: header.left
        anchors.right: header.right

        boundsMovement: Flickable.StopAtBounds
        highlightMoveDuration: 0
        highlightMoveVelocity: -1
        clip: true

        Behavior on anchors.rightMargin { NumberAnimation {}}
        Behavior on anchors.bottomMargin { NumberAnimation {}}

        ScrollBar.vertical: ScrollBar {
            id: verticalScrollbar
            parent: logListView.parent
            anchors {
                top: logListView.top
                right: logListView.right
                bottom: logListView.bottom
            }
            width: 10

            policy: ScrollBar.AlwaysOn
            minimumSize: 0.1
            visible: logListView.height < logListView.contentHeight
        }

        onContentYChanged: {
            if (logListView.atYEnd) {
                logViewerMain.automaticScroll = true
            } else {
                logViewerMain.automaticScroll = false
            }
        }

        delegate: FocusScope {
            id: delegate
            width: msg.x + msg.width + contentRightMargin
            height: msg.contentHeight

            property bool isHovered: cellMouseArea.containsMouse

            ListView.onCurrentItemChanged: {
                if (ListView.isCurrentItem && startAnimation) {
                    cellAnimation.start()
                } else {
                    cellAnimation.complete()
                }
            }

            ParallelAnimation {
                id: cellAnimation
                loops: 1
                running: false
                SequentialAnimation {
                    ColorAnimation {
                        target: delegateBg
                        property: "color"
                        from: "white"
                        to: highlightColor
                        duration: animationDuration
                    }
                    ColorAnimation {
                        target: delegateBg
                        property: "color"
                        from: highlightColor
                        to: "darkgray"
                        duration: animationDuration
                    }
                }
                SequentialAnimation {
                    ParallelAnimation {
                        ColorAnimation {
                            targets: [ts,pid,tid,msg]
                            properties: "color"
                            from: "black"
                            to: "white"
                            duration: animationDuration
                        }

                        ColorAnimation {
                            target: level
                            property: "color"
                            from: level.color
                            to: "white"
                            duration: animationDuration
                        }
                    }
                }
            }

            Rectangle {
                id: delegateBg
                anchors.fill: parent

                color: {
                    if (delegate.ListView.isCurrentItem) {
                        if (logViewWrapper.activeFocus) {
                            return highlightColor
                        } else {
                            return "darkgray"
                        }
                    }

                    if (delegate.isHovered) {
                        if (logViewWrapper.activeFocus) {
                            return hoverColor
                        }
                        else {
                            return Qt.lighter("gray")
                        }
                    }

                    if (index % 2) {
                        return "#f2f0f0"
                    } else {
                        return "white"
                    }
                }
            }

            SGWidgets.SGAbstractContextMenu {
                id: contextMenuMarkPopup

                Action {
                    id: copyAction
                    text: qsTr("Copy")
                    onTriggered: {
                        let line = []
                        let delimiter = " , "

                        if (ts.text) {
                            line.push(ts.text)
                        }
                        if (pid.text) {
                            line.push(pid.text)
                        }
                        if (tid.text) {
                            line.push(tid.text)
                        }
                        if (level.text) {
                            line.push(level.text)
                        }
                        if (msg.text) {
                            line.push(msg.text.trim())
                        }
                        copyToClipboard(line.join(delimiter))
                    }
                }

                onClosed: {
                    logViewWrapper.forceActiveFocus()
                }
            }

            MouseArea {
                id: cellMouseArea
                anchors.fill: parent
                hoverEnabled: true
                acceptedButtons: Qt.LeftButton | Qt.RightButton

                onPressed: {
                    logViewWrapper.forceActiveFocus()
                    currentIndex = index
                    delegateSelected(index)
                }

                onReleased: {
                    if (containsMouse && (mouse.button === Qt.RightButton)) {
                        contextMenuMarkPopup.popup(null)
                    }
                }
            }

            SGWidgets.SGIcon {
                id: markIconWithMouseArea
                width: textMetricsMark.boundingRect.width
                height: textMetricsMark.boundingRect.height - 2
                x: markHeader.x
                anchors {
                    top: parent.top
                    topMargin: 1
                }

                source: model.isMarked ? "qrc:/sgimages/bookmark.svg" : "qrc:/sgimages/bookmark-blank.svg"
                iconColor: delegate.ListView.isCurrentItem || delegate.isHovered || model.isMarked ? markColor : delegateBg.color

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor

                    onClicked: {
                        logViewWrapper.forceActiveFocus()
                        var sourceIndex = logSortFilterModel.mapIndexToSource(index)
                        if (sourceIndex < 0) {
                            console.error(Logger.logviewerCategory, "index out of range")
                            return
                        }
                        delegate.isHovered ? logModel.toggleIsMarked(sourceIndex) : logModel.toggleIsMarked(currentIndex)
                    }
                }
            }

            SGWidgets.SGText {
                id: ts
                x: tsHeader.x
                width: tsHeader.width
                color: delegate.ListView.isCurrentItem ? "white" : "black"
                font.family: "monospace"
                text: {
                    if (visible) {
                        if (timestampSimpleFormat) {
                            return Qt.formatDateTime(model.timestamp, simpleTimestampFormat)
                        } else {
                            return CommonCPP.SGUtilsCpp.formatDateTimeWithOffsetFromUtc(model.timestamp, timestampFormat)
                        }
                    } else {
                        return ""
                    }
                }
                visible: timestampColumnVisible
                elide: messageWrapEnabled ? Text.Normal : Text.ElideRight
                wrapMode: messageWrapEnabled ? Text.WrapAtWordBoundaryOrAnywhere : Text.NoWrap
            }

            SGWidgets.SGText {
                id: pid
                x: pidHeader.x
                width: pidHeader.width
                color: delegate.ListView.isCurrentItem ? "white" : "black"
                font.family: "monospace"
                text: visible ? model.pid : ""
                visible: pidColumnVisible
                elide: messageWrapEnabled ? Text.Normal : Text.ElideRight
                wrapMode: messageWrapEnabled ? Text.WrapAtWordBoundaryOrAnywhere : Text.NoWrap
            }

            SGWidgets.SGText {
                id: tid
                x: tidHeader.x
                width: tidHeader.width
                color: delegate.ListView.isCurrentItem ? "white" : "black"
                font.family: "monospace"
                text: visible ? model.tid : ""
                visible: tidColumnVisible
                elide: messageWrapEnabled ? Text.Normal : Text.ElideRight
                wrapMode: messageWrapEnabled ? Text.WrapAtWordBoundaryOrAnywhere : Text.NoWrap
            }

            SGWidgets.SGText {
                id: level
                x: levelHeader.x
                width: levelHeader.width
                leftPadding: 2
                elide: messageWrapEnabled ? Text.Normal : Text.ElideRight
                wrapMode: messageWrapEnabled ? Text.WrapAtWordBoundaryOrAnywhere : Text.NoWrap
                visible: levelColumnVisible
                color: {
                    if (delegate.ListView.isCurrentItem
                            || (model.level === LogViewModels.LogLevel.LevelWarning
                                || model.level === LogViewModels.LogLevel.LevelError)) {
                        return "white"
                    } else {
                        return "black"
                    }
                }
                font.family: "monospace"
                text: {
                    if (visible) {
                        switch (model.level) {
                        case LogViewModels.LogLevel.LevelDebug:
                            return "DEBUG"
                        case LogViewModels.LogLevel.LevelInfo:
                            return "INFO"
                        case LogViewModels.LogLevel.LevelWarning:
                            return "WARN"
                        case LogViewModels.LogLevel.LevelError:
                            return "ERROR"
                        }
                        return ""
                    } else {
                        return ""
                    }
                }

                TextMetrics {
                    id: textMetricsLevel
                    font: level.font
                    text: level.text
                }

                Rectangle {
                    id: levelTag
                    anchors.top: parent.top
                    anchors.topMargin: 1
                    height: level.height - 2
                    width: levelHeader.width < textMetricsLevel.boundingRect.width + 5 ? parent.width : textMetricsLevel.boundingRect.width + 5
                    radius: 4
                    z: -1
                    color: {
                        if (model.level === LogViewModels.LogLevel.LevelWarning) {
                            return TangoTheme.palette.warning
                        }
                        if (model.level === LogViewModels.LogLevel.LevelError) {
                            return TangoTheme.palette.error
                        } else {
                            return delegateBg.color
                        }
                    }
                    clip: true
                }
            }

            SGWidgets.SGText {
                id: msg
                x: msgHeader.x
                width: msgHeader.width
                color: delegate.ListView.isCurrentItem ? "white" : "black"
                font.family: "monospace"
                text: visible ? model.message : ""
                visible: messageColumnVisible
                elide: messageWrapEnabled ? Text.Normal : Text.ElideRight
                wrapMode: messageWrapEnabled ? Text.WrapAtWordBoundaryOrAnywhere : Text.NoWrap
            }
        }
    }

    Keys.onPressed: {
        if (event.key === Qt.Key_Up && currentIndex > 0){
            currentIndex = currentIndex - 1
        } else if (event.key === Qt.Key_Down && currentIndex < (searchResultCount - 1)) {
            currentIndex = currentIndex + 1
        } else if (event.key === Qt.Key_PageDown) {
            contentY = contentY + logListView.height

            if (currentIndex < indexOfVisibleItem) {
                currentIndex = indexOfVisibleItem
            } else {
                currentIndex = logListView.count - 1
            }
        } else if (event.key === Qt.Key_PageUp) {
            contentY = contentY - logListView.height

            if ((currentIndex > indexOfVisibleItem) && (indexOfVisibleItem > 0)) {
                currentIndex = indexOfVisibleItem
            } else {
                currentIndex = 0
            }
        } else if (event.key === Qt.Key_Home) {
            logListView.positionViewAtBeginning()
        } else if (event.key === Qt.Key_End) {
            logListView.positionViewAtEnd()
        } else if (event.key === Qt.Key_M) {
            var sourceIndex = logSortFilterModel.mapIndexToSource(currentIndex)
            if (sourceIndex < 0) {
                console.error(Logger.logviewerCategory, "index out of range")
                return
            }
            logModel.toggleIsMarked(sourceIndex)
        }
    }
}

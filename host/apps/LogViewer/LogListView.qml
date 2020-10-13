import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import tech.strata.sgwidgets 1.0 as SGWidgets
import tech.strata.commoncpp 1.0 as CommonCPP
import tech.strata.logviewer.models 1.0 as LogViewModels

Item {
    id: logViewWrapper

    property alias model: logListView.model
    property alias currentIndex: logListView.currentIndex
    property int cellWidthSpacer: 6
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
    property alias contentX: logListView.contentX
    property alias contentY: logListView.contentY
    property int animationDuration: 500
    property bool automaticScroll: true
    property bool timestampSimpleFormat: false

    signal currentItemChanged(int index)

    function positionViewAtIndex(index, param) {
        logListView.positionViewAtIndex(index, param)
    }

    function positionViewAtEnd() {
        logListView.positionViewAtEnd();
    }

    //fontMetrics.boundingRect(text) does not re-evaluate itself upon changing the font size
    TextMetrics {
        id: textMetricsTs
        font: timestampHeaderText.font
        text: "9999-99-99 99:99.99.999 +UTC99:99"
    }

    TextMetrics {
        id: textMetricsTsSimpleTime
        font: timestampHeaderText.font
        text: "99:99.99.999"
    }

    TextMetrics {
        id: textMetricsPid
        font: timestampHeaderText.font
        text: "9999999999"
    }

    TextMetrics {
        id: textMetricsTid
        font: timestampHeaderText.font
        text: "9999999999"
    }

    TextMetrics {
        id: textMetricsLevelTag
        font: timestampHeaderText.font
        text: "DEBUG"
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

    Item {
        id: header
        anchors.top: parent.top
        width: if (logListView.contentWidth > root.width) {
                   return logListView.contentWidth
               } else {
                   return root.width
               }
        height: headerContent.height + 8
        x: -logViewWrapper.contentX

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
            spacing: 8

            Item {
                id: tsHeader
                Layout.preferredHeight: timestampHeaderText.contentHeight + cellHeightSpacer
                Layout.preferredWidth: timestampSimpleFormat ? textMetricsTsSimpleTime.boundingRect.width + cellWidthSpacer : textMetricsTs.boundingRect.width + cellWidthSpacer
                Layout.minimumWidth: textMetricsTsMinimum.boundingRect.width
                Layout.maximumWidth: logListView.width/2
                Layout.leftMargin: handleSpacer
                Layout.fillWidth: true

                visible: timestampColumnVisible
                clip: true

                onWidthChanged: {
                    if (tsDivider.mouseArea.onPressed) {
                        Layout.preferredWidth = width
                    }
                }

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
                clickable: true

                mouseArea.onMouseXChanged: {
                    tsHeader.width = tsHeader.width + mouseX
                }
            }

            Item {
                id: pidHeader
                Layout.preferredHeight: pidHeaderText.contentHeight + cellHeightSpacer
                Layout.preferredWidth: textMetricsPid.boundingRect.width + cellWidthSpacer
                Layout.minimumWidth: textMetricsPidMinimum.boundingRect.width
                Layout.maximumWidth: logListView.width/4
                Layout.fillWidth: true

                visible: pidColumnVisible
                clip: true

                onWidthChanged: {
                    if (pidDivider.mouseArea.onPressed) {
                        Layout.preferredWidth = width
                    }
                }

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
                clickable: true

                mouseArea.onMouseXChanged: {
                    pidHeader.width = pidHeader.width + mouseX
                }
            }

            Item {
                id: tidHeader
                Layout.preferredHeight: tidHeaderText.contentHeight + cellHeightSpacer
                Layout.preferredWidth: textMetricsTid.boundingRect.width + cellWidthSpacer
                Layout.minimumWidth: textMetricsTidMinimum.boundingRect.width
                Layout.maximumWidth: logListView.width/4
                Layout.fillWidth: true

                visible: tidColumnVisible
                clip: true

                onWidthChanged: {
                    if (tidDivider.mouseArea.onPressed) {
                        Layout.preferredWidth = width
                    }
                }

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
                clickable: true

                mouseArea.onMouseXChanged: {
                    tidHeader.width = tidHeader.width + mouseX
                }
            }

            Item {
                id: levelHeader
                Layout.preferredHeight: levelHeaderText.contentHeight + cellHeightSpacer
                Layout.preferredWidth: textMetricsLevelTag.boundingRect.width + cellWidthSpacer
                Layout.minimumWidth: textMetricsLevelMinimum.boundingRect.width
                Layout.maximumWidth: logListView.width/4
                Layout.fillWidth: true

                visible: levelColumnVisible
                clip: true

                onWidthChanged: {
                    if (levelDivider.mouseArea.onPressed) {
                        Layout.preferredWidth = width
                    }
                }

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
                clickable: true

                mouseArea.onMouseXChanged: {
                    levelHeader.width = levelHeader.width + mouseX
                }
            }

            Item {
                id: msgHeader
                Layout.preferredHeight: messageHeaderText.contentHeight + cellHeightSpacer
                Layout.preferredWidth: root.width
                Layout.minimumWidth: textMetricsMsgMinimum.boundingRect.width
                Layout.fillWidth: true

                visible: messageColumnVisible
                clip: true

                onWidthChanged: {
                    if (msgDivider.mouseArea.onPressed) {
                        Layout.preferredWidth = width
                    }
                }

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

            Divider {
                id: msgDivider
                Layout.fillHeight: true
                visible: messageColumnVisible
                clickable: true

                mouseArea.onMouseXChanged: {
                    msgHeader.width = msgHeader.width + mouseX
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
        text: searchResultCount == 1 ? "Search Result: " + searchResultCount : "Search Results: " + searchResultCount
    }

    ListView {
        id: logListView
        anchors.top: header.bottom
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        flickableDirection: Flickable.HorizontalAndVerticalFlick
        boundsMovement: Flickable.StopAtBounds
        boundsBehavior: Flickable.DragAndOvershootBounds
        highlightMoveDuration: 0
        highlightMoveVelocity: -1

        clip: true

        ScrollBar.vertical: ScrollBar {
            minimumSize: 0.1
            policy: ScrollBar.AlwaysOn
        }

        ScrollBar.horizontal: ScrollBar {
            id: horizontalScrollbar
            minimumSize: 0.1
            policy: ScrollBar.AsNeeded
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
            width: row.width
            height: row.height

            onWidthChanged: {
                logListView.contentWidth = delegate.width + 10
            }

            ListView.onCurrentItemChanged : {
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
                        target: cell
                        property: "color"
                        from: "white"
                        to: highlightColor
                        duration: animationDuration
                    }
                    ColorAnimation {
                        target: cell
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
                id: cell
                height: parent.height
                width: if (logListView.contentWidth > root.width) {
                           return logListView.contentWidth
                       } else {
                           return root.width
                       }
                color: {
                    if (delegate.ListView.isCurrentItem) {
                        if (logViewWrapper.activeFocus) {
                            return highlightColor
                        } else {
                            return "darkgray"
                        }
                    }
                    if (index % 2) {
                        return "#f2f0f0"
                    } else {
                        return "white"
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onPressed:  {
                        logViewWrapper.forceActiveFocus()
                        logListView.currentIndex = index
                        currentItemChanged(index)
                    }
                }
            }

            Row {
                id: row
                leftPadding: handleSpacer
                spacing: 18

                SGWidgets.SGText {
                    id: ts
                    width: tsHeader.width
                    color: delegate.ListView.isCurrentItem ? "white" : "black"
                    font.family: "monospace"
                    text: {
                        if (visible) {
                            if (timestampSimpleFormat == false) {
                                return CommonCPP.SGUtilsCpp.formatDateTimeWithOffsetFromUtc(model.timestamp, timestampFormat)
                            } else {
                                return Qt.formatDateTime(model.timestamp, simpleTimestampFormat)
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
                    width: levelHeader.width
                    leftPadding: 2
                    elide: messageWrapEnabled ? Text.Normal : Text.ElideRight
                    wrapMode: messageWrapEnabled ? Text.WrapAtWordBoundaryOrAnywhere : Text.NoWrap
                    visible: levelColumnVisible
                    color: {
                        if (delegate.ListView.isCurrentItem
                                || (model.level === LogViewModels.LogModel.LevelWarning
                                    || model.level === LogViewModels.LogModel.LevelError)) {
                            return "white"
                        } else {
                            return "black"
                        }
                    }
                    font.family: "monospace"
                    text: {
                        if (visible) {
                            switch (model.level) {
                            case LogViewModels.LogModel.LevelDebug:
                                return "DEBUG"
                            case LogViewModels.LogModel.LevelInfo:
                                return "INFO"
                            case LogViewModels.LogModel.LevelWarning:
                                return "WARN"
                            case LogViewModels.LogModel.LevelError:
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
                            if (model.level === LogViewModels.LogModel.LevelWarning) {
                                return SGWidgets.SGColorsJS.WARNING_COLOR
                            }
                            if (model.level === LogViewModels.LogModel.LevelError) {
                                return SGWidgets.SGColorsJS.ERROR_COLOR
                            } else {
                                return cell.color
                            }
                        }
                        clip: true
                    }
                }

                SGWidgets.SGText {
                    id: msg
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
    }

    property var currentPosition: logListView.indexAt(contentX, contentY)

    Keys.onPressed: {
        if (event.key === Qt.Key_Up && currentIndex > 0){
            currentIndex = currentIndex - 1
            currentItemChanged(currentIndex)
        } else if (event.key === Qt.Key_Down && currentIndex < (searchResultCount - 1)) {
            currentIndex = currentIndex + 1
            currentItemChanged(currentIndex)
        }
        else if (event.key === Qt.Key_Left) {
            contentX = contentX - logListView.width
        }
        else if (event.key === Qt.Key_Right) {
            contentX = contentX + logListView.width
        }
        else if (event.key === Qt.Key_PageDown) {
            contentY = contentY + logListView.height

            if (currentIndex < currentPosition) {
                currentIndex = currentPosition
            } else {
                currentIndex = logListView.count - 1
            }
            currentItemChanged(currentIndex)
        }
        else if (event.key === Qt.Key_PageUp) {
            contentY = contentY - logListView.height

            if ((currentIndex > currentPosition) && (currentPosition > 0)) {
                currentIndex = currentPosition
            } else {
                currentIndex = 0
            }
            currentItemChanged(currentIndex)
        }
        else if (event.key === Qt.Key_Home) {
            logListView.positionViewAtBeginning()
        }
        else if (event.key === Qt.Key_End) {
            logListView.positionViewAtEnd()
        }
    }
}

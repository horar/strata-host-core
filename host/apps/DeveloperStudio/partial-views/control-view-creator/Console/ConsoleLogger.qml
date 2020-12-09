import QtQuick 2.12
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.12

import tech.strata.sgwidgets 1.0
import tech.strata.commoncpp 1.0

ScrollView {
    id: root
    width: parent.width
    height: parent.height
    clip: true
    wheelEnabled: true

    property double fontMultiplier: 1.1
    property string searchText: ""
    property int defaultRole: 1
    property int hit: -1

    onFontMultiplierChanged: {
        if(fontMultiplier >= 2.0){
            fontMultiplier = 2.0
        } else if(fontMultiplier <= 1.0){
            fontMultiplier = 1.0
        }
    }

    ListView {
        id: consoleLogs
        anchors.fill: parent
        model: consoleItems
        clip: true
        spacing: 0

        delegate: Rectangle {
            width: parent.width - 50
            height: consoleItems.filterAcceptsRow(model.index) ? 20 : 0
            color: "#eee"
            anchors.leftMargin: 10
            visible: consoleItems.filterAcceptsRow(model.index)
            RowLayout{
                id: row
                anchors.fill: parent
                height: msgText.height
                SGText {
                    id: msgTime
                    fontSizeMultiplier: fontMultiplier
                    wrapMode: Text.WordWrap
                    Layout.minimumWidth: 85
                    Layout.preferredWidth: 85
                    text: model.time
                }

                RowLayout {
                    Layout.preferredHeight: textMetric.height
                    Layout.preferredWidth: textMetric.width

                    spacing: 0

                    SGText {
                        id: leftSide
                        Layout.alignment: Qt.AlignLeft
                        text: leftSidesColor(model.type)
                        fontSizeMultiplier: fontMultiplier
                    }

                    SGText {
                        id: msgType
                        Layout.alignment: Qt.AlignCenter
                        text: getMsgType(model.type)
                        fontSizeMultiplier: fontMultiplier
                    }

                    SGText {
                        id: rightSide
                        Layout.alignment: Qt.AlignRight
                        text: rightSidesColor(model.type)
                        fontSizeMultiplier: fontMultiplier
                    }
                }

                SGText {
                    id: msgText
                    fontSizeMultiplier: fontMultiplier
                    Layout.fillWidth: true
                    Layout.minimumHeight: textMetric.height
                    elide: Text.ElideRight
                    text: model.msg
                }
            }
        }
    }

    SGSortFilterProxyModel {
        id: consoleItems
        sourceModel: consoleModel
        sortEnabled: true
        invokeCustomFilter: true

        function filterAcceptsRow(row){
            var item = sourceModel.get(row)
            return containsFilterText(item)
        }

        function containsFilterText(item){
            if(searchText === ""){
                return true
            } else {
                let type;

                switch(item.type){
                case 0:
                    type = "debug"
                    break;
                case 1:
                    type = "warning"
                    break;
                case 2:
                    type = "error"
                    break;
                case 4:
                    type = "info"
                    break;
                }

                var searchMsg = item.time  + ` [ ${type} ] ` + item.msg
                if(searchMsg.includes(searchText)){
                    return true
                } else {
                    return false
                }
            }
        }
    }

    ListModel {
        id: consoleModel
    }

    Connections {
        id: srcConnection
        target: logger
        onLogMsg: {
            if(parent.visible){
                consoleModel.append({time: timestamp(), type: type, msg: msg})

                if(type === 1){
                    warningCount += 1
                }
                if(type === 2){
                    errorCount += 1
                }
            }
        }
    }

    function rightSidesColor(type){
        switch(type){
        case 0: return "<font color=\"cyan\" > ] </font>"
        case 1: return "<font color=\"#ffd700\"> ] </font>"
        case 2: return "<font color=\"red\"> ] </font>"
        case 4: return "<font color=\"green\"> ] </font>"
        }
    }

    function leftSidesColor(type){
        switch(type){
        case 0: return "<font color=\"cyan\" > [ </font>"
        case 1: return "<font color=\"#ffd700\"> [ </font>"
        case 2: return "<font color=\"red\"> [ </font>"
        case 4: return "<font color=\"green\"> [ </font>"
        }
    }

    function getMsgType(type){
        switch(type){
        case 0: return "<font color=\"cyan\" > debug </font>"
        case 1: return "<font color=\"#ffd700\"> warning </font>"
        case 2: return "<font color=\"red\"> error </font>"
        case 4: return "<font color=\"green\"> info </font>"
        }
    }


    function timestamp(){
        var date = new Date(Date.now())
        let hours = date.getHours()
        let minutes = date.getMinutes()
        let seconds = date.getSeconds()
        let millisecs = date.getMilliseconds()


        if(hours < 10){
            hours = `0${hours}`
        }

        if(minutes < 10){
            minutes = `0${minutes}`
        }

        if(seconds < 10){
            seconds = `0${seconds}`
        }

        if(millisecs < 100){
            if(millisecs < 10){
                millisecs =`00${millisecs}`
            } else {
                millisecs = `0${millisecs}`
            }
        }

        return `${hours}:${minutes}:${seconds}.${millisecs}`
    }

    function clearLogs() {
        consoleItems.clear();
        consoleModel.clear();
        errorCount = 0
        warningCount = 0
    }

    TextMetrics {
        id: textMetric
        text: `[  warning  ]`
        font.pixelSize: 13 * fontMultiplier
    }
}

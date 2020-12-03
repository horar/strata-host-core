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

    property double fontMultiplier: 1.3
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
            height: consoleItems.filterAcceptsRow(model.index) ? msgText.height * fontMultiplier : 0
            color: "#eee"
            anchors.leftMargin: 10
            visible: consoleItems.filterAcceptsRow(model.index)

            SGText {
                id: msgText
                fontSizeMultiplier: fontMultiplier
                wrapMode: Text.WordWrap
                width: parent.width
                text: `${model.time} \t ${getMsgType(type)} \t ${model.msg}`
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
                var searchMsg = item.msg
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
            }
        }
    }

    function getMsgType(type){
        switch(type){
        case 0: return "<font color=\"cyan\" > \t[\tdebug\t]\t </font>"
        case 1: return "<font color=\"yellow\"> \t[warning]\t </font>"
        case 2: return "<font color=\"red\"> \t[\terror\t]\t </font>"
        case 4: return "<font color=\"green\"> \t[\tinfo\t]\t </font>"
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
}

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

    onSearchTextChanged: {

    }

    ListView {
        id: consoleLogs
        anchors.fill: parent
        model: consoleItems

        clip: true

        delegate: Rectangle {
            width: parent.width
            height: consoleItems.filterAcceptsRow(model.index) ? row.height : 0
            color: "#eee"
            anchors.leftMargin: 10
            visible: consoleItems.filterAcceptsRow(model.index)

            RowLayout {
                id: row

                SGText {
                    text: model.time
                    fontSizeMultiplier: fontMultiplier
                    leftPadding: 5
                    rightPadding: 5
                }

                Item{
                    Layout.preferredWidth: 100
                    Layout.preferredHeight: 20

                    SGText {
                        text: "["
                        anchors.left: parent.left
                        anchors.leftMargin: 10
                        fontSizeMultiplier: fontMultiplier
                        color: switch(model.type){
                               case 2:
                                   return "red"
                               case 1:
                                   return "yellow"
                               case 0:
                                   return "cyan"
                               case 4:
                                   return "green"
                               case 3:
                                   return "grey"
                               }
                    }


                    SGText {
                        id: errorTxt
                        anchors.centerIn: parent

                        color: switch(model.type){
                               case 2:
                                   return "red"
                               case 1:
                                   return "yellow"
                               case 0:
                                   return "cyan"
                               case 4:
                                   return "green"
                               case 3:
                                   return "grey"
                               }
                        text: switch(model.type){
                              case 2:
                                  return "error"
                              case 1:
                                  return "warning"
                              case 0:
                                  return "debug"
                              case 4:
                                  return "info"
                              case 3:
                                  return "log"
                              }

                        fontSizeMultiplier: fontMultiplier
                    }

                    SGText {
                        text: "]"
                        anchors.right: parent.right
                        anchors.rightMargin: 10
                        fontSizeMultiplier: fontMultiplier
                        color: switch(model.type){
                               case 2:
                                   return "red"
                               case 1:
                                   return "yellow"
                               case 0:
                                   return "cyan"
                               case 4:
                                   return "green"
                               case 3:
                                   return "grey"
                               }
                    }
                }

                SGText {
                    text: model.msg
                    fontSizeMultiplier: fontMultiplier
                    Layout.preferredWidth: 1100
                    Layout.maximumHeight: 40
                    wrapMode: Text.WordWrap
                    leftPadding: 5
                    rightPadding: 5
                    Layout.alignment: Qt.AlignVCenter
                }

                Item {
                    Layout.preferredWidth: 10
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
                consoleModel.append({time: new Date(Date.now()).toUTCString(), type: type, msg: msg})
            }
        }
    }
}

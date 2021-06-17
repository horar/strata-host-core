import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import tech.strata.sgwidgets 1.0

Item {
    id: exSgIcon
    width: contentColumn.width
    height: contentColumn.height
    
    ColumnLayout {
        id: contentColumn

        SGAlignedLabel {
            target: basicIconGrid
            text: "SGWidgets Icons"
            fontSizeMultiplier: 1.3

            GridLayout {
                id: basicIconGrid
                width: flickWrapper.width
                rowSpacing: 1
                columnSpacing: 1
                columns: {
                    let columnCount = width / longestTextWidth.boundingRect.width
                    return columnCount
                }

                Repeater {
                    id: repeater
                    model: iconModel

                    delegate: ColumnLayout {
                        id: basicDelegate
                        width: longestTextWidth.boundingRect.width
                        visible: model.visibility

                        SGIcon {
                            id: icon
                            source: model.source
                            width: basicDelegate.width
                            height: 22
                            iconColor: model.color
                            Layout.alignment: Qt.AlignHCenter
                        }

                        SGText {
                            text: model.name
                            width: basicDelegate.width
                            Layout.alignment: Qt.AlignHCenter
                            fontSizeMultiplier: 1.1
                        }
                    }
                }
            }
        }

        RowLayout {
            id: toolRow
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            
            SGButton {
                id: colorButton
                Layout.alignment: Qt.AlignHCenter
                text: "Randomize Colors"

                onClicked: {
                    for (let i = 0; i < iconModel.count; i++) {
                        const icon = iconModel.get(i)
                        iconModel.set(i,
                            {
                                "name": icon.name,
                                "source": icon.source,
                                "color": randomColor(),
                                "visibility": true,
                            }
                        )
                    }
                }
            }

            SGCheckBox {
                id: visibileButton
                Layout.alignment: Qt.AlignHCenter
                text: "Toggle Visibilty "
                checked: true

                onCheckedChanged: {
                    for (let i = 0; i < iconModel.count; i++) {
                        const icon = iconModel.get(i)
                        iconModel.set(i,
                            {
                                "name": icon.name,
                                "source": icon.source,
                                "color": "black",
                                "visibility": checked
                            }
                        )
                    }
                }
            }
        }
    }

    ListModel {
        id: iconModel

        Component.onCompleted: {
            // list of svg icons that are located in SGWidgets
            let arr = [
                    "arrow-list-bottom","asterisk","ban","bars","bookmark-blank","bookmark","broom",
                    "check-circle","chevron-down","chevron-left","chevron-right","chevron-up","chip-flash",
                    "clock","cog","connected","disconnected","download","drop-file","edit","exclamation-circle",
                    "exclamation-triangle","exclamation","eye-slash","eye","file-add","file-blank","file-export",
                    "file-import","folder-open-solid","folder-open","folder-plus","funnel","info-circle","list",
                    "minus","plug","plus","question-circle","redo","save","sign-in","sign-out",
                    "sliders-h","sliders-v","status-light-off","status-light-transparent","times-circle",
                    "times","tools","undo","user","zoom"
                ]

            for (let i = 0; i < arr.length; i++) {
                append(
                    {
                        "name": arr[i],
                        "source": `qrc:/sgimages/${arr[i]}.svg`,
                        "color": "black",
                        "visibility": true
                    }
                )
            }
        }
    }

    TextMetrics {
        id: longestTextWidth
        text: "status-light-transparent"
        font.pixelSize: 13 * 1.1
    }

    function randomColor() {
        return Qt.rgba(Math.random(),Math.random(),Math.random(),1).toString()
    }

}

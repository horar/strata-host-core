import QtQuick 2.12
import tech.strata.sgwidgets 1.0 as SGWidgets
import tech.strata.logger 1.0

Item {

    width: contentColumn.width
    height: editEnabledCheckBox.y + editEnabledCheckBox.height

    Column {
        id: contentColumn

        spacing: 20
        enabled: editEnabledCheckBox.checked

        Column {
            SGWidgets.SGText {
                text: "Exclusive mode"
                fontSizeMultiplier: 1.3
            }

            SGWidgets.SGButtonStrip {
                id: buttonStrip1
                model: ["One","Two","Three","Four"]

                onClicked: {
                    console.info(Logger.wgCategory, "buttonStrip1", index)
                }
            }

            SGWidgets.SGText {
                text: {
                    var checkedButtons = []
                    for (var i =0; i < buttonStrip1.count; ++i) {
                        if (buttonStrip1.isChecked(i)) {
                            checkedButtons.push(i)
                        }
                    }

                    return "checkedIndices="+buttonStrip1.checkedIndices+"\n"+
                            "checkedButtons="+checkedButtons.join(" ")
                }
            }
        }

        Column {
            SGWidgets.SGText {
                text: "Non-exclusive mode"
                fontSizeMultiplier: 1.3
            }

            SGWidgets.SGButtonStrip {
                id: buttonStrip2
                model: ["One","Two","Three","Four"]
                exclusive: false

                onClicked: {
                    console.info(Logger.wgCategory, "buttonStrip2", index)
                }
            }

            SGWidgets.SGText {
                text: {
                    var checkedButtons = []
                    for (var i =0; i < buttonStrip2.count; ++i) {
                        if (buttonStrip2.isChecked(i)) {
                            checkedButtons.push(i)
                        }
                    }

                    return "checkedIndices=" + buttonStrip2.checkedIndices + "\n"
                            + "checkedButtons=" + checkedButtons.join(" ")
                }
            }
        }

        Column {
            SGWidgets.SGText {
                text: "Vertical orientation"
                fontSizeMultiplier: 1.3
            }

            SGWidgets.SGButtonStrip {
                id: buttonStrip3
                model: ["One","Two","Three","Four"]
                orientation: Qt.Vertical

                onClicked: {
                    console.info(Logger.wgCategory, "buttonStrip3", index)
                }
            }

            SGWidgets.SGText {
                text: "checkedIndices= " + buttonStrip3.checkedIndices
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

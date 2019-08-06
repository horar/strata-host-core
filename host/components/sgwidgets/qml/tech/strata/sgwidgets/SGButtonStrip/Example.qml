import QtQuick 2.12
import tech.strata.sgwidgets 1.0 as SGWidgets

Grid {
    spacing: 20
    columns: 2


    // example 1
    SGWidgets.SGButtonStrip {
        id: buttonStrip1
        model: ["One","Two","Three","Four"]

        onClicked: {
            console.log("buttonStrip1 onClicked", index)
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


    // example 2
    SGWidgets.SGButtonStrip {
        id: buttonStrip2
        model: ["One","Two","Three","Four"]
        exclusive: false

        onClicked: {
            console.log("buttonStrip2 onClicked", index)
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

            return "checkedIndices="+buttonStrip2.checkedIndices+"\n"+
                   "checkedButtons="+checkedButtons.join(" ")
        }
    }


    // example 3
    SGWidgets.SGButtonStrip {
        id: buttonStrip3
        model: ["One","Two","Three","Four"]
        orientation: Qt.Vertical

        onClicked: {
            console.log("buttonStrip3 onClicked", index)
        }
    }

    SGWidgets.SGText {
        text: "checkedIndices= " + buttonStrip3.checkedIndices
    }
}

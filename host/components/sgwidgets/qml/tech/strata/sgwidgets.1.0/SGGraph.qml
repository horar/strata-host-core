import QtQuick 2.0
import tech.strata.commoncpp 1.0
import QtQuick.Controls 2.12

QwtQuick2Plot {
    id: root
//    anchors.fill: parent

    Component.onCompleted: {
        initQwtPlot()
    }

    function startTimers(milliseconds) {
        timer.start()
        root.startTime(milliseconds)
    }

    function stopTimers() {
        timer.stop()
        root.stopTime()
    }
}

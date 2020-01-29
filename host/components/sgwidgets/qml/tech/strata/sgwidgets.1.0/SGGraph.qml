import QtQuick 2.0
import tech.strata.commoncpp 1.0
import QtQuick.Controls 2.12

SGQWTPlot {
    id: root

    Component.onCompleted: {
        initialize()
    }

    property bool panXEnabled: true
    property bool panYEnabled: true
    property bool zoomXEnabled: true
    property bool zoomYEnabled: true

    MouseArea {
        anchors.fill: parent
        enabled: (root.panXEnabled || root.panYEnabled || root.zoomXEnabled || root.zoomYEnabled) && !(root.xLogarithmic || root.yLogarithmic)
        preventStealing: true

        property point mousePosition: "0,0"
        property int wheelChoke: 0 // chokes output of high resolution trackpads on mac

        onPressed: {
            if (root.panXEnabled || root.panYEnabled) {
                mousePosition = Qt.point(mouse.x, mouse.y)
            }
        }

        onPositionChanged: {
            if (root.panXEnabled || root.panYEnabled) {
                let originToPosition = root.mapToPosition(Qt.point(0,0))
                originToPosition.x += (mouse.x - mousePosition.x)
                originToPosition.y += (mouse.y - mousePosition.y)
                let deltaLocation = root.mapToValue(originToPosition)
                root.autoUpdate = false
                if (root.panXEnabled) {
                    root.shiftXAxis(-deltaLocation.x)
                }
                if (root.panYEnabled) {
                    root.shiftYAxis(-deltaLocation.y)
                }
                root.autoUpdate = true
                root.update()

                mousePosition = Qt.point(mouse.x, mouse.y)

            }
        }

        onWheel: {
            if (root.zoomXEnabled || root.zoomYEnabled){
                wheelChoke += wheel.angleDelta.y

                if (wheelChoke > 119 || wheelChoke < -119){
                    var scale = Math.pow(1.5, wheelChoke * 0.001)

                    var scaledChartWidth = (root.xMax - root.xMin) / scale
                    var scaledChartHeight = (root.yMax - root.yMin) / scale

                    var chartCenter = Qt.point((root.xMin + root.xMax) / 2, (root.yMin + root.yMax) / 2)
                    var chartWheelPosition = mapToValue(Qt.point(wheel.x, wheel.y))
                    var chartOffset = Qt.point((chartCenter.x - chartWheelPosition.x) * (1 - scale), (chartCenter.y - chartWheelPosition.y) * (1 - scale))

                    root.autoUpdate = false

                    if (root.zoomXEnabled) {
                        root.xMin = (chartCenter.x - (scaledChartWidth / 2)) + chartOffset.x
                        root.xMax = (chartCenter.x + (scaledChartWidth / 2)) + chartOffset.x
                    }
                    if (root.zoomYEnabled) {
                        root.yMin = (chartCenter.y - (scaledChartHeight / 2)) + chartOffset.y
                        root.yMax = (chartCenter.y + (scaledChartHeight / 2)) + chartOffset.y
                    }

                    root.autoUpdate = true
                    root.update()

                    wheelChoke = 0

                    // resetChart.visible = true
                }
            }
        }
    }
}

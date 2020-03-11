import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.0

import tech.strata.fonts 1.0

Row {
    id: upperContainer
    spacing: 20

    Image {
        id: strataLogo
        sourceSize.height: 175
        fillMode: Image.PreserveAspectFit
        source: "qrc:/images/strata-logo.svg"
        mipmap: true;
    }
}

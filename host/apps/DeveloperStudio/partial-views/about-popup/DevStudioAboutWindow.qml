import QtQuick 2.12
import tech.strata.sgwidgets 1.0 as SGWidgets

import "qrc:/js/constants.js" as Constants

SGWidgets.SGAboutWindow {
    appLogoSource: "qrc:/sgimages/on-logo-green.svg"

    additionalAttributionText: {
        return "OpenSSL 1.1.1<br>" +
                "<a href=\'" + Constants.LICENSE_URL + "'>" + Constants.LICENSE_URL + "</a><br>"
    }
}

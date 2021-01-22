import QtQuick 2.12
import tech.strata.sgwidgets 1.0 as SGWidgets
import tech.strata.UrlConfig 1.0

SGWidgets.SGAboutWindow {
    appLogoSource: "qrc:/sgimages/on-logo-green.svg"

    additionalAttributionText: {
        return "OpenSSL 1.1.1<br>" +
                "<a href=\'" + urlConf.licenseUrl + "'>" + urlConf.licenseUrl + "</a><br>"
    }

    UrlConfig {
        id: urlConf
    }

}

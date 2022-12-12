/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include "SGTranslator.h"

SGTranslator::SGTranslator (QQuickItem* parent) : QQuickItem(parent)
{

}

bool SGTranslator::loadLanguageFile(const QString languageFileName)
{
    // Calling of this method causes reevaluation of all bindings within application.
    // See CS-3546
    // Make this method void, so calling it inside CVs has no effect.

    Q_UNUSED(languageFileName)

    qCritical() << "This this experimental feature. Do not use.";
    return false;

/*
    QCoreApplication* app = QCoreApplication::instance();
    QQmlEngine* engine = qmlEngine(parentItem());

    if (app && engine) {
        app->removeTranslator(&translator_);

        bool success = true;

        if (languageFileName != "") {
            if (translator_.load(languageFileName, ":/") == false) {
                qWarning () << "Language file failed to load";
                success = false;
            } else if (app->installTranslator(&translator_) == false) {
                qWarning () << "Translator failed to install";
                success = false;
            }
        }

        engine->retranslate();
        return success;
    } else {
        qCritical () << "Engine or app not initialized";
        return false;
    }
*/
}

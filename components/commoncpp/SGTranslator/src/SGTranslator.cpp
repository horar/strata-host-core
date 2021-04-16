#include "SGTranslator.h"

SGTranslator::SGTranslator (QQuickItem* parent) : QQuickItem(parent)
{

}

bool SGTranslator::loadLanguageFile(const QString languageFileName)
{
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
}

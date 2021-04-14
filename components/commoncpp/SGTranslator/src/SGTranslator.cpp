#include "SGTranslator.h"

SGTranslator::SGTranslator (QQuickItem* parent) : QQuickItem(parent)
{

}

void SGTranslator::loadLanguageFile(QString languageFileName)
{
    QCoreApplication* app = QCoreApplication::instance();
    QQmlEngine* engine = qmlEngine(parentItem());

    if (app && engine) {
        app->removeTranslator(&translator_);

        if (languageFileName != "") {
            translator_.load(languageFileName, ":/");
            app->installTranslator(&translator_);
        }

        engine->retranslate();
    } else {
        qCritical () << "Engine or app not initialized";
    }
}

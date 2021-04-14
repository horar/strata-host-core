#include "SGTranslator.h"

SGTranslator::SGTranslator (QQuickItem* parent)
{
    Q_UNUSED(parent)
}

void SGTranslator::componentComplete()
{
    if (parentItem()) {
        mEngine = qmlEngine(parentItem());
    }
}

void SGTranslator::loadLanguageFile(QString languageFileName)
{
    if (mApp && mEngine) {
        mApp->removeTranslator(&mTranslator);

        if (languageFileName != "") {
            mTranslator.load(languageFileName, ":/");
            mApp->installTranslator(&mTranslator);
        }

        mEngine->retranslate();
    } else {
        qDebug () << "engine or app not initialized";
    }
}

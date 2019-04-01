#include "EnhancedQmlApplicationEngine.h"


EnhancedQmlApplicationEngine::EnhancedQmlApplicationEngine(QObject *parent)
    : QQmlApplicationEngine(parent)
{

}

void EnhancedQmlApplicationEngine::clearCache()
{
    this->clearComponentCache();
}

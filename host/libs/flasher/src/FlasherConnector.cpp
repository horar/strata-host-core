#include "FlasherConnector.h"

#include <QThread>
#include <QDebug>

FlasherWorker::FlasherWorker(spyglass::PlatformConnectionShPtr connection, const QString &firmwarePath, QObject *parent)
    : QObject(parent), connection_(connection), firmwarePath_(firmwarePath), stopFlag_(false)
{
}

void FlasherWorker::process()
{
    Q_ASSERT(connection_ != nullptr);
    if (connection_ == nullptr) {
        return;
    }

    Flasher flasher(connection_, firmwarePath_.toStdString());
    flasher.setCancelCallback(std::bind(&FlasherWorker::isCancelRequested, this));

    QString connectionId = QString::fromStdString(connection_->getName());

    emit notify(connectionId, "Initializing bootloader");

    if (flasher.initializeBootloader()) {
        emit notify(connectionId, "Programming");
        if (flasher.flash(true)) {

            emit taskDone(connectionId, true);
            emit finished();
            return;
        }
    } else {
        emit notify(connectionId, "Initializing of bootloader failed");
    }

    emit taskDone(connectionId, false);
    emit finished();
}

void FlasherWorker::stop()
{
    stopFlag_.store(true);
}

bool FlasherWorker::isCancelRequested()
{
    return (stopFlag_.load() == true);
}

///////////////////////////////////////////////////////////////////////////////////////////////////////

FlasherConnector::FlasherConnector(QObject *parent)
    : QObject(parent)
{
}

FlasherConnector::~FlasherConnector()
{
    stopAll();
}

bool FlasherConnector::start(spyglass::PlatformConnectionShPtr connection, const QString &firmwarePath)
{
    QString connectionId = QString::fromStdString(connection->getName());
    {
        QMutexLocker lock(&connectionToWorkerMutex_);
        auto findIt = connectionToWorker_.find(connectionId);
        if (findIt != connectionToWorker_.end()) {
            return false;
        }
    }

    FlasherWorker* worker = new FlasherWorker(connection, firmwarePath);

    {
        QMutexLocker lock(&connectionToWorkerMutex_);
        connectionToWorker_.insert(connectionId, worker);
    }

    QThread* thread = new QThread;
    worker->moveToThread(thread);

    connect(worker, &FlasherWorker::taskDone, this, &FlasherConnector::taskDone);
    connect(worker, &FlasherWorker::notify, this, &FlasherConnector::notify);

    connect(thread, &QThread::started, worker, &FlasherWorker::process);
    connect(worker, &FlasherWorker::finished, thread, &QThread::quit);
    connect(worker, &FlasherWorker::finished, worker, &FlasherWorker::deleteLater);
    connect(thread, &QThread::finished, thread, &QThread::deleteLater);

    thread->start();
    return true;
}

void FlasherConnector::stop(const QString& connectionId)
{
    FlasherWorker* worker = nullptr;
    {
        QMutexLocker lock(&connectionToWorkerMutex_);
        auto findIt = connectionToWorker_.find(connectionId);
        if (findIt == connectionToWorker_.end()) {
            return;
        }

        worker = findIt.value();
    }

    Q_ASSERT(worker);
    QThread* thread = worker->thread();

    worker->stop();

    thread->quit();
    thread->wait();
}

void FlasherConnector::stopAll()
{
    while(!connectionToWorker_.empty()) {

        QString connectionId;
        FlasherWorker* item;
        {
            QMutexLocker lock(&connectionToWorkerMutex_);
            item = connectionToWorker_.first();
            connectionId = connectionToWorker_.firstKey();
        }

        QThread* thread = item->thread();
        Q_ASSERT(thread);

        item->stop();

        thread->quit();
        thread->wait();

        {
            QMutexLocker lock(&connectionToWorkerMutex_);
            connectionToWorker_.remove(connectionId);
        }
    }
}


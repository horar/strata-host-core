#pragma once

#include <QObject>
#include <QUrl>
#include <QFile>

namespace strata {

class InternalDownloadRequest: public QObject {
    Q_OBJECT
    Q_DISABLE_COPY(InternalDownloadRequest)

public:
    explicit InternalDownloadRequest(QObject* parent = nullptr);

    enum class DownloadState {
        Pending,
        Running,
        Finished,
        FinishedWithError,
    };

    QUrl url;
    QString originalFilePath;
    QString md5;
    DownloadState state;
    QString groupId;
    QString errorString;
    QFile savedFile;
};

}

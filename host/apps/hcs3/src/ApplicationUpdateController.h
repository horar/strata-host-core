#ifndef APPLICATIONUPDATECONTROLLER_H
#define APPLICATIONUPDATECONTROLLER_H

#include <QObject>

class ApplicationUpdateController : public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(ApplicationUpdateController)
public:
    explicit ApplicationUpdateController(QObject *parent = nullptr);

signals:
    void executionOfUpdate(QByteArray clientId, QString errorString);

public slots:
    /**
     * Update Application.
     * @param clientId
     */
    void updateApplication(const QByteArray& clientId);


};

#endif // APPLICATIONUPDATECONTROLLER_H

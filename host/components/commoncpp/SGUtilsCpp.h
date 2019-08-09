#ifndef SGUTILSCPP_H
#define SGUTILSCPP_H

#include <QObject>

class SGUtilsCpp : public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(SGUtilsCpp)

public:
    explicit SGUtilsCpp(QObject *parent = nullptr);
    virtual ~SGUtilsCpp();

    Q_INVOKABLE QString urlToLocalFile(const QUrl &url);
    Q_INVOKABLE bool isFile(const QString &file);
    Q_INVOKABLE bool isExecutable(const QString &file);
    Q_INVOKABLE bool atomicWrite(const QString &path, const QString &content);
};

#endif  // SGUTILSCPP_H

#ifndef PKCEGENERATOR_H
#define PKCEGENERATOR_H

#include <QObject>
#include <QPair>
#include <QString>
class PKCEGenerator : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString code_verifier READ getCodeVerifier);
    Q_PROPERTY(QString code_challenge READ getCodeChallenge);
public:
    explicit PKCEGenerator(QObject *parent = nullptr);
    Q_INVOKABLE bool generate(int length = 43);
    QString getCodeVerifier() const;
    QString getCodeChallenge() const;

private:
    QString generateRandomString(unsigned int length);
    QString code_verifier_;
    QString code_challenge_;
};

#endif // PKCEGENERATOR_H

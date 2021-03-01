#include "pkcegenerator.h"

#include <QtMath>
#include <QRandomGenerator>
#include <QCryptographicHash>
#include <QRegularExpression>

PKCEGenerator::PKCEGenerator(QObject *parent) : QObject(parent)
{
    generate();
}

bool PKCEGenerator::generate(int length)
{
    if(length < 43 || length > 128){
        return false;
    }
    code_verifier_ = generateRandomString(length);
    code_challenge_ = QCryptographicHash::hash(code_verifier_.toUtf8(), QCryptographicHash::Sha256).toBase64();

    code_challenge_ = code_challenge_.replace(QRegularExpression("="), "")
                                  .replace(QRegularExpression("\\+"), "-")
                                  .replace(QRegularExpression("\\/"), "_");
    return true;
}

QString PKCEGenerator::getCodeVerifier() const
{
    return code_verifier_;
}

QString PKCEGenerator::getCodeChallenge() const
{
    return code_challenge_;
}

QString PKCEGenerator::generateRandomString(unsigned int length)
{
    QString possible = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~";
    QString random_string;
    for(unsigned int i=0; i < length; i++){
        random_string += possible[ qFloor( QRandomGenerator::global()->bounded(possible.size()) ) ];
    }
    return random_string;
}

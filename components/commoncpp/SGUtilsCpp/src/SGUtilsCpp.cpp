/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include "SGUtilsCpp.h"
#include "logging/LoggingQtCategories.h"

#include <QFileInfo>
#include <QUrl>
#include <QSaveFile>
#include <QTextStream>
#include <QDebug>
#include <QDir>
#include <QDateTime>
#include <QImageReader>
#include <cmath>
#include <QUuid>
#include <cctype>
#include <QGuiApplication>
#include <QClipboard>
#include <QKeySequence>
#include <QProcess>

#include <rapidjson/schema.h>
#include <rapidjson/document.h>
#include <rapidjson/writer.h>
#include <rapidjson/error/en.h>

SGUtilsCpp::SGUtilsCpp(QObject *parent)
    : QObject(parent)
{
}

SGUtilsCpp::~SGUtilsCpp()
{
}

const QStringList SGUtilsCpp::fileSizePrefixList_{"B", "KB", "MB", "GB", "TB", "PB", "EB"};
const QList<QChar> SGUtilsCpp::forbiddenCharactersList_{'<','>',':','"','/','\\','?','|','*'};

QString SGUtilsCpp::urlToLocalFile(const QUrl &url, const bool toNativeSeparators)
{
    if (toNativeSeparators) {
        return QDir::toNativeSeparators(QUrl(url).toLocalFile());
    }
    return QUrl(url).toLocalFile();
}

bool SGUtilsCpp::isFile(const QString &file)
{
    QFileInfo info(file);
    return info.isFile();
}

bool SGUtilsCpp::isValidFile(const QString &file)
{
    QUrl url(file);
    return url.isValid();
}

bool SGUtilsCpp::createFile(const QString &filepath)
{
    QFile file(filepath);
    if (file.exists()) {
        file.close();
        return false;
    }

    bool success = file.open(QIODevice::WriteOnly);
    file.close();
    return success;
}

bool SGUtilsCpp::removeFile(const QString &filepath)
{
    return QFile::remove(filepath);
}

bool SGUtilsCpp::copyFile(const QString &fromPath, const QString &toPath)
{
    return QFile::copy(fromPath, toPath);
}

QString SGUtilsCpp::fileSuffix(const QString &filename)
{
    return QFileInfo(filename).suffix();
}

QString SGUtilsCpp::fileBaseName(const QString &filename)
{
    return QFileInfo(filename).baseName();
}

bool SGUtilsCpp::isValidImage(const QString &file)
{
    QImageReader reader(file);
    return reader.canRead();
}

bool SGUtilsCpp::isExecutable(const QString &file)
{
    QFileInfo info(file);
    return info.isExecutable();
}

bool SGUtilsCpp::isRelative(const QString &file)
{
    QFileInfo info(file);
    return info.isRelative();
}

bool SGUtilsCpp::containsForbiddenCharacters(const QString &fileName)
{
    return std::any_of(forbiddenCharactersList_.constBegin(), forbiddenCharactersList_.constEnd(),
                       [&fileName](const auto& s) { return fileName.contains(s); });
}

QString SGUtilsCpp::fileName(const QString &file)
{
    QFileInfo fi(file);
    return fi.fileName();
}

QString SGUtilsCpp::fileAbsolutePath(const QString &file)
{
    QFileInfo fi(file);
    return fi.absoluteFilePath();
}

QString SGUtilsCpp::dirName(const QString &path)
{
    QDir dir(path);
    return dir.dirName();
}

QString SGUtilsCpp::parentDirectoryPath(const QString &filepath)
{
    QFileInfo fi(filepath);
    return fi.absolutePath();
}

QUrl SGUtilsCpp::pathToUrl(const QString &path, const QString &scheme)
{
    QUrl url;
    url.setScheme(scheme);
    url.setPath(path);

    return url;
}

bool SGUtilsCpp::atomicWrite(const QString &path, const QString &content)
{
    QSaveFile file(path);

    bool ret = file.open(QIODevice::WriteOnly | QIODevice::Text);
    if (ret == false) {
        qCCritical(lcUtils) << "cannot open file" << path << file.errorString();
        return false;
    }

    QTextStream out(&file);
    out.setCodec("UTF-8");

    out << content;

    return file.commit();
}

bool SGUtilsCpp::fileIsChildOfDir(const QString &filePath, QString dirPath)
{
    if (dirPath.length() > 0 && dirPath[dirPath.length() - 1] != QDir::separator()) {
        dirPath.append(QDir::separator());
    }

    return filePath.startsWith(dirPath);
}

QString SGUtilsCpp::readTextFileContent(const QString &path)
{
    QFile file(path);
    if (file.open(QFile::ReadOnly | QFile::Text) == false) {
        qCCritical(lcUtils) << "cannot open file" << path << file.errorString();
        return QString();
    }

    return file.readAll();
}

QByteArray SGUtilsCpp::toBase64(const QByteArray &text)
{
    return text.toBase64();
}

QByteArray SGUtilsCpp::fromBase64(const QByteArray &text)
{
    return QByteArray::fromBase64(text);
}

QString SGUtilsCpp::joinFilePath(const QString &path, const QString &fileName)
{
    QDir dir(path);
    return dir.filePath(fileName);
}

bool SGUtilsCpp::exists(const QString &filepath)
{
    return QFileInfo::exists(filepath);
}

QString SGUtilsCpp::formattedDataSize(qint64 bytes, int precision)
{
    if (bytes == 0) {
        return "0 "+ fileSizePrefixList_.at(0);
    }

    int base, power = 0;

    #ifdef Q_OS_MACOS
    base = 1000;
    power = int(log10(qAbs(bytes)) / 3);
    #else
    base = 1024;
    //compute log2(bytes) / 10
    power = int((63 - qCountLeadingZeroBits(quint64(qAbs(bytes)))) / 10);
    #endif

    if (power < 0 || power >= fileSizePrefixList_.length()) {
        //no support for sizes larger than exabytes as they would not fit into qint64
        return QString();
    }

    QString number = QString::number(bytes / (pow(double(base), power)), 'f', precision);

    return number + " " + fileSizePrefixList_.at(power);
}

QString SGUtilsCpp::formatDateTimeWithOffsetFromUtc(const QDateTime &dateTime, const QString &format)
{
    return dateTime.toOffsetFromUtc(dateTime.offsetFromUtc()).toString(format);
}

QString SGUtilsCpp::generateUuid()
{
    return QUuid::createUuid().toString(QUuid::WithoutBraces);
}

bool SGUtilsCpp::validateJson(const QByteArray &json, const QByteArray &schema)
{
    //parse json
    rapidjson::Document jsonDoc;
    rapidjson::ParseResult result = jsonDoc.Parse(json.data());
    if (result.IsError()) {
        qCCritical(lcUtils).nospace().noquote()
                << "Json is not valid: " << endl << json;

        qCCritical(lcUtils).nospace().noquote()
                << "JSON parse error at offset " << result.Offset()
                << ": " << rapidjson::GetParseError_En(result.Code());

        return false;
    }

    //parse schema
    rapidjson::Document schemaDoc;
    result = schemaDoc.Parse(schema.data());
    if (result.IsError()) {
        qCCritical(lcUtils).nospace().noquote()
                << "Schema is not valid: " << endl << schema;

        qCCritical(lcUtils).nospace().noquote()
                << "JSON parse error at offset " << result.Offset()
                << ": " << rapidjson::GetParseError_En(result.Code());

        return false;
    }

    //validate
    rapidjson::SchemaDocument schemaDocument(schemaDoc);
    rapidjson::SchemaValidator validator(schemaDocument);
    if (jsonDoc.Accept(validator) == false) {
        rapidjson::StringBuffer buffer;
        rapidjson::Writer<rapidjson::StringBuffer> writer(buffer);

        jsonDoc.Accept(writer);

        buffer.Clear();
        writer.Reset(buffer);
        validator.GetError().Accept(writer);

        qCDebug(lcUtils).nospace().noquote() << "json: " << json;
        qCCritical(lcUtils).nospace().noquote() << "validate error: " << buffer.GetString();

        return false;
    }

    return true;
}

QString SGUtilsCpp::toHex(qint64 number, int width)
{
    return QStringLiteral("0x") + QString::number(number, 16).rightJustified(width, '0');
}

void SGUtilsCpp::copyToClipboard(const QString &text)
{
    QClipboard *clipboard = QGuiApplication::clipboard();
    clipboard->setText(text, QClipboard::Clipboard);
}

QString SGUtilsCpp::keySequenceNativeText(QString sequence)
{
    return QKeySequence(sequence).toString(QKeySequence::NativeText);
}

bool SGUtilsCpp::keySequenceMatches(QString sequence, int key)
{
    return QKeySequence(sequence).matches(QKeySequence(key));
}

QList<QString> SGUtilsCpp::getQrcPaths(QString path) {
    QList<QString> pathList;
    QDirIterator it(path, QDirIterator::Subdirectories);
    while (it.hasNext()) {
        pathList.append(it.next());
    }
    return pathList;
}

void SGUtilsCpp::showFileInFolder(const QString &path){
    #ifdef Q_OS_WIN
        QProcess::startDetached("explorer.exe", {"/select,", QDir::toNativeSeparators(path)});
    #else
        QProcess::execute("/usr/bin/osascript", {"-e", "tell application \"Finder\" to reveal POSIX file \"" + path + "\""});
        QProcess::execute("/usr/bin/osascript", {"-e", "tell application \"Finder\" to activate"});
    #endif
}

QString SGUtilsCpp::joinForbiddenCharacters(QString separator)
{
    return getForbiddenCharacters().join(separator);
}

QStringList SGUtilsCpp::getForbiddenCharacters()
{
    QStringList list;
    for (int i = 0; i < forbiddenCharactersList_.length(); i++) {
        list.append(forbiddenCharactersList_[i]);
    }
    return list;
}

QVariantMap SGUtilsCpp::getWordStartEndPositions(const QString &text, int pos)
{
    QVariantMap result;
    int startPos = -1;
    int endPos = -1;
    if (text.isEmpty() || (pos == -1)) {
        result.insert("word_start", startPos);
        result.insert("word_end", endPos);
        return result;
    }

    // we will be selecting block to the right, except for \n
    if ((pos > 0) && ((text.size() == pos) || (text.at(pos) == "\n"))) {
        pos--;
    }

    startPos = pos;
    endPos = pos+1;

    auto getCharacterType = [](const QChar &character, bool &endLine, bool &letter, bool &symbol, bool &space)
    {
        endLine = letter = symbol = space = false;
        if (character == "\n") {
            endLine = true;
        } else if (character.isLetterOrNumber() || character == "_" || character == "-") {
            letter = true;
        } else if (character.isSpace()) {
            space = true;
        } else {
            symbol = true;
        }
    };

    bool lookingForEndlines, lookingForLetters, lookingForSymbols, lookingForSpaces;
    getCharacterType(text.at(pos), lookingForEndlines, lookingForLetters, lookingForSymbols, lookingForSpaces);

    if (lookingForEndlines) {
        result.insert("word_start", startPos);
        result.insert("word_end", endPos);
        return result;
    }

    bool isEndline, isLetter, isSymbol, isSpace;
    for (int i = pos-1; i >= 0; i--) {
        getCharacterType(text.at(i), isEndline, isLetter, isSymbol, isSpace);
        if ((lookingForLetters && isLetter) ||
            (lookingForSymbols && isSymbol) ||
            (lookingForSpaces && isSpace)) {
            startPos = i;
        } else {
            break;
        }
    }

    for (int i = pos+1; i < text.size(); i++) {
        endPos = i;
        getCharacterType(text.at(i), isEndline, isLetter, isSymbol, isSpace);
        if ((lookingForLetters && isLetter) == false &&
            (lookingForSymbols && isSymbol) == false &&
            (lookingForSpaces && isSpace) == false) {
            break;
        }
    }

    result.insert("word_start", startPos);
    result.insert("word_end", endPos);
    return result;
}

QVariantMap SGUtilsCpp::getLineStartEndPositions(const QString &text, int pos)
{
    QVariantMap result;
    int startPos = -1;
    int endPos = -1;
    if (text.isEmpty() || (pos == -1)) {
        result.insert("line_start", startPos);
        result.insert("line_end", endPos);
        return result;
    }

    startPos = text.lastIndexOf("\n", pos);
    endPos = text.indexOf("\n", pos);

    if (startPos == endPos) {
        // we clicked at last character
        if ((pos > 0) && (text.at(pos - 1) != "\n")) {
            startPos = text.lastIndexOf("\n", pos - 1);
        }
    }

    if (endPos == -1) {
        endPos = text.size();
    }

    if (startPos != 0) {
        startPos++; // we do not want to copy endline
    }

    result.insert("line_start", startPos);
    result.insert("line_end", endPos);
    return result;
}

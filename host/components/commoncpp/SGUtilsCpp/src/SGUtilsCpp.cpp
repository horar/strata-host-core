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

#include <rapidjson/schema.h>
#include <rapidjson/document.h>
#include <rapidjson/writer.h>
#include <rapidjson/error/en.h>

SGUtilsCpp::SGUtilsCpp(QObject *parent)
    : QObject(parent),
      fileSizePrefixList_(QStringList() <<"B"<<"KB"<<"MB"<<"GB"<<"TB"<<"PB"<<"EB")
{
}

SGUtilsCpp::~SGUtilsCpp()
{
}

QString SGUtilsCpp::urlToLocalFile(const QUrl &url)
{
    return QDir::toNativeSeparators(QUrl(url).toLocalFile());
}

bool SGUtilsCpp::isFile(const QString &file)
{
    QFileInfo info(file);
    return info.isFile();
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

bool SGUtilsCpp::isValidImage(const QString &file)
{
    QImageReader reader(file);
    if(reader.canRead()){
        return true;
    }
    return false;
}

bool SGUtilsCpp::isExecutable(const QString &file)
{
    QFileInfo info(file);
    return info.isExecutable();
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
        qCCritical(logCategoryUtils) << "cannot open file" << path << file.errorString();
        return false;
    }

    QTextStream out(&file);

    out << content;

    return file.commit();
}

bool SGUtilsCpp::fileIsChildOfDir(const QString &filePath, QString dirPath)
{
    if (dirPath.length() > 0 && dirPath[dirPath.length() - 1] != QDir::separator()) {
        dirPath.append(QDir::separator());
    }

    if (filePath.startsWith(dirPath)) {
        return true;
    } else {
        return false;
    }
}

QString SGUtilsCpp::readTextFileContent(const QString &path)
{
    QFile file(path);
    if (file.open(QFile::ReadOnly | QFile::Text) == false) {
        qCCritical(logCategoryUtils) << "cannot open file" << path << file.errorString();
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
        qCCritical(logCategoryUtils).nospace().noquote()
                << "Json is not valid: " << endl << json;

        qCCritical(logCategoryUtils).nospace().noquote()
                << "JSON parse error at offset " << result.Offset()
                << ": " << rapidjson::GetParseError_En(result.Code());

        return false;
    }

    //parse schema
    rapidjson::Document schemaDoc;
    result = schemaDoc.Parse(schema.data());
    if (result.IsError()) {
        qCCritical(logCategoryUtils).nospace().noquote()
                << "Schema is not valid: " << endl << schema;

        qCCritical(logCategoryUtils).nospace().noquote()
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

        qCDebug(logCategoryUtils).nospace().noquote() << "json: " << json;
        qCCritical(logCategoryUtils).nospace().noquote() << "validate error: " << buffer.GetString();

        return false;
    }

    return true;
}

QString SGUtilsCpp::toHex(qint64 number, int width)
{
    return QStringLiteral("0x") + QString::number(number, 16).rightJustified(width, '0');
}

QByteArray SGUtilsCpp::prettifyJson(const QByteArray &json, int indentSize)
{
    QByteArray prettifiedJson;
    int level = 0;
    bool inString = false;
    bool inEscapeSequence = false;

    for (int i = 0; i < json.size(); ++i) {
        char c = json.at(i);

        if (inString == false && std::isspace(c)) {
            continue;
        }

        prettifiedJson.append(c);

        if (inEscapeSequence) {
            inEscapeSequence = false;
            continue;
        }

        if (c == '\\') {
            inEscapeSequence = true;
            continue;
        }

        if (inString == false) {
            if (c == '{' || c == '[') {
                 ++level;

                //do not wrap when object or array is empty
                int j = i+1;
                char firstNoSpaceChar = 0;
                while (j < json.size()) {
                    firstNoSpaceChar = json.at(j);
                    if (std::isspace(firstNoSpaceChar) == false) {
                        break;
                    }

                    ++j;
                }

                if (firstNoSpaceChar != '}' && firstNoSpaceChar != ']') {
                    prettifiedJson += '\n';
                    prettifiedJson.append(indentSize * level, ' ');
                }

            } else if (c == '}' || c == ']') {
                --level;

                char previousC = prettifiedJson.at(prettifiedJson.size()-2);
                if (previousC != '{' && previousC != '[') {
                    prettifiedJson.insert(prettifiedJson.size()-1, '\n');
                    prettifiedJson.insert(prettifiedJson.size()-1, indentSize * level, ' ');
                }

            } else if (c == ',') {
                prettifiedJson += '\n';
                prettifiedJson.append(indentSize * level, ' ');
            } else if (c == ':') {
                prettifiedJson.append(' ');
            }
        }

        if (c == '"') {
            inString = !inString;
        }
    }

    return prettifiedJson;
}

QByteArray SGUtilsCpp::minifyJson(const QByteArray &json)
{
    QByteArray minifiedJson;
    bool inString = false;
    bool inEscapeSequence = false;

    for (int i = 0; i < json.size(); ++i) {
        char c = json.at(i);

        if (inString == false && std::isspace(c)) {
            continue;
        }

        minifiedJson.append(c);

        if (inEscapeSequence) {
            inEscapeSequence = false;
            continue;
        }

        if (c == '\\') {
            inEscapeSequence = true;
            continue;
        }

        if (inEscapeSequence == false && c == '"') {
            inString = !inString;
        }
    }

    return minifiedJson;
}

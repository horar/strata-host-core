#include "SGUtilsCpp-test.h"

#include <QTemporaryFile>
#include <QIODevice>
#include <QTextStream>
#include <QDateTime>
#include <QDebug>

void SGUtilsCppTest::SetUp()
{
}

void SGUtilsCppTest::TearDown()
{
}

TEST_F(SGUtilsCppTest, testFileUtils)
{
    QTemporaryFile tempFile;
    tempFile.setFileName("isFileText.txt");

    if (!tempFile.open()) {
        throw "Unable to open file";
    }
    EXPECT_TRUE(utils.isFile(tempFile.fileName()));
    EXPECT_FALSE(utils.isFile("non-existent-file.xyz"));
    EXPECT_EQ(utils.fileName("/path/to/test.txt").toStdString(), "test.txt");
    EXPECT_EQ(utils.dirName("/this/is/a/test"), "test");
    QUrl url("/path/to/something/on/disk/test.html");
    url.setScheme("file");
    EXPECT_EQ(utils.pathToUrl("/path/to/something/on/disk/test.html").toString().toStdString(), url.toString().toStdString());

#ifdef _WIN32
    EXPECT_EQ(utils.urlToLocalFile(url), "\\path\\to\\something\\on\\disk\\test.html");
#else
    EXPECT_EQ(utils.urlToLocalFile(url), "/path/to/something/on/disk/test.html");
#endif

    EXPECT_EQ(utils.joinFilePath("/prepend/path", "append-me.txt"), "/prepend/path/append-me.txt");

    // Text executable file utils
    // Commented because these fail on Windows. See CS-1070
    QTemporaryFile exeFile;
    exeFile.setFileName("text.exe");

    if (!exeFile.open()) {
        qCritical() << "Unable to open text.exe";
        return;
    }
    exeFile.setPermissions(QFile::Permission::ExeUser);
    QString testText = "test";
    exeFile.write(testText.toUtf8());
    EXPECT_TRUE(utils.isExecutable(exeFile.fileName()));
    exeFile.close();

    QTemporaryFile nonExeFile;
    nonExeFile.setFileName("nonExeTest.txt");

    if (!nonExeFile.open()) {
        qCritical() << "Unable to open" << nonExeFile.fileName();
        return;
    }
    nonExeFile.write(testText.toUtf8());
    EXPECT_FALSE(utils.isExecutable(nonExeFile.fileName()));
    nonExeFile.close();
}

TEST_F(SGUtilsCppTest, testFileIO)
{
    QTemporaryFile tempFile;
    tempFile.setFileName("testFileIo.txt");

    if (!tempFile.open()) {
        qCritical() << "Unable to open" << tempFile.fileName();
        return;
    }
    QTextStream out(&tempFile);
    out << lorumIpsumText;

    // Go back to the beginning of file and make sure data is written to disk
    out.flush();
    tempFile.seek(0);

    // Read from file
    EXPECT_EQ(utils.readTextFileContent(tempFile.fileName()).toStdString(), lorumIpsumText.toStdString());

    // Write to file
    // Commented because these fail on Windows. See CS-1070
    QTemporaryFile writingTestFile;
    writingTestFile.setFileName("writingTest.txt");
    EXPECT_TRUE(utils.atomicWrite(writingTestFile.fileName(), "hello world"));
    EXPECT_EQ(utils.readTextFileContent(writingTestFile.fileName()).toStdString(), "hello world");
}

TEST_F(SGUtilsCppTest, testRandomUtils)
{
    QString test = "this is a test";
    QByteArray testTo = utils.toBase64(test.toUtf8());
    EXPECT_EQ(utils.fromBase64(testTo), test.toUtf8());
}


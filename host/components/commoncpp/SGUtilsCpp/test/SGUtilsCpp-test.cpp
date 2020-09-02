#include "SGUtilsCpp-test.h"

#include <QFile>
#include <QIODevice>
#include <QTextStream>
#include <QDateTime>

void SGUtilsCppTest::SetUp()
{
    QFile tempFile("test.txt");
    if (!tempFile.open(QIODevice::WriteOnly | QIODevice::Text)) {
        exit(EXIT_FAILURE);
    }

    QTextStream out(&tempFile);
    out << lorumIpsumText;

    tempFile.close();
}

void SGUtilsCppTest::TearDown()
{
    QFile tempFile("test.txt");
    tempFile.remove();
}

TEST_F(SGUtilsCppTest, testFileUtils)
{
    EXPECT_TRUE(utils.isFile("test.txt"));
    EXPECT_EQ(utils.fileName("test.txt"), "test");
    EXPECT_EQ(utils.dirName("/this/is/a/test"), "test");
    QUrl url("/path/to/something/on/disk/test.html");
    EXPECT_EQ(utils.pathToUrl("/path/to/something/on/disk/test.html"), url);
    EXPECT_EQ(utils.urlToLocalFile(url), "/path/to/something/on/disk/test.html");

    EXPECT_EQ(utils.joinFilePath("/prepend/path", "append-me.txt"), "/prepend/path/append-me.txt");

    EXPECT_TRUE(utils.isExecutable("test.exe"));
    EXPECT_FALSE(utils.isExecutable("test.txt"));
}

TEST_F(SGUtilsCppTest, testFileIO)
{
    // Read from file
    EXPECT_EQ(utils.readTextFileContent("test.txt"), lorumIpsumText);

    // Write to file
    EXPECT_TRUE(utils.atomicWrite("test.txt", "hello world"));
    EXPECT_EQ(utils.readTextFileContent("test.txt"), "hello world");
}

TEST_F(SGUtilsCppTest, testRandomUtils)
{
    QString test = "this is a test";
    QByteArray testTo = utils.toBase64(test.toUtf8());
    EXPECT_EQ(utils.fromBase64(testTo), test.toUtf8());
}


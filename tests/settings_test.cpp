#include <QCoreApplication>
#include <QFile>
#include <QSettings>
#include <QStandardPaths>
#include <QTest>

#include "common/settings.h"
#include "common/workingfolder.h"

class SettingsTest : public QObject
{
    Q_OBJECT

private slots:
    void initTestCase()
    {
        QStandardPaths::setTestModeEnabled(true);
        QCoreApplication::setApplicationName(QStringLiteral("OpenSoundMeterSettingsTest"));
        QFile::remove(workingfolder::settingsFilePath());
    }

    void storesAndReturnsDefaultForMissingValue()
    {
        Settings settings;

        QCOMPARE(settings.value(QStringLiteral("layout/charts/count"), 1).toInt(), 1);
        settings.flush();

        QSettings stored(workingfolder::settingsFilePath(), QSettings::IniFormat);
        QCOMPARE(stored.value(QStringLiteral("layout/charts/count")).toInt(), 1);
    }

    void preservesExistingValueInsteadOfDefault()
    {
        Settings settings;
        settings.setValue(QStringLiteral("layout/charts/count"), 3);

        QCOMPARE(settings.value(QStringLiteral("layout/charts/count"), 1).toInt(), 3);
    }

    void returnsInvalidVariantWithoutDefault()
    {
        Settings settings;

        QVERIFY(!settings.value(QStringLiteral("missing")).isValid());
    }
};

QTEST_GUILESS_MAIN(SettingsTest)

#include "settings_test.moc"

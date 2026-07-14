#include <QColor>
#include <QJsonObject>
#include <QTest>

#include "remote/variantjson.h"

namespace {
enum class ExampleMode {
    First = 1,
    Second = 2
};
}

Q_DECLARE_METATYPE(ExampleMode)

class RemoteVariantTest : public QObject
{
    Q_OBJECT

private slots:
    void convertsScalarValues()
    {
        QCOMPARE(remote::variantToJson(true), QJsonValue(true));
        QCOMPARE(remote::variantToJson(42), QJsonValue(42));
        QCOMPARE(remote::variantToJson(42U), QJsonValue(42));
        QCOMPARE(remote::variantToJson(QVariant::fromValue(42L)), QJsonValue(42));
        QCOMPARE(remote::variantToJson(1.25F), QJsonValue(1.25));
        QCOMPARE(remote::variantToJson(2.5), QJsonValue(2.5));
        QCOMPARE(remote::variantToJson(QStringLiteral("measurement")),
                 QJsonValue(QStringLiteral("measurement")));
    }

    void convertsColorChannels()
    {
        const auto json = remote::variantToJson(QColor(12, 34, 56, 78)).toObject();

        QCOMPARE(json.value(QStringLiteral("red")).toInt(), 12);
        QCOMPARE(json.value(QStringLiteral("green")).toInt(), 34);
        QCOMPARE(json.value(QStringLiteral("blue")).toInt(), 56);
        QCOMPARE(json.value(QStringLiteral("alpha")).toInt(), 78);
    }

    void convertsEnumerationToInteger()
    {
        QCOMPARE(remote::variantToJson(QVariant::fromValue(ExampleMode::Second)),
                 QJsonValue(2));
    }

    void leavesUnsupportedValuesUndefined()
    {
        QVERIFY(remote::variantToJson(QDate(2026, 7, 15)).isUndefined());
    }
};

QTEST_MAIN(RemoteVariantTest)

#include "remote_variant_test.moc"

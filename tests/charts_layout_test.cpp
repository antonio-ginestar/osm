#include <QFile>
#include <QQmlComponent>
#include <QQmlContext>
#include <QQmlEngine>
#include <QQmlExpression>
#include <QQuickItem>
#include <QQuickWindow>
#include <QStandardPaths>
#include <QStyleHints>
#include <QTemporaryDir>
#include <QTest>

#include "common/settings.h"
#include "common/workingfolder.h"
#include "chart/splitviewobserver.h"

class ChartsLayoutTest : public QObject
{
    Q_OBJECT

    QTemporaryDir m_qmlDirectory;
    Settings *m_settings = nullptr;

    static QQuickItem *pane(QQuickItem *charts, const QString &id)
    {
        QQmlExpression expression(QQmlEngine::contextForObject(charts), charts, id);
        return qvariant_cast<QQuickItem *>(expression.evaluate());
    }

private slots:
    void initTestCase()
    {
        QStandardPaths::setTestModeEnabled(true);
        QCoreApplication::setApplicationName(QStringLiteral("OpenSoundMeterChartsLayoutTest"));
        QFile::remove(workingfolder::settingsFilePath());
        m_settings = new Settings({}, this);
        qmlRegisterType<Chart::SplitViewObserver>("OpenSoundMeter", 1, 0, "SplitViewObserver");

        QVERIFY(m_qmlDirectory.isValid());
        QVERIFY(QFile::copy(QStringLiteral(OSM_CHARTS_QML_FILE), m_qmlDirectory.filePath("Charts.qml")));
        // Exercise the production splitter without starting audio or chart renderers.
        QFile chart(m_qmlDirectory.filePath("Chart.qml"));
        QVERIFY(chart.open(QIODevice::WriteOnly));
        chart.write("import QtQuick\nItem { property string type; property var settings; "
                    "property int doubleClickCount: 0; MouseArea { anchors.fill: parent; "
                    "onDoubleClicked: parent.doubleClickCount += 1 } }\n");
    }

    void restoresPaneHeightsAfterStartup_data()
    {
        QTest::addColumn<int>("count");
        QTest::newRow("double") << 2;
        QTest::newRow("three") << 3;
    }

    void restoresPaneHeightsAfterStartup()
    {
        QFETCH(int, count);
        m_settings->setValue("layout/charts/count", count);
        m_settings->setValue("layout/charts/1/height", 300);
        m_settings->setValue("layout/charts/2/height", 240);
        m_settings->setValue("layout/charts/3/height", 200);
        m_settings->setValue("layout/charts/1/type", "Magnitude");
        m_settings->setValue("layout/charts/2/type", "Phase");
        m_settings->setValue("layout/charts/3/type", "Step");
        qreal expectedFirstHeight = 300;
        qreal expectedSecondHeight = 240;

        // Reconstruct the QML engine twice, including the initial zero-sized layout.
        for (int restart = 0; restart < 2; ++restart) {
            QQmlEngine engine;
            engine.rootContext()->setContextProperty("applicationSettings", m_settings);
            QQmlComponent component(&engine, QUrl::fromLocalFile(m_qmlDirectory.filePath("Charts.qml")));
            QVERIFY2(component.isReady(), qPrintable(component.errorString()));
            QQuickWindow window;
            QScopedPointer<QQuickItem> charts(qobject_cast<QQuickItem *>(component.create()));
            QVERIFY2(charts, qPrintable(component.errorString()));
            charts->setParentItem(window.contentItem());
            window.resize(1000, count == 3 ? 750 : 545);
            charts->setSize(window.size());
            window.show();

            auto first = pane(charts.data(), "first");
            auto second = pane(charts.data(), "second");
            auto third = pane(charts.data(), "third");
            QVERIFY(first && second && third);
            QTRY_COMPARE_WITH_TIMEOUT(second->height(), expectedSecondHeight, 1000);
            if (count == 3)
                QTRY_COMPARE_WITH_TIMEOUT(third->height(), 200, 1000);
            QCOMPARE(first->height(), expectedFirstHeight);
            QCOMPARE(first->property("type").toString(), QStringLiteral("Magnitude"));
            QCOMPARE(second->property("type").toString(), QStringLiteral("Phase"));
            QCOMPARE(third->property("type").toString(), QStringLiteral("Step"));

            if (restart == 0) {
                const QPoint handle(500, qRound(second->y() - 2));
                QTest::mousePress(&window, Qt::LeftButton, Qt::NoModifier, handle);
                QTest::mouseMove(&window, handle + QPoint(0, 40));
                QTest::mouseRelease(&window, Qt::LeftButton, Qt::NoModifier, handle + QPoint(0, 40));
                expectedFirstHeight = 340;
                expectedSecondHeight = 200;
                QTRY_COMPARE_WITH_TIMEOUT(second->height(), expectedSecondHeight, 1000);
                QCOMPARE(first->height(), expectedFirstHeight);
                m_settings->flush();
                QSettings stored(workingfolder::settingsFilePath(), QSettings::IniFormat);
                QCOMPARE(stored.value("layout/charts/2/height").toReal(), expectedSecondHeight);

                // A constrained window must not replace the user's preferred heights.
                charts->setHeight(180);
                QTRY_COMPARE_WITH_TIMEOUT(second->height(), 100, 1000);
                charts->setHeight(window.height());
                QTRY_COMPARE_WITH_TIMEOUT(second->height(), expectedSecondHeight, 1000);
            }
        }
    }

    void equalizesOnDividerDoubleClick_data()
    {
        QTest::addColumn<int>("count");
        QTest::addColumn<int>("divider");
        QTest::newRow("double-first-divider") << 2 << 0;
        QTest::newRow("three-first-divider") << 3 << 0;
        QTest::newRow("three-second-divider") << 3 << 1;
    }

    void equalizesOnDividerDoubleClick()
    {
        QFETCH(int, count);
        QFETCH(int, divider);
        m_settings->setValue("layout/charts/count", count);
        m_settings->setValue("layout/charts/1/height", 300);
        m_settings->setValue("layout/charts/2/height", 240);
        m_settings->setValue("layout/charts/3/height", 200);

        for (int restart = 0; restart < 2; ++restart) {
            QQmlEngine engine;
            engine.rootContext()->setContextProperty("applicationSettings", m_settings);
            QQmlComponent component(&engine, QUrl::fromLocalFile(m_qmlDirectory.filePath("Charts.qml")));
            QVERIFY2(component.isReady(), qPrintable(component.errorString()));
            QQuickWindow window;
            QScopedPointer<QQuickItem> charts(qobject_cast<QQuickItem *>(component.create()));
            QVERIFY2(charts, qPrintable(component.errorString()));
            charts->setParentItem(window.contentItem());
            window.resize(1000, count == 3 ? 750 : 545);
            charts->setPosition(QPointF(30, 40));
            charts->setSize(QSizeF(window.width() - 30, window.height() - 40));
            window.show();
            auto first = pane(charts.data(), "first");
            auto second = pane(charts.data(), "second");
            auto third = pane(charts.data(), "third");
            QVERIFY(first && second && third);

            if (restart == 0) {
                QTRY_COMPARE_WITH_TIMEOUT(second->height(), 240, 1000);
                const QPoint chartCenter = charts->mapToScene(QPointF(500, 50)).toPoint();
                QTest::mouseClick(&window, Qt::LeftButton, Qt::NoModifier, chartCenter, 30);
                QTest::mouseClick(&window, Qt::LeftButton, Qt::NoModifier, chartCenter, 30);
                QCOMPARE(second->height(), 240);
                QCOMPARE(first->property("doubleClickCount").toInt(), 1);
                // Start a separate double-click sequence on the chosen divider.
                QTest::qWait(QGuiApplication::styleHints()->mouseDoubleClickInterval() + 1);
                const auto lowerPane = divider == 0 ? second : third;
                const QPoint handle = charts->mapToScene(QPointF(500, lowerPane->y() - 2)).toPoint();
                QTest::mouseClick(&window, Qt::LeftButton, Qt::NoModifier, handle, 30);
                QTest::mouseClick(&window, Qt::LeftButton, Qt::NoModifier, handle, 30);
            }
            const qreal equalHeight = charts->height() / qreal(count);
            QTRY_VERIFY_WITH_TIMEOUT(qAbs(second->height() - equalHeight) <= 1, 1000);
            if (count == 3)
                QTRY_VERIFY_WITH_TIMEOUT(qAbs(third->height() - equalHeight) <= 1, 1000);

            if (restart == 1) {
                const auto lowerPane = divider == 0 ? second : third;
                const qreal originalHeight = lowerPane->height();
                const QPoint handle = charts->mapToScene(QPointF(500, lowerPane->y() - 2)).toPoint();
                QTest::mousePress(&window, Qt::LeftButton, Qt::NoModifier, handle);
                QTest::mouseMove(&window, handle + QPoint(0, 40));
                QTest::mouseRelease(&window, Qt::LeftButton, Qt::NoModifier, handle + QPoint(0, 40));
                QTRY_VERIFY_WITH_TIMEOUT(qAbs(lowerPane->height() - (originalHeight - 40)) <= 1, 1000);
            }
        }
    }
};

QTEST_MAIN(ChartsLayoutTest)

#include "charts_layout_test.moc"

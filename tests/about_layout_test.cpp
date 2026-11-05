#include <QQmlComponent>
#include <QQmlContext>
#include <QQmlEngine>
#include <QQmlExpression>
#include <QQuickItem>
#include <QQuickWindow>
#include <QRegularExpression>
#include <QTest>

class AboutLayoutTest : public QObject
{
    Q_OBJECT

private slots:
    void opensAndResizesWithoutLayoutLoops_data()
    {
        QTest::addColumn<QSize>("windowSize");
        QTest::newRow("regular-window") << QSize(1200, 900);
        QTest::newRow("small-window") << QSize(768, 540);
    }

    void opensAndResizesWithoutLayoutLoops()
    {
        QFETCH(QSize, windowSize);
        QTest::failOnWarning(QRegularExpression(".*recursive rearrange.*"));
        QQmlEngine engine;
        engine.rootContext()->setContextProperty("appVersion", "v1.5.2-Qt6.12-test");
        QQuickWindow window;
        window.resize(windowSize);
        window.show();

        QQmlComponent component(&engine, QUrl::fromLocalFile(QStringLiteral(OSM_ABOUT_QML_FILE)));
        QVERIFY2(component.isReady(), qPrintable(component.errorString()));
        QScopedPointer<QObject> popup(component.createWithInitialProperties({
            {"parent", QVariant::fromValue(window.contentItem())},
            {"width", window.width() - 200},
            {"height", window.height() - 200}
        }));
        QVERIFY2(popup, qPrintable(component.errorString()));
        QVERIFY(QMetaObject::invokeMethod(popup.data(), "open"));
        QTRY_VERIFY_WITH_TIMEOUT(popup->property("visible").toBool(), 1000);
        QTest::qWait(100);
        auto item = [&](const QString &id) {
            QQmlExpression expression(QQmlEngine::contextForObject(popup.data()), popup.data(), id);
            return qvariant_cast<QQuickItem *>(expression.evaluate());
        };
        auto viewport = item("aboutContent");
        auto appStoreLink = item("mouseArea");
        QVERIFY(viewport && appStoreLink);
        QVERIFY(viewport->clip());
        viewport->setProperty("contentY", viewport->property("contentHeight").toReal() - viewport->height());
        const auto linkTop = appStoreLink->mapToItem(viewport, QPointF(0, 0));
        const auto linkBottom = appStoreLink->mapToItem(viewport, QPointF(0, appStoreLink->height()));
        QVERIFY(linkTop.y() >= -1);
        QVERIFY(linkBottom.y() <= viewport->height() + 1);
        popup->setProperty("width", window.width() - 250);
        QTest::qWait(100);
        QVERIFY(QMetaObject::invokeMethod(popup.data(), "close"));
        QTest::qWait(100);
        QVERIFY(QMetaObject::invokeMethod(popup.data(), "open"));
        QTest::qWait(100);
    }
};

QTEST_MAIN(AboutLayoutTest)

#include "about_layout_test.moc"

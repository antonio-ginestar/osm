#include <QElapsedTimer>
#include <QPointer>
#include <QRegularExpression>
#include <QScopeGuard>
#include <QTest>
#include <QThread>
#include <atomic>
#include <cstring>

#include "audio/plugins/wasapi.h"

class CountingEndpoint : public QIODevice
{
public:
    std::atomic<qint64> transferred{0};
    std::atomic<QThread *> worker{nullptr};
    bool closedBeforeWorkerFinished = false;
    bool closeOnTransfer = false;

    bool isSequential() const override { return true; }

    void close() override
    {
        auto thread = worker.load();
        closedBeforeWorkerFinished = thread && !thread->isFinished();
        QIODevice::close();
    }

protected:
    qint64 readData(char *data, qint64 size) override
    {
        // Exercise playback without producing sound.
        std::memset(data, 0, static_cast<size_t>(size));
        return count(size);
    }

    qint64 writeData(const char *, qint64 size) override
    {
        // Count microphone samples without retaining or saving audio.
        return count(size);
    }

private:
    qint64 count(qint64 size)
    {
        worker.store(QThread::currentThread());
        transferred += size;
        if (closeOnTransfer) {
            closeOnTransfer = false;
            QIODevice::close();
        }
        return size;
    }
};

class WasapiShutdownTest : public QObject
{
    Q_OBJECT

private slots:
    void initTestCase()
    {
        QVERIFY(SUCCEEDED(CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED)));
    }

    void cleanupTestCase() { CoUninitialize(); }

    void closesOnlyAfterWorkerFinishes_data()
    {
        QTest::addColumn<int>("direction");
        QTest::newRow("capture") << int(audio::Plugin::Input);
        QTest::newRow("silent-playback") << int(audio::Plugin::Output);
    }

    void closesOnlyAfterWorkerFinishes()
    {
        QFETCH(int, direction);
        QTest::failOnWarning(QRegularExpression("QIODevice::(read|write).*device not open"));
        audio::WasapiPlugin plugin;
        const auto mode = static_cast<audio::Plugin::Direction>(direction);
        const auto id = plugin.defaultDeviceId(mode);
        const auto format = plugin.deviceFormat(id, mode);
        QVERIFY2(!id.isEmpty() && format.isValid(), "This opt-in test requires an available audio endpoint.");

        for (int cycle = 0; cycle < 3; ++cycle) {
            CountingEndpoint endpoint;
            QPointer<audio::Stream> stream = plugin.open(id, mode, format, &endpoint);
            QVERIFY(stream);
            bool closed = false;
            auto cleanup = qScopeGuard([&]() {
                if (!closed && stream) {
                    stream->close();
                    QTest::qWait(1100);
                }
            });
            QTRY_VERIFY2_WITH_TIMEOUT(endpoint.transferred.load() > 0,
                                     "This opt-in test needs audio callbacks; unmute the microphone for capture.", 3000);
            QElapsedTimer closeTime;
            closeTime.start();
            stream->close();
            closed = true;
            const auto elapsed = closeTime.elapsed();
            const auto bytesAtClose = endpoint.transferred.load();
            // Let even the unfixed worker finish before test-local objects go away.
            QTest::qWait(1100);
            QVERIFY(!endpoint.closedBeforeWorkerFinished);
            QVERIFY(!endpoint.isOpen());
            QCOMPARE(endpoint.transferred.load(), bytesAtClose);
            QVERIFY2(elapsed < 1500, "Closing exceeded the native audio wait timeout.");
        }
    }

    void keepsInputStreamAliveAfterEarlyWorkerExit()
    {
        audio::WasapiPlugin plugin;
        const auto id = plugin.defaultDeviceId(audio::Plugin::Input);
        const auto format = plugin.deviceFormat(id, audio::Plugin::Input);
        QVERIFY2(!id.isEmpty() && format.isValid(), "This opt-in test requires an available microphone.");
        CountingEndpoint endpoint;
        endpoint.closeOnTransfer = true;
        QPointer<audio::Stream> stream = plugin.open(id, audio::Plugin::Input, format, &endpoint);
        QVERIFY(stream);
        auto cleanup = qScopeGuard([&]() {
            if (stream) {
                stream->close();
                QTest::qWait(1100);
            }
        });
        QTRY_VERIFY2_WITH_TIMEOUT(endpoint.transferred.load() > 0,
                                 "This opt-in test needs non-silent data from an unmuted microphone.", 3000);
        QTRY_VERIFY_WITH_TIMEOUT(endpoint.worker.load()->isFinished(), 2000);
        QTest::qWait(100);
        QVERIFY2(stream, "The worker deleted the stream before its owner could close it.");
    }
};

QTEST_GUILESS_MAIN(WasapiShutdownTest)

#include "wasapi_shutdown_test.moc"

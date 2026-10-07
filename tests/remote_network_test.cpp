#include <QSignalSpy>
#include <QTest>
#include <QtEndian>

#include "remote/network.h"
#include "remote/tcpreciever.h"

class RemoteNetworkTest : public QObject
{
    Q_OBJECT

private slots:
    void sendsCompressedResponse_data()
    {
        QTest::addColumn<QByteArray>("response");
        QTest::newRow("empty") << QByteArray();
        QTest::newRow("binary") << QByteArray("response\0bytes", 14);

        QByteArray largeResponse(100000, Qt::Uninitialized);
        quint32 state = 42;
        for (char &byte : largeResponse) {
            state ^= state << 13;
            state ^= state >> 17;
            state ^= state << 5;
            byte = static_cast<char>(state & 0xff);
        }
        QVERIFY(qCompress(largeResponse).size() > 32767);
        QTest::newRow("multiple-chunks") << largeResponse;
    }

    void sendsCompressedResponse()
    {
        QFETCH(QByteArray, response);
        const QByteArray request("request\0bytes", 13);
        QByteArray receivedRequest;
        remote::Network network;
        network.setTcpCallback([&](const QHostAddress &&, const QByteArray &&data) {
            receivedRequest = data;
            return response;
        });
        QVERIFY(network.startTCPServer());

        QTcpSocket socket;
        socket.setProxy(QNetworkProxy::NoProxy);
        QSignalSpy connected(&socket, &QTcpSocket::connected);
        QSignalSpy disconnected(&socket, &QTcpSocket::disconnected);
        QByteArray wireResponse;
        connect(&socket, &QTcpSocket::readyRead, this, [&] {
            wireResponse += socket.readAll();
        });
        socket.connectToHost(QHostAddress::LocalHost, network.port());
        QVERIFY(connected.wait(5000));
        const auto header = remote::TCPReciever::makeHeader(request);
        QCOMPARE(socket.write(header.data(), header.size()), qint64(header.size()));
        QCOMPARE(socket.write(request), qint64(request.size()));
        QVERIFY(disconnected.wait(5000));
        wireResponse += socket.readAll();

        QCOMPARE(receivedRequest, request);
        QVERIFY(wireResponse.size() >= 4);
        const auto compressed = wireResponse.mid(4);
        QCOMPARE(qFromLittleEndian<qint32>(wireResponse.constData()), compressed.size());
        QCOMPARE(qUncompress(compressed), response);
    }
};

QTEST_GUILESS_MAIN(RemoteNetworkTest)

#include "remote_network_test.moc"

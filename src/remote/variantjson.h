#ifndef REMOTE_VARIANTJSON_H
#define REMOTE_VARIANTJSON_H

#include <QJsonValue>
#include <QMetaType>
#include <QVariant>

namespace remote {

QJsonValue variantToJson(const QVariant &value);
QVariant jsonToVariant(const QJsonValue &value, QMetaType metaType);

} // namespace remote

#endif // REMOTE_VARIANTJSON_H

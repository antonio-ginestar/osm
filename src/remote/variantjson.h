#ifndef REMOTE_VARIANTJSON_H
#define REMOTE_VARIANTJSON_H

#include <QJsonValue>
#include <QVariant>

namespace remote {

QJsonValue variantToJson(const QVariant &value);

} // namespace remote

#endif // REMOTE_VARIANTJSON_H

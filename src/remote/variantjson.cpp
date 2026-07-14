#include "variantjson.h"

#include <QColor>
#include <QJsonObject>
#include <QMetaType>

namespace remote {

QJsonValue variantToJson(const QVariant &value)
{
    const auto metaType = value.metaType();
    switch (metaType.id()) {
    case QMetaType::Bool:
        return value.toBool();
    case QMetaType::UInt:
    case QMetaType::Int:
    case QMetaType::Long:
        return value.toInt();
    case QMetaType::Float:
        return value.toFloat();
    case QMetaType::Double:
        return value.toDouble();
    case QMetaType::QString:
        return value.toString();
    case QMetaType::QColor: {
        const auto color = value.value<QColor>();
        return QJsonObject {
            {QStringLiteral("red"), color.red()},
            {QStringLiteral("green"), color.green()},
            {QStringLiteral("blue"), color.blue()},
            {QStringLiteral("alpha"), color.alpha()}
        };
    }
    default:
        if (metaType.flags().testFlag(QMetaType::IsEnumeration)) {
            return value.toInt();
        }
        return QJsonValue(QJsonValue::Undefined);
    }
}

} // namespace remote

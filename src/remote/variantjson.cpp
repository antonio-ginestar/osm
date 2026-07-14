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
        if (metaType.flags().testFlag(QMetaType::IsEnumeration)
            || metaType.id() >= QMetaType::User) {
            return value.toInt();
        }
        return QJsonValue(QJsonValue::Undefined);
    }
}

QVariant jsonToVariant(const QJsonValue &value, QMetaType metaType)
{
    switch (metaType.id()) {
    case QMetaType::Bool:
        return value.toBool();
    case QMetaType::UInt:
        return static_cast<uint>(value.toInt());
    case QMetaType::Int:
        return value.toInt();
    case QMetaType::Long:
        return QVariant::fromValue(static_cast<long>(value.toInt()));
    case QMetaType::Float:
        return static_cast<float>(value.toDouble());
    case QMetaType::Double:
        return value.toDouble();
    case QMetaType::QString:
        return value.toString();
    case QMetaType::QColor: {
        const auto color = value.toObject();
        return QColor(color.value(QStringLiteral("red")).toInt(0),
                      color.value(QStringLiteral("green")).toInt(0),
                      color.value(QStringLiteral("blue")).toInt(0),
                      color.value(QStringLiteral("alpha")).toInt(1));
    }
    default:
        if (metaType.flags().testFlag(QMetaType::IsEnumeration)
            || metaType.id() >= QMetaType::User) {
            return value.toInt();
        }
        return {};
    }
}

} // namespace remote

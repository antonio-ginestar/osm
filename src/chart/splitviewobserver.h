// SPDX-License-Identifier: GPL-3.0-or-later
#ifndef CHART_SPLITVIEWOBSERVER_H
#define CHART_SPLITVIEWOBSERVER_H

#include <QMouseEvent>
#include <QQuickItem>

namespace Chart {

// Observe divider double-clicks without changing SplitView's pointer grabs.
class SplitViewObserver : public QQuickItem
{
    Q_OBJECT

public:
    explicit SplitViewObserver(QQuickItem *parent = nullptr) : QQuickItem(parent)
    {
        setFiltersChildMouseEvents(true);
    }

signals:
    void doubleClicked(const QPointF &position);

protected:
    bool childMouseEventFilter(QQuickItem *item, QEvent *event) override
    {
        if (event->type() == QEvent::MouseButtonDblClick) {
            const auto mouseEvent = static_cast<QMouseEvent *>(event);
            if (mouseEvent->button() == Qt::LeftButton)
                emit doubleClicked(mapFromItem(item, mouseEvent->position()));
        }
        return false;
    }
};

}

#endif // CHART_SPLITVIEWOBSERVER_H

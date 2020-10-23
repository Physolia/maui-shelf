import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3

import org.kde.mauikit 1.2 as Maui

import org.maui.shelf 1.0

Maui.AltBrowser
{
    id: control
    enableLassoSelection: true

    gridView.itemSize: 180
    gridView.topMargin: Maui.Style.contentMargins
    listView.topMargin: Maui.Style.contentMargins
    listView.spacing: Maui.Style.space.medium

    property alias list : _libraryList

    Connections
    {
        target: control.currentView
        function onItemsSelected(indexes)
        {
            for(var i in indexes)
            {
                const item =  control.model.get(indexes[i])
                _selectionbar.append(item.path, item)
            }
        }
    }

    model: Maui.BaseModel
    {
        id: _libraryModel
        sort: "modified"
        sortOrder: Qt.DescendingOrder
        recursiveFilteringEnabled: true
        sortCaseSensitivity: Qt.CaseInsensitive
        filterCaseSensitivity: Qt.CaseInsensitive
        list: LibraryList
        {
            id: _libraryList
        }
    }

    headBar.rightSretch: false
    headBar.leftContent: Maui.ToolActions
    {
        autoExclusive: true
        expanded: isWide
        currentIndex : control.viewType === Maui.AltBrowser.ViewType.List ? 0 : 1
        cyclic: true

        Action
        {
            text: qsTr("List")
            icon.name: "view-list-details"
            onTriggered: control.viewType = Maui.AltBrowser.ViewType.List
        }

        Action
        {
            text: qsTr("Grid")
            icon.name: "view-list-icons"
            onTriggered: control.viewType= Maui.AltBrowser.ViewType.Grid
        }
    }
    headBar.rightContent:[
        Maui.ToolButtonMenu
        {
            icon.name: "view-sort"
            MenuItem
            {
                text: qsTr("Title")
                checkable: true
                checked: _libraryModel.sort === "label"
                onTriggered: _libraryModel.sort = "label"
            }

            MenuItem
            {
                text: qsTr("Date")
                checkable: true
                checked: _libraryModel.sort === "modified"
                onTriggered: _libraryModel.sort = "modified"
            }

//            MenuItem
//            {
//                text: qsTr("Format")
//                checkable: true
//                checked: _libraryModel.sort === "mime"
//                onTriggered: _libraryModel.sort = "mime"
//            }

            MenuItem
            {
                text: qsTr("Size")
                checkable: true
                checked: _libraryModel.sort === "size"
                onTriggered: _libraryModel.sort = "size"
            }

            MenuSeparator {}

            MenuItem
            {
                text: i18n("Ascending")
                checked: _libraryModel.sortOrder === Qt.AscendingOrder
                onTriggered: _libraryModel.sortOrder = Qt.AscendingOrder
            }

            MenuItem
            {
                text: i18n("Descending")
                checked: _libraryModel.sortOrder === Qt.DescendingOrder
                onTriggered: _libraryModel.sortOrder = Qt.DescendingOrder
            }
        }
    ]

    headBar.middleContent: Maui.TextField
    {
        Layout.fillWidth: true
        placeholderText: qsTr("Filter...")
        onAccepted: control.model.filter = text
        onCleared:  control.model.filter = text
    }


    gridDelegate: Item
    {
        id: _gridDelegate

        property bool isCurrentItem : GridView.isCurrentItem

        height: control.gridView.cellHeight
        width: control.gridView.cellWidth

        Maui.ItemDelegate
        {
            id: _gridItemDelegate
            padding: Maui.Style.space.tiny
            isCurrentItem : GridView.isCurrentItem
            anchors.centerIn: parent
            height: parent.height- 10
            width: control.gridView.itemSize - 10
            draggable: true
            Drag.keys: ["text/uri-list"]

            Drag.mimeData: Drag.active ?
                               {
                                   "text/uri-list": control.filterSelectedItems(model.path)
                               } : {}

        background: Item {}
        Maui.GridItemTemplate
        {
            id: _gridTemplate
            isCurrentItem: _gridDelegate.isCurrentItem || checked
            hovered: _gridItemDelegate.hovered || _gridItemDelegate.containsPress
            anchors.fill: parent
            label1.text: model.label
            imageSource: model.thumbnail
            iconSource: model.icon
            iconSizeHint: height * 0.8
            imageHeight: iconSizeHint
            fillMode: Image.PreserveAspectFit
            checkable: selectionMode
            checked: _selectionbar.contains(model.path)
            onToggled: _selectionbar.append(model.path, control.model.get(index))
        }

        Connections
        {
            target: _selectionbar
            function onUriRemoved(uri)
            {
                if(uri === model.path)
                    _gridTemplate.checked = false
            }

            function onUriAdded(uri)
            {
                if(uri === model.path)
                    _gridTemplate.checked = true
            }

            function onCleared()
            {
                _gridTemplate.checked = false
            }
        }

        onClicked:
        {
            control.currentIndex = index
            const item = control.model.get(control.currentIndex)

            if(selectionMode || (mouse.button == Qt.LeftButton && (mouse.modifiers & Qt.ControlModifier)))
            {
                const item = control.model.get(control.currentIndex)
                _selectionbar.append(item.path, item)

            }else if(Maui.Handy.singleClick)
            {
                viewerView.open(item)
            }
        }

        onDoubleClicked:
        {
            control.currentIndex = index
            if(!Maui.Handy.singleClick && !selectionMode)
            {
                const item = control.model.get(control.currentIndex)
                viewerView.open(item)
            }
        }
    }
}

listDelegate: Maui.ItemDelegate
{
    id: _listDelegate

    property alias checked :_listTemplate.checked
    isCurrentItem: ListView.isCurrentItem || checked

    height: Maui.Style.rowHeight * 2
    width: parent.width
    leftPadding: Maui.Style.space.small
    rightPadding: Maui.Style.space.small
    draggable: true
    Drag.keys: ["text/uri-list"]
    Drag.mimeData: Drag.active ?
                       {
                           "text/uri-list": control.filterSelectedItems(model.path)
                       } : {}

    Maui.ListItemTemplate
    {
        id: _listTemplate
        anchors.fill: parent
        label1.text: model.label
        label2.text: model.path

        label3.text: Qt.formatDateTime(new Date(model.modified), "d MMM yyyy")

        iconSource: model.icon
        iconSizeHint: Maui.Style.iconSizes.big
        checkable: selectionMode
        checked: _selectionbar.contains(model.path)
        onToggled: _selectionbar.append(model.path, control.model.get(index))
        isCurrentItem: _listDelegate.isCurrentItem
    }

    Connections
    {
        target: _selectionbar
        function onUriRemoved(uri)
        {
            if(uri === model.path)
            _listDelegate.checked = false
        }

        function onUriAdded(uri)
        {
            if(uri === model.path)
            _listDelegate.checked = true
        }

        function onCleared()
        {
            _listDelegate.checked = false
        }
    }

    onClicked:
    {
        control.currentIndex = index
        const item = control.model.get(control.currentIndex)

        if(selectionMode || (mouse.button == Qt.LeftButton && (mouse.modifiers & Qt.ControlModifier)))
        {
            _selectionbar.append(item.path, item)

        }else if(Maui.Handy.singleClick)
        {
            viewerView.open(item)
        }
    }

    onDoubleClicked:
    {
        control.currentIndex = index

        if(!Maui.Handy.singleClick && !selectionMode)
        {
            const item = control.model.get(control.currentIndex)
            viewerView.open(item)
        }
    }
}


function filterSelectedItems(path)
{
    if(_selectionbar && _selectionbar.count > 0 && _selectionbar.contains(path))
    {
        const uris = _selectionbar.uris
        return uris.join("\n")
    }

    return path
}

}

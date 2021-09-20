import QtQuick 2.14
import QtQuick.Controls 2.14

import org.mauikit.controls 1.3 as Maui
import org.mauikit.imagetools 1.0 as IT

import org.kde.kirigami 2.9 as Kirigami

import org.shelf.poppler 1.0 as Poppler

Maui.Page
{
    id: control

    property bool fitWidth: false
    property int currentPage : _listView.currentIndex
    property alias currentItem :_listView.currentItem
    property alias orientation : _listView.orientation
    property alias path : poppler.path

    headBar.visible: false
    footBar.visible: !Kirigami.Settings.isMobile && poppler.pages > 1
    title: poppler.title
    padding: 0

    Maui.NewDialog
    {
        id: _passwordDialog

        title: i18n("Document Locked")
        message: i18n("Please enter your password to unlock and open the file.")
        textEntry.echoMode: TextInput.Password
        onFinished: poppler.unlock(text, text)
    }

    footBar.middleContent: [
        Maui.ToolActions
        {
            expanded: true
            autoExclusive: false
            checkable: false

            Action
            {
                enabled: _listView.currentIndex > 0
                icon.name:  _listView.orientation === ListView.Horizontal ? "go-previous" : "go-up"
                onTriggered:
                {
                    if( _listView.currentIndex > 0)
                    _listView.currentIndex = _listView.currentIndex - 1
                }
            }

            Action
            {
                text:  _listView.currentIndex + 1 +" / "+ poppler.pages
            }

            Action
            {
                enabled: _listView.currentIndex +1 < poppler.pages
                icon.name:  _listView.orientation === ListView.Horizontal ? "go-next" : "go-down"
                onTriggered:
                {
                    if( _listView.currentIndex +1 < poppler.pages)
                    _listView.currentIndex = _listView.currentIndex + 1
                }
            }
        }
    ]

    Maui.ListBrowser
    {
        id: _listView
        anchors.fill: parent
        model: Poppler.Document
        {
            id: poppler

            property bool isLoading: true

            onPagesLoaded:
            {
                isLoading = false;
            }

            onDocumentLocked: _passwordDialog.open()
        }

        orientation: ListView.Vertical
        snapMode: ListView.SnapOneItem
        //        cacheBuffer: control.fitWidth ? poppler.providersNumber *  : height * poppler.providersNumber

        flickable.onMovementEnded:
        {
            var index = indexAt(_listView.contentX, _listView.contentY)
            currentIndex = index
        }

        delegate: Item
        {
            id: delegate
            width: ListView.view.width
            height: ListView.view.height

            IT.ImageViewer
            {
                id: pageImg
                asynchronous: true

                anchors.centerIn: parent
                height: fitWidth ? undefined : parent.height
                width:  parent.width

                cache: false
                //                source: "image://poppler" + (index % poppler.providersNumber) + "/page/" + _listView.currentPage;
                //                source: "image://poppler" + (index % poppler.providersNumber) + "/page/" + index;
                source: "image://poppler" + (index % poppler.providersNumber) + "/page/" + index
                //                                source: "image://poppler/page/" + _listView.currentPage;
                sourceSize.width: 2000
                //                    sourceSize.height: 2000
                //                    imageWidth: 1000
                //                    imageHeight: 1000
                fillMode: Image.PreserveAspectFit

                //                onSourceChanged: console.log(source)
            }
        }

        //         ScrollBar.vertical: ScrollBar {}
    }

    function open(filePath)
    {
        poppler.path = filePath
    }
}
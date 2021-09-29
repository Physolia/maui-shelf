import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Window 2.12

import org.mauikit.controls 1.3 as Maui
import org.mauikit.filebrowsing 1.3 as FB

import org.kde.kirigami 2.7 as Kirigami
import org.shelf.poppler 1.0 as Poppler

Maui.Page
{
    id: control

    property string currentPath : ""
    property bool currentPathFav : false
    property alias currentViewer: _viewerLoader.item

    title: currentViewer ? currentViewer.title : ""
    padding: 0

    onGoBackTriggered: _stackView.pop()
    property alias viewer : _viewerLoader.item

    Maui.Doodle
    {
        id: doodle
        sourceItem: currentViewer.currentItem
        hint: 1
    }

    Maui.Holder
    {
        anchors.fill: parent
        visible: !viewer
        emoji: "qrc:/assets/draw-watercolor.svg"
        title : i18n("Nothing here")
        body: i18n("Drop or open a document to view.")
        emojiSize: Maui.Style.iconSizes.huge
    }

    headBar.forceCenterMiddleContent: root.isWide

    headBar.farLeftContent: ToolButton
    {
        icon.name: "go-previous"
        text: i18n("Browser")
        display: isWide ? ToolButton.TextBesideIcon : ToolButton.IconOnly
        onClicked: _stackView.pop()
    }

    headBar.rightContent: Maui.ToolButtonMenu
    {
        icon.name: "overflow-menu"

        Maui.MenuItemActionRow
        {
            Action
            {
                icon.name: "love"
                text: i18n("Fav")

                checked: currentPathFav
                icon.color: currentPathFav ? "#f84172" : Kirigami.Theme.textColor
                onTriggered:
                {
                    FB.Tagging.toggleFav(control.currentPath)
                    currentPathFav = FB.Tagging.isFav(control.currentPath)
                }
            }

            Action
            {
                icon.name: "tool_pen"
                text: i18n("Doodle")

                onTriggered: doodle.open()
            }

            Action
            {
                icon.name: "document-share"
                text: i18n("Share")

                onTriggered:
                {
                    Maui.Platform.shareFiles([control.currentPath])
                }
            }
        }


        MenuSeparator {}

        MenuItem
        {
            icon.name: "view-right-new"
            text: i18n("Browse Horizontally")

            checkable: true
            checked:  currentViewer.orientation === ListView.Horizontal
            onClicked:
            {
                currentViewer.orientation = currentViewer.orientation === ListView.Horizontal ? ListView.Vertical : ListView.Horizontal
            }
        }

        MenuItem
        {
            icon.name:  "zoom-fit-width"
            text: i18n("Fill")
            checkable: true
            checked: currentViewer.fitWidth
            onTriggered:
            {
                currentViewer.fitWidth= !currentViewer.fitWidth
            }
        }

        MenuItem
        {
            text: i18n("Fullscreen")
            checkable: true
            checked: root.visibility === Window.FullScreen
            icon.name: "view-fullscreen"
            onTriggered: root.visibility = (root.visibility === Window.FullScreen  ? Window.Windowed : Window.FullScreen)
        }
    }


    Loader
    {
        id: _viewerLoader
        anchors.fill: parent
    }

    Component
    {
        id: _pdfComponent

        Poppler.PDFViewer
        {
            anchors.fill: parent
            onGoBackTriggered: _stackView.pop()
        }
    }

    Component
    {
        id: _txtComponent

        Viewer_TXT
        {
            anchors.fill: parent
        }
    }

    Component
    {
        id: _epubComponent

        Viewer_EPUB
        {
            anchors.fill: parent
        }
    }

    function open(path)
    {
        control.currentPath = path
        control.currentPathFav = FB.Tagging.isFav(path)

        console.log("openinf file:", control.currentPath)
        if(FB.FM.fileExists(  control.currentPath))
        {
            _stackView.push(viewerView)
            if(control.currentPath.endsWith(".pdf"))
                _viewerLoader.sourceComponent = _pdfComponent
            else if(control.currentPath.endsWith(".txt"))
                _viewerLoader.sourceComponent = _txtComponent
            else if(control.currentPath.endsWith(".epub"))
                _viewerLoader.sourceComponent = _epubComponent
            else return;

            viewer.open(control.currentPath)
        }
    }
}

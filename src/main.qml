import QtQuick 2.15
import QtQuick.Controls 2.15
import Qt.labs.settings 1.0

import org.kde.kirigami 2.14 as Kirigami
import org.mauikit.controls 1.3 as Maui
import org.mauikit.filebrowsing 1.3 as FB

import org.maui.shelf 1.0 as Shelf

import "views"
import "views/library/"
import "views/Viewer/"

Maui.ApplicationWindow
{
    id: root
    title: viewerView.title
    Maui.App.darkMode: viewerSettings.darkMode

    headBar.visible: false

    property bool selectionMode: false
    property alias dialog :_dialogLoader.item

    Settings
    {
        id: viewerSettings
        property bool thumbnailsPreview : true
        property bool darkMode: true
        property int viewType : Maui.AltBrowser.ViewType.Grid
    }

    Component
    {
        id: _settingsDialogComponent

        SettingsDialog {}
    }

    Component
    {
        id: _fileDialog
        FB.FileDialog
        {
            mode: modes.OPEN
            settings.filterType: FB.FMList.DOCUMENT
            callback: function(paths)
            {
                console.log(paths)
                Shelf.Library.openFiles(paths)
            }
        }
    }

    Loader
    {
        id: _dialogLoader
    }

    StackView
    {
        id: _stackView
        anchors.fill: parent

        pushEnter: Transition
        {
            PropertyAnimation
            {
                property: "opacity"
                from: 0
                to:1
                duration: 200
            }
        }

        pushExit: Transition
        {
            PropertyAnimation
            {
                property: "opacity"
                from: 1
                to:0
                duration: 200
            }
        }

        popEnter: Transition
        {
            PropertyAnimation
            {
                property: "opacity"
                from: 0
                to:1
                duration: 200
            }
        }

        popExit: Transition
        {
            PropertyAnimation
            {
                property: "opacity"
                from: 1
                to:0
                duration: 200
            }
        }

        Viewer
        {
            id: viewerView
            visible: StackView.status === StackView.Active
        }

        initialItem: LibraryView
        {
            id: libraryView
            showCSDControls: true
        }
    }

    Connections
    {
        target: Shelf.Library

        ignoreUnknownSignals: true

        onRequestedFiles:
        {
            viewerView.open(files[0])
        }
    }

    Component.onCompleted:
    {
        setAndroidStatusBarColor()
    }        

    function toggleViewer()
    {
        if(viewerView.visible)
        {
            if(_stackView.depth === 1)
            {
                _stackView.replace(viewerView, libraryView)

            }else
            {
                _stackView.pop()
            }

        }else
        {
            _stackView.push(viewerView)
        }

        _stackView.currentItem.forceActiveFocus()
    }

    function setAndroidStatusBarColor()
    {
        if(Maui.Handy.isAndroid)
        {
            Maui.Android.statusbarColor( Kirigami.Theme.backgroundColor, !Maui.App.darkMode)
            Maui.Android.navBarColor(headBar.visible ? headBar.Kirigami.Theme.backgroundColor : Kirigami.Theme.backgroundColor, !Maui.App.darkMode)
        }
    }
}

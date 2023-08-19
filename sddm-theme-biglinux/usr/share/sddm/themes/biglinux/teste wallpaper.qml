import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.XmlListModel 2.15

ApplicationWindow {
    visible: true
    width: 800
    height: 600

    property string wallpaperPath: "" // Aqui você armazenará o caminho do wallpaper

    Rectangle {
        width: parent.width
        height: parent.height

        Image {
            source: wallpaperPath
            anchors.fill: parent
        }
    }

    // Lê o caminho do wallpaper do arquivo theme.conf.user
    XmlListModel {
        id: themeConfModel
        source: file: usr/share/sddm/themes/biglinux/theme.conf.user // Substitua pelo caminho correto

        query: "/General"
        XmlRole { name: "background"; query: "background/string()" }
    }

    // Ao carregar o caminho do wallpaper, atribui à propriedade 'wallpaperPath'
    Component.onCompleted: {
        if (themeConfModel.count > 0) {
            wallpaperPath = themeConfModel.get(0).background;
        }
    }
}

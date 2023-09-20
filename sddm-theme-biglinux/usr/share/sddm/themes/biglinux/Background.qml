/*
 *   Copyright 2016 Boudhayan Gupta <bgupta@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2 or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

import QtQuick 2.12
import QtGraphicalEffects 1.12

FocusScope {
    id: sceneBackground

    property var sceneBackgroundType
    property alias sceneBackgroundColor: sceneColorBackground.color
    property alias sceneBackgroundImage: sceneImageBackground.source

    Rectangle {
        id: sceneColorBackground
        anchors.fill: parent
    }

    Image {
        id: sceneImageBackground
        anchors.fill: parent
        sourceSize.width: parent.width
        sourceSize.height: parent.height
        fillMode: Image.PreserveAspectCrop
        smooth: false
        
        ShaderEffectSource {
            id: shader
            format: RGB
            live: false
            smooth: false 
            
            anchors.centerIn: parent
            implicitWidth: parent.width / 2.4
            implicitHeight: parent.height / 1.2
            width: Math.max(150, implicitWidth)
            height: Math.max(150, implicitHeight)
            sourceItem: sceneImageBackground
            sourceRect: Qt.rect(x,y, width, height) 
            
        }
        
        GaussianBlur {
                smooth: false 
                anchors.fill: shader
                source: shader
                radius: 16
                transparentBorder: true
                cached: true
            }
        
    }
    
    
    states: [
        State {
            name: "imageBackground"
            when: sceneBackgroundType === "image"
            PropertyChanges {
                target: sceneColorBackground
                visible: false
            }
            PropertyChanges {
                target: sceneImageBackground
                visible: true
            }
        },
        State {
            name: "colorBackground"
            when: sceneBackgroundType !== "image"
            PropertyChanges {
                target: sceneColorBackground
                visible: true
            }
            PropertyChanges {
                target: sceneImageBackground
                visible: false
            }
        }
    ]
}

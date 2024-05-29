import QtQuick 2.15
import QtQuick.Window 2.15

Window {
    visible: true
    width: 800
    height: 600
    title: "Telescópio Noturno"

    Rectangle {
        width: parent.width
        height: parent.height

        // Gradient background
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#0b0d1c" }  // Darker blue at the top
            GradientStop { position: 0.5; color: "#101634" }  // Dark blue in the middle
            GradientStop { position: 1.0; color: "#191919" }  // Dark gray at the bottom
        }

        Canvas {
            id: canvas
            anchors.fill: parent
            property var stars: []
            property real centerX: canvas.width / 2
            property real centerY: canvas.height / 2

            function createStar() {
                var colors = [
                    {r: 255, g: 255, b: 255}, // White
                    {r: 255, g: 255, b: 200}, // Yellowish
                    {r: 255, g: 200, b: 200}, // Reddish
                    {r: 200, g: 255, b: 200}, // Greenish
                    {r: 200, g: 200, b: 255}  // Bluish
                ];
                var color = colors[Math.floor(Math.random() * colors.length)];
                var depth = Math.random();
                return {
                    x: Math.random() * canvas.width,
                    y: Math.random() * canvas.height,
                    baseX: Math.random() * canvas.width,
                    baseY: Math.random() * canvas.height,
                    depth: depth, // Depth from 0 (closest) to 1 (farthest)
                    size: (Math.random() * 1.5 + 0.5) * (1 - depth), // Smaller size for farther stars
                    opacity: Math.random() * (1 - depth) + 0.1, // Less opacity for farther stars
                    twinkleSpeed: Math.random() * 0.02 + 0.01, // Speed of twinkling
                    color: color
                };
            }

            onPaint: {
                var ctx = canvas.getContext("2d");
                ctx.clearRect(0, 0, canvas.width, canvas.height);

                // Draw stars
                for (var i = 0; i < stars.length; i++) {
                    var star = stars[i];
                    ctx.save();
                    ctx.beginPath();
                    ctx.arc(star.x, star.y, star.size, 0, 2 * Math.PI, false);
                    var gradient = ctx.createRadialGradient(star.x, star.y, 0, star.x, star.y, star.size);
                    gradient.addColorStop(0, "rgba(" + star.color.r + ", " + star.color.g + ", " + star.color.b + ", " + star.opacity + ")");
                    gradient.addColorStop(1, "rgba(" + star.color.r + ", " + star.color.g + ", " + star.color.b + ", 0)");
                    ctx.fillStyle = gradient;
                    ctx.fill();
                    ctx.restore();
                }
            }

            Component.onCompleted: {
                for (var i = 0; i < 300; i++) { // Increase the number of stars
                    stars.push(createStar());
                }

                canvas.requestPaint();
            }

            Timer {
                interval: 70 // Increase interval to reduce CPU usage
                running: true
                repeat: true
                onTriggered: {
                    for (var i = 0; i < canvas.stars.length; i++) {
                        var star = canvas.stars[i];
                        star.opacity += star.twinkleSpeed;
                        if (star.opacity <= 0 || star.opacity >= 1) {
                            star.twinkleSpeed = -star.twinkleSpeed; // Reverse direction for twinkling
                        }
                    }

                    canvas.requestPaint();
                }
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onPositionChanged: {
                    var parallaxFactor = 0.05; // Adjust parallax effect

                    for (var i = 0; i < canvas.stars.length; i++) {
                        var star = canvas.stars[i];
                        var depthFactor = (1 - star.depth) * parallaxFactor;
                        star.x = star.baseX + (mouse.x - canvas.centerX) * depthFactor;
                        star.y = star.baseY + (mouse.y - canvas.centerY) * depthFactor;
                    }

                    canvas.requestPaint();
                }
            }

            Timer {
                interval: 100 // Adjust the rotation speed
                running: true
                repeat: true
                onTriggered: {
                    var rotationSpeed = 0.0005; // Adjust rotation speed
                    for (var i = 0; i < canvas.stars.length; i++) {
                        var star = canvas.stars[i];
                        var angle = Math.atan2(star.baseY - canvas.centerY, star.baseX - canvas.centerX);
                        var distance = Math.sqrt(Math.pow(star.baseX - canvas.centerX, 2) + Math.pow(star.baseY - canvas.centerY, 2));
                        angle += rotationSpeed;
                        star.baseX = canvas.centerX + distance * Math.cos(angle);
                        star.baseY = canvas.centerY + distance * Math.sin(angle);
                    }

                    canvas.requestPaint();
                }
            }
        }
    }
}

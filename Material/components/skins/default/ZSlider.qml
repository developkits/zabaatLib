import Zabaat.Material 1.0 as M
import QtQuick 2.4
import "helpers"
M.ZSkin {
    id : rootObject
    color : "transparent"
    property alias  graphical     : graphical
    property int    minHeight     : Math.max(parent.height/8 , M.Units.dp(15))
    property int    minTextHeight : M.Units.dp(25)
    property string lblDisp       : logic.labelDispFunc ? logic.labelDispFunc(logic.value) : logic.label
    property string valDisp       : logic.valueDispFunc ? logic.valueDispFunc(logic.value) : logic.value

    property alias  font               : valueText.font
    property alias  labelLeftContainer : labelLeftContainer
    property alias  bar                : bar
    property alias  valueContainer     : valueContainer

    Connections {
        target        : logic ? logic : null
        onValueChanged: update()
    }

    onLogicChanged : if(logic){
                         update()
                     }

    function update(caller){
        if(logic) {
            bar_fill.width = bar_fill.widthFunc(logic.value)
            knob.x         = bar_fill.width - knob.width/2
        }
    }



    //LEFT AND RIGHT MOUSEAREAS TO MIN MAX VALUE
    MouseArea {
        height     : knob.height
        width       : (parent.width - bar.width)/2
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        onClicked : { knob.x = knob.minDrag; knob.setValUsingX(knob.x) }
//        Rectangle { anchors.fill: parent; border.width: 1; color : 'transparent' }
    }
    MouseArea {
        height : knob.height
        width  : (parent.width - bar.width)/2
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        onClicked : { knob.x = knob.maxDrag; knob.setValUsingX(knob.x) }
//        Rectangle { anchors.fill: parent; border.width: 1; color : 'transparent' }
    }
    Rectangle {
        id                    : labelLeftContainer
        anchors.left          : parent.left
        anchors.verticalCenter: parent.verticalCenter
        visible               : logic && logic.label !== "" ? true : false
        width                 : visible ? parent.width * 0.1 : 0
        height                : width
        border.width          : 0
        color                 : "transparent"
        rotation : logic ? -logic.rotation : 0
        Text {
            anchors.fill        : parent
            font.pixelSize      : Math.min(height * 1/2, minTextHeight)
            font.family         : logic.font1
            text                : lblDisp
            color               : graphical.labelColor
            horizontalAlignment : Text.AlignHCenter
            verticalAlignment   : Text.AlignVCenter
        }
    }
    Rectangle {
        id : bar
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter  : parent.verticalCenter
        height                  : minHeight
        width                   : parent.width - (labelLeftContainer.width + valueContainer.width + parent.width * 0.10)
        color                   : graphical.emptyColor
        radius                  : 5
        onWidthChanged: rootObject.update()
        property alias knob : knob

        MouseArea {
            width  : parent.width
            height : knob.height
            anchors.centerIn: parent
            onClicked : {
                var x = logic && logic.isInt ? mouseX : mouseX - knob.width/2
                if(x > knob.maxDrag)         x = knob.maxDrag
                else if(x < knob.minDrag)    x = knob.minDrag

//                knob.x = x
                knob.setValUsingX(x)
            }
        }
        Rectangle {
            id : bar_fill
            height      : parent.height
            anchors.left: parent.left
            color       : graphical.fillColor
            radius      : parent.radius
            function widthFunc(val) {
                return bar.width * ((logic.value - logic.min) / (logic.max - logic.min))
            }
        }
        Knob {
            id : knob
            height : parent.height * 2
            anchors.verticalCenter: parent.verticalCenter
            dragEnabled           : true
            x                     : -width/2
            minDrag               : -width/2
            maxDrag               : bar.width + minDrag//!logic.isInt ? bar.width - width/2 : bar.width + width/2
            color                 : graphical.knobColor
            inkColor              : graphical.fillColor
            scale                 : graphical.knobScale

            property bool   internalChange : false
            readonly property double value : logic.value
            readonly property double min   : logic.min
            readonly property double max   : logic.max

            function getVal(x) {
//                x -= minDrag
                var max  = maxDrag + minDrag
                var perc = x / max
                var val  = perc * (logic.max - logic.min ) + logic.min

                if(logic.isInt)
                    val = Math.round(val)

                if(val > logic.max)        val = logic.max
                else if(val < logic.min)   val = logic.min
                return val;
            }


            onDragging: setValUsingX(x)
            function setValUsingX(x){
                if(!internalChange){
                    internalChange = true

                    logic.value = getVal(x)
                    rootObject.update()

                    internalChange = false
                }
            }

            Bubble {
                id : bubble
                anchors.bottom: parent.top
                anchors.bottomMargin: height/2
                anchors.horizontalCenter: parent.horizontalCenter

                property double c : Math.max(Math.cos(rotation) * 3)
                property double s : Math.sin(rotation)

                property double g : rotation !== 0 ? Math.max(Math.sin(rotation) , Math.cos(rotation)) : 1.5

                width  : (c * parent.width + s * parent.width)
                height : (c * parent.height + s * parent.height)
                visible : graphical.bubbleEnabled
                color  : M.Colors.getContrastingColor(graphical.fillColor)
                scale  : knob.isPressed ? 1 : 0
                Behavior on scale { NumberAnimation { duration : 200 }}
                Text {
                    id : bubbleText
                    anchors.fill        : parent

                    font.pixelSize      : height * 1/3
                    font.family         : rootObject.font.family
                    font.bold           : rootObject.font.bold
                    font.italic         : rootObject.font.italic
                    font.underline: rootObject.font.underline
                    font.strikeout: rootObject.font.strikeout
                    font.weight: rootObject.font.weight
                    font.capitalization: rootObject.font.capitalization


                    text                : valDisp
                    color               : graphical.bubbleTextColor
                    horizontalAlignment : Text.AlignHCenter
                    verticalAlignment   : Text.AlignVCenter
                    elide               : Text.ElideRight
                    rotation            : logic ? -logic.rotation : 0
                }
            }

        }
        z : 999
    }
    Rectangle {
        id : valueContainer
        anchors.right         : parent.right
        anchors.verticalCenter: parent.verticalCenter
        visible               : graphical.valueVisible
        width                 : visible ? parent.width * 0.1 : 0
        height                : width
        border.width          : 0
        color                 : "transparent"
        rotation : logic ? -logic.rotation : 0
        property alias valueText: valueText
        Text {
            id : valueText
            anchors.fill        : parent
            font.pixelSize      : Math.min(height * 1/2, minTextHeight)
            font.family         : logic.font1
            text                : valDisp
            color               : graphical.valueColor
            horizontalAlignment : Text.AlignHCenter
            verticalAlignment   : Text.AlignVCenter
            elide               : Text.ElideRight
        }
    }
    Item {
        id : ticks
        anchors.fill: bar
        readonly property bool isInt : logic && logic.isInt ? true : false
        property var min: logic ? Math.floor(logic.min) : null
        property var max: logic ? Math.floor(logic.max) : null
        property int numTicks : 0

        property color fillColor : Qt.darker(graphical.fillColor , 1.3)
        property color emptyColor: Qt.darker(graphical.emptyColor, 1.3)
//        scale : knob.isPressed ? 1 : 0

        property bool hasInit : false
        onMinChanged: if(hasInit) privates.makeTicks()
        onMaxChanged: if(hasInit) privates.makeTicks()
        Component.onCompleted: {  privates.makeTicks() ; hasInit = true }

        onIsIntChanged: if(!isInt) {
                            ticksContainer.clear()
                            numTicks = 0
                        } else {
                             privates.makeTicks() ;
                        }

        z : 1000
        Item {
            id : ticksContainer
            anchors.fill: parent
            property alias fill      : ticks.fillColor
            property alias empty     : ticks.emptyColor

            function clear(){
                for(var c in children){
                    var item = children[c]
                    item.destroy()
                }
                children = []
            }
        }
        Component {
            id : tickFactory
            Rectangle {
                width  : height
                height : parent ? parent.height * 1.5 : 0
                radius : height / 2
                property var number      : null
                property int numTicks    : 1
                anchors.left             : parent ? parent.left : undefined
                anchors.leftMargin       : number !== null && numTicks && parent ? number * parent.width/numTicks - width/2 : 0
                property var lf : anchors.leftMargin
//                onLfChanged : if(number && numTicks) console.log(number,numTicks, lf, bar.width)
                anchors.verticalCenter   : parent ? parent.verticalCenter : undefined
                color                    : {
                    if(rootObject.logic && parent){
                        var val = rootObject.logic.value - rootObject.logic.min
                        if(val >= number){
                            return parent.fill
                        }
                        return parent.empty
                    }
                    return "black"
                }
                scale : knob.isPressed ? 1 : 0
                Behavior on scale { NumberAnimation { duration : 500 } }
//                Text {
//                    anchors.bottom: parent.top
//                    text : parent.number
//                    horizontalAlignment: Text.AlignHCenter
//                    width : parent.width
//                }
            }
        }
        QtObject {
            id : privates

            function makeTicks(){
                if(!isInt)
                    return

                if(ticks.min === null || ticks.max === null) {
                    ticksContainer.clear()
                    ticks.numTicks = 0
                }
                else if(ticks.max >= ticks.min) {
//                    console.log("MAKE TICKS CALLED", ticks.min, ticks.max)
                    //figure out how many ticks we need to make, this is the
                    //difference between min and max
                    ticks.numTicks = ticks.max - ticks.min

                    if(ticks.numTicks <= 0)
                        return


                    //figure out at which intervals , we need to place a tick
                    for(var i = 0; i <= ticks.numTicks; i++){
//                        console.log("CREATING TICK NUMBER", i, numTicks)
                        var tick = tickFactory.createObject(ticksContainer)
                        tick.number   = i
                        tick.numTicks = ticks.numTicks
                    }
                }
            }
        }


    }
    Item {
        id : graphical
        property bool   valueVisible    : true
        property color  fillColor       : M.Colors.success
        property color  emptyColor      : "darkGray"
        property color  labelColor      : M.Colors.getContrastingColor(M.Colors.text1)
        property color  valueColor      : M.Colors.getContrastingColor(M.Colors.text1)
        property color  knobColor       : M.Colors.success
        property double knobScale       : 1
        property color  bubbleTextColor : M.Colors.text2
        property bool   bubbleEnabled   : true
    }

    states : ({
                  "default" : { "rootObject": {   "border.width" : 0,
                                                  "radius"       : 0,
                                                  "@width"       : [parent,"width"],
                                                  "@height"      : [parent,"height"],
                                                  rotation       : 0
                                              } ,
                                "graphical" : {   "valueVisible"     : true,
                                                  "bubbleEnabled"    : true,
                                                  "knobScale"        : 1,
                                                  "@fillColor"       : [M.Colors,"accent"],
                                                  "emptyColor"       : "darkGray",
                                                  "@labelColor"      : [M.Colors,"text1"],
                                                  "@valueColor"      : [M.Colors,"text1"],
                                                  "@knobColor"       : [M.Colors,"accent"],
                                                  "@bubbleTextColor" : [M.Colors,"text1"]
                                               },
                                 labelLeftContainer : { "@visible" : function() { return logic && logic.label !== "" ? true : false },
                                                        "@width"   : function() { return labelLeftContainer.visible ? labelLeftContainer.parent.width * 0.1 : 0},
                                                        "@height"  : [labelLeftContainer, "width"],
                                                        "border.width" : 0,
                                                        "color"   : "transparent"
                                                      },
                                 bar                : { "@height" : [rootObject,"minHeight"],
                                                        "@width"  : function() { return bar.parent.width - (labelLeftContainer.width + valueContainer.width + bar.parent.width * 0.10)},
                                                        radius    : 5
                                                      },
                                 "bar.knob"         : { "@height" : [knob.parent, "height", 2],
                                                         spillScale : 2
                                                      } ,
                                 valueContainer     : { "@width"        : function() { return valueContainer.visible ? parent.width * 0.1 : 0 },
                                                        "@height"       : [valueContainer,"width"],
                                                        "border.width"  : 0,
                                                        "color"         : "transparent",
                                                        "@visible"      : [graphical,"valueVisible"]
                                                      }
                               },
                  "notext"    : { labelLeftContainer : {  "visible" : false,
                                                          "width"   : 0,
                                                          "height"  : 0
                                                        },
                                   valueContainer     : { "visible" : false,
                                                          "width"   : 0,
                                                          "height"  : 0
                                                        }
                                } ,
                  "bar1"    : { bar : { "@height" : [rootObject,"height",0.1] } } ,
                  "bar2"    : { bar : { "@height" : [rootObject,"height",0.2] } } ,
                  "bar3"    : { bar : { "@height" : [rootObject,"height",0.3] } } ,
                  "bar4"    : { bar : { "@height" : [rootObject,"height",0.4] } } ,
                  "bar5"    : { bar : { "@height" : [rootObject,"height",0.5] } } ,
                  "bar6"    : { bar : { "@height" : [rootObject,"height",0.6] } } ,
                  "bar7"    : { bar : { "@height" : [rootObject,"height",0.7] } } ,
                  "bar8"    : { bar : { "@height" : [rootObject,"height",0.8] } } ,
                  "bar9"    : { bar : { "@height" : [rootObject,"height",0.9] } } ,
                  "bar10"   : { bar : { "@height" : [rootObject,"height"]     } } ,
                  "knob1"     : { "bar.knob" : { "@height" : [bar, "height", 1.25 ] } } ,
                  "knob2"     : { "bar.knob" : { "@height" : [bar, "height", 1.5  ] } } ,
                  "knob3"     : { "bar.knob" : { "@height" : [bar, "height", 1.75 ] } } ,
                  "knob4"     : { "bar.knob" : { "@height" : [bar, "height", 2    ] } } ,
                  "knob5"     : { "bar.knob" : { "@height" : [bar, "height", 2.25 ] } } ,
                  "knob6"     : { "bar.knob" : { "@height" : [bar, "height", 2.50 ] } } ,
                  "knob7"     : { "bar.knob" : { "@height" : [bar, "height", 2.75 ] } } ,
                  "knob8"     : { "bar.knob" : { "@height" : [bar, "height", 3    ] } } ,
                  "knob9"     : { "bar.knob" : { "@height" : [bar, "height", 3.25 ] } } ,
                  "knob10"    : { "bar.knob" : { "@height" : [bar, "height", 3.5  ] } } ,
                  "spill1"  : { "bar.knob" : { "spillScale" : 1.1 } } ,
                  "spill2"  : { "bar.knob" : { "spillScale" : 1.2 } } ,
                  "spill3"  : { "bar.knob" : { "spillScale" : 1.3 } } ,
                  "spill4"  : { "bar.knob" : { "spillScale" : 1.4 } } ,
                  "spill5"  : { "bar.knob" : { "spillScale" : 1.5 } } ,
                  "spill6"  : { "bar.knob" : { "spillScale" : 1.6 } } ,
                  "spill7"  : { "bar.knob" : { "spillScale" : 1.7 } } ,
                  "spill8"  : { "bar.knob" : { "spillScale" : 1.8 } } ,
                  "spill9"  : { "bar.knob" : { "spillScale" : 1.9 } } ,

                  "alternate" : { "graphical" : { "@fillColor"       : [M.Colors,"success"],
                                                  "emptyColor"       : "darkGray",
                                                  "@labelColor"      : [M.Colors.contrasting,"text2"],
                                                  "@valueColor"      : [M.Colors.contrasting,"text2"],
                                                  "@knobColor"       : [M.Colors,"success"],
                                                  "@bubbleTextColor" : [M.Colors,"text2"]
                                                }
                              },
                  "disabled" : { "graphical" : {  "bubbleEnabled"    : false,
                                                  "knobScale"        : 0.5,
                                                  "fillColor"        : "darkGray",
                                                  "emptyColor"       : "Gray",
                                                  "labelColor"       : "darkGray",
                                                  "valueColor"       : "darkGray",
                                                  "knobColor"        : "darkGray",
                                                  "@bubbleTextColor" : [M.Colors,"text2"]
                                                }
                              },
                  "nobubble" : { "graphical" : {  "bubbleEnabled"    : false
                                               }
                              },
                  "noknob" : { "bar.knob" : {  "visible"    : false
                                               }
                              },
                  "dynamicvaluesize" : { "valueContainer.valueText" : { "@scale": function() {
                                                                                    if(valueText.paintedWidth > valueText.width)
                                                                                        return valueText.width / valueText.paintedWidth
                                                                                    return 1
                                                                                  } ,
                                                                         elide : Text.ElideNone
                                                                      }
                  }
     })





}
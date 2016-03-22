import Zabaat.Material 1.0
import QtQuick 2.4
Item {
    id : rootObject
    property var    logic        : null         //the pointer to the parent logic itme
    property string colorTheme   : logic ? logic.colors : "default"
    readonly property point  pos : logic ? Qt.point(logic.x,logic.y) : Qt.point(0,0)
    property bool debug          : false
//    focus                        : false
    property alias color          : rect.color
    property alias border         : rect.border
    property alias radius         : rect.radius
    property alias graphical      : graphical

    Rectangle { id: rect ; anchors.fill : parent; color: logic ? Colors.get(logic.colors , "standard") : "white" }

    property string state  : "default"
    property var    states : []

    function log(){
        if(debug)
            console.log.apply(this,arguments)
    }
    function clr(name){
        return Colors.get(colorTheme , name)
    }

    Connections {
        target          : logic ? logic : null
        onStateChanged  : stateChangeOp(logic.state, logic.enabled)
        onEnabledChanged: stateChangeOp(logic.state, logic.enabled)
    }
    onStatesChanged: {
        if(logic && logic.hasOwnProperty('font')) {
            addFontStates()
            stateChangeOp(logic.state, logic.enabled)
        }
    }
    onLogicChanged: {
        if(logic) {
            addBorderStates()
            addGraphicalStates()
            if(rootObject.hasOwnProperty("font"))
                addFontStates()
            stateChangeOp(logic.state, logic.enabled)
        }
    }

    QtObject {
        id : cache
        property string state  : ""
        property bool   enable : false

        property bool fontsAdded   : false
        property bool bordersAdded : false
        property bool graphicalAdded  : false
        property bool ready : rootObject.hasOwnProperty("font") ? fontsAdded && bordersAdded && graphicalAdded : bordersAdded && graphicalAdded
        onReadyChanged : if(ready){
                             stateChangeOp(state,enable,true)
                         }


        property QtObject graphical : QtObject{ //these things are available in every skin!! so why not merge em?
            id : graphical
            property color fill_Empty       : "transparent"
            property color fill_Default     : Colors.standard
            property color fill_Press       : Colors.accent
            property color fill_Focus       : Colors.info
            property color text_Default     : Colors.text1
            property color text_Press       : Colors.text2
            property color text_Focus       : Colors.text2
            property int   text_hAlignment  : Text.AlignHCenter
            property int   text_vAlignment  : Text.AlignVCenter
            property color inkColor         : Colors.getContrastingColor(fill_Default)
            property color borderColor      : Colors.text1
            property real  inkOpacity       : 1
            property color disabled1        : "Gray"
            property color disabled2        : "DarkGray"
        }

        function injectState(name, key, stateObject){    //makes sure we don't overwrite an existing state!
            if(states[name]){
                if(states[name][key]){  //this key already exists!! don't overwrite special values!
                    for(var s in stateObject){
                        if(typeof states[name][key][s] === 'undefined'){
                            //do nothing
                            states[name][key][s] = stateObject[s]
                        }
                    }
                }
                else
                    states[name][key] = stateObject
            }
            else {
                var obj = {}
                obj[key] = stateObject
                states[name] = obj
            }

        }

    }




    //Automatically adds borderStates and fontStates if there is a font in the rootLevel Object!!
    //these states are - b1-b10 , f1-f10, fw1-fw10      //fw means font size is dependent on the Width instead of height of the component
    function stateChangeOp(state, enabled, force){
        if(!force && state === cache.state && enabled === cache.enable)
            return;


        if(cache.ready) {
            rootObject.enabled = enabled;
            if(!enabled && logic.disableShowsGraphically) {
                ZStateHandler.setState(rootObject, state + "-disabled")
            }
            else
                ZStateHandler.setState(rootObject, state)
        }

        cache.state  = state
        cache.enable = enabled
    }

    function addBorderStates(){
        cache.injectState("b0"  , "rootObject" , { "border.width" : 0  });
        cache.injectState("b1"  , "rootObject" , { "border.width" : 1  });
        cache.injectState("b2"  , "rootObject" , { "border.width" : 2  });
        cache.injectState("b3"  , "rootObject" , { "border.width" : 3  });
        cache.injectState("b4"  , "rootObject" , { "border.width" : 4  });
        cache.injectState("b5"  , "rootObject" , { "border.width" : 5  });
        cache.injectState("b6"  , "rootObject" , { "border.width" : 6  });
        cache.injectState("b7"  , "rootObject" , { "border.width" : 7  });
        cache.injectState("b8"  , "rootObject" , { "border.width" : 8  });
        cache.injectState("b9"  , "rootObject" , { "border.width" : 9  });
        cache.injectState("b10" , "rootObject" , { "border.width" : 10 });

        cache.bordersAdded = true;
    }
    function addFontStates(){

        cache.injectState("default","font", { bold : false, italic : false, "@pixelSize":[parent,"height",1/4],
                                              weight:Font.Normal, strikeout : false, underline : false })

        cache.injectState("w1"         , "font" , { weight : Font.Thin                    })
        cache.injectState("w2"         , "font" , { weight : Font.Light                   })
        cache.injectState("w3"         , "font" , { weight : Font.ExtraLight              })
        cache.injectState("w4"         , "font" , { weight : Font.Normal                  })
        cache.injectState("w5"         , "font" , { weight : Font.Medium                  })
        cache.injectState("w6"         , "font" , { weight : Font.DemiBold                })
        cache.injectState("w7"         , "font" , { weight : Font.Bold                    })
        cache.injectState("w8"         , "font" , { weight : Font.ExtraBold               })
        cache.injectState("w9"         , "font" , { weight : Font.Black                   })
        cache.injectState("f1"         , "font" , { "@pixelSize" : [parent,"height",1]    })
        cache.injectState("f2"         , "font" , { "@pixelSize" : [parent,"height",1/2]  })
        cache.injectState("f3"         , "font" , { "@pixelSize" : [parent,"height",1/3]  })
        cache.injectState("f4"         , "font" , { "@pixelSize" : [parent,"height",1/4]  })
        cache.injectState("f5"         , "font" , { "@pixelSize" : [parent,"height",1/5]  })
        cache.injectState("f6"         , "font" , { "@pixelSize" : [parent,"height",1/6]  })
        cache.injectState("f7"         , "font" , { "@pixelSize" : [parent,"height",1/7]  })
        cache.injectState("f8"         , "font" , { "@pixelSize" : [parent,"height",1/8]  })
        cache.injectState("f9"         , "font" , { "@pixelSize" : [parent,"height",1/9]  })
        cache.injectState("f10"        , "font" , { "@pixelSize" : [parent,"height",1/10] })
        cache.injectState("fw1"        , "font" , { "@pixelSize" : [parent,"width",1]     })
        cache.injectState("fw2"        , "font" , { "@pixelSize" : [parent,"width",1/2]   })
        cache.injectState("fw3"        , "font" , { "@pixelSize" : [parent,"width",1/3]   })
        cache.injectState("fw4"        , "font" , { "@pixelSize" : [parent,"width",1/4]   })
        cache.injectState("fw5"        , "font" , { "@pixelSize" : [parent,"width",1/5]   })
        cache.injectState("fw6"        , "font" , { "@pixelSize" : [parent,"width",1/6]   })
        cache.injectState("fw7"        , "font" , { "@pixelSize" : [parent,"width",1/7]   })
        cache.injectState("fw8"        , "font" , { "@pixelSize" : [parent,"width",1/8]   })
        cache.injectState("fw9"        , "font" , { "@pixelSize" : [parent,"width",1/9]   })
        cache.injectState("fw10"       , "font" , { "@pixelSize" : [parent,"width",1/10]  })
        cache.injectState("bold"       , "font" , { bold      : true                      })
        cache.injectState("italic"     , "font" , { italic    : true                      })
        cache.injectState("underline"  , "font" , { underline : true                      })
        cache.injectState("strikeout"  , "font" , { strikeout : true                      })
        cache.injectState("caps"       , "font" , { capitalization : Font.AllUppercase  }  )
        cache.injectState("lowercase"  , "font" , { capitalization : Font.AllLowercase  }  )
        cache.injectState("smallcaps"  , "font" , { capitalization : Font.SmallCaps  }     )
        cache.injectState("capitalize" , "font" , { capitalization : Font.Capitalize  }    )

        cache.fontsAdded = true;
    }
    function addGraphicalStates() {
        cache.injectState("default","graphical", {
            "fill_Empty"   : "transparent",
           "@fill_Default"   : [Colors,"standard"],
           "@text_Default"   : [Colors,"text1"],
           "@fill_Press"     : [Colors,"standard"],
           "@text_Press"     : [Colors,"info"],
           "@fill_Focus"     : [Colors,"info"],
           "@text_Focus"     : [Colors,"text2"],
           "@inkColor"       : [Colors,"accent"],
           "@borderColor"    : [Colors,"text1"],
           "inkOpacity"      : 1,
           "text_hAlignment" : Text.AlignHCenter,
           "text_vAlignment" : Text.AlignVCenter
        })

        cache.injectState("disabled","graphical", {
             "@fill_Default": [graphical, "disabled1"],
             "@text_Default": [graphical, "disabled2"],
             "@fill_Press"  : [graphical, "disabled1"],
             "@text_Press"  : [graphical, "disabled2"],
             "@fill_Focus"  : [graphical, "disabled1"],
             "@text_Focus"  : [graphical, "disabled2"],
             "@inkColor"    : [graphical, "disabled1"],
             "@borderColor" : [graphical, "disabled2"]
        })


        cache.injectState("accent","graphical", {
              "@fill_Default": [Colors,"accent"],
              "@text_Default": [Colors,"text2"],
              "@fill_Press"  : [Colors.darker,"accent"],
              "@text_Press"  : [Colors,"text2"],
              "@fill_Focus"  : [Colors,"accent"],
              "@text_Focus"  : [Colors,"text1"],
              "@inkColor"    : [Colors,"info"],
              "@borderColor" : [Colors,"text1"]
         })

        cache.injectState("info","graphical", {
            "@fill_Default": [Colors,"info"],
            "@text_Default": [Colors,"text2"],
            "@fill_Press"  : [Colors.darker,"info"],
            "@text_Press"  : [Colors,"text2"],
            "@fill_Focus"  : [Colors,"info"],
            "@text_Focus"  : [Colors,"text1"],
            "@inkColor"    : [Colors,"info"],
            "@borderColor" : [Colors,"text1"]
        })

       cache.injectState("danger","graphical", {
                           "@fill_Default": [Colors,"danger"],
                           "@text_Default": [Colors,"text2"],
                           "@fill_Press"  : [Colors.darker,"danger"],
                           "@text_Press"  : [Colors,"text2"],
                           "@fill_Focus"  : [Colors,"danger"],
                           "@text_Focus"  : [Colors,"text1"],
                           "@inkColor"    : [Colors.contrasting,"danger"],
                           "@borderColor" : [Colors,"text1"]
       })

       cache.injectState("success","graphical", {
                           "@fill_Default": [Colors,"success"],
                           "@text_Default": [Colors,"text2"],
                           "@fill_Press"  : [Colors.darker,"success"],
                           "@text_Press"  : [Colors,"text2"],
                           "@fill_Focus"  : [Colors,"success"],
                           "@text_Focus"  : [Colors,"text1"],
                           "@inkColor"    : [Colors.contrasting,"success"],
                           "@borderColor" : [Colors,"text1"]
        })

        cache.injectState("warning","graphical", {
                            "@fill_Default": [Colors,"warning"],
                            "@text_Default": [Colors,"text2"],
                            "@fill_Press"  : [Colors.darker,"warning"],
                            "@text_Press"  : [Colors,"text2"],
                            "@fill_Focus"  : [Colors,"warning"],
                            "@text_Focus"  : [Colors,"text1"],
                            "@inkColor"    : [Colors.contrasting,"warning"],
                            "@borderColor" : [Colors,"text1"]
         })

        cache.injectState("ghost","rootObject", {"border.width" : 2 })
        cache.injectState("ghost","graphical" , {
                              "fill_Default" : "transparent",
                              "@text_Default": [Colors,"text1"],
                              "@fill_Press"  : [Colors.darker,"success"],
                              "@text_Press"  : [Colors,"text1"],
                              "@fill_Focus"  : [Colors,"success"],
                              "@text_Focus"  : [Colors,"text2"],
                              "@inkColor"    : [Colors,"text1"],
                              "@borderColor" : [Colors,"text1"],
                              inkOpacity : 0.5
                        })


        cache.injectState("transparent", "rootObject", {"border.width" : 0})
        cache.injectState("transparent", "graphical" , {
                              "fill_Default": "transparent",
                              "@fill_Press"  : [Colors.darker,"success"],
                              "@fill_Focus"  : [Colors,"success"],
                              "@inkColor"    : [Colors,"text2"],
                              "@borderColor" : [Colors,"text2"],
                              inkOpacity : 0.5
        })


        cache.injectState("t1","graphical", {
            "@text_Default": [Colors,"text1"],
            "@text_Press"  : [Colors,"text1"],
            "@text_Focus"  : [Colors,"text2"],
            "@inkColor"    : [Colors,"accent"],
            "@borderColor" : [Colors,"text1"]
        })


        cache.injectState("t2","graphical", {
              "@text_Default": [Colors,"text2"],
              "@text_Press"  : [Colors,"text2"],
              "@text_Focus"  : [Colors,"text1"],
              "@inkColor"    : [Colors,"accent"],
              "@borderColor" : [Colors,"text2"]
        })

        cache.injectState("tcenter"      , "graphical" , { text_hAlignment : Text.AlignHCenter, text_vAlignment : Text.AlignVCenter })
        cache.injectState("tcenterright" , "graphical" , { text_hAlignment : Text.AlignRight  , text_vAlignment : Text.AlignVCenter })
        cache.injectState("tcenterleft"  , "graphical" , { text_hAlignment : Text.AlignLeft   , text_vAlignment : Text.AlignVCenter })
        cache.injectState("ttopright"    , "graphical" , { text_hAlignment : Text.AlignRight  , text_vAlignment : Text.AlignTop     })
        cache.injectState("ttopleft"     , "graphical" , { text_hAlignment : Text.AlignLeft   , text_vAlignment : Text.AlignTop     })
        cache.injectState("tbottomright" , "graphical" , { text_hAlignment : Text.AlignRight  , text_vAlignment : Text.AlignBottom  })
        cache.injectState("tbottomleft"  , "graphical" , { text_hAlignment : Text.AlignLeft   , text_vAlignment : Text.AlignBottom  })

        cache.graphicalAdded = true;
    }



}

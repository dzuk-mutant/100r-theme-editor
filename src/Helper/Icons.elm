module Helper.Icons exposing (importIcon, download)

import Css exposing (displayFlex, property)
import Svg.Styled exposing (Svg, g, path, svg)
import Svg.Styled.Attributes exposing (css, d, version, viewBox )


icon : String -> List ( Svg msg ) -> Svg msg
icon viewBoxSize iconGeometry =
    svg [ viewBox viewBoxSize
        , version "1.1"
        , css   [ property "fill-rule" "evenodd" -- prevents punched holes from disappearing.
                , property "fill" "currentColor" -- allows icons to inherit colours specified further up the chain.
                , property "flex" "0 0 auto" -- keeps the sizing stable and static.
                , displayFlex
                ]
        ]
        [ g []
            iconGeometry
        ]

importIcon : Svg msg
importIcon =
    icon
        "0 0 36 28"
        [ path [ d "M16.5,17.621l-4.439,4.44l-2.122,-2.122l7,-7c0.586,-0.585 1.536,-0.585 2.122,0l7,7l-2.122,2.122l-4.439,-4.44l-0,9.379l-3,0l-0,-9.379Zm-12,5.879l5.5,-0l-0,3l-7,-0c-0.828,0 -1.5,-0.672 -1.5,-1.5l-0,-22c-0,-0.828 0.672,-1.5 1.5,-1.5l30,-0c0.828,0 1.5,0.672 1.5,1.5l-0,22c-0,0.828 -0.672,1.5 -1.5,1.5l-6,-0l-0,-3l4.5,-0l-0,-19l-27,-0l-0,19Z" ][]]

download : Svg msg
download =
    icon
        "0 0 36 28"
        [ path [ d "M31.5,23.5l-0,-4.5l3,0l-0,6c-0,0.828 -0.672,1.5 -1.5,1.5l-30,0c-0.828,0 -1.5,-0.672 -1.5,-1.5l-0,-6l3,0l-0,4.5l27,0Zm-15,-8.121l-0,-9.379l3,-0l-0,9.379l4.439,-4.44l2.122,2.122l-7,7c-0.586,0.585 -1.536,0.585 -2.122,-0l-7,-7l2.122,-2.122l4.439,4.44Z" ][]]

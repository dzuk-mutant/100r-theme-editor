module FilePrev exposing (svgFilePreview)

import Color exposing (Color)
import Color.Convert exposing (colorToHex)
import HRTheme exposing (HRTheme)
import Html.Styled exposing (Html)
import Svg.Styled exposing (Svg, svg, rect, circle)
import Svg.Styled.Attributes exposing (xmlBase, id, fill, width, height, cx, cy, r, version, baseProfile)


{-| Generates a theme svg as an Svg type.
-}
svgFilePreview : HRTheme -> Html msg
svgFilePreview theme =
    svg
        [ width "96px"
        , height "64px"
        , xmlBase "http://www.w3.org/2000/svg"
        , baseProfile "full"
        , version "1.1"
        ]
        [ bgRect theme
        , paletteCircle "f_high" theme.fHigh 24 24
        , paletteCircle "f_med" theme.fMed 40 24
        , paletteCircle "f_low" theme.fLow 56 24
        , paletteCircle "f_inv" theme.fInv 72 24
        , paletteCircle "b_high" theme.bHigh 24 40
        , paletteCircle "b_med" theme.bMed 40 40
        , paletteCircle "b_low" theme.bLow 56 40
        , paletteCircle "b_inv" theme.bInv 72 40
        ]


-- <rect width='96' height='64' id='background' fill='#171717'></rect>
bgRect : HRTheme -> Svg msg
bgRect theme =
    rect
        [ width "96"
        , height "64"
        , id "background"
        , fill <| colorToHex theme.background
        ]
        []

--<circle cx='24' cy='40' r='8' id='b_high' fill='#373737'></circle>
paletteCircle : String -> Color -> Int -> Int -> Svg msg
paletteCircle idStr col xPos yPos =
    circle
        [ cx <| String.fromInt xPos
        , cy <| String.fromInt yPos
        , r "8"
        , id idStr
        , fill <| colorToHex col
        ]
        []
module PreviewArea exposing (view)

import Css exposing (alignItems, backgroundColor, borderRadius, center, column, displayFlex, flex, flexDirection, height, none, padding, row, width)
import Color exposing (Color)
import ColorHelper exposing (convColor)
import Html.Styled exposing (Html, div)
import Html.Styled.Attributes exposing (css)
import HRTheme exposing (HRTheme)
import Rpx exposing (rpx, blc)


view : HRTheme -> Html msg
view theme =
    div [ css
            [ displayFlex
            , flexDirection column
            ]
        ]
        [ colorSect theme.background theme
        , colorSect theme.bLow theme
        , colorSect theme.bMed theme
        , colorSect theme.bHigh theme
        , invSect theme
        ]

-- VIEW

paletteCircle : Color -> Html msg
paletteCircle c =
    div [ css -- spacing area
            [ width (blc 8)
            ]

        ]
        [ div  -- circle
            [ css 
                [ width (blc 4)
                , height (blc 4)
                , backgroundColor (convColor c)
                , borderRadius (blc 2)
                ]
            ]
            []
        ]

paletteBox : Color -> List (Html msg) -> Html msg
paletteBox c content =
    div [ css
            [ displayFlex
            , flex none
            , flexDirection row
            , alignItems center
            , backgroundColor (convColor c)
            , padding (blc 2)
            , width (blc 24)
            ]
        ]
        content

colorSect : Color -> HRTheme -> Html msg
colorSect fg theme = 
    paletteBox fg
        [ paletteCircle theme.fHigh
        , paletteCircle theme.fMed
        , paletteCircle theme.fLow
        ]

invSect : HRTheme -> Html msg
invSect theme =
    paletteBox theme.bInv
            [ paletteCircle theme.fInv
            ]

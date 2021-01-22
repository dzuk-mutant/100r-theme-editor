module Section.Preview exposing (view)

import Css exposing (alignItems, backgroundColor, border, borderBox, borderRadius, boxSizing, center, color, column, displayFlex, flex, flexDirection, fontWeight, height, int, left, minWidth, none, padding, row, textAlign, unset, width, zero)
import Color exposing (Color)
import Helper exposing (convColor)
import Html.Styled as Html exposing (Html, button, div)
import Html.Styled.Attributes exposing (css, class)
import Html.Styled.Events exposing (onClick)
import HRTheme exposing (HRTheme)
import Model exposing (Model, SelectedColor(..))
import Rpx exposing (blc)
import Section.Dimen exposing (leftBlocking, rightBlocking)
import ViewHelper exposing (buttonStyles)




view : Model -> (SelectedColor -> msg) -> Html msg
view model selectMsg =
    let
        theme = model.theme
    in
        div 
            [ css
                [ displayFlex
                , flexDirection row
                ]
            , class "preview"
            ]

            ------------- left area
            [ smallerBlocking
                [ blankCell []

                , div [ css [ height (blc 1) ]][] -- spacer

                , paletteButton model "background" selectMsg Background
                , paletteButton model "b_low" selectMsg BLow
                , paletteButton model "b_med" selectMsg BMed
                , paletteButton model "b_high" selectMsg BHigh

                , div [ css [ height (blc 2) ] ][] -- spacer

                , paletteButton model "b_inv" selectMsg BInv
                ]

            , div [ css [ width (blc 1) ] ][] -- spacer
            
            ------------- right area
            , largerBlocking
                [ buttonRow
                    [ paletteButton model "f_high" selectMsg FHigh
                    , paletteButton model "f_med" selectMsg FMed
                    , paletteButton model "f_low" selectMsg FLow
                    ]

                , div [ css [ height (blc 1) ]][] -- spacer

                , colorSect theme.background theme
                , colorSect theme.bLow theme
                , colorSect theme.bMed theme
                , colorSect theme.bHigh theme

                , div [ css [ height (blc 2) ]][] -- spacer

                , invSect theme

                , div [ css [ height (blc 1) ]][] -- spacer

                , buttonRow
                    [ paletteButton model "f_inv" selectMsg FInv
                    ]
                ]

            ]
    






smallerBlocking : List (Html msg) -> Html msg
smallerBlocking content =
    div
        [ css
            [ displayFlex
            , flexDirection column
            , minWidth leftBlocking
            ]
        ]
        content


{-| To keep the different areas of the editor looking nice,
there are two blocking areas, the larger one on the right,
and the smaller one on the left, this is the larger of
the two.
-}
largerBlocking : List (Html msg) -> Html msg
largerBlocking content =
    div
        [ css
            [ displayFlex
            , flexDirection column
            , minWidth rightBlocking
            ]
        ]
        content









blankCell : List (Html msg) -> Html msg
blankCell content =
    div 
        [ css -- spacing area
            [ minWidth (blc 12)
            , height (blc 3)
            , padding (blc 1)
            ]
        ]
        content


previewCell : Color -> List (Html msg) -> Html msg
previewCell bg content =
    div 
        [ css -- spacing area
            [ minWidth (blc 12)
            , height (blc 3)
            , padding (blc 1)
            , backgroundColor (convColor bg)
            ]
        ]
        content


paletteButton : Model -> String -> (SelectedColor -> msg) -> SelectedColor  -> Html msg
paletteButton model label msg thisColor =
    button
        [ css
            [ buttonStyles

            , minWidth (blc 14)
            , height (blc 5)
            , padding (blc 1)

            , border zero
            , ViewHelper.defaultFonts

            , Css.batch (
                case model.selectedColor == thisColor of
                    True ->
                        [ backgroundColor (convColor model.theme.bLow)
                        , color (convColor model.theme.fMed)
                        ]
                    False ->
                        [ backgroundColor unset
                        , color (convColor model.theme.fLow)
                        ]
                )

            , textAlign left

            , boxSizing borderBox
            ]
            
        , onClick <| msg thisColor
        ]
        [ Html.text label ]
        












buttonRow : List (Html msg) -> Html msg
buttonRow content =
    div
        [ css
            [ displayFlex
            ]
        ]
        content
        



paletteCircle : Color -> Color -> Html msg
paletteCircle fg bg =
    previewCell bg
        [ div  -- circle
            [ css 
                [ width (blc 3)
                , height (blc 3)
                , backgroundColor (convColor fg)
                , borderRadius (blc 2)
                ]
            ]
            []
        ]

paletteRow : List (Html msg) -> Html msg
paletteRow content =
    div [ css
            [ displayFlex
            , flex none
            , flexDirection row
            , alignItems center
            ]
        , class "palette-box"
        ]
        content

colorSect : Color -> HRTheme -> Html msg
colorSect bg theme = 
    paletteRow
        [ paletteCircle theme.fHigh bg
        , paletteCircle theme.fMed bg
        , paletteCircle theme.fLow bg
        ]

invSect : HRTheme -> Html msg
invSect theme =
    paletteRow
            [ paletteCircle theme.fInv theme.bInv
            ]

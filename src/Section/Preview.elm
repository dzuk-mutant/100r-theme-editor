module Section.Preview exposing (view)

import Css exposing (alignItems, backgroundColor, border, borderBox, borderRadius, boxSizing, center, color, column, displayFlex, flex, flexDirection, height, left, marginLeft, minWidth, none, padding, row, textAlign, unset, width, zero)
import Color exposing (Color)
import Color.Accessibility exposing (contrastRatio)
import Helper.Color exposing (convColor)
import Helper.Styles exposing (buttonStyles, cellWidth)
import Html.Styled as Html exposing (Html, button, div)
import Html.Styled.Attributes exposing (css, class)
import Html.Styled.Events exposing (onClick)
import HRTheme exposing (HRTheme)
import Model exposing (Model, SelectedColor(..))
import Rpx exposing (blc)
import Html.Styled exposing (span)




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
    






{-| Provides a grade colour based on the
background color for best possible contrast
for the WCAG contrast grades.
-}
gradeColor : Color -> Color
gradeColor bgCol =
    let
        lightness =
            bgCol
            |> Color.toHsla
            |> .lightness
    in
        if lightness < 0.5 then
            Color.rgb255 255 255 255
        else
            Color.rgb255 0 0 0 


smallerBlocking : List (Html msg) -> Html msg
smallerBlocking content =
    div
        [ css
            [ displayFlex
            , flexDirection column
            , minWidth cellWidth
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
            , minWidth (blc <| 18 * 3)
            ]
        ]
        content









blankCell : List (Html msg) -> Html msg
blankCell content =
    div 
        [ css -- spacing area
            [ minWidth cellWidth
            , height (blc 3)
            , padding (blc 1)
            ]
        ]
        content



paletteButton : Model -> String -> (SelectedColor -> msg) -> SelectedColor  -> Html msg
paletteButton model label msg thisColor =
    button
        [ css
            [ buttonStyles

            , minWidth <| Rpx.add cellWidth (blc 2)
            , height (blc 5)
            , padding (blc 1)

            , border zero
            , Helper.Styles.defaultFonts

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
    let
        accScore = contrastRatio fg bg

        accScorePresent = Helper.Color.getWCAGScoreString accScore

        accScoreGrade =
            if accScore < 3 then
                "X"
            else if accScore >= 3 && accScore < 4.5 then
                "A"
            else if accScore >= 4.5 && accScore < 7 then
                "AA"
            else -- if accScore >= 7 then
                "AAA"
    in
        div
            [ css
                [ displayFlex
                , flexDirection row
                , minWidth (blc 18)
                , height (blc 3)
                , padding (blc 1)
                , backgroundColor (convColor bg)
                ]
            ]
            [ div  -- circle
                [ css 
                    [ width (blc 3)
                    , height (blc 3)
                    , backgroundColor (convColor fg)
                    , borderRadius (blc 2)
                    ]
                ]
                []
            , span -- accessibility score
                [ css
                    [ marginLeft (blc 1)
                    , color (convColor fg)
                    ]
                ]
                [ Html.text accScorePresent ]

            , span -- accessibility grade
                [ css
                    [ marginLeft (blc 1)
                    , color (convColor <| gradeColor bg)
                    ]
                ]
                [ Html.text <| "[" ++ accScoreGrade ++ "]" ]
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

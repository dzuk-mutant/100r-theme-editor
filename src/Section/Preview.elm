module Section.Preview exposing (view)

import Css exposing (..)
import Color exposing (Color)
import Helper.Color exposing (convColor)
import Helper.Styles exposing (cellWidth)
import Helper.Layout as Layout
import Html.Styled as Html exposing (Html, div, span)
import Html.Styled.Attributes exposing (css, class)
import Html.Styled.Events exposing (onClick)
import Model exposing (Model, SelectedColor(..))
import Rpx exposing (blc)
import Tests exposing (getWCAGGrade, getWCAGScoreString, GradationTest(..), getGradationTests)




view : Model -> (SelectedColor -> msg) -> Html msg
view model selectMsg =
    let
        theme = model.theme
        tests = model.tests
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

                , paletteButton model "background" selectMsg Background ""
                , paletteButton model "b_low" selectMsg BLow
                    ( gradation [(BMedTooLow, "↑")] model )
                , paletteButton model "b_med" selectMsg BMed
                    ( gradation [(BMedTooLow, "↓"), (BHighTooLow, "↑")] model)
                , paletteButton model "b_high" selectMsg BHigh
                    ( gradation [(BHighTooLow, "↓")] model )

                , div [ css [ height (blc 2) ] ][] -- spacer

                , paletteButton model "b_inv" selectMsg BInv ""
                ]

            , div [ css [ width (blc 1) ] ][] -- spacer
            
            ------------- right area
            , largerBlocking
                [ buttonRow
                    [ paletteButton model "f_high" selectMsg FHigh
                        ( gradation [(FHighTooLow, "←")] model )
                    , paletteButton model "f_med" selectMsg FMed
                        ( gradation [(FHighTooLow, "→"), (FMedTooLow, "←")] model)
                    , paletteButton model "f_low" selectMsg FLow
                        ( gradation [(FMedTooLow, "→")] model )
                    ]

                , div [ css [ height (blc 1) ]][] -- spacer
                
                ,  paletteRow
                    [ paletteCircle tests.contrastBgFHigh theme.background theme.fHigh
                    , paletteCircle tests.contrastBgFMed theme.background theme.fMed
                    , paletteCircle tests.contrastBgFLow theme.background theme.fLow
                    ]
                
                ,  paletteRow
                    [ paletteCircle tests.contrastBLowFHigh theme.bLow theme.fHigh
                    , paletteCircle tests.contrastBLowFMed theme.bLow theme.fMed
                    , paletteCircle tests.contrastBLowFLow theme.bLow theme.fLow
                    ]
                
                ,  paletteRow
                    [ paletteCircle tests.contrastBMedFHigh theme.bMed theme.fHigh
                    , paletteCircle tests.contrastBMedFMed theme.bMed theme.fMed
                    , paletteCircle tests.contrastBMedFLow theme.bMed theme.fLow
                    ]

                ,  paletteRow
                    [ paletteCircle tests.contrastBHighFHigh theme.bHigh theme.fHigh
                    , paletteCircle tests.contrastBHighFMed theme.bHigh theme.fMed
                    , paletteCircle tests.contrastBHighFLow theme.bHigh theme.fLow
                    ]

                , div [ css [ height (blc 2) ]][] -- spacer

                ,  paletteRow
                    [ paletteCircle tests.contrastBInvFInv theme.bInv theme.fInv
                    ]

                , div [ css [ height (blc 1) ]][] -- spacer

                , buttonRow
                    [ paletteButton model "f_inv" selectMsg FInv ""
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



gradation : List (GradationTest, String) -> Model -> String
gradation results model =
    let
        gradationTestsMet = List.filter (\x -> getGradationTests model.tests == Tuple.first x) results
    in
        case List.head gradationTestsMet of
            Nothing -> ""
            Just h -> "[" ++ Tuple.second h ++ "]"


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



paletteButton : Model -> String -> (SelectedColor -> msg) -> SelectedColor -> String -> Html msg
paletteButton model label msg thisColor endStr =
    Layout.cellButton
        model.theme
        ( model.selectedColor == thisColor )
        [ onClick <| msg thisColor ]
        [ ]
        ( label ++ " " ++ endStr )
        












buttonRow : List (Html msg) -> Html msg
buttonRow content =
    div
        [ css
            [ displayFlex
            ]
        ]
        content
        



paletteCircle : Float -> Color -> Color -> Html msg
paletteCircle contrastScore bg fg =
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
            [ Html.text <| getWCAGScoreString contrastScore  ]

        , span -- accessibility grade
            [ css
                [ marginLeft (blc 1)
                , color (convColor <| gradeColor bg)
                ]
            ]
            [ Html.text <| "[" ++ (getWCAGGrade contrastScore) ++ "]" ]
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

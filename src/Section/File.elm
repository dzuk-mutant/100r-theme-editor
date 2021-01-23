module Section.File exposing (view)

import Css exposing (..)
import FilePrev exposing (svgFilePreview)
import Model exposing (Model)
import Helper.Color exposing (convColor)
import Helper.Styles exposing (cellWidth)
import Helper.Icons as Icon
import HRTheme exposing (HRTheme)
import Html.Styled as Html exposing (Html, button, div, span)
import Html.Styled.Attributes exposing (class, css)
import Html.Styled.Events exposing (onClick)
import Tests exposing (getThemeScore, getWCAGScoreString, getWCAGGrade, getGradationTests, GradationTest(..))
import Rpx exposing (rpx, blc)


view : Model -> msg -> msg -> (Html msg)
view model importMsg exportMsg =
    let
        theme = model.theme

        passedTestStr = 
            case getGradationTests model.tests of
                BHighTooLow -> "[!] swap b_high and b_med"
                BMedTooLow -> "[!] swap b_med and b_low"
                FHighTooLow -> "[!] swap f_high and f_med"
                FMedTooLow -> "[!] swap f_med and f_low"
                Pass -> "passed!"

    in
        
        div [ class "files"
            , css
                [ marginTop (blc 2)
                , height (blc 14)
                , displayFlex
                , flexDirection row
                , alignItems center
                , justifyContent spaceBetween
                ]
            ]
            -------------- SCORE
            [ div
                [ class "tests"
                , css
                    [ displayFlex
                    , flexDirection column
                    , justifyContent center

                    , width cellWidth
                    , height (blc 12)
                    , marginLeft (blc 1)
                    ]
                ]
                [ div
                    [ css [ color (convColor model.theme.fMed) ] ]
                    [ Html.text "theme contrast"
                    ]
                , div [ ]
                    [ span [] [ Html.text <| "[" ++  (getWCAGGrade <| getThemeScore model.tests) ++ "] " ]
                    , span [] [ Html.text <| getWCAGScoreString <| getThemeScore model.tests ]
                    ]
                , div [ css [ height (blc 2) ] ][] -- spacer
                , div
                    [ css [ color (convColor model.theme.fMed) ] ]
                    [ Html.text "basic tests"
                    ]
                , div [ ]
                    [ span [] [ Html.text passedTestStr ]
                    ]
                ]

            -------------- FILE PREVIEW
            , div
                [ class "file-prev"
                , css
                    [ border3 (rpx 1) solid (convColor model.theme.bMed)
                    , height (rpx 64)
                    ]
                ]
                [ svgFilePreview model.theme ]

            -------------- BUTTONS
            , div
                [ class "buttons"
                , css
                    [ displayFlex
                    , flexDirection row
                    , justifyContent flexEnd
                    , alignItems center
                    
                    , width cellWidth
                    , marginRight (blc 1)
                    ]
                ]
                [ button
                    [ onClick importMsg
                    , css
                        [ fileButtonStyles theme
                        , marginRight (blc 2)
                        ]
                    ]
                    [ Icon.importIcon ]
                , button
                    [ onClick exportMsg
                    , css
                        [ fileButtonStyles theme
                        ]
                    ]
                    [ Icon.download ]
                ]
            ]
        

fileButtonStyles : HRTheme -> Style
fileButtonStyles theme =
    Css.batch
        [ Helper.Styles.buttonStyles |> important
        , width (rpx (36))
        , height (rpx (28))

        , backgroundColor (convColor theme.background)
        , color (convColor theme.fLow)
        , hover [ color (convColor theme.fMed) ]
        ]

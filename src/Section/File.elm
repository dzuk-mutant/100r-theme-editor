module Section.File exposing (view)

import Css exposing (..)
import Color.Accessibility exposing (contrastRatio)
import FilePrev exposing (svgFilePreview)
import Model exposing (Model)
import Helper.Color exposing (convColor)
import Helper.Styles exposing (cellWidth)
import Helper.Icons as Icon
import HRTheme exposing (HRTheme)
import Html.Styled as Html exposing (Html, button, div, text, span)
import Html.Styled.Attributes exposing (class, css)
import Html.Styled.Events exposing (onClick)
import Rpx exposing (rpx, blc)


view : Model -> msg -> msg -> (Html msg)
view model importMsg exportMsg =
    let
        theme = model.theme
    in
        
        div [ class "files"
            , css
                [ marginTop (blc 2)
                , displayFlex
                , flexDirection row
                , justifyContent spaceBetween
                ]
            ]
            -------------- SCORE
            [ div
                [ class "score"
                , css
                    [ displayFlex
                    , flexDirection column
                    , justifyContent center

                    , width cellWidth
                    , marginLeft (blc 1)
                    ]
                ]
                [ div
                    [ css
                        [ color (convColor model.theme.fMed)
                        ]
                    ]
                    [ Html.text "theme score"
                    ]
                , div [ ]
                    [ span [] [ Html.text <| Helper.Color.getWCAGScoreString <| minAccScore model.theme ]
                    , span [] [ Html.text <| " [" ++ minAccGrade model.theme ++ "]" ]
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


{-| Returns the score of the lowest scoring contrast combo.
-}
minAccScore : HRTheme -> Float
minAccScore t =
    let
        calcs =
            [ contrastRatio t.background t.fHigh 
            , contrastRatio t.background t.fMed
            , contrastRatio t.background t.fLow

            , contrastRatio t.bLow t.fHigh 
            , contrastRatio t.bLow t.fMed
            , contrastRatio t.bLow t.fLow

            , contrastRatio t.bMed t.fHigh 
            , contrastRatio t.bMed t.fMed
            , contrastRatio t.bMed t.fLow

            , contrastRatio t.bHigh t.fHigh 
            , contrastRatio t.bHigh t.fMed
            , contrastRatio t.bHigh t.fLow

            , contrastRatio t.bInv t.fInv
            ]

    in
        -- assume it will work, because there's no way it can't
        Maybe.withDefault 0.1 <| List.minimum calcs
        



{-| Returns the grade of the lowest scoring contrast combo. (X-AAA)
-}
minAccGrade : HRTheme -> String
minAccGrade t =
    t
    |> minAccScore
    |> Helper.Color.getWCAGGrade
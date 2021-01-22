module Section.File exposing (view)

import Css exposing (..)
import Color.Accessibility exposing (contrastRatio)
import FilePrev exposing (svgFilePreview)
import Model exposing (Model)
import Helper exposing (convColor)
import HRTheme exposing (HRTheme)
import Html.Styled as Html exposing (Html, button, div, text, span)
import Html.Styled.Attributes exposing (class, css)
import Html.Styled.Events exposing (onClick)

view : Model -> msg -> msg -> (Html msg)
view model importMsg exportMsg =
    div [ class "files"
        , css
            [ displayFlex
            , flexDirection row
            , justifyContent spaceBetween
            ]
        ]
        -------------- SCORE
        [ div [ class "score" ]
            [ div [ css [ color (convColor model.theme.fMed)]]
                [ Html.text "theme score:"
                ]
            , div [ ]
                [ span [] [ Html.text <| Helper.getWCAGScoreString <| minAccScore model.theme ]
                , span [] [ Html.text <| " [" ++ minAccGrade model.theme ++ "]" ]
                ]
            ]
        -------------- FILE PREVIEW
        , div [ class "file-prev" ]
            [ svgFilePreview model.theme ]

        -------------- BUTTONS
        , div [ class "buttons" ]
            [ button [ onClick importMsg ] [ text "import" ]
            , button [ onClick exportMsg ] [ text "export" ]
            ]
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
    |> Helper.getWCAGGrade
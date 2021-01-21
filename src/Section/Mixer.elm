module Section.Mixer exposing (view)

import Color
import Color.Convert exposing (colorToHex)
import ColorHelper exposing (convColor)
import Css exposing (backgroundColor, border, borderBox, borderColor, borderWidth, boxSizing, color, displayFlex, fontWeight, height, int, left, textAlign, minWidth, padding, width, unset, zero)
import Html.Styled as Html exposing (Html, button, div, input, label)
import Html.Styled.Attributes exposing (class, css, type_)
import Html.Styled.Events exposing (onClick)
import Model exposing (Model, SelectedColor(..), ColorEditMode(..))
import Rpx exposing (blc, rpx)
import Section.Dimen exposing (leftBlocking, rightBlocking)
import Color.Convert exposing (colorToHex)
import ViewHelper


view : Model -> (ColorEditMode -> msg) -> (Color.Color -> msg) -> Html msg
view model colorModeMsg colorMsg =
    div
        [ class "mixer"
        , css   
            [ displayFlex
            ]
        ]
        [ colorArea model

        , div [ css [width (blc 1)]][]

        , div
            [ class "slider-area"
            , css
                [ width rightBlocking
                ]
            ]
            [ div
                []
                [ colorModeButton model colorModeMsg HSL "HSL"
                , colorModeButton model colorModeMsg RGB "RGB"
                ]
            ]
        ]


colorArea : Model -> Html msg
colorArea model =
    let
        theme = model.theme
        label = 
            case model.selectedColor of
                Background -> "background"
                FHigh -> "f_high"
                FMed -> "f_med"
                FLow -> "f_low"
                FInv -> "f_inv"
                BHigh -> "b_high"
                BMed -> "b_med"
                BLow -> "b_low"
                BInv -> "b_inv"
        
        colorPrev =
            case model.selectedColor of
                Background -> theme.background
                FHigh -> theme.fHigh
                FMed -> theme.fMed
                FLow -> theme.fLow
                FInv -> theme.fInv
                BHigh -> theme.bHigh
                BMed -> theme.bMed
                BLow -> theme.bLow
                BInv -> theme.bInv
    in
        div
            [ class "mixer"
            , css
                [ width (Rpx.add leftBlocking (blc 2))
                ]
            ]
            [ div
                [ css
                    [ height (blc 4)
                    , padding (blc 1)
                    ]
                ]
                [ Html.text label ]
            , div
                [ css
                    [ height (blc 4)
                    , padding (blc 1)
                    , backgroundColor (convColor theme.bHigh)
                    ]
                ]
                [ Html.text <| colorToHex colorPrev ]
            , div
                [ class "preview"
                , css
                    [ boxSizing borderBox
                    , height (blc 11)

                    , backgroundColor (convColor colorPrev)
                    , borderColor (convColor theme.bHigh)
                    , borderWidth (rpx 2)
                    ]
                ]
                []
            ]

colorModeButton : Model -> (ColorEditMode -> msg) -> ColorEditMode -> String -> Html msg
colorModeButton model msg colorMode label =
    button
        [ css
            [ ViewHelper.buttonStyles

            , minWidth (blc 14)
            , height (blc 5)
            , padding (blc 1)

            , border zero
            , fontWeight (int 600)
            , ViewHelper.defaultFonts

            , Css.batch (
                case model.colorEditMode == colorMode of
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
            
        , onClick <| msg colorMode
        ]
        [ Html.text label ]

hslSliders : Model -> (Color.Color -> msg) -> Html msg
hslSliders model colorChangeMsg =
    div
        [
        ]
        [ slider model colorChangeMsg
        , slider model colorChangeMsg
        , slider model colorChangeMsg
        ]
    
slider : Model -> (Color.Color -> msg) -> Html msg
slider model colorChangeMsg =
    div
        []
        [ label
            []
            []
        , input
            [ type_ "range"
            ]
            []
        ]
        
module Section.Mixer exposing (view)

import Color
import Color.Convert exposing (colorToHex)
import ColorHelper exposing (convColor, getColorValue, getCurrentColor)
import Css exposing (backgroundColor, border, borderBox, borderColor, borderWidth, boxSizing, color, column, displayFlex, fontWeight, flexDirection, height, int, left, textAlign, marginTop, minWidth, padding, width, unset, zero)
import Html.Styled as Html exposing (Html, button, div, input, label)
import Html.Styled.Attributes as Attr exposing (class, css, type_, value)
import Html.Styled.Events exposing (onClick, onInput)
import Model exposing (Model, SelectedColor(..), ColorMode(..), EditType(..))
import Rpx exposing (blc, rpx)
import Section.Dimen exposing (leftBlocking, rightBlocking)
import ViewHelper


type alias ColorEditMsg msg = EditType -> String -> msg
type alias ColorModeMsg msg = ColorMode -> msg

view : Model ->  ColorModeMsg msg -> ColorEditMsg msg -> Html msg
view model colorModeMsg colorEditMsg =
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
                [ class "mixer-area"
                , css
                    [ displayFlex
                    , flexDirection column
                    ]
                ]
                [ div
                    [ class "colorMode"
                    ]
                    [ colorModeButton model colorModeMsg HSL "HSL"
                    , colorModeButton model colorModeMsg RGB "RGB"
                    ]
                , div
                    [ class "sliderArea"
                    ]
                    [ case model.colorEditMode of
                        HSL -> hslSliders model colorEditMsg
                        RGB -> rgbSliders model colorEditMsg
                    ]
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
        
        colorPrev = getCurrentColor model
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

colorModeButton : Model -> ColorModeMsg msg -> ColorMode -> String -> Html msg
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


rgbSliders : Model -> ColorEditMsg msg -> Html msg
rgbSliders model colorEditMsg =
    div
        [
        ]
        [ slider model colorEditMsg Red 0 255
        , slider model colorEditMsg Green 0 255
        , slider model colorEditMsg Blue 0 255
        ]


hslSliders : Model -> ColorEditMsg msg -> Html msg
hslSliders model colorEditMsg =
    div
        [
        ]
        [ slider model colorEditMsg Hue 0 360
        , slider model colorEditMsg Saturation 0 100
        , slider model colorEditMsg Lightness 0 100
        ]

    
slider : Model -> ColorEditMsg msg -> EditType -> Int -> Int -> Html msg
slider model colorEditMsg editType minVal maxVal =
    div
        []
        [ label
            []
            []
        , input
            [ type_ "range"
            , Attr.min <| String.fromInt minVal
            , Attr.max <| String.fromInt maxVal
            , onInput (colorEditMsg editType)
            , value <| getColorValue model editType
            , css
                [ height (blc 4)
                , marginTop (blc 1)
                ]
            ]
            []
        ]
        


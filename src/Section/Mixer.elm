module Section.Mixer exposing (view)

import Helper.Color exposing (convColor, getColorValue, getSelectedColor)
import Helper.Styles
import Css exposing (..)
import Html.Styled as Html exposing (Html, Attribute, button, div, input, label)
import Html.Styled.Attributes as Attr exposing (class, css, type_, value, step)
import Html.Styled.Events exposing (onClick, onInput, onFocus, onBlur)
import Model exposing (Model, SelectedColor(..), ColorMode(..), ValueEditType(..))
import Rpx exposing (blc, rpx)



type alias ColorEditMsg msg = ValueEditType -> String -> msg
type alias ColorModeMsg msg = ColorMode -> msg
type alias HexEdit msg = String -> msg
type alias HexFocus msg = Bool -> msg

view : Model ->  ColorModeMsg msg -> ColorEditMsg msg -> HexEdit msg -> HexFocus msg -> Html msg
view model colorModeMsg colorEditMsg hexEditMsg hexFocusMsg =
    div
        [ class "section-mixer"
        , css   
            [ displayFlex
            , marginBottom (blc 4)
            ]
        ]
        [ colorArea model hexEditMsg hexFocusMsg

        , div [ css [width (blc 1)]][]

        , div
            [ class "slider-area"
            , css
                [ width (blc <| (18*3) + (2*3))
                ]
            ]
            [ div
                [ class "color-values"
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


colorArea : Model -> HexEdit msg -> HexFocus msg -> Html msg
colorArea model hexEditMsg hexFocusMsg =
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
        
        colorPrev = getSelectedColor model

        maybeHexVal : List (Attribute msg)
        maybeHexVal =
            case model.hexInputFocused of
                False -> [ value <| model.hexInputValue ]
                True -> [ value <| model.hexInputValue ]
    in
        div
            [ class "preview"
            , css
                [ displayFlex
                , flexDirection column
                , width (Rpx.add Helper.Styles.cellWidth (blc 2))
                ]
            ]
            [ div
                [ css
                    [ height (blc 4)
                    , padding (blc 1)
                    ]
                ]
                [ Html.text label ]

                
            , input
                (   [ class "hex"
                    , type_ "text"
                    , Attr.maxlength 7
                    , onInput hexEditMsg

                    , onBlur <| hexFocusMsg False
                    , onFocus <| hexFocusMsg True

                    , css
                        [ --- housecleaning
                        border zero

                        --- real styles
                        , textBoxStyle
                        , Helper.Styles.defaultFonts
                        , backgroundColor (convColor theme.bHigh)
                        , color (convColor theme.fHigh)
                        ]
                    ]
                    ++ maybeHexVal
                )
                []


            , div
                [ class "preview"
                , css
                    [ boxSizing borderBox
                    , height (blc 11)

                    , backgroundColor (convColor colorPrev)

                    , Css.batch (
                        case model.selectedColor of
                            Background -> [ border3 (rpx 1) solid (convColor theme.bMed)]
                            _ -> []
                        )
                    ]
                ]
                []
            ]

colorModeButton : Model -> ColorModeMsg msg -> ColorMode -> String -> Html msg
colorModeButton model msg colorMode label =
    button
        [ css
            [ Helper.Styles.buttonStyles

            , minWidth <| Rpx.add Helper.Styles.cellWidth (blc 2)
            , height (blc 5)
            , padding (blc 1)

            , border zero
            , fontWeight (int 600)
            , Helper.Styles.defaultFonts

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
    let
        redVal = getColorValue model Red
        greenVal = getColorValue model Green
        blueVal = getColorValue model Blue
    in
        div
            [ css [ marginTop (blc 2) ]
            ]
            [ slider model colorEditMsg "R" Red 0 255 redVal
            , slider model colorEditMsg "G" Green 0 255 greenVal
            , slider model colorEditMsg "B" Blue 0 255 blueVal
            ]


hslSliders : Model -> ColorEditMsg msg -> Html msg
hslSliders model colorEditMsg =
    let
        hueVal = model.hslSliders.hue
        satVal = model.hslSliders.saturation
        liteVal = model.hslSliders.lightness
    in
        div
            [ css [ marginTop (blc 2) ]
            ]
            [ slider model colorEditMsg "H" Hue 0 360 hueVal
            , slider model colorEditMsg "S" Saturation 0 100 satVal
            , slider model colorEditMsg "L" Lightness 0 100 liteVal
            ]

    
slider : Model -> ColorEditMsg msg -> String -> ValueEditType -> Int -> Int -> Int -> Html msg
slider model colorEditMsg labelStr editType minVal maxVal currentVal =
    div
        [ class "sliderArea"
        , css
            [ displayFlex
            , flexDirection row
            , alignItems center
            , height (blc 4)
            , marginTop (blc 1)
            ]

        ]
        [ label
            []
            []

        ----------- LABEL
        , div
            [ css
                [ textBoxStyle
                , width (blc 2)
                , color (convColor model.theme.fMed)
                ]

            ]
            [Html.text labelStr]
        
        ----------- THE ACTUAL SLIDER
        , input
            [ type_ "range"
            , Attr.min <| String.fromInt minVal
            , Attr.max <| String.fromInt maxVal
            , onInput (colorEditMsg editType)
            , value <| String.fromInt currentVal

            , css
                [ ------ housecleaning styles
                  sliderHousecleaningStyles
                 
                ------- real styles
                , sliderThumb
                    [ width (blc 2)
                    , height (blc 2)
                    , marginTop (blc -1) -- specifying a margin is mandatory in Chrome
                    
                    , cursor pointer

                    , border3 (rpx 2) solid (convColor model.theme.background) 
                    , borderRadius <| Rpx.add (blc 1) (rpx 2)
                    , backgroundColor (convColor model.theme.fLow)
                    ]

                , sliderTrack
                    [ height (rpx 2)
                    , color (convColor model.theme.fLow)
                    , backgroundColor (convColor model.theme.bMed)
                    ]
                ]
            ]
            []

        ----------- TEXT BOX
        , input
            [ class "text"
            , type_ "number"
            , onInput (colorEditMsg editType)
            , value <| String.fromInt currentVal
            , Attr.min <| String.fromInt minVal
            , Attr.max <| String.fromInt maxVal
            , step "1"

            , css
                [ ---- housecleaning
                  numberHousecleaningStyles

                ---- normal styles    
                , textBoxStyle
                , Helper.Styles.defaultFonts
                , color (convColor model.theme.fHigh)
                , width (blc 5)
                , marginLeft (blc 2)
                , backgroundColor (convColor model.theme.bHigh)
                ]
            ]
            [Html.text <| String.fromInt currentVal]
        ]
        

textBoxStyle : Style
textBoxStyle =
    Css.batch
        [ displayFlex
        , alignItems center
        , padding2 zero (blc 1)
        , height (blc 4)
        ]


numberHousecleaningStyles : Style
numberHousecleaningStyles =
    Css.batch
        [ pseudoElement "-webkit-outer-spin-button"
            [ property "-webkit-appearance" "none"
            , margin zero
            ]

        , pseudoElement "-webkit-inner-spin-button"
            [ property "-webkit-appearance" "none"
            , margin zero
            ]

        , property "-moz-appearance" "textfield"
        , border zero
        ]

sliderHousecleaningStyles : Style
sliderHousecleaningStyles =
    Css.batch
        [ property "-webkit-appearance" "none"
        , width (pct 100) -- apparently FF needs this
        , backgroundColor transparent

        , pseudoElement "-webkit-slider-thumb"
            [ property "-webkit-appearance" "none"
            ]
        , pseudoElement "-ms-track"
            [ width (pct 100)
            , cursor pointer

            -- hides the slider so custom styles can be added
            , backgroundColor transparent
            , borderColor transparent
            , color transparent
            ]
        , focus
            [ outline none ]
        ]

{-| Argh, it's HTML input styling time!
-}
sliderThumb : List Style -> Style
sliderThumb styles =
    Css.batch
        [ pseudoElement "-webkit-slider-thumb" styles
        , pseudoElement "-moz-range-thumb" styles
        ]

{-| Argh, it's HTML input styling time!
-}
sliderTrack : List Style -> Style
sliderTrack styles =
    Css.batch
        [ pseudoElement "-webkit-slider-runnable-track" styles
        , pseudoElement "-moz-range-track" styles
        ]

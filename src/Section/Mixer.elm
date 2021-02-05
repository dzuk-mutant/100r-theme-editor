module Section.Mixer exposing (view)

import Helper.Color exposing (convColor)
import Helper.Styles
import ColorMixer exposing (ColorMixer, EditActivity(..), RGBEdit(..), HSLEdit(..))
import Css exposing (..)
import Html.Styled as Html exposing (Html, Attribute, button, div, input, label)
import Html.Styled.Attributes as Attr exposing (class, css, type_, value, step)
import Html.Styled.Events exposing (onClick, onInput, onFocus, onBlur)
import Model exposing (Model, SelectedColor(..), ColorMode(..))
import Rpx exposing (blc, rpx)


type alias EditMsg msg = EditActivity -> msg
type alias ColorModeMsg msg = ColorMode -> msg
type alias HexFocus msg = Bool -> msg

view : Model ->  ColorModeMsg msg -> HexFocus msg -> EditMsg msg -> Html msg
view model colorModeMsg hexFocusMsg editMsg  =
    div
        [ class "section-mixer"
        , css   
            [ displayFlex
            , marginBottom (blc 4)
            ]
        ]
        [ colorArea model editMsg hexFocusMsg

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
                        HSL -> hslSliders model editMsg
                        RGB -> rgbSliders model editMsg
                    ]
                ]
            ]
        ]


colorArea : Model -> EditMsg msg -> HexFocus msg -> Html msg
colorArea model editMsg hexFocusMsg =
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
        
        colorPrev = model.mixer.color
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
                [ class "hex"
                , type_ "text"
                , Attr.maxlength 7
                , onInput <| editMsg << HexEdited
                , value model.mixer.hex

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


rgbSliders : Model -> EditMsg msg -> Html msg
rgbSliders model editMsg =
    div
        [ css [ marginTop (blc 2) ]
        ]
        [ slider model editMsg "R" (RGBEdited << Red) 0 255 .red
        , slider model editMsg "G" (RGBEdited << Green) 0 255 .green
        , slider model editMsg "B" (RGBEdited << Blue) 0 255 .blue
        ]


hslSliders : Model -> EditMsg msg -> Html msg
hslSliders model editMsg =
    div
        [ css [ marginTop (blc 2) ]
        ]
        [ slider model editMsg "H" (HSLEdited << Hue) 0 360 .hue
        , slider model editMsg "S" (HSLEdited << Saturation) 0 100 .saturation
        , slider model editMsg "L" (HSLEdited << Lightness) 0 100 .lightness
        ]

    
slider : Model 
    -> EditMsg msg
    -> String
    -> (Float -> EditActivity)
    -> Int
    -> Int
    -> (ColorMixer -> Float)
    -> Html msg
slider model editMsg labelStr editType minVal maxVal currentValAcc =
    let
        currentVal = currentValAcc model.mixer
        updateFunc = 
            ColorMixer.stringToVal minVal maxVal
            >> editType
            >> editMsg

        valStr = ColorMixer.valToString maxVal currentVal
        minStr = String.fromInt minVal
        maxStr = String.fromInt maxVal
    in
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
                , Attr.min minStr
                , Attr.max maxStr
                , onInput updateFunc
                , value valStr

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
                , onInput updateFunc
                , value valStr
                , Attr.min minStr
                , Attr.max maxStr
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
                [Html.text valStr]
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

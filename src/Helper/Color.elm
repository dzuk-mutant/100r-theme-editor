module Helper.Color exposing ( convColor

                        , getSelectedColor
                        , getNewSelectedColor
                        , changeSelectedColor

                        , getColorValue
                        , editColorValue
                        , editColorHex

                        , editHSLSliders
                        , editOneHSlSlider
                        )

import Color exposing (Color)
import Color.Convert
import Css
import HRTheme exposing (HRTheme)
import Model exposing (Model, SelectedColor(..), ValueEditType(..), HSLSliders)

{-| Converts avh4's elm-color
to elm-css's Color type.
-}
convColor : Color.Color -> Css.Color
convColor colorData =
    colorData
    |> Color.Convert.colorToHex
    |> Css.hex



{-| Returns a colour from the currently selected color.
-}
getSelectedColor : Model -> Color.Color
getSelectedColor model =
    case model.selectedColor of
        Background -> model.theme.background
        FHigh -> model.theme.fHigh
        FMed -> model.theme.fMed
        FLow -> model.theme.fLow
        FInv -> model.theme.fInv
        BHigh -> model.theme.bHigh
        BMed -> model.theme.bMed
        BLow -> model.theme.bLow
        BInv -> model.theme.bInv


{-| Returns a color from a newly selected colour
(ie. one that would be in an update function case)
-}
getNewSelectedColor : SelectedColor -> HRTheme -> Color.Color
getNewSelectedColor selCol theme =
    case selCol of
        Background -> theme.background
        FHigh -> theme.fHigh
        FMed -> theme.fMed
        FLow -> theme.fLow
        FInv -> theme.fInv
        BHigh -> theme.bHigh
        BMed -> theme.bMed
        BLow -> theme.bLow
        BInv -> theme.bInv

{-| Takes a colour and applies it to the current
selected colour in the theme and returns the new theme.
-}
changeSelectedColor : Color.Color -> Model -> HRTheme
changeSelectedColor color model =
    let
        c = color
        t = model.theme
    in
        case model.selectedColor of
            Background -> { t | background = c }
            FHigh -> { t | fHigh = c }
            FMed -> { t | fMed = c }
            FLow -> { t | fLow = c }
            FInv -> { t | fInv = c }
            BHigh -> { t | bHigh = c }
            BMed -> { t | bMed = c }
            BLow -> { t | bLow = c }
            BInv -> { t | bInv = c }



{-| Gets a specific value of the current colour with an
EditType value.
-}
getColorValue : Model -> ValueEditType -> Int
getColorValue model editType =
    let
        getColorAspect : Color.Color -> Float
        getColorAspect c =
            case editType of
                Red -> c |> Color.toRgba |> .red |> (*) 255
                Green -> c |> Color.toRgba |> .green |> (*) 255
                Blue -> c |> Color.toRgba |> .blue |> (*) 255
                Hue -> c |> Color.toHsla |> .hue |> (*) 360
                Saturation -> c |> Color.toHsla |> .saturation |> (*) 100
                Lightness ->  c |> Color.toHsla |> .lightness |> (*) 100
    in
        model
        |> getSelectedColor
        |> getColorAspect
        |> round


{-| Takes a string representing a particular
color value, an edit type and existing colour
and returns a modified colour based on the first 2 arguments.
-}
editColorValue : String -> ValueEditType -> Model -> Color
editColorValue valueString editType model =
    let
        color = getSelectedColor model
        rgb = Color.toRgba color
        hsl = model.hslSliders

        hue = toFloat hsl.hue / 360
        saturation = toFloat hsl.saturation / 100
        lightness = toFloat hsl.lightness / 100
        
        
        {- it's important that they are clamped because the value
        could be coming from a slider or a number box, in the latter,
        the user can still enter an invalidly high/low value even with
        min/max attrs.

        So clamping makes sure they can never do that.
        -}
        clampValue : Float -> Float
        clampValue c =
            case editType of
                Red -> clamp 0 255 c
                Green -> clamp 0 255 c
                Blue -> clamp 0 255 c

                Hue -> clamp 0 360 c
                Saturation -> clamp 0 100 c
                Lightness -> clamp 0 100 c

        {- Color.Color treats color values as a Float between 0 and 1, so
        the int-derived values we have need to be fit into that format.
        -}
        prepareValue : Float -> Float
        prepareValue c =
            case editType of
                Red -> c / 255
                Green -> c / 255
                Blue -> c / 255

                Hue -> c / 360
                Saturation -> c / 100
                Lightness -> c / 100


        {- Puts the channel into a new color value to mix it with the
        pre-existing values..
        -}
        packValue : Float -> Color
        packValue c =
            case editType of
                Red -> Color.rgb c rgb.green rgb.blue
                Green -> Color.rgb rgb.red c rgb.blue
                Blue -> Color.rgb rgb.red rgb.green c

                -- HSL operations have to look to the sliders
                -- rather than the conversions from the color.
                Hue -> Color.hsl c saturation lightness
                Saturation -> Color.hsl hue c lightness
                Lightness -> Color.hsl hue saturation c

    in
        valueString
        |> String.toInt
        |> Maybe.withDefault 0 -- there should be no error with cnversion from string to int
        |> toFloat
        |> clampValue -- clamp to prevent user error.
        |> prepareValue -- fit it between 0 and 1.
        |> packValue -- mix into a new color.



{-| Performs the colour transformations necessary for
previewing what the hex color is as the user is inputting it.

It's also used to properly 'set' the hex input once the
user has focused away.
-}
editColorHex : String -> Model -> Color
editColorHex hex model =
    let
        color = getSelectedColor model

        hashed = case String.left 1 hex == "#" of
            True -> hex
            False -> "#" ++ hex

        -- if the new color isn't good, keep the old one
        newColor = hashed
            |> Color.Convert.hexToColor
            |> Result.toMaybe
            |> Maybe.withDefault color
    in
        newColor

{-| For when the HSL sliders need to be edited by action coming from other types of value editing.
-}
editHSLSliders : Color -> HSLSliders
editHSLSliders color =
    let
        hsl = Color.toHsla color
    in
        { hue = round <| hsl.hue * 360 
        , saturation = round <| hsl.saturation * 100
        , lightness = round <| hsl.lightness * 100
        }

{-| Changes the HSL sliders based on what kinds of values are being edited.
-}
editOneHSlSlider : Model -> String -> ValueEditType -> Color -> HSLSliders
editOneHSlSlider model newValStr editType fallbackColor =
    let
        val = Maybe.withDefault 0 <| String.toInt newValStr
    in
        case editType of
            Hue -> { hue = val, saturation = model.hslSliders.saturation, lightness = model.hslSliders.lightness }
            Saturation -> { hue = model.hslSliders.hue, saturation = val, lightness = model.hslSliders.lightness }
            Lightness -> { hue = model.hslSliders.hue, saturation = model.hslSliders.saturation, lightness = val }
            _ ->  editHSLSliders fallbackColor
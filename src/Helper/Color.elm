module Helper.Color exposing ( convColor

                        , getSelectedColor
                        , getNewSelectedColor
                        , changeSelectedColor

                        , getColorValue
                        , editColorValue
                        , editColorHex
                        )

import Color exposing (Color)
import Color.Convert
import Css
import HRTheme exposing (HRTheme)
import Model exposing (Model, SelectedColor(..), ValueEditType(..))

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
getColorValue : Model -> ValueEditType -> String
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
        |> String.fromInt


{-| Takes a string representing a particular
color value, an edit type and existing colour
and returns a modified colour based on the first 2 arguments.
-}
editColorValue : String -> ValueEditType -> Model -> Color
editColorValue channelString editType model =
    let
        color = getSelectedColor model
        rgb = Color.toRgba color
        hsl = Color.toHsla color
        
        
        {- it's important that they are clamped because the value
        could be coming from a slider or a number box, in the latter,
        the user can still enter an invalidly high/low value even with
        min/max attrs.

        So clamping makes sure they can never do that.
        -}
        clampChannel : Float -> Float
        clampChannel c =
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
        prepareChannel : Float -> Float
        prepareChannel c =
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
        packChannel : Float -> Color
        packChannel c =
            case editType of
                Red -> Color.rgb c rgb.green rgb.blue
                Green -> Color.rgb rgb.red c rgb.blue
                Blue -> Color.rgb rgb.red rgb.green c
                Hue -> Color.hsl c hsl.saturation hsl.lightness
                Saturation -> Color.hsl hsl.hue c hsl.lightness
                Lightness -> Color.hsl hsl.hue hsl.saturation c

    in
        channelString
        |> String.toInt
        |> Maybe.withDefault 0 -- there should be no error with cnversion from string to int
        |> toFloat
        |> clampChannel -- clamp to prevent user error.
        |> prepareChannel -- fit it between 0 and 1.
        |> packChannel -- mix into a new color.


{-| Performs the colour transformations necessary for previewing what the 
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
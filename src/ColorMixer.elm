module ColorMixer exposing ( ColorMixer
                           , EditActivity(..)
                           , RGBEdit(..)
                           , HSLEdit(..)

                           , fromColor
                           , edit

                           , intToVal
                           , stringToVal
                           , valToInt
                           , valToString
                           )


{-| A module for editing a colour in a user interface.

# Types
@docs ColorMixer, EditActivity, RGBEdit, HSLEdit

# Create
@docs fromColor

# Edit
@docs edit

## Convert values

While ColorMixer stores Colors as Floats for
high resolution and inter-operability with `Color`,
it's likely you'll want to be converting to and from
other types of inputs.

@docs intToVal, stringToVal, valToInt, valToString

-}

import Color exposing (Color)
import Color.Convert exposing (colorToHex)


{-| A type representing a color mixer in a user interface.

- `color` : The current color being worked on.
- `red` : The value for the red slider in RGB controls.
- `green` : The value for the green slider in RGB controls.
- `blue` : The value for the blue slider in RGB controls.
- `hue` : The value for the hue slider in HSL controls.
- `saturation` : The value for the saturation slider in HSL controls.
- `lightness` : The value for the lightness slider in HSL controls.
- `hex` : The value for the hex text input.
-}
type alias ColorMixer =
    { color : Color

    , red : Float
    , green : Float
    , blue : Float

    , hue : Float
    , saturation : Float
    , lightness : Float

    , hex : String
    }


{-| The range of possibilities for controlling/editing a 
ColorMixer.

- `ColorChange` - when the color this mixer operates
is changed altogether.
- `RGBEdited` - when RGB sliders/values are edited.
- `HSLEdited` - when HSL sliders/values are edited.

Hex works differently because the mixer's color can't directly
be saved as the user is typing, only until they focus away from
the text input.

### HexEdited
When a Hex value representing this colour
is being edited right now.

### HexDone
Setting a hex's input is different to editing
based on hex input because we can't be sure
if the user is correct or not until they're
finished typing.

This function means that the user has done editing
the hex input and we can safely apply the user's
hex value to everything including the hex input itself.

This means that if the user's input is wrong, it will
revert to the last good known hex input.

-}
type EditActivity
    = ColorChanged Color
    | RGBEdited RGBEdit
    | HSLEdited HSLEdit
    | HexEdited String
    | HexDone

type RGBEdit
    = Red Float
    | Green Float
    | Blue Float

type HSLEdit
    = Hue Float
    | Saturation Float
    | Lightness Float


{-| Creates a new mixer from a Color value.
-}
fromColor : Color -> ColorMixer
fromColor newColor =
    let
        newRgb = Color.toRgba newColor
        newHsl = Color.toHsla newColor
    in
        { color = newColor

        , red = newRgb.red
        , green = newRgb.green
        , blue = newRgb.blue

        , hue = newHsl.hue
        , saturation = newHsl.saturation
        , lightness = newHsl.lightness

        , hex = colorToHex newColor
        }


{-| Takes an EditActivity and a ColorMixer
and edits the ColorMixer based on that activity.
-}
edit : EditActivity -> ColorMixer -> ColorMixer
edit activity mixer =
    case activity of
        ColorChanged c -> fromColor c -- we can just reuse fromColor.
        RGBEdited r -> rgbEdit r mixer
        HSLEdited h -> hslEdit h mixer
        HexEdited x -> hexEdit x mixer
        HexDone -> hexSet mixer


{-| Takes an String representing a Int-based color
value with a min anx max bounds and turns it into a
Float that's between 0 and 1 so it can be updated
to a ColorMixer.

    onInput <| RGBEdit << Blue << (ColorMixer.stringToVal 0 255)

If the input number is higher than the max bounds
you've given, then this function will clamp it.

If the number conversion fails, the value will be 0.
-}
stringToVal : Int -> Int -> String -> Float
stringToVal minVal maxVal str =
    str
    |> String.toInt
    -- this should be used in an environment
    -- where failure is not possible
    |> Maybe.withDefault 0
    |> intToVal minVal maxVal

{-| Takes an int representing a color value with
a min anx max bounds and turns it into a Float
that's between 0 and 1 so it can be updated to a
ColorMixer.

    HSLEdit <| Hue <| stringToVal 0 360 hue

If the number given is higher than the max bounds
you've given, then this function will clamp it.
-}
intToVal : Int -> Int -> Int -> Float
intToVal minVal maxVal int =
    int
    {- it's important that they are clamped because the value
    could be coming from a slider or a number box, in the latter,
    the user can still enter an invalidly high/low value even with
    min/max attrs.

    So clamping makes sure they can never do that.
    -}
    |> clamp minVal maxVal
    |> toFloat
    |> (\c -> c / toFloat maxVal)


{-| Takes a value from the mixer and converts it to an Int
at the scale provided by the max value (the first Int.)

    ColorMixer.valToInt 255 model.mixer.green
-}
valToInt : Int -> Float -> Int
valToInt maxVal val =
    val
    |> (*) (toFloat maxVal)
    |> round

{-| Takes a value from the mixer and converts it to an String
representing an int at the scale provided by the max value
(the first Int.)

    value <| ColorMixer.valToString 255 model.mixer.green
-}
valToString : Int -> Float -> String
valToString maxVal val =
    val
    |> valToInt maxVal
    |> String.fromInt


-------------------------------------------------------
-------------------------------------------------------
-------------------------------------------------------
--------------------- INTERNAL ------------------------
-------------------------------------------------------
-------------------------------------------------------
-------------------------------------------------------


{-| Updates a ColorMixer based on an RGBEdit action.
-}
rgbEdit : RGBEdit -> ColorMixer -> ColorMixer
rgbEdit rgbAction mixer =
    let
        currentRgb = Color.toRgba mixer.color
        newColor = 
            case rgbAction of
                Red newRed -> Color.rgb (clampZeroOne newRed) currentRgb.green currentRgb.blue
                Green newGreen -> Color.rgb currentRgb.red (clampZeroOne newGreen) currentRgb.blue
                Blue newBlue -> Color.rgb currentRgb.red currentRgb.green (clampZeroOne newBlue)
    in
        -- Apply the newly mixed color to everything.
        fromColor newColor





{-| Updates a ColorMixer based on an HSLEdit action.

HSL acts differently to RGB so it needs its own
updating function.
-}
hslEdit : HSLEdit -> ColorMixer -> ColorMixer
hslEdit hslAction mixer =
    let
        newColor =
            -- HSL operations have to look to the sliders
            -- rather than the conversions from the color.
            case hslAction of
                Hue newHue ->
                    Color.hsl (clampZeroOne newHue) mixer.saturation mixer.lightness

                Saturation newSaturation ->
                    Color.hsl mixer.hue (clampZeroOne newSaturation) mixer.lightness

                Lightness newLightness ->
                    Color.hsl mixer.hue mixer.saturation (clampZeroOne newLightness)
        
        -- Only update the slider the user is changing.
        updateHSlSliders = 
            case hslAction of
                Hue newHue ->
                    (\m -> { m | hue = newHue })

                Saturation newSaturation ->
                    (\m -> { m | saturation = newSaturation })

                Lightness newLightness ->
                    (\m -> { m | lightness = newLightness })

        newRgb = Color.toRgba newColor

    in
        -- Apply the newly mixed color to everything but HSL sliders.
        { mixer | color = newColor

                , red = newRgb.red
                , green = newRgb.green
                , blue = newRgb.blue

                , hex = colorToHex newColor
        }
        -- Only change the HSL slider that the user changed.
        |> updateHSlSliders



{-| This tries to put the hex color into `color` as
the user is typing in. So this leaves the hex alone
while it tries to edit the colors around it.
-}
hexEdit : String -> ColorMixer -> ColorMixer
hexEdit newHex mixer =
    let
        newColor = tryToEditHex newHex mixer.color
        newRgb = Color.toRgba newColor
        newHsl = Color.toHsla newColor
    in

        { mixer | color = newColor

                , red = newRgb.red
                , green = newRgb.green
                , blue = newRgb.blue

                , hue = newHsl.hue
                , saturation = newHsl.saturation
                , lightness = newHsl.lightness

                -- edit the hex based on what
                -- the user is typing right now.
                , hex = newHex
        }


{-| Setting a hex's input is different to editing
based on hex input because we can't be sure
if the user is correct or not until they're
finished typing.

This function means that the user has done editing
the hex input and we can safely apply the user's
hex value to everything including the hex input itself.

This means that if the user's input is wrong, it will
revert to the last good known hex input.
-}
hexSet : ColorMixer -> ColorMixer
hexSet mixer =
    let
        newColor = tryToEditHex mixer.hex mixer.color
    in
        fromColor newColor




-------------------------------------------------------
-------------------------------------------------------
-------------------------------------------------------
------------ INTERNAL OF THE INTERNAL -----------------
-------------------------------------------------------
-------------------------------------------------------
-------------------------------------------------------



{-| Internal function that tries to create a new
Color based on hex input. If the hex input fails,
it returns the existing color.
-}
tryToEditHex : String -> Color -> Color
tryToEditHex newHexStr currentColor =
    let
        color = currentColor

        hashed = case String.left 1 newHexStr == "#" of
            True -> newHexStr
            False -> "#" ++ newHexStr

        -- if the new color isn't good, keep the old one
        newColor = hashed
            |> Color.Convert.hexToColor
            |> Result.toMaybe
            |> Maybe.withDefault color
    in
        newColor


{-| Ensures that floats coming in are properly clamped
between 0 and 1 because that's what Color requires.
-}
clampZeroOne : Float -> Float
clampZeroOne = clamp 0 1
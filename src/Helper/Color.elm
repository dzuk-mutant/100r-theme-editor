module Helper.Color exposing ( convColor

                            , getNewSelectedColor
                            , changeSelectedColor
                            )

import Color exposing (Color)
import Color.Convert
import Css
import HRTheme exposing (HRTheme)
import Model exposing (Model, SelectedColor(..))

{-| Converts avh4's elm-color
to elm-css's Color type.
-}
convColor : Color.Color -> Css.Color
convColor colorData =
    colorData
    |> Color.Convert.colorToHex
    |> Css.hex



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



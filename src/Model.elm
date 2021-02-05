module Model exposing (Model
                      , SelectedColor(..)
                      , ColorMode(..)
                      , ValueEditType(..)
                      , HSLSliders
                      )

import HRTheme exposing (HRTheme)
import Tests exposing (Tests)


type alias Model =
    { theme : HRTheme
    , selectedColor : SelectedColor
    , colorEditMode : ColorMode
    , tests : Tests

    , hexInputValue : String
    , hexInputFocused : Bool
    , hslSliders : HSLSliders
    }


type SelectedColor
    = Background
    | FHigh
    | FMed
    | FLow
    | FInv
    | BHigh
    | BMed
    | BLow
    | BInv

type ColorMode
    = HSL
    | RGB

type ValueEditType
    = Red
    | Green
    | Blue
    | Hue
    | Saturation
    | Lightness

{-| We need separate modelling for the HSL sliders
because they function differently to RGB.

RGB sliders can essentially be stored in the theme
colors, because they are discrete and independent.
-}
type alias HSLSliders =
    { hue : Int
    , saturation : Int
    , lightness : Int
    }
module Model exposing (Model
                      , SelectedColor(..)
                      , ColorMode(..)
                      , EditType(..)
                      )

import HRTheme exposing (HRTheme)

type alias Model =
    { theme : HRTheme
    , selectedColor : SelectedColor
    , colorEditMode : ColorMode
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

type EditType
    = Red
    | Green
    | Blue
    | Hue
    | Saturation
    | Lightness
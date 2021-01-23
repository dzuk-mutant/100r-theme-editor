module Model exposing (Model
                      , SelectedColor(..)
                      , ColorMode(..)
                      , EditType(..)
                      )

import HRTheme exposing (HRTheme)
import Tests exposing (Tests)


type alias Model =
    { theme : HRTheme
    , selectedColor : SelectedColor
    , colorEditMode : ColorMode
    , tests : Tests
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
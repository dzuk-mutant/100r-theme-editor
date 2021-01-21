module Model exposing (Model, SelectedColor(..), ColorEditMode(..))

import HRTheme exposing (HRTheme)

type alias Model =
    { theme : HRTheme
    , selectedColor : SelectedColor
    , colorEditMode : ColorEditMode
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

type ColorEditMode
    = HSL
    | RGB
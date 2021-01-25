module Model exposing (Model
                      , SelectedColor(..)
                      , ColorMode(..)
                      , ValueEditType(..)
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
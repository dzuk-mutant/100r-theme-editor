module Model exposing (Model
                      , SelectedColor(..)
                      , ColorMode(..)
                      )

import ColorMixer exposing (ColorMixer)
import HRTheme exposing (HRTheme)
import Tests exposing (Tests)


type alias Model =
    { theme : HRTheme
    , selectedColor : SelectedColor
    , colorEditMode : ColorMode
    , tests : Tests
    
    , hexInputFocused : Bool
    , mixer : ColorMixer
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

module ColorHelper exposing (convColor)

import Color
import Color.Convert
import Css

{-| Converts avh4's elm-color
to elm-css's Color type.
-}
convColor : Color.Color -> Css.Color
convColor colorData =
    colorData
    |> Color.Convert.colorToHex
    |> Css.hex


module Section.File exposing (view)

import Model exposing (Model)
import Html.Styled as Html exposing (Html, button, div, text)
import Html.Styled.Events exposing (onClick)

view : Model -> msg -> msg -> (Html msg)
view model importMsg exportMsg =
    div
        []
        [ button [ onClick importMsg ] [ text "Upload Theme" ] ]
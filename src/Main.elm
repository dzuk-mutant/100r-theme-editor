module Main exposing (main)

import Browser
import Color
import Color.Convert
import Css exposing (auto, alignItems, backgroundColor, borderRadius, center, color, column, displayFlex, flex, flexDirection, height, justifyContent, margin2, maxWidth, none, padding, row, vh, vw, width)
import File exposing (File)
import File.Select as Select
import Html
import Html.Styled exposing (Attribute, Html, button, div, span, text)
import Html.Styled.Attributes exposing (css)
import Html.Styled.Events exposing (..)
import HRTheme exposing (HRTheme)
import Json.Decode as JD
import Task
import Rpx exposing (rpx, blc)
import Xml.Decode as XD


-- MAIN


main = Browser.element
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }


{-| Converts avh4's elm-color
to elm-css's Color type.
-}
convColor : Color.Color -> Css.Color
convColor colorData =
    colorData
    |> Color.Convert.colorToHex
    |> Css.hex

-- MODEL


type alias Model =
  { hover : Bool
  , theme : HRTheme
  }



{-| The example theme on the Hundred Rabbits theme git readme.
-}
defaultTheme : HRTheme
defaultTheme =
    let
        hexConv hexStr =
            hexStr
            |> Color.Convert.hexToColor
            |> Result.toMaybe
            |> Maybe.withDefault Color.black

    in
        { background = hexConv "E0B1CB"
        , fHigh = hexConv "231942"
        , fMed = hexConv "5E548E"
        , fLow = hexConv "BE95C4"
        , fInv = hexConv "E0B1CB"
        , bHigh = hexConv "FFFFFF"
        , bMed = hexConv "5E548E"
        , bLow = hexConv "BE95C4"
        , bInv = hexConv "9F86C0"
        }


applyTheme : String -> HRTheme -> HRTheme
applyTheme file existingTheme =
    let
        newTheme = XD.run HRTheme.decoder file
    in
        case newTheme of
           Ok t -> t
           Err _ -> existingTheme 

init : () -> (Model, Cmd Msg)
init _ =
    (   { hover = False
        , theme = defaultTheme
        }
    , Cmd.none
    )



-- UPDATE


type Msg
  = Pick
  | DragEnter
  | DragLeave
  | GotFiles File (List File)
  | ThemeLoaded String


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Pick ->
      ( model
      , Select.files ["image/svg+xml"] GotFiles
      )

    DragEnter ->
      ( { model | hover = True }
      , Cmd.none
      )

    DragLeave ->
      ( { model | hover = False }
      , Cmd.none
      )

    GotFiles file files ->
      ( { model | hover = False }
      , Task.perform ThemeLoaded (File.toString file)
      )
    
    ThemeLoaded fileStr ->
        ( { model | theme = applyTheme fileStr model.theme }
        , Cmd.none
        )
    



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none



-- VIEW

paletteCircle : Color.Color -> Html msg
paletteCircle c =
    div [ css -- spacing area
            [ width (blc 8)
            ]

        ]
        [ div  -- circle
            [ css 
                [ width (blc 4)
                , height (blc 4)
                , backgroundColor (convColor c)
                , borderRadius (blc 2)
                ]
            ]
            []
        ]

paletteBox : Color.Color -> List (Html msg) -> Html msg
paletteBox c content =
    div [ css
            [ displayFlex
            , flex none
            , flexDirection row
            , alignItems center
            , backgroundColor (convColor c)
            , padding (blc 2)
            , width (blc 24)
            ]
        ]
        content

colorSect : Color.Color -> HRTheme -> Html msg
colorSect fg theme = 
    paletteBox fg
        [ paletteCircle theme.fHigh
        , paletteCircle theme.fMed
        , paletteCircle theme.fLow
        ]

invSect : HRTheme -> Html msg
invSect theme =
    paletteBox theme.bInv
            [ paletteCircle theme.fInv
            ]


view : Model -> Html.Html Msg
view model =

    let
        theme = model.theme
    in

        Html.Styled.toUnstyled
            ( div
                [ css
                    [ displayFlex
                    , flexDirection column
                    , alignItems center
                    ]
                ]
                [ div
                    [ css   [ borderRadius (rpx 20)
                            , width (blc 20)
                            , height (blc 20)
                            , margin2 (rpx 100) auto
                            , padding (rpx 20)
                            , displayFlex
                            , flexDirection Css.column
                            , justifyContent Css.center
                            , alignItems Css.center
                            , Css.batch (
                                    case model.hover of
                                        True -> [ Css.border3 (rpx 6) Css.dashed (Css.hex "#ff00ff") ]
                                        False -> [ Css.border3 (rpx 6) Css.dashed (Css.hex "#ccc") ]
                                )
                            ]
                    , hijackOn "dragenter" (JD.succeed DragEnter)
                    , hijackOn "dragover" (JD.succeed DragEnter)
                    , hijackOn "dragleave" (JD.succeed DragLeave)
                    , hijackOn "drop" dropDecoder
                    ]
                    [ button [ onClick Pick ] [ text "Upload Theme" ]
                    ]
                , div
                    [ css
                        [ Css.displayFlex
                        , Css.flexDirection Css.column
                        ]
                    ]
                    [ colorSect theme.background theme
                    , colorSect theme.bLow theme
                    , colorSect theme.bMed theme
                    , colorSect theme.bHigh theme
                    , invSect theme
                    ]
                ]
            )



dropDecoder : JD.Decoder Msg
dropDecoder =
  JD.at ["dataTransfer","files"] (JD.oneOrMore GotFiles File.decoder)


hijackOn : String -> JD.Decoder msg -> Attribute msg
hijackOn event decoder =
  preventDefaultOn event (JD.map hijack decoder)


hijack : msg -> (msg, Bool)
hijack msg =
  (msg, True)
module Main exposing (main)

import Browser
import Color
import Color.Convert
import ColorHelper exposing (convColor)
import Css exposing (auto, alignItems, backgroundColor, borderRadius, center, column, displayFlex, flex, flexDirection, height, justifyContent, margin2, none, padding, row, vh, vw, width)
import File exposing (File)
import File.Select as Select
import Html
import Html.Styled exposing (Attribute, Html, button, div, text)
import Html.Styled.Attributes exposing (css)
import Html.Styled.Events exposing (..)
import HRTheme exposing (HRTheme)
import Json.Decode as JD
import Task
import Rpx exposing (rpx, blc)
import PreviewArea
import Xml.Decode as XD
import ViewHelper

-- MAIN


main = Browser.document
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }


-- MODEL


type alias Model =
  { theme : HRTheme
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


init : () -> (Model, Cmd Msg)
init _ =
    (   { theme = defaultTheme
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
      ( model
      , Cmd.none
      )

    DragLeave ->
      ( model
      , Cmd.none
      )
    GotFiles file _ ->
      ( model
      , Task.perform ThemeLoaded (File.toString file)
      )
    
    ThemeLoaded fileStr ->
        let
            newThemeAttempt = XD.run HRTheme.decoder fileStr
            newTheme =
                case newThemeAttempt of
                    Ok t -> t
                    Err _ -> model.theme 

        in
            ( { model | theme = newTheme }
            , Cmd.none
            )
    



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
  Sub.none


view : Model -> Browser.Document Msg
view model =
    { title = "Hundred Rabbits theme editor"
    , body = [ mainView model ]
    }

mainView : Model -> Html.Html Msg
mainView model =

    let
        theme = model.theme
    in
        Html.Styled.toUnstyled
            ( div 
                [ css
                    [ displayFlex
                    , flexDirection column
                    , alignItems center
                    , width (vw 100)
                    , height (vh 100)
                    ]
                , hijackOn "dragenter" (JD.succeed DragEnter)
                , hijackOn "dragover" (JD.succeed DragEnter)
                , hijackOn "dragleave" (JD.succeed DragLeave)
                , hijackOn "drop" dropDecoder
                ]
                [ ViewHelper.globalStyles model.theme
                , button [ onClick Pick ] [ text "Upload Theme" ]
                , PreviewArea.view model.theme
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
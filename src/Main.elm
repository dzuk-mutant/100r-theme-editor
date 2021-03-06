module Main exposing (main)

import Browser
import Color
import Color.Convert
import ColorMixer exposing (EditActivity(..))
import Css exposing (..)
import File exposing (File)
import File.Select as Select
import File.Download as Download
import Helper.Color exposing (convColor, getNewSelectedColor, changeSelectedColor)
import Html
import Html.Styled exposing (Attribute, div)
import Html.Styled.Attributes exposing (css)
import Html.Styled.Events exposing (..)
import HRTheme exposing (HRTheme)
import Json.Decode as JD
import Task
import Tests
import Model exposing (Model, SelectedColor(..), ColorMode(..))
import Section.File
import Section.Preview
import Section.Mixer
import Xml.Decode as XD
import Helper.Styles
import Rpx exposing (rpx, blc)



-- MAIN


main = Browser.document
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
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
        -- noir theme
        { background = hexConv "222222"
        , fHigh = hexConv "ffffff"
        , fMed = hexConv "cccccc"
        , fLow = hexConv "999999"
        , fInv = hexConv "ffffff"
        , bHigh = hexConv "888888"
        , bMed = hexConv "666666"
        , bLow = hexConv "444444"
        , bInv = hexConv "000000"
        }


init : () -> (Model, Cmd Msg)
init _ =
    (   { theme = defaultTheme
        , tests = Tests.fromTheme defaultTheme

        , selectedColor = Background
        , colorEditMode = HSL
        , hexInputFocused = False

        , mixer = ColorMixer.fromColor defaultTheme.background
        }
    , Cmd.none
    )



-- UPDATE


type Msg
  = DragEnter
  | DragLeave

  | Pick
  | GotFiles File (List File)
  | ThemeLoaded String
  | Export 

  | SelectedColorChanged SelectedColor
  | ColorHexFocusChanged Bool
  | ColorModeChanged ColorMode 
  | ColorMixerEdited ColorMixer.EditActivity

  




update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    {- As far as I understand (not very acquainted
    with drag and drop atm), these are required to
    make drag and drop work even if you have no
    intention of using these.
    -}
    DragEnter -> ( model, Cmd.none )
    DragLeave -> ( model, Cmd.none )


    ----------------- IMPORT/EXPORT ----------------

    Pick ->
        ( model
        , Select.files ["image/svg+xml"] GotFiles
        )

    GotFiles file _ ->
        ( model
        , Task.perform ThemeLoaded (File.toString file)
        )

    Export -> ( model, export model.theme )

    ThemeLoaded fileStr ->
        let
            newThemeAttempt = XD.run HRTheme.decoder fileStr

            newTheme = case newThemeAttempt of
                    Ok t -> t
                    Err _ -> model.theme 

            newSelectedCol = getNewSelectedColor model.selectedColor newTheme

        in
            ( { model | theme = newTheme
                      , tests = Tests.fromTheme newTheme
                      , mixer = ColorMixer.fromColor newSelectedCol
              }
            , Cmd.none
            )


    ----------------- EDITING ----------------

    SelectedColorChanged sc ->
        let
            newSelectedCol = getNewSelectedColor sc model.theme
        in
            ( { model | selectedColor = sc 
                      , mixer = ColorMixer.fromColor newSelectedCol
              }
            , Cmd.none
            )


    ColorModeChanged cem ->
        ( { model | colorEditMode = cem } , Cmd.none )
    

    ColorHexFocusChanged b ->
        if b then
            ( { model | hexInputFocused = b }, Cmd.none)
        else
            let
                newMixer = ColorMixer.edit HexDone model.mixer
                newTheme = changeSelectedColor newMixer.color model
            in
                ( { model | theme = newTheme
                        , tests = Tests.fromTheme newTheme
                        , mixer = newMixer 
                        }
                , Cmd.none
                )


    ColorMixerEdited editAction ->
        let
            newMixer = ColorMixer.edit editAction model.mixer
            newTheme = changeSelectedColor newMixer.color model
        in
            ( { model | theme = newTheme
                      , tests = Tests.fromTheme newTheme
                      , mixer = newMixer
              }
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


divider : HRTheme -> Html.Styled.Html Msg
divider theme =
    div
        [ Html.Styled.Attributes.class "divider"
        , css
            [ width (pct 100)
            , height (rpx 2)
            , marginTop <| Rpx.subtract (blc 4) (rpx 1)
            , marginBottom <| Rpx.subtract (blc 4) (rpx 1)
            , backgroundColor (convColor theme.bLow)
            ]
        ]
        []

mainView : Model -> Html.Html Msg
mainView model =
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
            [ Helper.Styles.globalStyles model.theme
            , div 
                [ css
                    [ padding (blc 2)
                    ]
                ]
                [ Section.File.view model Pick Export
                , divider model.theme
                , Section.Preview.view model SelectedColorChanged
                , divider model.theme
                , Section.Mixer.view model
                    ColorModeChanged
                    ColorHexFocusChanged
                    ColorMixerEdited
                    
                ]
            ]
        )
        

export : HRTheme -> Cmd msg
export theme =
    Download.string "theme.svg" "image/svg+xml" (HRTheme.toXmlString theme)

dropDecoder : JD.Decoder Msg
dropDecoder =
  JD.at ["dataTransfer","files"] (JD.oneOrMore GotFiles File.decoder)


hijackOn : String -> JD.Decoder msg -> Attribute msg
hijackOn event decoder =
  preventDefaultOn event (JD.map hijack decoder)


hijack : msg -> (msg, Bool)
hijack msg =
  (msg, True)
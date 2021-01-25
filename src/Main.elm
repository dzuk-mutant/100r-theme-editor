module Main exposing (main)

import Browser
import Color
import Color.Convert
import Css exposing (..)
import File exposing (File)
import File.Select as Select
import File.Download as Download
import Helper.Color exposing (convColor, editColorValue)
import Html
import Html.Styled exposing (Attribute, div)
import Html.Styled.Attributes exposing (css)
import Html.Styled.Events exposing (..)
import HRTheme exposing (HRTheme)
import Json.Decode as JD
import Task
import Tests
import Model exposing (Model, SelectedColor(..), ColorMode(..), ValueEditType(..))
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





{-| An important shorthand for all the things that
need to be done when colors get updated.
-}
updateColorInModel : Model -> HRTheme -> Model
updateColorInModel model newTheme = 
    { model | theme = newTheme
            , tests = Tests.fromTheme newTheme
            , hexInputValue = Color.Convert.colorToHex <| Helper.Color.getSelectedColor model
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
        , hexInputValue = Color.Convert.colorToHex defaultTheme.background
        }
    , Cmd.none
    )



-- UPDATE


type Msg
  = Pick
  | Export 

  | DragEnter
  | DragLeave
  | GotFiles File (List File)
  
  | ThemeLoaded String
  | SelectedColorChanged SelectedColor

  | ColorModeChanged ColorMode 
  | ColorValueEdited ValueEditType String

  | ColorHexEdited String
  | ColorHexFocusChanged Bool




update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Pick ->
        ( model
        , Select.files ["image/svg+xml"] GotFiles
        )

    Export ->
        ( model
        , export model.theme
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
            ( { model | theme = newTheme
                      , tests = Tests.fromTheme newTheme

                      {-    Get the same selected color, but from a new theme.
                      -}
                      , hexInputValue = Color.Convert.colorToHex <| Helper.Color.getNewSelectedColor model.selectedColor newTheme
              }
            , Cmd.none
            )



    SelectedColorChanged sc ->
        ( { model | selectedColor = sc 
                    
                    {-  the hex input has to be updated with the new selected color at this time.
                        the rest will change immediately automatically, but this won't.
                    -}
                  , hexInputValue = Color.Convert.colorToHex <| Helper.Color.getNewSelectedColor sc model.theme
          }
          , Cmd.none
        )
    



    ColorModeChanged cem ->
        ( { model | colorEditMode = cem }
        , Cmd.none
        )       

    ColorValueEdited editType val ->
        let
            newColor = editColorValue val editType model
            newTheme = Helper.Color.changeSelectedColor newColor model
        in
            ( { model | theme = newTheme
                      , tests = Tests.fromTheme newTheme

                      {- while the hex input isn't being edited,
                         make the hex whatever the color is right now.
                      -}
                      , hexInputValue = Color.Convert.colorToHex <| Helper.Color.getSelectedColor model
              }
            , Cmd.none
            )



    
    ColorHexFocusChanged b ->
        case b of 
            True -> ( { model | hexInputFocused = b }, Cmd.none)

            {-  when focusing away, we need to straighten the
                user input out by making it conform to valid hex input.
            -}
            False -> ( { model | hexInputFocused = b
                               , hexInputValue = Color.Convert.colorToHex <| Helper.Color.editColorHex model.hexInputValue model
                       }
                     , Cmd.none
                     )

    ColorHexEdited hex ->
        let
            newColor = Helper.Color.editColorHex hex model
            newTheme = Helper.Color.changeSelectedColor newColor model
        in
            ( { model | theme = newTheme
                      , tests = Tests.fromTheme newTheme

                      -- while editing, make the hex what the user is typing
                      , hexInputValue = hex 
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
                    ColorValueEdited
                    ColorHexEdited
                    ColorHexFocusChanged
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
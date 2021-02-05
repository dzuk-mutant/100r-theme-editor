module Helper.Layout exposing (..)

import Css exposing (..)
import Helper.Color exposing (convColor)
import Helper.Styles exposing (cellWidth)
import HRTheme exposing (HRTheme)
import Html.Styled as Html exposing (Attribute, Html, button)
import Html.Styled.Attributes exposing (css)
import Rpx exposing (blc, rpx)


cellButton : HRTheme -> Bool -> List (Attribute msg) -> List Style -> String -> Html msg
cellButton theme ifSelected attrs styles label  =
    button
        (   [ css
            (   [ Helper.Styles.buttonStyles

                , minWidth <| Rpx.add cellWidth (blc 2)
                , height (blc 5)
                , padding (blc 1)

                , border zero
                , fontWeight (int 600)
                , Helper.Styles.defaultFonts

                , textAlign left
                , boxSizing borderBox

                , Css.batch (
                    if ifSelected then
                        [ backgroundColor (convColor theme.bLow)
                        , color (convColor theme.fMed)
                        ]
                    else
                        [ backgroundColor unset
                        , color (convColor theme.fLow)
                        ]
                )

                ]
                ++ styles
            )
            ]
            ++ attrs
        )
        [ Html.text label ]
module Helper.Styles exposing ( globalStyles
                            , buttonStyles
                            , defaultFonts
                            , cellWidth
                            )

import Css exposing (Style, Rem, backgroundColor, boxSizing, border, borderBox, color, cursor, displayFlex, focus, fontSize, fontFamilies, fontWeight, int, lineHeight, margin, none, num, padding, opacity, outline, property, pointer, pseudoClass, textRendering, optimizeLegibility, zero)
import Css.Global exposing (global, selector, typeSelector)
import Helper.Color exposing (convColor)
import HRTheme exposing (HRTheme)
import Html.Styled exposing (Html)
import Rpx exposing (rpx, blc)



{-| Directly copied from Parastat's UI framework. weeeeee
-}
globalStyles : HRTheme -> Html msg
globalStyles theme =
    global
        [ selector "*" -- encourage everything to behave
            [ margin zero
            , padding zero
            ]
            
        , typeSelector "body" -- base properties
            [ displayFlex

            , defaultFonts
            , color <| convColor theme.fHigh
            --, lineHeight (num 1.5)
            , backgroundColor <| convColor theme.background

            ---------------------- body housecleaning -----------------------
            , margin zero
            , padding zero

            , textRendering optimizeLegibility
            , boxSizing borderBox

            {- Many browser in macOS have a default font anti-aliasing
            style that makes fonts look thicker with rough, pixelly edges.
            Applying these properties makes that go away.

            This should be applied to the <body> as well as anything else
            that happens to exist in it's own little bubble when it comes
            to font anti-aliasing..
            -}
            , property "-webkit-font-smoothing" "antialiased"
            , property "-moz-osx-font-smoothing" "grayscale"

            ]

        ------------------- housecleaning outside of body ----------------------

        -- Firefox reduces the opacity of placeholders by default.
        -- This forces it to not do that.
        , selector "*:placeholder" [ opacity (num 1) ]

        -- Firefox makes a bunch of awful dotted line borders
        -- on things that are focused on. This basically makes
        -- them go away.
        , selector "*::-moz-focus-inner" [ border zero ]

        , selector "@font-face"
                [ property "font-family" "JetBrains Mono"
                , property "src" "url('JetBrainsMono-Medium.woff2') format('woff2'), url('_fonts/Manrope-Medium.woff') format('woff');"
                , property "font-weight" "600"
                , property "font-style" "normal"
                ]

        ]

{-| Also copied from parastat! :P
-}
buttonStyles : Style
buttonStyles =
    Css.batch
        [ cursor pointer -- once you start messing with button styles, it becomes necessary to do this.
        , padding zero
        , margin zero
        , focus [ outline none ]
        , pseudoClass "-moz-focus-inner" [ border zero ]
        ]

defaultFonts : Style
defaultFonts =
    Css.batch
        [ fontFamilies ["JetBrains Mono", "Cousine", "Cascadia Code", "Courier", "monospace"]
        , fontSize (rpx 16)
        , fontWeight (int 600)
        ]


cellWidth : Rem
cellWidth = (blc 18)
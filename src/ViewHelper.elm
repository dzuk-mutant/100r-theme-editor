module ViewHelper exposing (globalStyles)

import Css exposing (backgroundColor, boxSizing, border, borderBox, color, displayFlex, fontSize, fontWeight, int, lineHeight, margin, num, padding, opacity, property, textRendering, optimizeLegibility, zero)
import Css.Global exposing (global, selector, typeSelector)
import HRTheme exposing (HRTheme)
import Html.Styled exposing (Html)
import Rpx exposing (rpx)
import ColorHelper exposing (convColor)

globalStyles : HRTheme -> Html msg
globalStyles theme =
    global
        [ selector "*" -- encourage everything to behave
            [ margin zero
            , padding zero
            ]
            
        , typeSelector "body" -- base properties
            [ displayFlex

            , fontSize (rpx 14)
            , fontWeight (int 500)
            , color <| convColor theme.fHigh
            , lineHeight (num 1.5)
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
        ]
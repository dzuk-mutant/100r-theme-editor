module Tests exposing ( Tests
                      , fromTheme

                      , getThemeScore
                      , getWCAGScoreString
                      , getWCAGGrade
                      
                      , GradationTest(..)
                      , getGradationTests
                      )

import Color.Accessibility exposing (contrastRatio)
import HRTheme exposing (HRTheme)

{-| A data structure encapsulating all possible theme tests.
-}
type alias Tests =
    { ----------- Contrast against BG tests
      contrastBgBMed : Float
    , contrastBgBHigh : Float
    , contrastBgBLow : Float
    
    -------- WCAG Tests + BG tests
    , contrastBgFHigh : Float
    , contrastBgFMed : Float
    , contrastBgFLow : Float

    ------- All WCAG tests
    , contrastBLowFHigh : Float
    , contrastBLowFMed : Float
    , contrastBLowFLow : Float

    , contrastBMedFHigh : Float
    , contrastBMedFMed : Float
    , contrastBMedFLow : Float

    , contrastBHighFHigh : Float
    , contrastBHighFMed : Float
    , contrastBHighFLow : Float

    , contrastBInvFInv : Float 
    }


{-| Takes an HRTheme and returns a full slate of tests.
-}
fromTheme : HRTheme -> Tests
fromTheme t =
    { ----------- Contrast against BG tests
      contrastBgBHigh = contrastRatio t.background t.bHigh
    , contrastBgBMed = contrastRatio t.background t.bMed
    , contrastBgBLow = contrastRatio t.background t.bLow
    
    -------- WCAG Tests + BG tests
    , contrastBgFHigh = contrastRatio t.background t.fHigh
    , contrastBgFMed = contrastRatio t.background t.fMed
    , contrastBgFLow = contrastRatio t.background t.fLow

    ------- All WCAG tests
    , contrastBLowFHigh = contrastRatio  t.bLow t.fHigh
    , contrastBLowFMed = contrastRatio t.bLow t.fMed
    , contrastBLowFLow = contrastRatio t.bLow t.fLow

    , contrastBMedFHigh = contrastRatio t.bMed t.fHigh
    , contrastBMedFMed = contrastRatio t.bMed t.fMed
    , contrastBMedFLow = contrastRatio t.bMed t.fLow

    , contrastBHighFHigh = contrastRatio t.bHigh t.fHigh
    , contrastBHighFMed = contrastRatio t.bHigh t.fMed
    , contrastBHighFLow = contrastRatio t.bHigh t.fLow

    , contrastBInvFInv = contrastRatio t.bInv t.fInv
    }


{-| Returns the score of the lowest scoring contrast combo.
-}
getThemeScore : Tests -> Float
getThemeScore t =
    let
        calcs =
            [ t.contrastBgFHigh
            , t.contrastBgFMed 
            , t.contrastBgFLow 

            ------- All WCAG tests
            , t.contrastBLowFHigh
            , t.contrastBLowFMed 
            , t.contrastBLowFLow 

            , t.contrastBMedFHigh 
            , t.contrastBMedFMed
            , t.contrastBMedFLow

            , t.contrastBHighFHigh 
            , t.contrastBHighFMed
            , t.contrastBHighFLow

            , t.contrastBInvFInv
            ]

    in
        -- assume it will work, because there's no way it can't
        Maybe.withDefault 0.1 <| List.minimum calcs
        



{-| Returns a presentable WCAG contrast score, showing only one decimal place.

(Floats are fickle when presenting in web browsers.)
-}
getWCAGScoreString : Float -> String
getWCAGScoreString accScore =
    let
        inted = accScore
            |> (*) 10
            |> truncate
            |> String.fromInt
    in
        String.slice 0 -1 inted ++ "." ++ String.right 1 inted



{-| Returns a grade consistent with WCAG 2.0 standards
based on the contrast ratio given.

(Apart from X, that's just something I came up with to
denote those that don't pass minimum standards.)
-}
getWCAGGrade : Float -> String
getWCAGGrade accScore =
    if accScore < 3 then
        "X"
    else if accScore >= 3 && accScore < 4.5 then
        "A"
    else if accScore >= 4.5 && accScore < 7 then
        "AA"
    else -- if accScore >= 7 then
        "AAA"


type GradationTest
    = BHighTooLow
    | BMedTooLow
    | FHighTooLow
    | FMedTooLow
    | Pass

getGradationTests : Tests -> GradationTest
getGradationTests t =
    if t.contrastBgBHigh < t.contrastBgBMed then
        BHighTooLow
    else if t.contrastBgBMed < t.contrastBgBLow then
        BMedTooLow
    else if t.contrastBgFHigh < t.contrastBgFMed then
        FHighTooLow
    else if t.contrastBgFMed < t.contrastBgFLow then
        FMedTooLow
    else
        Pass
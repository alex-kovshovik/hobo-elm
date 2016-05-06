module Utils.Numbers where

import Html exposing (Attribute)
import Html.Events exposing (on, targetValue)
import Signal exposing (Address)
import Numeral

import String

onInput : Address a -> (String -> a) -> Attribute
onInput address f =
  on "input" targetValue (\v -> Signal.message address (f v))

toFloatPoh : String -> Float
toFloatPoh value =
  String.toFloat value |> Result.withDefault 0.0

formatAmount : Float -> String
formatAmount amount =
  Numeral.format "$0,0.00" amount

module Utils.Numbers exposing(..)

import Numeral
import String

toFloatPoh : String -> Float
toFloatPoh value =
  String.toFloat value |> Result.withDefault 0.0

formatAmount : Float -> String
formatAmount amount =
  Numeral.format "$0,0.00" amount

formatAmountRound : Float -> String
formatAmountRound amount =
  Numeral.format "$0" amount

module Utils.Parsers where

import Debug

resultToList : Result a (List b) -> List b
resultToList listResult =
  case listResult of
    Ok list -> list
    Err error ->
      let
        errorMessage = Debug.log "Expense loading/decoding error" error
      in
        []

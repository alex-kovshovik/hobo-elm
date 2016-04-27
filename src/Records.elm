module Records where

type alias RecordId = Int

type alias Budget = {
  id : RecordId,
  name : String
}

type alias Expense = {
  id : RecordId,
  budget: Budget,
  amount : Float,
  comment : String
}

module Records where

type alias RecordId = Int

type alias Budget = {
  id : RecordId,
  name : String
}

type alias Expense = {
  id : RecordId,
  budgetId: RecordId,
  budgetName: String,
  amount : Float,
  comment : String
}

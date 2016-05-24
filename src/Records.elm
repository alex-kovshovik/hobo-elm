module Records exposing(..)

import Date exposing(Date)

type alias RecordId = Int
type alias BudgetId = RecordId

type alias Budget = {
  id : RecordId,
  name : String,
  amount : Float
}

type alias Expense = {
  id : RecordId,
  budgetId: RecordId,
  budgetName: String,
  createdByName: String,
  amount : Float,
  comment : String,
  createdAt : Date,
  clicked : Bool
}

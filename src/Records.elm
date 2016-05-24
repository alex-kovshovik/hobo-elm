module Records exposing(..)

import Date exposing(Date)

type alias RecordId = Int
type alias BudgetId = RecordId

type alias HoboAuth = {
  apiBaseUrl: String,
  email: String,
  token: String
}

type alias User = {
  email: String,
  token: String,
  authenticated: Bool,
  apiBaseUrl: String,
  weekFraction: Float, -- Fraction of week that's passed so far
  currency: String
}

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

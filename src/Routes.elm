module Routes exposing (..)

import String
import Navigation
import UrlParser exposing (..)

import Expenses.Types exposing (ExpenseId)
-- import Budgets.Types exposing (BudgetId)

type Route
    = ExpensesRoute
    | ExpenseRoute ExpenseId
    | BudgetsRoute
    -- | BudgetRoute BudgetId
    | NotFoundRoute


matchers : Parser (Route -> a) a
matchers =
  oneOf [
    format ExpenseRoute (s "expenses" </> int),
    format ExpensesRoute (s "expenses"),
    -- format BudgetRoute (s "budgets" </> int),
    -- format BudgetsRoute (s "budgets"),
    format ExpensesRoute (s "")
  ]


hashParser : Navigation.Location -> Result String Route
hashParser location =
  location.hash
    |> String.dropLeft 1
    |> parse identity matchers


parser : Navigation.Parser (Result String Route)
parser =
  Navigation.makeParser hashParser


routeFromResult : Result String Route -> Route
routeFromResult result =
  case result of
    Ok route -> route
    Err string -> NotFoundRoute

module Routes exposing (..)

import String
import Navigation exposing (Location)
import UrlParser exposing (..)
import Expenses.List.Types exposing (ExpenseId)


type Route
    = ExpensesRoute
    | ExpenseRoute ExpenseId
    | BudgetsRoute
    | NotFoundRoute


matchers : Parser (Route -> a) a
matchers =
    oneOf
        [ map ExpensesRoute top
        , map ExpenseRoute (s "expenses" </> int)
        , map ExpensesRoute (s "expenses")
        , map BudgetsRoute (s "budgets")
        ]


parseLocation : Location -> Route
parseLocation location =
    case (parseHash matchers location) of
        Just route ->
            route

        Nothing ->
            NotFoundRoute

module App.View exposing (root)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)


-- import Html.App as Html exposing (map)

import App.Types exposing (..)
import Expenses.Edit.View
import Expenses.List.View
import BudgetEditor.View
import Routes exposing (..)


root : Model -> Html Msg
root model =
    div [ class "container-full mt1" ]
        [ header model
        , pages model
        ]


header : Model -> Html Msg
header model =
    div [ class "clear mb1" ]
        [ div [ class "col-6" ]
            [ text ("Welcome " ++ model.user.email)
            ]
        , div [ class "col-6 tar" ]
            [ a [ onClick EditBudgets ] [ text "Budgets" ]
            , text " | "
            , a [ onClick Logout ] [ text "Logout" ]
            ]
        ]


pages : Model -> Html Msg
pages model =
    case model.route of
        ExpensesRoute ->
            Html.map List (Expenses.List.View.root model.user model.data)

        ExpenseRoute expenseId ->
            Html.map Edit (Expenses.Edit.View.root model.user model.editData)

        BudgetsRoute ->
            Html.map BudgetEditor (BudgetEditor.View.root model.user model.data.buttons)

        -- BudgetRoute budgetId ->
        --   text "One budget route"
        --
        NotFoundRoute ->
            text "404 Not Found"

module App.Types exposing (..)

import Http
import HttpBuilder exposing (..)
import Navigation exposing (Location)
import Routes exposing (Route)
import Types exposing (..)
import Expenses.List.Types as Expenses
import Expenses.Edit.Types as Expense
import BudgetEditor.Types


type alias CheckData =
    ( Float, String )


type alias Model =
    { data : Expenses.Model
    , editData : Expense.Model
    , user : User
    , route : Route
    }


type Msg
    = OnLocationChange Location
    | List Expenses.Msg
    | Edit Expense.Msg
    | BudgetEditor BudgetEditor.Types.Msg
    | UserCheckOk CheckData
    | UserCheckFail Http.Error
    | EditBudgets
    | Logout

module BudgetEditor.View exposing (root)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Types exposing (..)
import Budgets.Types exposing (Model, Budget)
import BudgetEditor.Types exposing (..)


root : User -> Model -> Html Msg
root user model =
    div [ class "col-12" ]
        [ div []
            [ h1 [] [ text "Budgets" ]
            , manyBudgets model.budgets
            , a [ onClick AddMore ] [ text "Add more" ]
            ]
        , div []
            [ br [] []
            , br [] []
            , button [ class "button", onClick Save ] [ text "Save" ]
            , button [ class "button", onClick Cancel ] [ text "Cancel" ]
            ]
        ]


tableHeader : Html Msg
tableHeader =
    tr []
        [ th [] [ text "Id" ]
        , th [] [ text "Name" ]
        , th [] [ text "Amount" ]
        , th [] []
        ]


manyBudgets : List Budget -> Html Msg
manyBudgets budgets =
    table [] (tableHeader :: (List.map oneBudget budgets))


oneBudget : Budget -> Html Msg
oneBudget budget =
    tr []
        [ td []
            [ div [ class "field-group" ]
                [ if budget.id < 0 then
                    text ""
                  else
                    budget.id |> toString |> text
                ]
            ]
        , td []
            [ div [ class "field-group" ]
                [ input
                    [ type_ "text"
                    , onInput (InputName budget.id)
                    , class "field"
                    , value budget.name
                    ]
                    []
                ]
            ]
        , td []
            [ div [ class "field-group" ]
                [ input
                    [ type_ "number"
                    , onInput (InputAmount budget.id)
                    , class "field"
                    , value (budget.amount |> toString)
                    ]
                    []
                ]
            ]
        , td []
            [ a [ onClick (Delete budget.id) ] [ text "Delete!" ]
            ]
        ]

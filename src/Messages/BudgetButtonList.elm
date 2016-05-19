module Messages.BudgetButtonList exposing(..)

import Http
import Records exposing(Budget, BudgetId)

type Msg
  = Toggle BudgetId
  | Request
  | DisplayLoaded (Result Http.Error (List Budget))

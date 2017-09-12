module Types exposing (..)

type alias RecordId = Int

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
  monthFraction: Float, -- Fraction of month that's passed so far
  currency: String
}

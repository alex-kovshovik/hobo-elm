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
  weekFraction: Float, -- Fraction of week that's passed so far
  currency: String
}

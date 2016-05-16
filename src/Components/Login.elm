module Components.Login exposing(..)

type alias User = {
  email: String,
  token: String,
  authenticated: Bool,
  apiBaseUrl: String
}

module Components.Login where

type alias User = {
  email: String,
  token: String,
  authenticated: Bool,
  apiBaseUrl: String
}

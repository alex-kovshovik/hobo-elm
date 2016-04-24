// pull in desired CSS/SASS files
require('./styles/base.css')
require('./styles/hobo.css')
require('font-awesome-webpack')

// { email: '', token: '', authenticated: false }
const hoboAuthKey = 'hobo-auth'
let hoboAuth = null

loadAuth()

const Elm = require('./Main')
const elmApp = Elm.embed(Elm.Main, document.getElementById('main'), { getAuth: hoboAuth })

function loadAuth () {
  const storedAuth = window.localStorage.getItem(hoboAuthKey)
  hoboAuth = storedAuth ? JSON.parse(storedAuth) : null // Global variable is intentional
}

elmApp.ports.setAuth.subscribe(function (auth) {
  // Only store the authentication if different
  if (hoboAuth.authenticated !== auth.authenticated) {
    console.log('Storing new hoboAuth: ', auth)

    const authJson = JSON.stringify(auth)
    window.localStorage.setItem(hoboAuthKey, authJson)
    hoboAuth = auth
  }
})

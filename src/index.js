// pull in desired CSS/SASS files
require('./styles/base.css')
require('./styles/hobo.css')
require('font-awesome-webpack')

const Elm = require('./Main')

const hoboAuthKey = 'hobo-auth'

class HoboJs {
  constructor () {
    const elmApp = Elm.embed(Elm.Main, document.getElementById('main'), { getAuth: this.getAuth() })

    this.setupElmPorts(elmApp)
  }

  getAuth () {
    const storedAuth = window.localStorage.getItem(hoboAuthKey)
    return storedAuth ? JSON.parse(storedAuth) : null
  }

  setAuth (hoboAuth) {
    const oldAuth = this.getAuth()

    // Only store the authentication if different
    if (oldAuth === null || oldAuth.authenticated !== hoboAuth.authenticated) {
      const authJson = JSON.stringify(hoboAuth)
      window.localStorage.setItem(hoboAuthKey, authJson)

      this.hoboAuth = hoboAuth
    }
  }

  setupElmPorts (elmApp, hoboAuth) {
    elmApp.ports.setAuth.subscribe(auth => this.setAuth(auth))
  }
}

const hobo = new HoboJs()

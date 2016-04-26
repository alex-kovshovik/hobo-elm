// pull in desired CSS/SASS files
require('./styles/base.css')
require('./styles/hobo.css')
require('font-awesome-webpack')

const Elm = require('./Main')

const hoboAuthKey = 'hobo-auth'

class HoboJs {
  constructor () {
    let hoboAuth = this.getAuth()

    if (!hoboAuth.authenticated) {
      this.showFacebookLogin()
    }

    this.elmApp = Elm.embed(Elm.Main, document.getElementById('main'), { loginSuccess: hoboAuth })

    if (hoboAuth.authenticated) {
      this.elmApp.ports.loginSuccess.send(hoboAuth)
    }
  }

  getAuth () {
    const storedAuth = window.localStorage.getItem(hoboAuthKey)
    return storedAuth ? JSON.parse(storedAuth) : this.getDefaultAuth()
  }

  getDefaultAuth () {
    return { email: '', token: '', authenticated: false }
  }

  setAuth (hoboAuth) {
    const oldAuth = this.getAuth()

    // Only store the authentication if different
    if (oldAuth.authenticated !== hoboAuth.authenticated) {
      const authJson = JSON.stringify(hoboAuth)
      window.localStorage.setItem(hoboAuthKey, authJson)

      this.hoboAuth = hoboAuth
    }
  }

  showFacebookLogin () {
    document.getElementById('main').style.display = 'none'
    document.getElementById('fblogin').style.display = 'block';

    (function (d, s, id) {
      var js, fjs = d.getElementsByTagName(s)[0]
      if (d.getElementById(id)) return
      js = d.createElement(s); js.id = id
      js.src = '//connect.facebook.net/en_US/sdk.js'
      fjs.parentNode.insertBefore(js, fjs)
    }(document, 'script', 'facebook-jssdk'))
  }

  hideFacebookLogin () {
    document.getElementById('main').style.display = 'block'
    document.getElementById('fblogin').style.display = 'none';
  }

  handleFacebookResponse (fbResponse) {
    $.post('http://localhost:3000/auth/register', fbResponse, this.handleRegisterResponse.bind(this)).fail(function (data) {
      alert('Error registering user account')
    })
  }

  handleRegisterResponse (authData) {
    const auth = this.getAuth()

    auth.email = authData.email
    auth.token = authData.token
    auth.authenticated = true
    this.setAuth(auth)

    this.elmApp.ports.loginSuccess.send(auth)
    this.hideFacebookLogin()
  }

  statusChangeCallback (response) {
    if (response.status === 'connected') {
      FB.api('/me?fields=name,email', this.handleFacebookResponse.bind(this))
    } else if (response.status === 'not_authorized') {
      alert('Facebook login is not authorized')
    } else {
      alert('Unknown Facebook login status')
    }
  }
}

window.hobo = new HoboJs()

// This function is called when someone finishes with the Login
// Button.  See the onlogin handler attached to it in the sample
// code below.
window.checkLoginState = function () {
  FB.getLoginStatus(window.hobo.statusChangeCallback.bind(window.hobo))
}

window.fbAsyncInit = function () {
  FB.init({
    appId: '1752657608283631',
    cookie: true,  // enable cookies to allow the server to access
                        // the session
    xfbml: true,  // parse social plugins on this page
    version: 'v2.5' // use graph api version 2.5
  })
}

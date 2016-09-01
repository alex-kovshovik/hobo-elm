// pull in desired CSS/SASS files
require('./styles/styles.css')
require('./styles/hobo.scss')
require('font-awesome-webpack')

const Elm = require('./src/Main')

const hoboAuthKey = 'hobo-auth'
const fbAppId = location.hostname === 'localhost' ? '1766948786854513' : '1752657608283631'

class HoboJs {
  constructor () {
    let hoboAuth = this.getAuth()

    if (hoboAuth.authenticated) {
      this.embedElmApp(hoboAuth)
    } else {
      this.showFacebookLogin()
    }

    // FUCK YOU APPLE!
    // This interval only exists because of you, motherfuckers!
    // Your goddamn mobile safari browser refuses to act on JavaScript's "focus"
    // calls, unless they are caused by touch event.
    setInterval(function() {
      const $amount = $('#amount')
      const $amountInput = $('#amount-input')

      if ($amount.length > 0 && $amountInput.length > 0) {
        $amount.off('click')
        $amountInput.off('touchstart')

        $amount.on('click', function () {
          $amountInput.trigger('touchstart')
        })

        $amountInput.on('touchstart', function () {
          $(this).focus()
        })
      }
    }, 100);
  }

  embedElmApp (auth) {
    const elmApp = Elm.Main.embed(document.getElementById('main'), auth)

    elmApp.ports.logout.subscribe(function(message) {
      window.localStorage.clear()
      window.location.reload()
    })
  }

  getAuth () {
    const storedAuth = window.localStorage.getItem(hoboAuthKey)
    const auth = storedAuth ? JSON.parse(storedAuth) : this.getDefaultAuth()

    if (!auth.apiBaseUrl) {
      auth.apiBaseUrl = this.getHoboApiUrl()
    }

    return auth
  }

  getDefaultAuth () {
    return { email: '', token: '', authenticated: false, apiBaseUrl: this.getHoboApiUrl() }
  }

  getHoboApiUrl() {
    let location = window.location;

    if (location.hostname === 'localhost') {
      // Assume default Rails port 3000, running on localhost.
      return 'http://localhost:3000/'
    } else {
      // Assume http(s)://api.<hostname>
      return location.protocol + '//' + 'api.' + location.hostname + '/'
    }
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
    fbResponse.facebookAccessToken = this.facebookAccessToken // Mutation, but fuck it, my main app is in Elm LOL!
    const apiBaseUrl = this.getHoboApiUrl()

    $.post(apiBaseUrl + 'auth/register', fbResponse, this.handleRegisterResponse.bind(this)).fail(function (data) {
      alert('Error registering user account')
    })
  }

  handleRegisterResponse (authData) {
    const auth = this.getAuth()

    auth.email = authData.user.email
    auth.token = authData.user.api_key
    auth.authenticated = true

    this.setAuth(auth)
    this.embedElmApp(auth)
    this.hideFacebookLogin()
  }

  statusChangeCallback (response) {
    if (response.status === 'connected') {
      this.facebookAccessToken = response.authResponse.accessToken // Another mutation and also fuck it - see above LOL!

      FB.api('/me?fields=name,email,currency,timezone', this.handleFacebookResponse.bind(this))
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
    appId: fbAppId,
    cookie: true,  // enable cookies to allow the server to access the session
    xfbml: true,  // parse social plugins on this page
    version: 'v2.5' // use graph api version 2.5
  })
}

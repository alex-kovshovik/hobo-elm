// pull in desired CSS/SASS files
require( './styles/base.css' );
require( './styles/hobo.css' );

var Elm = require( './Main' );
Elm.embed( Elm.Main, document.getElementById( 'main' ) );

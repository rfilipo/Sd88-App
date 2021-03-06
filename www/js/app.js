/**
    app.js
    
    Copyright 2017 Ricardo Filipo (Monsenhor) filipo@kobkob.org  

    This file is part of Sd88 App Framework.

    Sd88 App Framework is free software: you can redistribute it and/or modify
    it under the terms of the GNU Affero General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Sd88 App Framework is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Affero General Public License for more details.

    You should have received a copy of the GNU Affero General Public License
    along with Sd88 App Framework.  If not, see <http://www.gnu.org/licenses/>.

*/

console.log("Running app ... ");
/**
**
sd88 framework has 3 Worker states:

- OFF: Worker is not connected but it's working
- CON: Worker is connected via ws ( after sd88.wsInit() )
- AUT: Worker is authenticated for this auth key

*/
sd88.wsInit(function(e){
  console.log("Ws CON inited!!");
  /** Authenticate ... 
  if you don't know the mean of brungredrah, just ask me
  sd88.wsAuth(function (e){
     if (e.error) { 
       alert (e.error);
       //sd88.docCookies.setItem("sd88_auth", "Brungredrah!!!");
       window.location.reload();
     } else {
       sd88.docCookies.setItem("sd88_auth", e.auth);
       console.log(sd88.docCookies.getItem("sd88_auth"));
     }
  });
  */
});
/////////////////////////////////////
console.log("Load menus ... ");
sd88.menu("public", function( menu ){
  console.log("The menu: ", menu);
  // do something with the menu
});
/////////////////////////////////////
//console.log("Reformat screen ... ");
//sd88.reformat();
////////////////////////////////
/////////////////////////////////////
//console.log("Do app stuff ... ");
///////////////////////////////
// app code here
console.log ("sd88:",sd88);
///////////////////////////////


/**
    framework.js
    
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

console.log("Loading sd88 framework ...");
var sd88 = {};
sd88.auth = function () {
  var self = this;
  this.loadJSON( "api/auth", function (resp){
     self.authData = JSON.parse(resp);
  });
}
sd88.menu = function () {
  var self = this;
  this.loadJSON( "api/menu", function (resp){
     self.menuData = JSON.parse(resp);
  });
}
sd88.content = function (id) {
  var self = this;
  this.loadJSON( "api/content/"+id, function (resp){
     self.contentData = JSON.parse(resp);
  });
}
sd88.reformat = function () {
console.log("Implement me!!!");
}

sd88.loadJSON = function (path, callback) {   
    if (!path) path = "/";
    var xobj = new XMLHttpRequest();
    xobj.overrideMimeType("application/json");
    xobj.open('GET', path, true);
    xobj.onreadystatechange = function () {
          if (xobj.readyState == 4 && xobj.status == "200") {
            callback(xobj.responseText);
          }
    };
    xobj.send(null);  
}

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

//console.log("Loading sd88 framework ...");
var sd88 = {"state":"OFF"};
// Events
sd88.ev = {};
sd88.ev.open = new Event('open');
sd88.ev.init = new Event('init');
sd88.ev.register = new Event('register');
sd88.ev.login = new Event('login');
sd88.ev.done = new Event('done');

/**
* @class EventTarget
* as in https://developer.mozilla.org/en-US/docs/Web/API/EventTarget
*/
var EventTarget = function() {
  this.listeners = {};
};

EventTarget.prototype.listeners = null;
EventTarget.prototype.addEventListener = function(type, callback) {
  if(!(type in this.listeners)) {
    this.listeners[type] = [];
  }
  this.listeners[type].push(callback);
};

EventTarget.prototype.removeEventListener = function(type, callback) {
  if(!(type in this.listeners)) {
    return;
  }
  var stack = this.listeners[type];
  for(var i = 0, l = stack.length; i < l; i++) {
    if(stack[i] === callback){
      stack.splice(i, 1);
      return this.removeEventListener(type, callback);
    }
  }
};

EventTarget.prototype.dispatchEvent = function(event, data) {
  if(!(event.type in this.listeners)) {
    return;
  }
  var stack = this.listeners[event.type];
  event.target = this;
  for(var i = 0, l = stack.length; i < l; i++) {
      stack[i].call(this, event, data);
  }
};
/* the framework events pool */
sd88.pool = new EventTarget();

// the websocket worker process
sd88.wsWorker = new Worker("/js/ws_worker.js");
sd88.wsInit = function (cb) {
  var self = this;
  // pool events to listen:
  sd88.pool.addEventListener('done', function (e, d) { 
      console.log("Sd88 Done!!!", e, d);
      if (d.data.error == "UNIQUE constraint failed: users.email") {
          var login = confirm("This email is still registered. Do you want to login stead?");
          if (login) {
              window.location.href = "/login";
          } else {
              document.querySelector( "#email").value = "";
          }
      }
      else if (d.data.error){
          alert("Error, please try again. "+d.data.error);
      } else {
          if (d.cmd == "register"){
              console.log(d.data);
              //sd88.auth(d.data);
             self.state = "AUT";
             sd88.docCookies.setItem("sd88_auth", d.data.auth_key);
          }
      }
  }, false);
  // messages from websockets worker
  self.wsWorker.onmessage = function(e){
    console.log('Message received from worker: ', e);
    //var data = JSON.parse(e.data);
    var data = e.data;
    if (data.msg == "WS Services opened!!!"){
         console.log("Opened comunication with Worker!");
         self.state = "OFF";
    } else if (data.msg == "WS Services inited!!!"){
         console.log("Worker received list of commands!");
         self.state = "CON";
         self.cmdws = data.cmd.data;
         self.generateSchema(self.cmdws);
         if (cb) cb(e);
    } else {
         console.log("Put Worker response on pool!");
         // put in pool
         sd88.pool.dispatchEvent(sd88.ev.done, data);
    }
  };
}
/**
generates all methods MVC abstracted from 
schema, a WSCommand::Tree structure
*/
sd88.generateSchema = function (cmds) {
  Object.keys(cmds).forEach(function (name) {
    /* Controller */
    sd88.createCmd(name, cmds[name]);
    /* View */
    sd88.createWidget(name, cmds[name]);
    /* Model */
    sd88.createData(name, cmds[name]);
  });
}
sd88.wsAuth = function (cb) {
  var self = this;
  var auth = sd88.docCookies.getItem("sd88_auth");
  if (auth == "Brungredrah!!!"){
    var e = {"auth":"Brungredrah!!!"};
    if (cb) cb(e);
    return 0;
  } else {
    self.contentWidget.load(self.template.login());
    var loginBtn = document.querySelector( "#login");
    var email    = document.querySelector( "#email");
    var password = document.querySelector( "#password");
    loginBtn.addEventListener("click", function (){
      console.log("Clicked!!!");
      self.wsWorker.postMessage({"msg":"Authenticate!!!","cmd":"auth","email":email.value,"password":password.value});
/*
      self.wsWorker.onmessage = function(e){
        console.log('Message about authentication: ', e);
        if (e.msg == "WS Auth!!!"){
             self.state = "AUT";
             sd88.docCookies.setItem("sd88_auth", e.auth);
             if (cb) cb(e);
        } else {
             if (cb) cb({"error":"WS can't authenticate!"});
        }
      };
*/
    });
  }
}
/* Controller */
sd88.createCmd = function (name, schema){
  var cmf = "sd88."+name+"=function(";
  if (schema.schema[0]){
    Object.keys(schema.schema[0].properties).forEach(function (name) {
      cmf += name+",";
    });
    //cmf = cmf.slice(0, -1);
    cmf += "cb";
  }
  cmf += "){";
  cmf += "var self=this;";
  //cmf += 'self.wsWorker.postMessage({type:"REQUEST","msg":"'+name+'!!!","cmd":"'+name+'",data:{id:"created"';
  cmf += 'self.wsWorker.postMessage({type:"REQUEST","msg":"'+name+'!!!","cmd":"'+name+'"';
  if (schema.schema[0]){
    Object.keys(schema.schema[0].properties).forEach(function (name) {
      cmf += ',"'+name+'":'+name;
    });
  }
  //cmf += '}});';
  cmf += '});';
  //cmf += 'self.wsWorker.onmessage = function(e){';
  //cmf += "if (cb) cb(e)};";
  cmf += "};";
  eval (cmf);
  //console.log("Schema "+name+":", schema);
  //console.log(cmf);

}
/* View */
sd88.createWidget = function (name, schema){
  var cmf = "sd88."+name+"Widget ={ load: function (";
  if (schema.schema[0]){
    Object.keys(schema.schema[0].properties).forEach(function (name) {
      cmf += name+",";
    });
    cmf = cmf.slice(0, -1);
  }
  cmf += "){}};";
  eval (cmf);
  //console.log("Schema "+name+":", schema);
  //console.log(cmf);
} 
/* Model */
sd88.createData= function (name, schema){
  if (schema.schema[0]){
    var cmf = "sd88."+name+"Data ={";
    Object.keys(schema.schema[0].properties).forEach(function (name) {
      cmf += name+":null,";
    });
    cmf = cmf.slice(0, -1);
    cmf += "};";
    eval (cmf);
  //console.log("Schema "+name+":", schema);
  //console.log(cmf);
  }
}

/*
*/
sd88.auth = function (data) {
  var self = this;
  this.loadJSON( "/api/auth", function (resp){
     self.authData = JSON.parse(resp);
  });
}
sd88.menuWidget = {};
sd88.menuWidget.load = function (menu){
  var menuEl = document.querySelector( "#menu");
  var menuHtml = '<div class="menu-content">';
  //console.log(menu);
  for (var key in menu) {
     menuHtml += '<div class="menu-field">';
     var menuItem = menu[key];
     for (var text in menuItem){
         menuHtml+= '<a href="'+menuItem[text]+'">'+text;
     }
     menuHtml += '</a></div>';
  }
  menuEl.innerHTML = menuHtml;
}
sd88.menu = function (id, cb) {
  var self = this;
  var url = "/api/menu/"+id;
  this.loadJSON( url, function (resp){
     self.menuData = JSON.parse(resp);
     self.menuWidget.load(self.menuData.menu);
     if (cb) cb(self.menuData.menu);
  });
}
sd88.contentWidget = {};
sd88.contentWidget.load = function (content){
  var contentEl = document.querySelector( "#content");
  var contentHtml = '<div class="main-content">';
  //console.log(content);
  contentHtml += content + '</a></div>';
  contentEl.innerHTML = contentHtml;
}

sd88.contentById = function (id, cb) {
  var self = this;
  this.loadJSON( "/api/content/"+id, function (resp){
     self.contentData = JSON.parse(resp);
     self.contentWidget.load(self.contentData.content);
     if (cb) cb(self.contentData.content);
  });
}
sd88.reformat = function () {
console.log("Implement me!!!");
}
//sd88.registerUser = function (email, password, cb) {
 // var self = this;
  //this.loadJSON( "/api/register/"+email+"/"+password, function (resp){
  //   self.userData = JSON.parse(resp);
  //   if (cb) cb(self.userData.content);
  //});
//}
/**
** basic JSON loader
*/
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

/*\
|*|
|*|  :: cookies.js ::
|*|
|*|  A complete cookies reader/writer framework with full unicode support.
|*|
|*|  Revision #1 - September 4, 2014
|*|
|*|  https://developer.mozilla.org/en-US/docs/Web/API/document.cookie
|*|  https://developer.mozilla.org/User:fusionchess
|*|  https://github.com/madmurphy/cookies.js
|*|
|*|  This framework is released under the GNU Public License, version 3 or later.
|*|  http://www.gnu.org/licenses/gpl-3.0-standalone.html
|*|
|*|  Syntaxes:
|*|
|*|  * docCookies.setItem(name, value[, end[, path[, domain[, secure]]]])
|*|  * docCookies.getItem(name)
|*|  * docCookies.removeItem(name[, path[, domain]])
|*|  * docCookies.hasItem(name)
|*|  * docCookies.keys()
|*|
\*/

sd88.docCookies = {
  getItem: function (sKey) {
    if (!sKey) { return null; }
    return decodeURIComponent(document.cookie.replace(new RegExp("(?:(?:^|.*;)\\s*" + encodeURIComponent(sKey).replace(/[\-\.\+\*]/g, "\\$&") + "\\s*\\=\\s*([^;]*).*$)|^.*$"), "$1")) || null;
  },
  setItem: function (sKey, sValue, vEnd, sPath, sDomain, bSecure) {
    if (!sKey || /^(?:expires|max\-age|path|domain|secure)$/i.test(sKey)) { return false; }
    var sExpires = "";
    if (vEnd) {
      switch (vEnd.constructor) {
        case Number:
          sExpires = vEnd === Infinity ? "; expires=Fri, 31 Dec 9999 23:59:59 GMT" : "; max-age=" + vEnd;
          break;
        case String:
          sExpires = "; expires=" + vEnd;
          break;
        case Date:
          sExpires = "; expires=" + vEnd.toUTCString();
          break;
      }
    }
    document.cookie = encodeURIComponent(sKey) + "=" + encodeURIComponent(sValue) + sExpires + (sDomain ? "; domain=" + sDomain : "") + (sPath ? "; path=" + sPath : "") + (bSecure ? "; secure" : "");
    return true;
  },
  removeItem: function (sKey, sPath, sDomain) {
    if (!this.hasItem(sKey)) { return false; }
    document.cookie = encodeURIComponent(sKey) + "=; expires=Thu, 01 Jan 1970 00:00:00 GMT" + (sDomain ? "; domain=" + sDomain : "") + (sPath ? "; path=" + sPath : "");
    return true;
  },
  hasItem: function (sKey) {
    if (!sKey) { return false; }
    return (new RegExp("(?:^|;\\s*)" + encodeURIComponent(sKey).replace(/[\-\.\+\*]/g, "\\$&") + "\\s*\\=")).test(document.cookie);
  },
  keys: function () {
    var aKeys = document.cookie.replace(/((?:^|\s*;)[^\=]+)(?=;|$)|^\s*|\s*(?:\=[^;]*)?(?:\1|$)/g, "").split(/\s*(?:\=[^;]*)?;\s*/);
    for (var nLen = aKeys.length, nIdx = 0; nIdx < nLen; nIdx++) { aKeys[nIdx] = decodeURIComponent(aKeys[nIdx]); }
    return aKeys;
  }
};
///////////////////////////////////////////////////////////////////
// Templates:
sd88.template = {};
sd88.template.login = function (params) {
  var html = '<div class="section" id="login-section">';
  html += '<h1>Login</h1>';
  html += '<div><label for="email">E-mail:</label><input id="email"></div>';
  html += '<div><label for="password">Password: </label><input id="password" type="password"></div>';
  html += '<button id="login">Login</button>';
  html += '</div>';
  return html;
}

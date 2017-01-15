/**
    ws_worker.js
    
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

// the global var wsurl will be used to contruct the CommandWS helper  
var wsurl = "ws://127.0.0.1:3000/ws";
importScripts('ws_commands.js');
//console.log("Begin Worker with ", WS);
WS.cmd.on("command", function(data) {
  //TODO: eliminate that stupid try catch ... :\
  // it comes from mojo modules under WSCommands/*.pm or from schems
  var d, cmd, dat;
  try {
    d = JSON.parse(data.msg);
  } catch (e) {
    d = data.msg;
    //console.warn("Error processing json", e, data.msg);
  }
  cmd = d.cmd;
  dat= d.data;
  try {
    dat = JSON.parse(data.msg.data);
  } catch (e) {
    dat = data.msg.data;
    //console.warn("Error processing json", e, data.msg);
  }
 
  if (cmd == "list_commands") {
    //console.log("Listing commands from WS:", dat);
    postMessage({ "msg":"WS Services inited!!!", "cmd": data.msg });
  } else postMessage({ "msg":"Response from WS!!!", "cmd": cmd, "data": dat });
});
// The box is a silly stuff the Worker uses to process commands
WS.box = { working: false, opt: []}; // will be working when WS.cmd is open
WS.box.click = function(sel, command, data) {
	var response;
	var jsonData, invalidJson = false;
        data.api_key = "123";
        data.auth_key = "456";
	try { 
           //jsonData = JSON.parse(data); 
           jsonData = data; 
        } 
        catch(e){ if(data != "") invalidJson = e.message; };
        //console.log("Box Command: ", sel, command, jsonData);
        if(WS.cmd.cmd[command]){ 
	    var trans_id = WS.cmd.cmd[command](jsonData, function(resp) {
		if (resp.error) response = JSON.stringify(resp.error);
		else            response = JSON.stringify(resp);
	        //postMessage({"cmd":response, "msg":"Boxed response from WS!!!"});
                //return 0;
                console.log ("Box received: ", response);
	    });
        // something is wrong ... :P
        } else { 
            response = JSON.stringify({"cmd":"error","msg":"WSCommand does not understand command "+command}) 
            console.log ("Box errors: ", response);
        }
        return 1;
};

WS.cmd.once("open", function() {
  postMessage({"msg":"WS Services opened!!!"});
  // fill box with commands
  var box = WS.box;
  box.working = true;
  Object.keys(WS.cmd.cmd).sort().forEach(function(cmd) {
    var opt = {};
    opt.text	= cmd;
    opt.value	= cmd;
    box.opt.push(opt);
  });
});

onmessage = function(e) {
  //console.log('Message received from main script', e);
  var cmd = e.data.cmd;
  //var data= JSON.stringify(e.data);
  var data= e.data;
/*
  if (cmd == "list_commands") {
    console.log("Listing commands from WS:", data);
    postMessage({"msg":"WS Services inited!!!", "data":data});
  }
*/
  //console.log('Going to process', cmd, data);
  if (WS.box.working) { WS.box.click("BOX!",cmd,data); } 
}


package com.iflashigame.controller
{
   import flash.display.DisplayObjectContainer;
   import flash.system.ApplicationDomain;
   
   public interface IController
   {
       
      
      function setRoot(param1:DisplayObjectContainer, param2:String, param3:ApplicationDomain = null) : *;
      
      function get requestCode() : String;
      
      function set requestCode(param1:String) : *;
      
      function get responseCode() : String;
      
      function set responseCode(param1:String) : *;
      
      function get serverURL() : String;
      
      function set serverURL(param1:String) : *;
      
      function get debug() : Boolean;
      
      function set debug(param1:Boolean) : void;
      
      function get test() : Boolean;
      
      function set test(param1:Boolean) : void;
      
      function sendJSON(param1:Object, param2:Function, param3:String = null) : String;
      
      function sendJSONToURL(param1:Object, param2:String = "") : String;
      
      function set testInstance(param1:IControllerTest) : void;
      
      function get testInstance() : IControllerTest;
      
      function get disable() : Boolean;
      
      function set disable(param1:Boolean) : void;
      
      function close(param1:String) : *;
      
      function addEventListener(param1:String, param2:Function, param3:Boolean = true, param4:int = 0, param5:Boolean = true) : void;
      
      function removeEventListener(param1:String, param2:Function, param3:Boolean = true) : void;
   }
}

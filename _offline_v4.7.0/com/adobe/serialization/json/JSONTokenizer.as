package com.adobe.serialization.json
{
   public class JSONTokenizer
   {
       
      
      private var obj:Object;
      
      private var jsonString:String;
      
      private var loc:int;
      
      private var ch:String;
      
      public function JSONTokenizer(param1:String)
      {
         super();
         this.jsonString = param1;
         this.loc = 0;
         this.nextChar();
      }
      
      public function getNextToken() : JSONToken
      {
         var _loc1_:String = null;
         var _loc2_:String = null;
         var _loc3_:String = null;
         var _loc4_:JSONToken = new JSONToken();
         this.skipIgnored();
         switch(this.ch)
         {
            case "{":
               _loc4_.type = JSONTokenType.LEFT_BRACE;
               _loc4_.value = "{";
               this.nextChar();
               break;
            case "}":
               _loc4_.type = JSONTokenType.RIGHT_BRACE;
               _loc4_.value = "}";
               this.nextChar();
               break;
            case "[":
               _loc4_.type = JSONTokenType.LEFT_BRACKET;
               _loc4_.value = "[";
               this.nextChar();
               break;
            case "]":
               _loc4_.type = JSONTokenType.RIGHT_BRACKET;
               _loc4_.value = "]";
               this.nextChar();
               break;
            case ",":
               _loc4_.type = JSONTokenType.COMMA;
               _loc4_.value = ",";
               this.nextChar();
               break;
            case ":":
               _loc4_.type = JSONTokenType.COLON;
               _loc4_.value = ":";
               this.nextChar();
               break;
            case "t":
               _loc1_ = "t" + this.nextChar() + this.nextChar() + this.nextChar();
               if(_loc1_ == "true")
               {
                  _loc4_.type = JSONTokenType.TRUE;
                  _loc4_.value = true;
                  this.nextChar();
               }
               else
               {
                  this.parseError("Expecting \'true\' but found " + _loc1_);
               }
               break;
            case "f":
               _loc2_ = "f" + this.nextChar() + this.nextChar() + this.nextChar() + this.nextChar();
               if(_loc2_ == "false")
               {
                  _loc4_.type = JSONTokenType.FALSE;
                  _loc4_.value = false;
                  this.nextChar();
               }
               else
               {
                  this.parseError("Expecting \'false\' but found " + _loc2_);
               }
               break;
            case "n":
               _loc3_ = "n" + this.nextChar() + this.nextChar() + this.nextChar();
               if(_loc3_ == "null")
               {
                  _loc4_.type = JSONTokenType.NULL;
                  _loc4_.value = null;
                  this.nextChar();
               }
               else
               {
                  this.parseError("Expecting \'null\' but found " + _loc3_);
               }
               break;
            case "\"":
               _loc4_ = this.readString();
               break;
            default:
               if(this.isDigit(this.ch) || this.ch == "-")
               {
                  _loc4_ = this.readNumber();
               }
               else
               {
                  if(this.ch == "")
                  {
                     return null;
                  }
                  this.parseError("Unexpected " + this.ch + " encountered");
               }
         }
         return _loc4_;
      }
      
      private function readString() : JSONToken
      {
         var _loc1_:String = null;
         var _loc2_:int = 0;
         var _loc3_:JSONToken = new JSONToken();
         _loc3_.type = JSONTokenType.STRING;
         var _loc4_:* = "";
         this.nextChar();
         while(this.ch != "\"" && this.ch != "")
         {
            if(this.ch == "\\")
            {
               this.nextChar();
               switch(this.ch)
               {
                  case "\"":
                     _loc4_ += "\"";
                     break;
                  case "/":
                     _loc4_ += "/";
                     break;
                  case "\\":
                     _loc4_ += "\\";
                     break;
                  case "b":
                     _loc4_ += "\b";
                     break;
                  case "f":
                     _loc4_ += "\f";
                     break;
                  case "n":
                     _loc4_ += "\n";
                     break;
                  case "r":
                     _loc4_ += "\r";
                     break;
                  case "t":
                     _loc4_ += "\t";
                     break;
                  case "u":
                     _loc1_ = "";
                     _loc2_ = 0;
                     while(_loc2_ < 4)
                     {
                        if(!this.isHexDigit(this.nextChar()))
                        {
                           this.parseError(" Excepted a hex digit, but found: " + this.ch);
                        }
                        _loc1_ += this.ch;
                        _loc2_++;
                     }
                     _loc4_ += String.fromCharCode(parseInt(_loc1_,16));
                     break;
                  default:
                     _loc4_ += "\\" + this.ch;
               }
            }
            else
            {
               _loc4_ += this.ch;
            }
            this.nextChar();
         }
         if(this.ch == "")
         {
            this.parseError("Unterminated string literal");
         }
         this.nextChar();
         _loc3_.value = _loc4_;
         return _loc3_;
      }
      
      private function readNumber() : JSONToken
      {
         var _loc1_:JSONToken = new JSONToken();
         _loc1_.type = JSONTokenType.NUMBER;
         var _loc2_:* = "";
         if(this.ch == "-")
         {
            _loc2_ += "-";
            this.nextChar();
         }
         if(!this.isDigit(this.ch))
         {
            this.parseError("Expecting a digit");
         }
         if(this.ch == "0")
         {
            _loc2_ += this.ch;
            this.nextChar();
            if(this.isDigit(this.ch))
            {
               this.parseError("A digit cannot immediately follow 0");
            }
         }
         else
         {
            while(this.isDigit(this.ch))
            {
               _loc2_ += this.ch;
               this.nextChar();
            }
         }
         if(this.ch == ".")
         {
            _loc2_ += ".";
            this.nextChar();
            if(!this.isDigit(this.ch))
            {
               this.parseError("Expecting a digit");
            }
            while(this.isDigit(this.ch))
            {
               _loc2_ += this.ch;
               this.nextChar();
            }
         }
         if(this.ch == "e" || this.ch == "E")
         {
            _loc2_ += "e";
            this.nextChar();
            if(this.ch == "+" || this.ch == "-")
            {
               _loc2_ += this.ch;
               this.nextChar();
            }
            if(!this.isDigit(this.ch))
            {
               this.parseError("Scientific notation number needs exponent value");
            }
            while(this.isDigit(this.ch))
            {
               _loc2_ += this.ch;
               this.nextChar();
            }
         }
         var _loc3_:Number = Number(_loc2_);
         if(isFinite(_loc3_) && !isNaN(_loc3_))
         {
            _loc1_.value = _loc3_;
            return _loc1_;
         }
         this.parseError("Number " + _loc3_ + " is not valid!");
         return null;
      }
      
      private function nextChar() : String
      {
         return this.ch = this.jsonString.charAt(this.loc++);
      }
      
      private function skipIgnored() : void
      {
         var _loc1_:int = 0;
         do
         {
            _loc1_ = this.loc;
            this.skipWhite();
            this.skipComments();
         }
         while(_loc1_ != this.loc);
         
      }
      
      private function skipComments() : void
      {
         if(this.ch == "/")
         {
            this.nextChar();
            switch(this.ch)
            {
               case "/":
                  do
                  {
                     this.nextChar();
                  }
                  while(this.ch != "\n" && this.ch != "");
                  
                  this.nextChar();
                  break;
               case "*":
                  this.nextChar();
                  while(true)
                  {
                     if(this.ch == "*")
                     {
                        this.nextChar();
                        if(this.ch == "/")
                        {
                           break;
                        }
                     }
                     else
                     {
                        this.nextChar();
                     }
                     if(this.ch == "")
                     {
                        this.parseError("Multi-line comment not closed");
                     }
                  }
                  this.nextChar();
                  break;
               default:
                  this.parseError("Unexpected " + this.ch + " encountered (expecting \'/\' or \'*\' )");
            }
         }
      }
      
      private function skipWhite() : void
      {
         while(this.isWhiteSpace(this.ch))
         {
            this.nextChar();
         }
      }
      
      private function isWhiteSpace(param1:String) : Boolean
      {
         return param1 == " " || param1 == "\t" || param1 == "\n" || param1 == "\r";
      }
      
      private function isDigit(param1:String) : Boolean
      {
         return param1 >= "0" && param1 <= "9";
      }
      
      private function isHexDigit(param1:String) : Boolean
      {
         var _loc2_:String = param1.toUpperCase();
         return this.isDigit(param1) || _loc2_ >= "A" && _loc2_ <= "F";
      }
      
      public function parseError(param1:String) : void
      {
         throw new JSONParseError(param1,this.loc,this.jsonString);
      }
   }
}

package fl.managers
{
   import fl.core.UIComponent;
   import flash.text.TextFormat;
   import flash.utils.Dictionary;
   import flash.utils.getDefinitionByName;
   import flash.utils.getQualifiedClassName;
   import flash.utils.getQualifiedSuperclassName;
   
   public class StyleManager
   {
      
      private static var _instance:StyleManager;
       
      
      private var styleToClassesHash:Object;
      
      private var classToInstancesDict:Dictionary;
      
      private var classToStylesDict:Dictionary;
      
      private var classToDefaultStylesDict:Dictionary;
      
      private var globalStyles:Object;
      
      public function StyleManager()
      {
         super();
         this.styleToClassesHash = {};
         this.classToInstancesDict = new Dictionary(true);
         this.classToStylesDict = new Dictionary(true);
         this.classToDefaultStylesDict = new Dictionary(true);
         this.globalStyles = UIComponent.getStyleDefinition();
      }
      
      private static function getInstance() : *
      {
         if(_instance == null)
         {
            _instance = new StyleManager();
         }
         return _instance;
      }
      
      public static function registerInstance(param1:UIComponent) : void
      {
         var target:Class = null;
         target = null;
         var defaultStyles:Object = null;
         var styleToClasses:Object = null;
         var n:String = null;
         var instance:UIComponent = param1;
         var inst:StyleManager = getInstance();
         var classDef:Class = getClassDef(instance);
         if(classDef == null)
         {
            return;
         }
         if(inst.classToInstancesDict[classDef] == null)
         {
            inst.classToInstancesDict[classDef] = new Dictionary(true);
            target = classDef;
            while(defaultStyles == null)
            {
               if(target["getStyleDefinition"] != null)
               {
                  defaultStyles = target["getStyleDefinition"]();
                  break;
               }
               try
               {
                  target = instance.loaderInfo.applicationDomain.getDefinition(getQualifiedSuperclassName(target)) as Class;
               }
               catch(err:Error)
               {
                  try
                  {
                     target = getDefinitionByName(getQualifiedSuperclassName(target)) as Class;
                  }
                  catch(e:Error)
                  {
                     defaultStyles = UIComponent.getStyleDefinition();
                     break;
                  }
               }
            }
            styleToClasses = inst.styleToClassesHash;
            for(n in defaultStyles)
            {
               if(styleToClasses[n] == null)
               {
                  styleToClasses[n] = new Dictionary(true);
               }
               styleToClasses[n][classDef] = true;
            }
            inst.classToDefaultStylesDict[classDef] = defaultStyles;
            if(inst.classToStylesDict[classDef] == null)
            {
               inst.classToStylesDict[classDef] = {};
            }
         }
         inst.classToInstancesDict[classDef][instance] = true;
         setSharedStyles(instance);
      }
      
      private static function setSharedStyles(param1:UIComponent) : void
      {
         var _loc2_:String = null;
         var _loc3_:StyleManager = getInstance();
         var _loc4_:Class = getClassDef(param1);
         var _loc5_:Object = _loc3_.classToDefaultStylesDict[_loc4_];
         for(_loc2_ in _loc5_)
         {
            param1.setSharedStyle(_loc2_,getSharedStyle(param1,_loc2_));
         }
      }
      
      private static function getSharedStyle(param1:UIComponent, param2:String) : Object
      {
         var _loc3_:Class = getClassDef(param1);
         var _loc5_:Object;
         var _loc4_:StyleManager;
         if((_loc5_ = (_loc4_ = getInstance()).classToStylesDict[_loc3_][param2]) != null)
         {
            return _loc5_;
         }
         if((_loc5_ = _loc4_.globalStyles[param2]) != null)
         {
            return _loc5_;
         }
         return _loc4_.classToDefaultStylesDict[_loc3_][param2];
      }
      
      public static function getComponentStyle(param1:Object, param2:String) : Object
      {
         var _loc3_:Class = getClassDef(param1);
         var _loc4_:Object;
         return (_loc4_ = getInstance().classToStylesDict[_loc3_]) == null ? null : _loc4_[param2];
      }
      
      public static function clearComponentStyle(param1:Object, param2:String) : void
      {
         var _loc3_:Class = getClassDef(param1);
         var _loc4_:Object;
         if((_loc4_ = getInstance().classToStylesDict[_loc3_]) != null && _loc4_[param2] != null)
         {
            delete _loc4_[param2];
            invalidateComponentStyle(_loc3_,param2);
         }
      }
      
      public static function setComponentStyle(param1:Object, param2:String, param3:Object) : void
      {
         var _loc4_:Class = getClassDef(param1);
         var _loc5_:Object;
         if((_loc5_ = getInstance().classToStylesDict[_loc4_]) == null)
         {
            _loc5_ = getInstance().classToStylesDict[_loc4_] = {};
         }
         if(_loc5_ == param3)
         {
            return;
         }
         _loc5_[param2] = param3;
         invalidateComponentStyle(_loc4_,param2);
      }
      
      private static function getClassDef(param1:Object) : Class
      {
         var component:Object = null;
         component = param1;
         if(component is Class)
         {
            return component as Class;
         }
         try
         {
            return getDefinitionByName(getQualifiedClassName(component)) as Class;
         }
         catch(e:Error)
         {
            if(component is UIComponent)
            {
               try
               {
                  return component.loaderInfo.applicationDomain.getDefinition(getQualifiedClassName(component)) as Class;
               }
               catch(e:Error)
               {
               }
            }
         }
         return null;
      }
      
      private static function invalidateStyle(param1:String) : void
      {
         var _loc2_:Object = null;
         var _loc3_:Dictionary = getInstance().styleToClassesHash[param1];
         if(_loc3_ == null)
         {
            return;
         }
         for(_loc2_ in _loc3_)
         {
            invalidateComponentStyle(Class(_loc2_),param1);
         }
      }
      
      private static function invalidateComponentStyle(param1:Class, param2:String) : void
      {
         var _loc3_:Object = null;
         var _loc4_:UIComponent = null;
         var _loc5_:Dictionary;
         if((_loc5_ = getInstance().classToInstancesDict[param1]) == null)
         {
            return;
         }
         for(_loc3_ in _loc5_)
         {
            if((_loc4_ = _loc3_ as UIComponent) != null)
            {
               _loc4_.setSharedStyle(param2,getSharedStyle(_loc4_,param2));
            }
         }
      }
      
      public static function setStyle(param1:String, param2:Object) : void
      {
         var _loc3_:Object = getInstance().globalStyles;
         if(_loc3_[param1] === param2 && !(param2 is TextFormat))
         {
            return;
         }
         _loc3_[param1] = param2;
         invalidateStyle(param1);
      }
      
      public static function clearStyle(param1:String) : void
      {
         setStyle(param1,null);
      }
      
      public static function getStyle(param1:String) : Object
      {
         return getInstance().globalStyles[param1];
      }
   }
}

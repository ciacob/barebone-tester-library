package eu.claudius.iacob.testing.common {
import eu.claudius.iacob.testing.interfaces.IRunnable;
import eu.claudius.iacob.testing.ui.ListItemWrapper;

import flash.utils.describeType;
import flash.utils.getQualifiedClassName;

public class TestingUtils {

    public function TestingUtils() {
    }

    private static const RUNNABLES_REGISTRY:Object = {};

    /*
    Internally used to remove all keys and values from an Object.
     */
    private static function _purgeRegistry(registry:Object):void {
        var keys:Array = [];
        for (var key:String in registry) {
            keys.push(key);
            registry[key] = null;
        }
        while (keys.length > 0) {
            delete registry[keys.pop()];
        }
    }

    /*
     * Produces a runtime error as a reminder that given class instance is abstract.
     */
    public static function yieldAbstractClassError(instance:Object):void {
        throw ('The class `' + getQualifiedClassName(instance) +
                '` is abstract; please remember to extend it and override its methods as needed.');
    }

    /*
     Produces a runtime error as a reminder that given method needs to be implemented in a subclass.
     */
    public static function yieldStubMethodError(method:Function, instance:Object):void {
        var methodName:String = _getPublicFunctionName(method, instance);
        throw ('The public method `' + methodName +
                '` of class `' + getQualifiedClassName(instance) + '` is a stub, and needs to be implemented in a ' +
                'subclass');
    }

    /*
     Retrieves the name of a public method, given a reference to its Function Object and the class whose method it is.
     @param   callee
              Reference to the method's Function Object.
     @param   parent
              Reference to the Class instance whose method this is.
     @return  The name of the method.
     */
    private static function _getPublicFunctionName(callee:Function, parent:Object):String {
        for each (var m:XML in describeType(parent)..method) {
            if (parent[m.@name] == callee) return m.@name;
        }
        return "not found";
    }

    /*
     Returns the unqualified name of a class, given its instance.
     */
    public static function getShortClassName(instance:Object):String {
        var fqn:String = getQualifiedClassName(instance);
        return (fqn.split(/\W+/).pop() as String);
    }

    /*
    Returns the human readable state for a given integer, provided it matches one of the known states' value.
     */
    public static function getStateName(state:int):String {
        var allKeys:Array = _getAllNames(StatesRegistry);
        for each (var key:String in allKeys) {
            var keyVal:int = (StatesRegistry[key] as int);
            if (keyVal == state) {
                var tokens:Array = key.split('_');
                tokens.shift();
                return tokens.join(' ');
            }
        }
        return 'unknown';
    }

    /*
    Formats output of various `toString()` methods scattered across the library. They all produce debugging content in a consistent way, which qualifies it for further processing and formatting. Most specifically, this method will:
    - place every pipe char ('|') on a new line, respecting current indentation;
    - place every opening brace ('{') on a new line, respecting current indentation and increment indentation;
    - place every closing brace ('}') on a new line, respecting current indentation and decrement indentation.
    - keep everything else unchanged.
     */
    public static function formatOutput(source:*):String {
        const INDENTATION_STEP:String = ' ';
        var input:String = source.toString();
        var output:String = '';
        var numOpenBraces:int = 0;
        var indentation:String = '';
        var j:int;
        for (var i:int = 0; i < input.length; i++) {
            var lastAddedChar:String = output.charAt(output.length - 1);
            if (lastAddedChar == '\n') {
                indentation = '';
                for (j = 0; j < numOpenBraces; j++) {
                    indentation += INDENTATION_STEP;
                }
                output += indentation;
            }
            var $char:String = input.charAt(i);
            if ($char == '{') {
                numOpenBraces++;
                if (output.length > 0) {
                    output += '\n';
                    output += indentation;
                } else {
                    output += '–––––\n';
                    output += indentation;
                }
                output += $char;
                output += '\n';
            } else if ($char == '}') {
                numOpenBraces--;
                output += '\n';
                indentation = '';
                for (j = 0; j < numOpenBraces; j++) {
                    indentation += INDENTATION_STEP;
                }
                output += indentation;
                output += $char;
            } else if ($char == '|') {
                output += $char;
                output += '\n'
            } else {
                output += $char;
            }
        }
        return output;
    }

    /*
    Formats given `milliseconds` as " ([<minutes>]m [<seconds>]s <milliseconds>ms), as applicable. Returns an empty string if given `milliseconds` do not sum up to at least one second.
     */
    public static function formatMilliseconds(milliseconds:int):String {
        var seconds:int = Math.floor(milliseconds / 1000);
        var minutes:int = Math.floor(seconds / 60);
        seconds = seconds % 60;
        milliseconds = milliseconds % 1000;
        var result:String = "";
        var haveMinutes:Boolean = (minutes > 0);
        var haveSeconds:Boolean = (seconds > 0);
        if (haveMinutes) {
            result += minutes + " m, ";
        }
        if (haveSeconds || haveMinutes) {
            result += seconds + " s, ";
            result += milliseconds + " ms";
            result = " (" + result + ')';
        }
        return result;
    }


    /**
     Returns all names (or keys) defined by a given class of constants.
     @param    constants
     The class of constants to retrieve names of.
     @return   An list with all the names found.
     */
    private static function _getAllNames(constants:Class):Array {
        var list:Array = [];
        var info:XML = describeType(constants);
        var node:XML;
        var key:String;
        for each (node in info..constant) {
            key = ('' + node.@name);
            list.push(key);
        }
        return list;
    }

    /**
     * Fast UUID generator, RFC4122 version 4 compliant.
     *
     * Adapted from:
     * @author Jeff Ward (jcward.com).
     * @license MIT license
     * @link http://stackoverflow.com/questions/105034/how-to-create-a-guid-uuid-in-javascript/21963136#21963136
     **/
    public static function get UUID():String {
        var lut:Array = [];
        var i:int = 0;
        for (i; i < 256; i++) {
            lut[i] = ((i < 16) ? '0' : '') + (i).toString(16);
        }
        var d0:Number = Math.random() * 0xffffffff | 0;
        var d1:Number = Math.random() * 0xffffffff | 0;
        var d2:Number = Math.random() * 0xffffffff | 0;
        var d3:Number = Math.random() * 0xffffffff | 0;
        return (lut[d0 & 0xff] + lut[d0 >> 8 & 0xff] + lut[d0 >> 16 & 0xff] + lut[d0 >> 24 & 0xff] + '-' +
                lut[d1 & 0xff] + lut[d1 >> 8 & 0xff] + '-' + lut[d1 >> 16 & 0x0f | 0x40] + lut[d1 >> 24 & 0xff] + '-' +
                lut[d2 & 0x3f | 0x80] + lut[d2 >> 8 & 0xff] + '-' + lut[d2 >> 16 & 0xff] + lut[d2 >> 24 & 0xff] +
                lut[d3 & 0xff] + lut[d3 >> 8 & 0xff] + lut[d3 >> 16 & 0xff] + lut[d3 >> 24 & 0xff]);
    }

    /*
    Associates an IRunnable implementer instance to a UUID.
    */
    public static function registerRunnable(uid:String, runnable:IRunnable):void {
        if (!(uid in RUNNABLES_REGISTRY)) {
            RUNNABLES_REGISTRY[uid] = [];
        }
        RUNNABLES_REGISTRY[uid][0] = runnable;
    }

    /*
    Associates an ListItemWrapper instance to an the same UUID as the one used by the IRunnable implementer instance it wraps. Returns `true` in case of success, `false` in case of failure.
    */
    public static function registerWrapper(wrapper:ListItemWrapper):Boolean {
        var runnable:IRunnable = wrapper.runnable;
        if (runnable) {
            var uid:String = runnable.uuid;
            if (uid in RUNNABLES_REGISTRY) {
                RUNNABLES_REGISTRY[uid][1] = wrapper;
                return true;
            }
        }
        return false;
    }

    /*
    Provides a way to resolve a UUID to an IRunnable implementer instance, provided the two have ever been associated.  Returns null if not found.
     */
    public static function getRunnableById(uid:String):IRunnable {
        if (uid in RUNNABLES_REGISTRY) {
            return (RUNNABLES_REGISTRY[uid][0] as IRunnable);
        }
        return null;
    }

    /*
    Returns the ListItemWrapper currently wrapping the given IRunnable implementer instance,
    provided it was ever wrapped.Returns null if not found.
     */
    public static function getWrapperOf(runnable:IRunnable):ListItemWrapper {
        if (runnable) {
            var uid:String = runnable.uuid;
            if (uid in RUNNABLES_REGISTRY) {
                return (RUNNABLES_REGISTRY[uid][1] as ListItemWrapper);
            }
        }
        return null;
    }

    /*
    To only be used in the (unlikely) event that this class needs to be garbage collected. It releases all the values stored in its various registries. After calling this method, the class is probably not usable anymore.
     */
    public static function prepareForGarbageCollection():void {
        _purgeRegistry(RUNNABLES_REGISTRY);
    }
}
}

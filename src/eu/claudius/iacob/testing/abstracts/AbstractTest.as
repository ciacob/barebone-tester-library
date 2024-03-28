package eu.claudius.iacob.testing.abstracts {
import eu.claudius.iacob.testing.common.EnablementEvent;
import eu.claudius.iacob.testing.common.TestingUtils;
import eu.claudius.iacob.testing.interfaces.ITest;
import eu.claudius.iacob.testing.interfaces.ITestCase;

import flash.events.Event;

import flash.events.EventDispatcher;

import flash.events.IEventDispatcher;

public class AbstractTest implements ITest, IEventDispatcher {

    private var _uuid : String;
    private var _dispatcher:IEventDispatcher;
    private var _name:String;
    private var _description:String;
    private var _testCases:Vector.<ITestCase>;
    private var _enabled:Boolean;

    public function AbstractTest(subclass:AbstractTest, name:String, description:String) {
        if (!subclass) {
            TestingUtils.yieldAbstractClassError(this);
            return;
        }
        _uuid = TestingUtils.UUID;
        TestingUtils.registerRunnable (_uuid, this);
        _dispatcher = new EventDispatcher(this);
        _name = name;
        _description = description;
        _testCases = new Vector.<ITestCase>;
        _enabled = true;
    }

    public function get uuid () : String {
        return _uuid;
    }

    public function get name():String {
        return _name;
    }

    public function get description():String {
        return _description;
    }

    public function get testCases():Vector.<ITestCase> {
        return _testCases;
    }

    public function get enabled():Boolean {
        return _enabled;
    }

    public function set enabled(value:Boolean):void {
        if (_enabled != value) {
            _enabled = value;
            dispatchEvent(new EnablementEvent(value ? EnablementEvent.ENABLEMENT_ON : EnablementEvent.ENABLEMENT_OFF, this, EnablementEvent.REASON_DIRECT_CHANGE));
            for each (var testCase:ITestCase in _testCases) {
                testCase.enabled = value;
                dispatchEvent(new EnablementEvent(value ? EnablementEvent.ENABLEMENT_ON : EnablementEvent.ENABLEMENT_OFF, testCase, EnablementEvent.REASON_CASCADED_CHANGE));
            }
        }
    }

    public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void {
        _dispatcher.addEventListener(type, listener, useCapture, priority, useWeakReference);
    }

    public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void {
        _dispatcher.removeEventListener(type, listener, useCapture);
    }

    public function dispatchEvent(event:Event):Boolean {
        return _dispatcher.dispatchEvent(event);
    }

    public function hasEventListener(type:String):Boolean {
        return _dispatcher.hasEventListener(type);
    }

    public function willTrigger(type:String):Boolean {
        return _dispatcher.willTrigger(type);
    }

    /*
     Provides a human readable representation of this AbstractTestCase instance, for debugging purposes.
     */
    public function toString():String {
        var tokens:Array = [
            TestingUtils.getShortClassName(this),
            'TEST',
            'name: ' + _name,
            'description: ' + _description,
            '(' + _testCases.length + ' test cases)'
        ];
        return '{ ' + tokens.join(' | ') + ' }';
    }

}
}

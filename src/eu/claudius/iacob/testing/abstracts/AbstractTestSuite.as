package eu.claudius.iacob.testing.abstracts {
import eu.claudius.iacob.testing.common.EnablementEvent;
import eu.claudius.iacob.testing.common.TestingUtils;
import eu.claudius.iacob.testing.interfaces.ITest;
import eu.claudius.iacob.testing.interfaces.ITestCase;
import eu.claudius.iacob.testing.interfaces.ITestSuite;

import flash.events.Event;

import flash.events.EventDispatcher;

import flash.events.IEventDispatcher;

public class AbstractTestSuite implements ITestSuite, IEventDispatcher {
    private var _uuid : String;
    private var _dispatcher:IEventDispatcher;
    private var _name:String;
    private var _description:String;
    private var _enabled:Boolean;
    private var _tests:Vector.<ITest>;

    public function AbstractTestSuite(subclass:AbstractTestSuite, name:String, description:String) {
        if (!subclass) {
            TestingUtils.yieldAbstractClassError(this);
            return;
        }
        _uuid = TestingUtils.UUID;
        TestingUtils.registerRunnable (_uuid, this);
        _dispatcher = new EventDispatcher(this);
        _name = name;
        _description = description;
        _tests = new Vector.<ITest>
        _enabled = true;
    }

    public function get uuid () : String {
        return _uuid;
    }

    public function get tests():Vector.<ITest> {
        return _tests;
    }

    public function get testCases():Vector.<ITestCase> {
        var cases:Vector.<ITestCase> = new Vector.<ITestCase>;
        for each (var test:ITest in _tests) {
            cases = cases.concat(test.testCases);
        }
        return cases;
    }

    public function get name():String {
        return _name;
    }

    public function get description():String {
        return _description;
    }

    public function get enabled():Boolean {
        return _enabled;
    }

    public function set enabled(value:Boolean):void {
        if (_enabled != value) {
            _enabled = value;
            dispatchEvent(new EnablementEvent(value ? EnablementEvent.ENABLEMENT_ON : EnablementEvent.ENABLEMENT_OFF, this, EnablementEvent.REASON_DIRECT_CHANGE));
            for each (var test:ITest in _tests) {
                test.enabled = value;
                dispatchEvent(new EnablementEvent(value ? EnablementEvent.ENABLEMENT_ON : EnablementEvent.ENABLEMENT_OFF, test, EnablementEvent.REASON_CASCADED_CHANGE));
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

    public function toString():String {
        var tokens:Array = [
            TestingUtils.getShortClassName(this),
            'TEST SUITE',
            'name: ' + _name,
            'description: ' + _description,
            '(' + _tests.length + ' tests)'
        ];
        return '{ ' + tokens.join(' | ') + ' }';
    }
}
}

package eu.claudius.iacob.testing.common {

import eu.claudius.iacob.testing.interfaces.IValidationResult;

import flash.events.Event;

/*
Custom event to be dispatched by all ITestRunner implementors. Should contain an ITestRunnerResult implementor instance with info about an ITestCase the test runner is currently reporting. Known event types are those defined by the public static constants of the class TestRunnerEvent.
 */
public class TestRunnerEvent extends Event {

    public static const CASE_DONE:String = 'caseDone';
    public static const ALL_DONE:String = 'allDone';

    private var _result:IValidationResult;

    public function TestRunnerEvent(type:String, result:IValidationResult) {
        super(type, false, false);
        _result = result;
    }

    public function get result():IValidationResult {
        return _result;
    }

    override public function clone():Event {
        return new TestRunnerEvent(type, _result);
    }

    /*
     Provides a human readable representation of this TestRunnerEvent instance, for debugging purposes.
     */
    override public function toString():String {
        var tokens:Array = [
            TestingUtils.getShortClassName (this),
            'type: ' + type,
            'result: ' + _result
        ];
        return '{ ' + tokens.join(' | ') + ' }';
    }
}
}

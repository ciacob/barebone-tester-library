package eu.claudius.iacob.testing.common {
import eu.claudius.iacob.testing.interfaces.ITest;
import eu.claudius.iacob.testing.interfaces.ITestCase;
import eu.claudius.iacob.testing.interfaces.ITestSuite;
import eu.claudius.iacob.testing.interfaces.IValidationResult;

public class ValidationResult implements IValidationResult {
    private var _testCase:ITestCase;
    private var _test:ITest;
    private var _testSuite:ITestSuite;
    private var _state:int;
    private var _testTime:Date;
    private var _testDuration:uint;
    private var _error:Error;

    public function ValidationResult(
            testCase:ITestCase,
            test:ITest,
            testSuite:ITestSuite,
            testTime:Date
    ) {
        _testCase = testCase;
        _test = test;
        _testSuite = testSuite;
        _testTime = testTime;
    }

    public function get testCase():ITestCase {
        return _testCase;
    }

    public function get test():ITest {
        return _test;
    }

    public function get testSuite():ITestSuite {
        return _testSuite;
    }

    public function get state():int {
        return _state;
    }

    public function get testTime():Date {
        return _testTime;
    }

    public function get testDuration():uint {
        return _testDuration;
    }

    public function get error():Error {
        return _error;
    }

    public function set state(value:int):void {
        _state = value;
    }

    public function set testDuration(value:uint):void {
        _testDuration = value;
    }

    public function set error(value:Error):void {
        trace ('--> called set error with:', value);
        _error = value;
    }

    /*
     Provides a human readable representation of this ValidationResult instance, for debugging purposes.
     */
    public function toString():String {
        var tokens:Array = [
            TestingUtils.getShortClassName(this),
            'test case: ' + _testCase,
            'state: ' + TestingUtils.getStateName (_state),
            'test duration: ' + _testDuration,
            'test time: ' + _testTime.toLocaleTimeString()
        ];
        if (_error) {
            tokens.push('error: ' + _error.message + '\n' + _error.getStackTrace());
        }
        if (_test) {
            tokens.push('test:' + _test);
        }
        if (_testSuite) {
            tokens.push('suite:' + testSuite)
        }
        return '{ ' + tokens.join(' | ') + ' }';
    }
}
}

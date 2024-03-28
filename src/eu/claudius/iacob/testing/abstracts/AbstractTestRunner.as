package eu.claudius.iacob.testing.abstracts {
import eu.claudius.iacob.testing.common.ListingEvent;
import eu.claudius.iacob.testing.common.QueuePositionEvent;
import eu.claudius.iacob.testing.common.StatesRegistry;
import eu.claudius.iacob.testing.common.TestRunnerEvent;
import eu.claudius.iacob.testing.common.TestingUtils;
import eu.claudius.iacob.testing.common.ValidationResult;
import eu.claudius.iacob.testing.interfaces.IRunnable;
import eu.claudius.iacob.testing.interfaces.ITest;
import eu.claudius.iacob.testing.interfaces.ITestCase;
import eu.claudius.iacob.testing.interfaces.ITestRunner;
import eu.claudius.iacob.testing.interfaces.ITestSuite;
import eu.claudius.iacob.testing.interfaces.IValidationResult;

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;

/**
 Baseline implementor of the ITestRunner interface.
 */
public class AbstractTestRunner implements ITestRunner {

    private var _runnables:Vector.<IRunnable>;
    private var _dispatcher:IEventDispatcher;
    private var _initialQueueLength:uint = 0;

    private var _currRunnable:IRunnable;
    private var _currTestCase:ITestCase;
    private var _currTest:ITest;
    private var _currTestSuite:ITestSuite;

    private var _casesLeft:uint = 0;
    private var _testsLeft:uint = 0;
    private var _suitesLeft:uint = 0;

    private var _executionAborted:Boolean;

    // A list similar to `_runnables`, except everything is expanded at ITestCase level, the way that parents are followed by their children. Also, elements are removed from this list the moment they are processed.
    private var _testQueue:Vector.<IRunnable>;
    private var _name:String;
    private var _description:String;

    public function AbstractTestRunner(subclass:AbstractTestRunner, name:String, description:String) {
        if (!subclass) {
            TestingUtils.yieldAbstractClassError(this);
            return;
        }
        _name = name;
        _description = description;
        _dispatcher = new EventDispatcher(this);
        _runnables = new Vector.<IRunnable>;
        _testQueue = new Vector.<IRunnable>;
    }

    public function get name():String {
        return _name;
    }

    public function get description():String {
        return _description;
    }

    public function get runnables():Vector.<IRunnable> {
        return _runnables;
    }

    public function execute():void {
        _buildTestQueue();
        gotoNextCase();
    }

    public function addEventListener(kind:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void {
        _dispatcher.addEventListener(kind, listener, useCapture, priority, useWeakReference);
    }

    public function removeEventListener(kind:String, listener:Function, useCapture:Boolean = false):void {
        _dispatcher.removeEventListener(kind, listener, useCapture);
    }

    public function dispatchEvent(event:Event):Boolean {
        return _dispatcher.dispatchEvent(event);
    }

    public function hasEventListener(kind:String):Boolean {
        return _dispatcher.hasEventListener(kind);
    }

    public function willTrigger(kind:String):Boolean {
        return _dispatcher.willTrigger(kind);
    }

    public function gotoNextCase():void {
        var result:IValidationResult;
        if (!_isAllDone()) {
            _currRunnable = _testQueue.shift();
            while (!(_currRunnable is ITestCase)) {

                // Emit "leave" and "enter" queue position events for any ITest or ITestSuite we might be traversing.
                if (_currRunnable is ITest) {
                    _swapCurrentCase();
                    _swapCurrentTest(_currRunnable as ITest);
                    doEnterEvent(_currTest);
                }
                if (_currRunnable is ITestSuite) {
                    _swapCurrentCase();
                    _swapCurrentTest();
                    _swapCurrentTestSuite(_currRunnable as ITestSuite);
                    doEnterEvent(_currTestSuite);
                }
                _currRunnable = _testQueue.shift();
            }

            // By now, `_currRunnable` should be an ITestCase.
            _currTestCase = (_currRunnable as ITestCase);
            doEnterEvent(_currTestCase);

            if (_currTestCase.enabled) {

                // This ITestCase is enabled, and will be run.
                // Delegate the actual testing to ITestCase implementer itself.
                result = new ValidationResult(_currTestCase, _currTest, _currTestSuite, new Date());
                result.state = StatesRegistry.STATE_NOT_RUN;
                addEventListener(TestRunnerEvent.CASE_DONE, _onCurrTestCaseDone);
                try {
                    var callBackFn:Function = function (isTestPassed:Boolean):void {
                        var timeAfterTesting:Date = new Date;
                        result.state = isTestPassed ? StatesRegistry.STATE_PASS : StatesRegistry.STATE_FAIL;
                        result.testDuration = (timeAfterTesting.getTime() - result.testTime.getTime());
                        _currTestCase.actualResult = isTestPassed.toString();
                        dispatchEvent(new TestRunnerEvent(TestRunnerEvent.CASE_DONE, result));
                    }
                    _currTestCase.doTesting(callBackFn);
                } catch (e:Error) {
                    result.error = e;
                    result.state = StatesRegistry.STATE_ERROR;
                    result.testDuration = (new Date()).getTime() - result.testTime.getTime();
                    dispatchEvent(new TestRunnerEvent(TestRunnerEvent.CASE_DONE, result));
                }
            } else {

                // This ITestCase is disabled, and will be skipped.
                result = new ValidationResult(_currTestCase, _currTest, _currTestSuite, new Date());
                result.state = StatesRegistry.STATE_SKIPPED;
                addEventListener(TestRunnerEvent.CASE_DONE, _onCurrTestCaseDone);
                dispatchEvent(new TestRunnerEvent(TestRunnerEvent.CASE_DONE, result));
            }
        }
    }

    /*
    Internal hook to be triggered when our internal callback method is called from within a `doTesting()` implementation in client code. Causes the next case to be executed, unless the "execution aborted" flag has been raised.
     */
    private function _onCurrTestCaseDone(event:TestRunnerEvent):void {
        var target:ITestRunner = (event.target as ITestRunner)
        target.removeEventListener(TestRunnerEvent.CASE_DONE, _onCurrTestCaseDone);
        if (!_executionAborted) {
            gotoNextCase();
        }
    }

    public function gotoNextTest():void {
        if (!_isAllDone()) {
            _currRunnable = _testQueue.shift();
            while (!(_currRunnable is ITest)) {

                // Emit "leave" and "enter" queue position events for any ITestCase or ITestSuite we might be traversing.
                if (_currRunnable is ITestCase) {
                    _swapCurrentCase(_currRunnable as ITestCase);
                    doEnterEvent(_currTestCase);
                }
                if (_currRunnable is ITestSuite) {
                    _swapCurrentCase();
                    _swapCurrentTest();
                    _swapCurrentTestSuite(_currRunnable as ITestSuite);
                    doEnterEvent(_currTestSuite);
                }
                _currRunnable = _testQueue.shift();
            }

            // By now, `_currRunnable` should be an ITest
            _currTest = (_currRunnable as ITest);
            doEnterEvent(_currTest);

            // Any actual work to be done will be in the ITestCases of the current ITest, if any.
            gotoNextCase();
        }
    }

    public function gotoNextSuite():void {
        if (!_isAllDone()) {
            _currRunnable = _testQueue.shift();

            // Emit "leave" and "enter" queue position events for any ITestCase and ITest we might be traversing.
            while (!(_currRunnable is ITestSuite)) {
                if (_currRunnable is ITestCase) {
                    _swapCurrentCase(_currRunnable as ITestCase);
                    doEnterEvent(_currTestCase);
                }
                if (_currRunnable is ITest) {
                    _swapCurrentCase();
                    _swapCurrentTest(_currRunnable as ITest);
                    doEnterEvent(_currTest);
                }
                _currRunnable = _testQueue.shift();
            }

            // By now, `_currRunnable` should be an ITestSuite
            _currTestSuite = (_currRunnable as ITestSuite);
            doEnterEvent(_currTestSuite);

            // Any actual work to be done will be in the ITestCases of the closest ITest, if any.
            gotoNextCase();
        }
    }

    public function abort():void {
        _executionAborted = true;
        var event:TestRunnerEvent = new TestRunnerEvent(TestRunnerEvent.ALL_DONE, null);
        dispatchEvent(event);
    }

    private function _swapCurrentCase(replaceWith:ITestCase = null):void {
        if (_currTestCase) {
            doLeaveEvent(_currTestCase);
            _casesLeft--;
        }
        _currTestCase = replaceWith;
    }

    private function _swapCurrentTest(replaceWith:ITest = null):void {
        if (_currTest) {
            doLeaveEvent(_currTest);
            _testsLeft--;
        }
        _currTest = replaceWith;
    }

    private function _swapCurrentTestSuite(replaceWith:ITestSuite = null):void {
        if (_currTestSuite) {
            doLeaveEvent(_currTestSuite);
            _suitesLeft--;
        }
        _currTestSuite = replaceWith;
    }

    /*
    Checks if queue is empty, and exits if so.
     */
    private function _isAllDone():Boolean {
        if (_testQueue.length == 0) {
            _swapCurrentCase();
            if (_currTest) {
                doLeaveEvent(_currTest);
            }
            if (_currTestSuite) {
                doLeaveEvent(_currTestSuite);
            }
            var allDoneEvent:TestRunnerEvent = new TestRunnerEvent(TestRunnerEvent.ALL_DONE, null);
            dispatchEvent(allDoneEvent);
            _resetInternals();
            return true;
        }
        return false;
    }

    /*
    Wipes out current state, in order to prepare the class for a new lifecycle.
     */
    private function _resetInternals():void {
        _currRunnable = null;
        _currTestCase = null;
        _currTest = null;
        _currTestSuite = null;
        _initialQueueLength = 0;
        _casesLeft = 0;
        _testsLeft = 0;
        _suitesLeft = 0;
        _testQueue.length = 0;
        _executionAborted = false;
    }

    private function doLeaveEvent(runnable:IRunnable):void {
        var queueEvent:QueuePositionEvent = new QueuePositionEvent(
                QueuePositionEvent.POSITION_LEAVE,
                _initialQueueLength - _testQueue.length,
                runnable, _testQueue.length,
                _casesLeft, _testsLeft, _suitesLeft);
        dispatchEvent(queueEvent);
    }

    private function doEnterEvent(runnable:IRunnable):void {
        var queueEvent:QueuePositionEvent = new QueuePositionEvent(
                QueuePositionEvent.POSITION_ENTER,
                _initialQueueLength - _testQueue.length,
                runnable, _testQueue.length,
                _casesLeft, _testsLeft, _suitesLeft);
        dispatchEvent(queueEvent);
    }

    /*
    Populates `_testQueue`, which is a flat and volatile version of `_runnables`.
     */
    private function _buildTestQueue():void {
        _resetInternals();
        var i:int = 0;
        var numRunnables:uint = _runnables.length;
        var runnable:IRunnable;
        for (i; i < numRunnables; i++) {
            runnable = _runnables[i];
            if (!runnable) {
                continue;
            }
            if (!(runnable is ITestCase)) {
                _expandRunnable(runnable, _testQueue);
            } else {
                _testQueue.push(runnable);
                _casesLeft++;
            }
        }
        _initialQueueLength = _testQueue.length;
        dispatchEvent(new ListingEvent(ListingEvent.LIST_READY, _testQueue.concat()));
    }

    /*
    Recursively adds children of `runnable` at the end of the given `queue`.
     */
    private function _expandRunnable(runnable:IRunnable, queue:Vector.<IRunnable>):void {
        queue.push(runnable);
        var i:int = 0;
        var numChildRunnables:uint =
                (runnable is ITestSuite) ? (runnable as ITestSuite).tests.length :
                        (runnable is ITest) ? (runnable as ITest).testCases.length : 0;
        var childRunnable:IRunnable;
        for (i; i < numChildRunnables; i++) {
            if (runnable is ITestSuite) {
                _suitesLeft++;
                childRunnable = (runnable as ITestSuite).tests[i];
            } else if (runnable is ITest) {
                _testsLeft++;
                childRunnable = (runnable as ITest).testCases[i];
            }
            if (childRunnable) {
                if (!(runnable is ITestCase)) {
                    _expandRunnable(childRunnable, queue);
                } else {
                    queue.push(childRunnable);
                    _casesLeft++;
                }
            }
        }
    }

    public function compileTestQueue():void {
        _buildTestQueue();
    }
}
}

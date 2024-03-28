package eu.claudius.iacob.testing.ui {
import eu.claudius.iacob.testing.common.EnablementEvent;
import eu.claudius.iacob.testing.common.StatesRegistry;
import eu.claudius.iacob.testing.common.TestingUtils;
import eu.claudius.iacob.testing.interfaces.IRunnable;
import eu.claudius.iacob.testing.interfaces.ITest;
import eu.claudius.iacob.testing.interfaces.ITestCase;
import eu.claudius.iacob.testing.interfaces.ITestSuite;

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;

[Bindable]
public class ListItemWrapper implements IEventDispatcher {

    private var _runnable:IRunnable;
    private var _enabled:Boolean;
    private var _dispatcher:IEventDispatcher;
    private var _checkboxEnabled:Boolean = true;
    private var _state:int = StatesRegistry.STATE_NOT_RUN;
    private var _error:Error;
    private var _collapsed:Boolean = false;
    private var _title:String;
    private var _subtitle:String;
    private var _details:Object;
    private var _intrinsicColor:uint;
    private var _intrinsicGutter:uint;
    private var _intrinsicLabel:String;
    private var _time : Date;
    private var _duration : Number;

    public static const TEST_SUITE_LABEL : String = 'TEST SUITE';
    public static const TEST_LABEL : String = 'TEST';
    public static const TEST_CASE_LABEL : String = 'TEST CASE';

    public function get TEST_CASE():uint {
        return 0x03DDCD;
    }

    public function get TEST():uint {
        return 0x06ABC1;
    }

    public function get TEST_SUITE():uint {
        return 0x05789B;
    }

    public function get UP_DEFAULT_BG():uint {
        return 0xFFFFFF;
    }

    public function get UP_DEFAULT_FG():uint {
        return 0x000000;
    }

    public function get UP_PASSED_BG():uint {
        return 0x1C9907;
    }

    public function get UP_PASSED_FG():uint {
        return 0xFFFFFF;
    }

    public function get UP_FAILED_BG():uint {
        return 0xDB4E00;
    }

    public function get UP_FAILED_FG():uint {
        return 0xFFFFFF;
    }

    public function get UP_ERROR_BG():uint {
        return 0x8315B7;
    }

    public function get UP_ERROR_FG():uint {
        return 0xFFFFFF;
    }

    public function get OVER_DEFAULT_BG():uint {
        return 0xF2F2F2;
    }

    public function get OVER_DEFAULT_FG():uint {
        return 0x000000;
    }

    public function get OVER_PASSED_BG():uint {
        return 0x2A7719;
    }

    public function get OVER_PASSED_FG():uint {
        return 0xffffff;
    }

    public function get OVER_FAILED_BG():uint {
        return 0xAF4E1E;
    }

    public function get OVER_FAILED_FG():uint {
        return 0xffffff;
    }

    public function get OVER_ERROR_BG():uint {
        return 0x572B77;
    }

    public function get OVER_ERROR_FG():uint {
        return 0xffffff;
    }

    public function get SELECTED_DEFAULT_BG():uint {
        return 0xD8D8D8;
    }

    public function get SELECTED_DEFAULT_FG():uint {
        return 0x000000;
    }

    public function get SELECTED_PASSED_BG():uint {
        return 0x204C16;
    }

    public function get SELECTED_PASSED_FG():uint {
        return 0xD2F9DC;
    }

    public function get SELECTED_FAILED_BG():uint {
        return 0x7A3C29;
    }

    public function get SELECTED_FAILED_FG():uint {
        return 0xF7EAD5;
    }

    public function get SELECTED_ERROR_BG():uint {
        return 0x231C2D;
    }

    public function get SELECTED_ERROR_FG():uint {
        return 0xFBE6FC;
    }

    public function ListItemWrapper(runnable:IRunnable) {
        _dispatcher = new EventDispatcher(this);
        _runnable = runnable;
        _enabled = _runnable.enabled;
        TestingUtils.registerWrapper(this);

        // Cascade enablement changes
        _runnable.addEventListener(EnablementEvent.ENABLEMENT_ON, _onRunnableEnabled);
        _runnable.addEventListener(EnablementEvent.ENABLEMENT_OFF, _onRunnableDisabled);
    }

    private function _onRunnableEnabled(event:EnablementEvent):void {
        if (event.reason == EnablementEvent.REASON_CASCADED_CHANGE) {
            var targetWrapper:ListItemWrapper = TestingUtils.getWrapperOf(event.runnable);
            if (targetWrapper) {
                targetWrapper.enabled = true;
                targetWrapper.checkboxEnabled = true; // Enables children individual toggling.
            }
        }
    }

    private function _onRunnableDisabled(event:EnablementEvent):void {
        if (event.reason == EnablementEvent.REASON_CASCADED_CHANGE) {
            var targetWrapper:ListItemWrapper = TestingUtils.getWrapperOf(event.runnable);
            if (targetWrapper) {
                targetWrapper.enabled = false;
                targetWrapper.checkboxEnabled = false; // Disables children individual toggling.
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

    public function get runnable():IRunnable {
        return _runnable;
    }

    public function get enabled():Boolean {
        return _enabled;
    }

    public function set enabled(value:Boolean):void {
        if (_enabled != value) {
            _enabled = value;
            _runnable.enabled = value;
        }
    }

    public function get state():int {
        return _state;
    }

    public function set state(value:int):void {
        if (_state != value) {
            _state = value;
        }
    }

    public function get collapsed():Boolean {
        return _collapsed;
    }

    public function set collapsed(value:Boolean):void {
        _collapsed = value;
    }

    public function get title():String {
        if (!_title) {
            _title = _runnable.name;
        }
        return _title;
    }

    public function get intrinsicColor():uint {
        if (!_intrinsicColor) {
            _intrinsicColor = (_runnable is ITestSuite) ? TEST_SUITE :
                    (_runnable is ITest) ? TEST :
                            (_runnable is ITestCase) ? TEST_CASE :
                                    0x000001; // practically black, but evaluates to `true`.
        }
        return _intrinsicColor;
    }

    public function get intrinsicGutter():uint {
        if (!_intrinsicGutter) {
            _intrinsicGutter = (_runnable is ITestSuite) ? 52 :
                    (_runnable is ITest) ? 60 :
                            (_runnable is ITestCase) ? 68 : 1; // practically no gutter, but evaluates to `true`.
        }
        return _intrinsicGutter;
    }

    public function get canHaveChildren():Boolean {
        return (_runnable is ITest) || (_runnable is ITestSuite);
    }

    public function get intrinsicLabel():String {
        if (!_intrinsicLabel) {
            _intrinsicLabel =
                    (_runnable is ITestSuite) ? TEST_SUITE_LABEL :
                            (_runnable is ITest) ? TEST_LABEL :
                                    (_runnable is ITestCase) ? TEST_CASE_LABEL : '';
        }
        return _intrinsicLabel;
    }

    public function get subtitle():String {
        if (!_subtitle) {
            _subtitle = _runnable.description;
        }
        return _subtitle;
    }

    public function get details():Object {
        if (!_details) {
            if (_runnable is ITestCase) {
                _details = (_runnable as ITestCase).details;
            }
        }
        return _details;
    }

    public function get checkboxEnabled():Boolean {
        return _checkboxEnabled;
    }

    public function set checkboxEnabled(value:Boolean):void {
        if (_checkboxEnabled != value) {
            _checkboxEnabled = value;
        }
    }

    public function get error():Error {
        return _error;
    }

    public function set error(value:Error):void {
        _error = value;
    }

    public function get time():Date {
        return _time;
    }

    public function set time(value:Date):void {
        _time = value;
    }

    public function get duration():Number {
        return _duration;
    }

    public function set duration(value:Number):void {
        _duration = value;
    }
}
}

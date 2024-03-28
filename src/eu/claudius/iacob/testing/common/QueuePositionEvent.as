package eu.claudius.iacob.testing.common {
import eu.claudius.iacob.testing.interfaces.IRunnable;

import flash.events.Event;

/*
 Dispatched by an ITestRunner implementer when entering / leaving an IRunnable in the test queue. The Event should contain information about the current IRunnable, its position in the queue and the number of remaining objects to be processed there.
 */
public class QueuePositionEvent extends Event {

    public static const POSITION_ENTER : String = 'positionEnter';
    public static const POSITION_LEAVE : String = 'positionLeave';

    private var _index:uint;
    private var _runnable : IRunnable;
    private var _runnablesLeft : uint;
    private var _casesLeft : uint;
    private var _testsLeft : uint;
    private var _suitesLeft : uint;

    public function QueuePositionEvent (type : String, index : uint, runnable : IRunnable, runnablesLeft : uint, casesLeft : uint, testsLeft : uint, suitesLeft : uint) {
        super (type, false, false);
        _index = index;
        _runnable = runnable;
        _runnablesLeft = runnablesLeft;
        _casesLeft = casesLeft;
        _testsLeft = testsLeft;
        _suitesLeft = suitesLeft;
    }


    public function get index():uint {
        return _index;
    }

    public function get runnable():IRunnable {
        return _runnable;
    }

    public function get runnablesLeft():uint {
        return _runnablesLeft;
    }

    public function get casesLeft():uint {
        return _casesLeft;
    }

    public function get testsLeft():uint {
        return _testsLeft;
    }

    public function get suitesLeft():uint {
        return _suitesLeft;
    }

    override public function clone():Event {
        return new QueuePositionEvent (type, _index, _runnable, _runnablesLeft, _casesLeft, _testsLeft, _suitesLeft);
    }
}
}

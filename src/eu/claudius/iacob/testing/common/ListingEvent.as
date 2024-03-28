package eu.claudius.iacob.testing.common {
import eu.claudius.iacob.testing.interfaces.IRunnable;

import flash.events.Event;

/*
 Custom event type to be fired for use of client code that needs to provide a sort of visual representation of the current test queue. The events `queue` property contains a reference to a shallow copy of the current, internal test queue used by the ITestRunner implementation.
 */
public class ListingEvent extends Event {

    public static const LIST_READY:String = 'listReady';

    private var _queue:Vector.<IRunnable>;

    public function ListingEvent(type:String, queue:Vector.<IRunnable>) {
        super(type, false, false);
        _queue = queue;
    }

    public function get queue():Vector.<IRunnable> {
        return _queue;
    }

    override public function clone():Event {
        return new ListingEvent(type, _queue);
    }
}
}

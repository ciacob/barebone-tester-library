package eu.claudius.iacob.testing.common {
import eu.claudius.iacob.testing.interfaces.IRunnable;

import flash.events.Event;

/*
Custom event to be fired when the `enabled` property of an IRunnable implementer is changed for whatever reason. The event's `runnable` property contains a reference to the IRunnable implementer that has been changed (the event's `target` property can be used to find out "who" triggered the event); the event's `reason` property contains information on whether enablement was set directly at the IRunnable's level, or higher in hierarchy.
 */
public class EnablementEvent extends Event {

    public static const ENABLEMENT_ON : String = 'enablementOn';
    public static const ENABLEMENT_OFF : String = 'enablementOff';
    public static const REASON_DIRECT_CHANGE : uint = 1;
    public static const REASON_CASCADED_CHANGE : uint = 2;

    private var _runnable : IRunnable;
    private var _reason : uint;
    public function EnablementEvent(type : String, runnable : IRunnable, reason : uint) {
        super(type, false, false);
        _runnable = runnable;
        _reason = reason;
    }

    public function get runnable () : IRunnable {
        return _runnable;
    }

    public function get reason () : uint {
        return _reason;
    }

    override public function clone () : Event {
        return new EnablementEvent(type, _runnable, _reason);
    }
}
}

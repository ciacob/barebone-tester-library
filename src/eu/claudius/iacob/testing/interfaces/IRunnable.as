package eu.claudius.iacob.testing.interfaces {
import flash.events.IEventDispatcher;

/*
Provides a common way to address anything that can be run by an ITestRunner implementer: ITestCase, ITest, ITestSuite.
 */
public interface IRunnable extends IEventDispatcher {

    function get name() : String;

    function get description() : String;

    /*
    Retrieves the current enablement state of this IRunnable implementer.
    NOTE: an ITestCase that is not `enabled` should be omitted from execution, i.e., its specific test conditions/logic
     should not be evaluated.
     */
    function get enabled () : Boolean;

    /*
    Changes the enablement state of this IRunnable implementer. Enabling or disabling higher hierarchical levels (i.e.,
    ITest or ITestSuite) also enables or disables all levels beneath.

    NOTE: It is recommendable that implementors dispatch an EnablementEvent for each alteration of the `enabled`
    property.
     */
    function set enabled (value : Boolean) : void;

    /*
    Provides a universally unique way of identifying this IRunnable implementer instance. This value must not be
    externally provides; instead, it must generate within each IRunnable.
     */
    function get uuid () : String;
}
}

package eu.claudius.iacob.testing.interfaces {
import flash.events.IEventDispatcher;

/**
 Implementors of this interface are expected to execute one or more test cases and provide an answer on whether they
 have passed or not.
 */
public interface ITestRunner extends IEventDispatcher {

    /*
    Name of this test runner, useful for identifying it. Implementers should implement this property as "read-only",
    and populate it via class constructor arguments.
     */
    function get name() : String;

    /*
    Description of this test runner, useful for explaining its purpose. Implementers should implement this property as
    "read-only", and populate it via class constructor arguments.
     */
    function get description() : String;

    /*
    Externally accessible list with IRunnable implementors (ITestCase, ITest, ITestSuite) to be run by this runner.
    Elements can be added to or removed from this list, but the list itself is immutable. To this queue you can add
    ITestCases, ITests that contain ITestCases, or ITestSuites that contain ITests, that contain ITestCases. Other
    combinations are illegal.
     */
    function get runnables():Vector.<IRunnable>;

    /*
    Sequentially executes all the ITestCase implementors available, and emits various events (especially related to
    whether validation passed or failed).
     */
    function execute():void;

    /*
    Parses all the IRunnable implementer instances added to the "runnables" Vector (see above), producing a flat
    version where all parent-child hierarchical relationships translate into relationships of the preceding-subsequent
    type (i.e., the parents immediately precede their children).

     It is expected that a specific ListingEvent (ListingEvent.LIST_READY) is dispatched when this list is ready.

     This method should be implicitly called by "execute()", but can be called on its own if, e.g., a UI needs to
     render the test queue to the user before execution, so that the user can choose what tests to run, visually.
     */
    function compileTestQueue():void;

    /*
    Traverses elements to the closest ITestCase available and executes it. Traversal/execution continues until all
    queued elements are exhausted (or until aborted).
     */
    function gotoNextCase () : void;

    /*
    Traverses queued elements towards the closest ITest available, and then continues traversing up to the closest
    available ITestCase, and executes that. Traversal/execution continues from that point on, until all queued elements
    are exhausted (or until aborted).
    */
    function gotoNextTest () : void;

    /*
    Traverses queued elements towards the closest ITestSuite available, and then continues traversing up to the closest
    available ITestCase, and executes that. Traversal/execution continues from that point on, until all queued elements
    are exhausted (or until aborted).
    */
    function gotoNextSuite () : void;

    /*
    Halts and discards the current test queue, dispatching an `allDone` event. Has no power over the currently executing
     ITestCase, which shell be concluded nevertheless.
     */
    function abort () : void;
}
}

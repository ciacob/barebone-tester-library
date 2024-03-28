package eu.claudius.iacob.testing.interfaces {

/*
Meant to represent one very specific situation to be tested. Several related test cases should live under a test.
*/
public interface ITestCase extends IRunnable {

    /*
    Optional, further structured information about this specific test case. Subclasses need to override this field in order to make use of it.

    NOTE: This field is meant to be consumed from UI interfaces, when a visual rendition of an ITestCase implementer is activated/selected (e.g., when a list item representing it is clicked, its `details` should be parsed and displayed). Note that the library does not impose any restrictions/rules on how data is organized within this property. It is essentially the responsibility of the client code to both populate the `details` field and consume it from a corresponding visual component.
    */
    function get details() : Object;

    /*
    Optional, stringified information about the expected outcome of this specific test case. Subclasses need to override this field in order to make use of it.
    */
    function get expectedResult () : String;

    /*
    Optional, stringified information about the actual outcome of this specific test case. Subclasses can provide this value at runtime, once the actual testing has completed.
    */
    function get actualResult () : String;
    function set actualResult (value : String) : void;

    /*
    Implementers must override and add here the domain-specific code to perform the actual testing.
    When all testing has concluded, the provided `reportBack` callback function needs to be called. Testing will not proceed to the next ITestCase until this function is called.
    The `reportBack` function takes one Boolean argument, representing whether the test should be considered to have passed or failed.
     */
    function doTesting (reportBack : Function) : void;
}
}

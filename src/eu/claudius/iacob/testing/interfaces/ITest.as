package eu.claudius.iacob.testing.interfaces {

/*
Meant to represent one group of related test cases.
 */
public interface ITest extends IRunnable {

    /*
    List of test cases added to this test. For ITestSuite implementers, this will respectively return the test cases
    from all the tests they contain, in a collective, flat and volatile list (adding or removing test cases here will
    have no effect, but acting upon a specific ITestCase will work as expected).
     */
    function get testCases() : Vector.<ITestCase>;
}
}

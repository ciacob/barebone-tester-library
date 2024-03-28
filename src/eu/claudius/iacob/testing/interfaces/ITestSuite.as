package eu.claudius.iacob.testing.interfaces {

/*
Provides a way of grouping related tests togethe.

Note that any ITestSuite implementor is implicitly an ITest implementor, but the reverse does not apply.
 */
public interface ITestSuite extends ITest {

    /*
    List of tests added to this test suite.
     */
    function get tests() : Vector.<ITest>;
}
}

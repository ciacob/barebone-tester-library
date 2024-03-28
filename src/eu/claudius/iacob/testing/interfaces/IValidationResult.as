package eu.claudius.iacob.testing.interfaces {

/*
Implementers of this interface are intended to provide structured information about an ITestCase implementer that has just been validated, and most notably, whether that validation passed or failed.
 */
public interface IValidationResult {

    /*
    The ITestCase implementer that was just validated. Read-only, use constructor to populate.
     */
    function get testCase():ITestCase;

    /*
    The parent ITest implementer this ITestCase is a child of, if applicable. Read-only, use constructor to populate.
     */
    function get test():ITest;

    /*
    The grand-parent ITestSuite implementer this ITestCase is a grand-child of, if applicable. Read-only, use constructor to populate.
     */
    function get testSuite():ITestSuite;

    /*
    UTC time when validation started. Read-only, use constructor to populate.
 */
    function get testTime():Date;

    /*
    Standardized validation outcome, as one of the constants defined in the class `StatesRegistry`.
     */
    function get state():int;

    function set state(value:int):void;


    /*
    Duration, in milliseconds from the moment validation was started until the moment it concluded, or thrown an error.
     */
    function get testDuration():uint;

    function set testDuration(value:uint):void;

    /*
    If applicable, the error that prevented the validation process from being carried out.
     */
    function get error():Error;

    function set error(value:Error):void;
}
}

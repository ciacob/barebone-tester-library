package eu.claudius.iacob.testing {
import eu.claudius.iacob.testing.abstracts.AbstractTestRunner;

/*
Baseline implementation of AbstractTestRunner, to be used as such is more specialized implementations are not needed.
 */
public class TestRunner extends AbstractTestRunner {
    public function TestRunner (name : String, description : String) {
        super (this, name, description);
    }
}
}

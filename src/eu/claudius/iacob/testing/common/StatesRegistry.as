package eu.claudius.iacob.testing.common {
public class StatesRegistry {
    public function StatesRegistry() {
    }

    public static const STATE_SKIPPED : int = -2;
    public static const STATE_NOT_RUN : int = -1;
    public static const STATE_PASS : int = 0;
    public static const STATE_FAIL : int = 1;
    public static const STATE_ERROR : int = 2;
}
}

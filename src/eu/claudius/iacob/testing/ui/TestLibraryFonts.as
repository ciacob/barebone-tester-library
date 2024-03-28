package eu.claudius.iacob.testing.ui {
    import flash.text.Font;
    
    public final class TestLibraryFonts {

        private static var _fontsRegistered : Boolean = false;

        [Embed(source="fonts/notosans_bold.swf", symbol="notosans_embedded")]
        private static const NOTOSANS_BOLD : Class;

        [Embed(source="fonts/notosans_italic.swf", symbol="notosans_embedded")]
        private static const NOTOSANS_ITALIC : Class;

        [Embed(source="fonts/notosans.swf", symbol="notosans_embedded")]
        private static const NOTOSANS_REGULAR : Class;

        public static function get NOTO_SANS_EMBEDDED () : String {
            registerFonts();
            return 'notosans_embedded';
        }

        public static function registerFonts () : void {
            if (!_fontsRegistered) {
                Font.registerFont(NOTOSANS_BOLD);
                Font.registerFont(NOTOSANS_ITALIC);
                Font.registerFont(NOTOSANS_REGULAR);
                _fontsRegistered = true;
            }
        }
    }
}

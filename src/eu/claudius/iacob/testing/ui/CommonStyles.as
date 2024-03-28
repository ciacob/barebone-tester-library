package eu.claudius.iacob.testing.ui {
import mx.styles.CSSStyleDeclaration;
import mx.utils.ObjectUtil;

public class CommonStyles {

    private static const _MAIN_NAME:String = 'mainStyleName';
    private static const _HEADER_NAME:String = 'headerStyleName';

    private static var _initialized:Boolean;
    private static var _mainCSS:CSSStyleDeclaration;
    private static var _headerCSS:CSSStyleDeclaration;

    private static var _mainFormat:Object = {
        fontFamily: 'notosans_embedded',
        fontSize: 15,
        letterSpacing: 1,
        lineHeight: 18
    };

    private static var _headerFormat:Object = {
        fontWeight: 'bold',
        textAlign: 'right'
    };

    private static function _makeCss(selector:String, style:Object,
                                     baseStyle:Object = null):CSSStyleDeclaration {
        var css:CSSStyleDeclaration = new CSSStyleDeclaration(selector);
        var pairs:Object = baseStyle ? ObjectUtil.clone(baseStyle) : {};
        for (var key:String in style) {
            pairs[key] = style[key];
        }
        for (var styleName:String in pairs) {
            css.setStyle(styleName, pairs[styleName]);
        }
        return css;
    }

    private static function _initialize():void {
        _mainCSS = _makeCss('.' + _MAIN_NAME, _mainFormat);
        _headerCSS = _makeCss('.' + _HEADER_NAME, _headerFormat, _mainFormat);
        _initialized = true;
    }

    public function CommonStyles() {
    }

    public static function get HEADER_STYLE():String {
        if (!_initialized) {
            _initialize();
        }
        return _HEADER_NAME;
    }

    public static function get MAIN_STYLE():String {
        if (!_initialized) {
            _initialize();
        }
        return _MAIN_NAME;
    }

    public static function get HEADER_CSS():CSSStyleDeclaration {
        if (!_initialized) {
            _initialize();
        }
        return _headerCSS;
    }

    public static function get MAIN_CSS():CSSStyleDeclaration {
        if (!_initialized) {
            _initialize();
        }
        return _mainCSS;
    }

    public static const HEADER_CELL_WIDTH:int = 150;
}
}

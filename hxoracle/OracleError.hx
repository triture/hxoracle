package hxoracle;

class OracleError {

    public var errorCode:String = "";
    public var errorMessage:String = "";

    public function new(error:String) {

        var breakError:Array<String> = error.split(":");

        if (breakError.length > 1) {
            this.errorCode = StringTools.trim(breakError.shift());
            this.errorMessage = StringTools.trim(breakError.join(" "));
        } else {
            this.errorCode = "Undefined Code";
            this.errorMessage = StringTools.trim(breakError.join(" "));
        }
    }

    public function toString():String {
        return this.errorCode + ": " + this.errorMessage;
    }
}

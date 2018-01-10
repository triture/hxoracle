package hxoracle;

class OracleRecordSet {

    @:allow(hxoracle.Oracle)
    private var __fields:Array<String>;

    @:allow(hxoracle.Oracle)
    private var __types:Array<Int>;

    @:allow(hxoracle.Oracle)
    private var __values:Array<Array<String>>;

    public var length(get, null):Int;

    public function new() {

    }

    public function getInfo():String {
        var result:String = "";
        result += "FIELDS: " + this.getFields().join(", ") + "\n";
        result += "ROW LEN: " + this.length;

        return result;
    }

    public function getValue(rowIndex:Int, fieldName:String):Dynamic {
        if (this.__fields == null) return null;
        if (rowIndex >= this.length || rowIndex < 0) return null;

        var index:Int = this.__fields.indexOf(fieldName);

        if (index == -1) return null;
        else {
            var type:OracleDataType = this.__types[index];

            var value:Dynamic = this.__values[rowIndex][index];

            //trace(rowIndex, fieldName, index, value);

            if (value == null) return null;
            else {

                switch (type) {
                    case OracleDataType.NUMBER | OracleDataType.LONG: return Std.parseFloat(value);
                    case OracleDataType.DATE: {
                        var dateBreak:Array<String> = Std.string(value).split(";");

                        if (dateBreak.length == 3) {
                            return new Date(Std.parseInt(dateBreak[0]), Std.parseInt(dateBreak[1])-1, Std.parseInt(dateBreak[2]), 0, 0, 0);
                        } else if (dateBreak.length == 6) {
                            return new Date(Std.parseInt(dateBreak[0]), Std.parseInt(dateBreak[1])-1, Std.parseInt(dateBreak[2]), Std.parseInt(dateBreak[3]), Std.parseInt(dateBreak[4]), Std.parseInt(dateBreak[5]));
                        } else {
                            return null;
                        }
                    }
                    case _: return value;
                }

            }
        }
    }

    public function fieldType(fieldName:String):OracleDataType {
        if (this.__fields == null) return OracleDataType.UNDEFINED;

        var index:Int = this.__fields.indexOf(fieldName);

        if (index == -1) return OracleDataType.UNDEFINED;
        return this.__types[index];
    }

    public function hasField(field:String):Bool {
        if (this.__fields == null) return false;
        if (this.__fields.indexOf(field) == -1) return false;
        return true;
    }

    public function getTypes():Array<OracleDataType> {
        return this.__types.copy();
    }

    public function getFields():Array<String> {
        if (this.__fields == null) return [];
        return this.__fields.copy();
    }

    private function get_length():Int {
        if (this.__values == null) return 0;
        return this.__values.length;
    }
}

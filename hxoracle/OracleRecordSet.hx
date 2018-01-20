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

            if (value == null) return null;
            else {

                switch (type) {
                    case OracleDataType.NUMBER | OracleDataType.LONG: return Std.parseFloat(value);
                    case OracleDataType.DATE: {


                        var dateBreak:Array<String> = Std.string(value).split(";");

                        var y:String = StringTools.lpad(dateBreak[0], "0", 4);
                        var m:String = StringTools.lpad(Std.string(Std.parseInt(dateBreak[1])-1), "0", 2);
                        var d:String = StringTools.lpad(dateBreak[2], "0", 2);

                        if (dateBreak.length == 3) {
                            return '$y-$m-$d 00:00:00';

                        } else if (dateBreak.length == 6) {
                            var hh:String = StringTools.lpad(dateBreak[3], "0", 2);
                            var mm:String = StringTools.lpad(dateBreak[4], "0", 2);
                            var ss:String = StringTools.lpad(dateBreak[5], "0", 2);

                            return '$y-$m-$d $hh:$mm:$ss';
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
        if (this.__types == null) return [];
        return this.__types.copy();
    }

    public function getSimpleTypes():Array<OracleDataTypeSimplified> {

        var result:Array<OracleDataTypeSimplified> = [];

        if (this.__types != null) {
            for (item in this.__types) {
                var simple:OracleDataTypeSimplified = item;
                result.push(simple);
            }
        }

        return result;
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

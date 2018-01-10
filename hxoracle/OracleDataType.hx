package hxoracle;

// https://docs.oracle.com/cd/B28359_01/appdev.111/b28395/oci03typ.htm#i423684

@:enum
abstract OracleDataType(Int) to Int from Int {
    var UNDEFINED = -1;

    var VARCHAR = 1;
    var NUMBER = 2;
    var LONG = 8;
    var DATE = 12;
    var RAW = 23;
    var LONG_RAW = 24;
    var ROWID = 69;
    var CHAR = 96;
    var BINARY_FLOAT = 100;
    var BINARY_DOUBLE = 101;
    var VARRAY = 108;
    var REF = 111;
    var CLOB = 112;
    var BLOB = 113;
    var BFILE = 114;
    var TIMESTAMP = 180;
    var TIMESTAMP_WITH_TIME_ZONE = 181;
    var INTERVAL_YEAR_TO_MONTH = 182;
    var INTERVAL_DAY_TO_SECOND = 183;
    var UROWID = 208;
    var TIMESTAMP_WITH_LOCAL_TIME_ZONE = 231;

    @:to inline public function toString():String {
        return switch (this) {
            case UNDEFINED: "UNDEFINED";
            case VARCHAR: "VARCHAR";
            case NUMBER: "NUMBER";
            case LONG: "LONG";
            case DATE: "DATE";
            case RAW: "RAW";
            case LONG_RAW: "LONG_RAW";
            case ROWID: "ROWID";
            case CHAR: "CHAR";
            case BINARY_FLOAT: "BINARY_FLOAT";
            case BINARY_DOUBLE: "BINARY_DOUBLE";
            case VARRAY: "VARRAY";
            case REF: "REF";
            case CLOB: "CLOB";
            case BLOB: "BLOB";
            case BFILE: "BFILE";
            case TIMESTAMP: "TIMESTAMP";
            case TIMESTAMP_WITH_TIME_ZONE: "TIMESTAMP_WITH_TIME_ZONE";
            case INTERVAL_YEAR_TO_MONTH: "INTERVAL_YEAR_TO_MONTH";
            case INTERVAL_DAY_TO_SECOND: "INTERVAL_DAY_TO_SECOND";
            case UROWID: "UROWID";
            case TIMESTAMP_WITH_LOCAL_TIME_ZONE: "TIMESTAMP_WITH_LOCAL_TIME_ZONE";

            case _: "";
        }
    }
}

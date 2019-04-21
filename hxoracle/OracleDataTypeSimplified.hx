package hxoracle;

// https://docs.oracle.com/cd/B28359_01/appdev.111/b28395/oci03typ.htm#i423684

@:enum
abstract OracleDataTypeSimplified(String) to String from String {

    var UNDEFINED = "UNDEFINED";
    var NUMBER = "NUMBER";
    var TEXT = "TEXT";
    var DATE = "DATE";
    var OTHER = "OTHER";

    @:from inline static public function fromOracleDataType(oracleType:OracleDataType):OracleDataTypeSimplified {
        switch (oracleType) {
            case OracleDataType.UNDEFINED: return OracleDataTypeSimplified.UNDEFINED;

            case OracleDataType.NUMBER
                | OracleDataType.ROWID: return OracleDataTypeSimplified.NUMBER;

            case OracleDataType.DATE: return OracleDataTypeSimplified.DATE;

            case OracleDataType.CHAR
                | OracleDataType.VARCHAR
                | OracleDataType.LONG
                | OracleDataType.LONG_RAW
                | OracleDataType.CLOB: return OracleDataTypeSimplified.TEXT;

            case _: return OracleDataTypeSimplified.OTHER;
        }

    }
}

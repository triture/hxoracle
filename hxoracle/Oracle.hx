package hxoracle;

@:buildXml(
'
<include name="${haxelib:hxoracle}/cpp/Build.xml" />
<include name="${haxelib:hxoracle}/hxoracle/BuildOracle.xml" />
'
)
class Oracle {

    private static var _oci_connect;
    private static var _oci_request;
    private static var _oci_terminate;

    private var connected:Bool;

    public function new() {

        if (_oci_connect == null) {

            try {
                cpp.Lib.pushDllSearchPath("./build/ndll/" + cpp.Lib.getBinDirectory() );
                cpp.Lib.pushDllSearchPath("./ndll/" + cpp.Lib.getBinDirectory() );


                _oci_connect = cpp.Lib.load("hxoci", "oci_connect", 3 );
                _oci_request = cpp.Lib.load("hxoci", "oci_request", 2 );
                _oci_terminate = cpp.Lib.load("hxoci", "oci_terminate", 0 );

            } catch (e:Dynamic) {
                trace(e);
                Sys.exit(0);
            }
        }

        this.connected = false;
    }

    public function connect(username:String, password:String, connectionString:String):Bool {
        if (!this.connected) {
            var data:Dynamic = _oci_connect(username, password, connectionString);

            if (Std.is(data, String)) {
                // ocorreu um erro na requisicao
                throw new OracleError(Std.string(data));
            } else {
                this.connected = true;
            }
        }

        return this.connected;
    }


    public function request(query:String, printPlus:Bool = false):OracleRecordSet {
        var data:Dynamic = _oci_request(query, printPlus);

        if (Std.is(data, String)) {
            throw new OracleError(Std.string(data));
        } else {

            var bRow:String = "[~oci~%%~row]";
            var bNull:String = "[oci~%~null]";
            var bCol:String = "]/%/[";

            var dataString:String = data.result;
            var values:Array<Array<String>> = [];
            var rows:Array<String> = dataString.split(bRow);

            if (rows.length > 0) {
                rows.shift();

                for (i in 0 ... rows.length) {
                    var row:Array<String> = [];

                    var cols:Array<String> = rows.shift().split(bCol);

                    for (j in 0 ... cols.length) {
                        var value:String = cols.shift();
                        if (value == bNull) row.push(null);
                        else row.push(value);

                    }

                    values.push(row);
                }
            }

            var fields:Array<String> = data.field_names;
            var types:Array<Int> = data.type_order;

            var result:OracleRecordSet = new OracleRecordSet();
            result.__fields = fields;
            result.__types = types;
            result.__values = values;

            return result;
        }
    }

    public function requestBatch(tableName:String, fields:Array<String>, ?uniqueField:String = "", ?batchSize:Int = 5000, ?onUpdate:OracleRecordSet->Void = null):OracleRecordSet {
        var batchMaxItems:Int = batchSize;
        var result:OracleRecordSet = new OracleRecordSet();

        var hasItems:Bool = true;
        var indexStart:Int = 10000;

        while (hasItems) {

            var indexEnd:Int = indexStart + batchMaxItems;

            var query:String = " ";
            query += "SELECT " + fields.join(",") + " ";
            query += "FROM (SELECT v.*, ROWNUM rnum FROM " + tableName + " v WHERE ROWNUM < " + indexEnd;

            if (uniqueField != "") query += " AND " + uniqueField + " is not NULL ";

            query += ") a ";
            query += "WHERE a.rnum >= " + indexStart;

            try {
                Sys.sleep(0.2);

                var tempResult:OracleRecordSet = this.request(query);

                if (tempResult.length > 0) {
                    result.__fields = tempResult.__fields;
                    result.__types = tempResult.__types;

                    if (result.__values == null) result.__values = [];

                    // ORA-24550: signal received: Unhandled exception: Code=c0000005 Flags=0
                    for (i in 0 ... tempResult.length) result.__values.push(tempResult.__values[i]);

                    if (onUpdate != null) onUpdate(result);

                    indexStart = indexEnd;
                } else {
                    hasItems = false;
                }
            } catch (e:OracleError) {
                hasItems = false;
                trace(e.toString());
                return null;
            }
        }

        return result;
    }

    public function terminate():Bool {
        if (this.connected) {
            var data:Dynamic = cast _oci_terminate();

            if (Std.is(data, String)) {
                // ocorreu um erro na requisicao
                throw new OracleError(Std.string(data));
            } else {
                this.connected = false;
            }
        }

        return !this.connected;
    }

}

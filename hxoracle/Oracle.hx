package hxoracle;

import haxe.io.BytesInput;
import haxe.io.BytesOutput;
import cpp.vm.Gc;

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

            var fields:Array<String> = data.field_names;
            var types:Array<Int> = data.type_order;

            var bRow:String = "[~oci~%%~row]";
            var bNull:String = "[oci~%~null]";
            var bCol:String = "]/%/[";

            var dataString:String = data.result;

            var bytesValues:BytesOutput = new BytesOutput();
            var bytesPosition:Array<Int> = [];

            var lastPosition:Int = 0;

            if (dataString != null) {
                while (lastPosition < dataString.length) {

                    var index:Int = dataString.indexOf(bRow, lastPosition);
                    var rowData:String = "";


                    if (index == -1) {
                        rowData = dataString.substring(lastPosition, dataString.length);
                        lastPosition = dataString.length;
                    } else {
                        rowData = dataString.substring(lastPosition, index);
                        lastPosition = index + bRow.length;
                    }

                    var rowDataBreak:Array<String> = rowData.split(bCol);

                    if (rowDataBreak.length == fields.length) {
                        // validate null values
                        for (i in 0 ... rowDataBreak.length) {
                            if (rowDataBreak[i] == bNull) rowDataBreak[i] = null;
                        }

                        bytesPosition.push(bytesValues.length);
                        bytesValues.writeString(haxe.Json.stringify(rowDataBreak) + "\n");
                    }

                }
            }



            var result:OracleRecordSet = new OracleRecordSet();
            result.__fields = fields;
            result.__types = types;
            result.__bytesValue = new BytesInput(bytesValues.getBytes());
            result.__bytesPosition = bytesPosition;

            bytesValues.close();
            bytesValues = null;
            fields = null;
            types = null;
            data.field_names = null;
            data.type_order = null;
            data.result = null;
            data = null;

            Gc.compact();

            return result;
        }
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

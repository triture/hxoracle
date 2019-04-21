#define IMPLEMENT_API

// https://github.com/snowkit/hxcpp-guide/issues/1
// http://gamehaxe.com/2016/02/10/cffi-prime-for-cffi-users/
// https://github.com/HaxeFoundation/hxcpp/blob/master/test/cffi/project/Project.cpp
// https://www.codeguru.com/cpp/cpp/cpp_mfc/tutorials/article.php/c9855/DLL-Tutorial-For-Beginners.htm
// https://github.com/snowkit/hxcpp-guide/blob/master/work-in-progress/build/5.0-building-a-dynamic-library-from-hxcpp.md
// https://msdn.microsoft.com/en-us/library/fwkeyyhe.aspx
// https://docs.oracle.com/cd/B28359_01/appdev.111/b28395/oci03typ.htm#i423684

#include <hx/CFFI.h>

#include <iostream>
#include <occi.h>

using namespace std;
using namespace oracle::occi;

//Environment *env;
//Connection *conn;
//Statement *stmt;

vector<Environment*> vec_env;
vector<Connection*> vec_conn;
vector<Statement*> vec_stmt;

value convertToVal(string baseStr) {
    char* str;
    int strLen = baseStr.length() + 1;

    str = (char*)malloc(strLen);

    memcpy(str, baseStr.c_str(), strLen);

    return alloc_string(str);
}

value oci_connect(value username, value password, value connectString)
{

    string username_s = val_string(username);
    string password_s = val_string(password);
    string connectString_s = val_string(connectString);

    try
    {

        Environment *env = Environment::createEnvironment("UTF8", "UTF8", Environment::OBJECT);
        Connection *conn = env->createConnection(username_s, password_s, connectString_s);
        Statement *stmt = conn->createStatement();

        stmt->setPrefetchRowCount(200);

        vec_env.push_back(env);
        vec_conn.push_back(conn);
        vec_stmt.push_back(stmt);

    }
    catch (SQLException ex)
    {
        return alloc_string(ex.what());
    }
    catch (exception &excp)
    {
       // cout << excp.what() << endl;
       return alloc_string(excp.what());
    }

    return alloc_int(vec_env.size() - 1);
}

value oci_request(value index, value query, value printPlusValue, value isDebugValue)
{
    try
    {
        string queryString = val_string(query);
        bool isDebug = val_bool(isDebugValue);
        bool printPlus = val_bool(printPlusValue);
        int indexValue = val_int(index);

        if (isDebug) {
            cout << "" << endl;
            cout << " ORACLE :: executando query - " << queryString << endl;
        }

        ResultSet *rs = vec_stmt[indexValue]->executeQuery(queryString);

        // vectors para armazenar conteudo do resultset
        vector<int> typeOrder;
        vector<string> fieldNames;
        vector<value> valueData;

        // informacoes sobre as colunas recuperadas na query
        vector<MetaData> metadataVector = rs->getColumnListMetaData();

        // objeto que sera devolvido ao haxe
        value result = alloc_empty_object();

        buffer dataBuffer = alloc_buffer(NULL);

        if (isDebug) {
            cout << " ORACLE ::  - METADATA: " << endl;
        }

        // validando as colunas recuperadas
        for (int i = 0; i < metadataVector.size(); i++)
        {

            if (isDebug) {
                cout << " ORACLE ::      " << metadataVector[i].getString(MetaData::ATTR_NAME) << " :: TYPE - " << metadataVector[i].getInt(MetaData::ATTR_DATA_TYPE) << endl;
            }

            fieldNames.push_back(metadataVector[i].getString(MetaData::ATTR_NAME));
            typeOrder.push_back(metadataVector[i].getInt(MetaData::ATTR_DATA_TYPE));

            // para colunas onde o tamanho nao foi especificando, colocamo o tamanho de 1
            // ou o oracle pode disparar um erro ao recuperar dados do recordset
            if (metadataVector[i].getInt(MetaData::ATTR_DATA_SIZE) == 0)
            {
                rs->setMaxColumnSize(i+1, 1);
            }
            else
            {
                if (
                    typeOrder[i] != 12 &&
                    typeOrder[i] != 112 &&
                    metadataVector[i].getInt(MetaData::ATTR_DATA_SIZE) < 4096
                )
                {
                    rs->setMaxColumnSize(i+1, 4096);
                }
            }

        }

        // eliminando dados do metadata
        //vector<MetaData>().swap(metadataVector);

        if (isDebug) {
            cout << " ORACLE ::  - DADOS: " << endl;
        }

        int counter = 0;
        int rowCounter = 0;
        int resultCounter = -1;

        while (rs->next())
        {
            rowCounter = rowCounter + 1;

            buffer_append(dataBuffer, "[~oci~%%~row]");

            resultCounter = resultCounter + 1;

            if (isDebug == false && printPlus)
            {
                if (counter > 1000)
                {
                    cout << "+";
                    counter = 0;
                }
                else
                {
                    counter = counter + 1;
                }
            }
            //cout << resultCounter;
            //cout << " ";

            int n = typeOrder.size();
            for (int i = 0; i < n; i++)
            {

                // TODO create a way to retrieve truncated data
//                if (rs->isTruncated(i+1))
//                {
//                    cout << endl;
//                    cout << "trucated " << rs->preTruncationLength(i+1) << " - ";
//                    cout << fieldNames[i];
//                    cout << endl << rs->getString(i+1);
//                    cout << endl;
//
//                    buffer_append(dataBuffer, "[oci~%~null]");
//                }
//                else

                if (rs->isNull(i+1))
                {
                    buffer_append(dataBuffer, "[oci~%~null]");
                }
                else
                {
                    if (typeOrder[i] == 12)
                    {
                        Date valueDate = rs->getDate(i+1);
                        buffer_append(dataBuffer, valueDate.toText("YYYY-MM-DD HH24:MI:SS").c_str());

                        // eliminate object
                        valueDate.setNull();
                    }
                    else if (typeOrder[i] == 112)
                    {
                        // reference ftp://mail.hasjrat.co.id/Public/Backup/oracle/ora92/rdbms/demo/occiclob.cpp

                        Clob clob = rs->getClob(i+1);
                        unsigned int size = clob.length() * 4; // four bytes per char is a good choice??
                        unsigned int offset = 1;
                        unsigned char *buffer = new unsigned char[size];
                        memset(buffer, NULL, size);

                        int bytesRead = clob.read(size, buffer, size, offset);

                        for (int i = 0; i < bytesRead; ++i)
                        {
                            buffer_append_char(dataBuffer, buffer[i]);
                        }

                        delete []buffer;

                    }
                    else
                    {
                        string valueText = rs->getString(i+1);
                        buffer_append(dataBuffer, valueText.c_str());
                    }
                }

                if (i < n - 1) {
                    buffer_append(dataBuffer, "]/%/[");
                }
            }

            if (isDebug) {
                cout << " ORACLE ::      row " << rowCounter << " loaded" << endl;
            }
        }

        //cout << "fim de record set" << endl;

        value a_typeOrder = alloc_array(typeOrder.size());
        for (int i = 0; i < typeOrder.size(); i++)
        {
            val_array_set_i(a_typeOrder, i, alloc_int(typeOrder[i]));
        }

        value a_fieldNames = alloc_array(fieldNames.size());
        for (int i = 0; i < fieldNames.size(); i++)
        {
            val_array_set_i(a_fieldNames, i, convertToVal(fieldNames[i]));
        }

        alloc_field(result, val_id("type_order"), a_typeOrder);
        alloc_field(result, val_id("field_names"), a_fieldNames);
        alloc_field(result, val_id("result"), buffer_to_string(dataBuffer));


        // dealocando vectors
//        vector<int>().swap(typeOrder);
//        vector<string>().swap(fieldNames);
//        vector<value>().swap(valueData);

        // terminate resultset
        vec_stmt[indexValue]->closeResultSet(rs);
//        delete rs;

        //conn->terminateStatement(stmt);


        return result;
    }
    catch (SQLException ex)
    {
        // cout << ex.getMessage() << endl;

        return alloc_string(ex.what());
    }
    catch (exception &excp)
    {
       // cout << excp.what() << endl;
       return alloc_string(excp.what());
    }

    // nada a retornar
    return alloc_empty_object();
}

value oci_terminate(value index)
{
    try
    {
        int valueIndex = val_int(index);

        vec_conn[valueIndex]->terminateStatement(vec_stmt[valueIndex]);
        //cout << "stmt terminated" << endl;

        vec_env[valueIndex]->terminateConnection(vec_conn[valueIndex]);
        //cout << "conn terminated" << endl;

        Environment::terminateEnvironment(vec_env[valueIndex]);

    }
    catch (SQLException ex)
    {
        //cout << ex.getMessage() << endl;
        return alloc_string(ex.what());
    }
    catch (exception &excp)
    {
       // cerr << excp.what() << endl;
       return alloc_string(excp.what());
    }

    return alloc_bool(true);
}

DEFINE_PRIM(oci_connect, 3);
DEFINE_PRIM(oci_request, 4);
DEFINE_PRIM(oci_terminate, 1);
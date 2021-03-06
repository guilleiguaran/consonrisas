YAHOO.util.Event.addListener(window, "load", function() {

    YAHOO.util.Event.on(YAHOO.util.Dom.get('deleteRow'),'click',function(){
        //console.log("Table to delete: " + tName);
        var id = YAHOO.util.Dom.get('deleteRowId').value;
        //console.log("ID to delete: " + id);
        var name = document.getElementsByTagName('meta')[0];
        auth_token_name = name.content;
        var element = document.getElementsByTagName('meta')[1];
        auth_token = element.content;
        //console.log(auth_token);
        YAHOO.util.Connect.initHeader('X-CSRF-Token', auth_token, true);
        YAHOO.util.Connect.asyncRequest('POST', '/admin/db/delete/' + tName + '/' + id,createTable(tName) + '?' +auth_token_name+'='+auth_token, "_method=DELETE");
        
    });


    YAHOO.util.Event.on(YAHOO.util.Dom.get('addRow'),'click',function(){
        myDataTable.set("sortedBy", null);
        var vals = "";
        for(i in cols)
        {
            if(cols[i] != "id" && cols[i].lastIndexOf("_at") == -1)
            {
                var v = YAHOO.util.Dom.get(cols[i]).value;
                vals += tName +"["+ cols[i] +"]=" + v + "&";
            }
        }
        vals = vals.substring(0,vals.length-1);
        var element = document.getElementsByTagName('meta')[1];
        auth_token = element.content;
        YAHOO.util.Connect.initHeader('X-CSRF-Token', auth_token, true);
        YAHOO.util.Connect.asyncRequest('POST', '/admin/db/' + tName, '',vals);
        YAHOO.util.Dom.setStyle('newRow', 'display', 'none');
        YAHOO.util.Dom.setStyle('addRow', 'display', 'none');
        YAHOO.util.Dom.get('CreateNewRowLink').childNodes[0].nodeValue = "Create New Row"
        createTable(tName);
        
    });
    
    YAHOO.util.Event.on(YAHOO.util.Dom.get('CreateNewRowLink'), 'click', function(){
        var link_txt = this.text || this.childNodes[0].nodeValue;
        if(link_txt == "Cancel Add")
        {
            YAHOO.util.Dom.setStyle('newRow', 'display', 'none');
            YAHOO.util.Dom.setStyle('addRow', 'display', 'none');
            this.childNodes[0].nodeValue = "Create New Row"
        }
        else
        {
            var vals = "";
            for(i in cols)
            {
                if(cols[i] != "id" && cols[i].lastIndexOf("_at") == -1)
                {
                    vals += cols[i] + '<br/><input type="text" name="'+cols[i]+'" id="'+cols[i]+'" /><br/>';
                }
            }
            YAHOO.util.Dom.get('newRow').innerHTML = vals;
            YAHOO.util.Dom.setStyle('newRow', 'display', 'block');
            YAHOO.util.Dom.setStyle('addRow', 'display', 'block');
            this.childNodes[0].nodeValue = "Cancel Add"
        }
    });

    YAHOO.util.Event.on(YAHOO.util.Selector.query('.admin-table-list li a'), 'click', function(){
        tName = this.text || this.childNodes[0].nodeValue;
        YAHOO.util.Dom.setStyle('CreateNewRowLink', 'display', 'block');
        YAHOO.util.Dom.setStyle('newRow', 'display', 'none');
        YAHOO.util.Dom.setStyle('addRow', 'display', 'none');
        createTable(tName);
    });
});



function myAsyncSubmitter(fnCallback, oNewValue)
{
    var tmp_col = this.getColumn().field;
    var tbl = tmp_col.split(".")[0];
    var col = tmp_col.split(".")[1];
    var id = this.getRecord().getData(tbl + '.id');
    var success = true;
    var element = document.getElementsByTagName('meta')[1];
    auth_token = element.content;       
    YAHOO.util.Connect.initHeader('X-CSRF-Token', auth_token, true);
    YAHOO.util.Connect.asyncRequest('POST', '/admin/db/' + tbl + '/' + id,'', "_method=PUT&column_name="+col+"&value=" +oNewValue);
    
    fnCallback(success, oNewValue);
}

function createTable(tName)
{
    //Get the table name from a hash of table names stored on the page
    var tableized = all_tables[tName];
    cols = new Array();
    var columns = [];
    columns['delete']= {
key: 'delete',
label: 'delete'
    };
    var fs =[];
    for (column in all_data[tName]["columns"]) {
        var c = (columns[column] = {})
        var f = (fs[column] = {})
        var colName = all_data[tName]["columns"][column]
        cols.push(colName);
        c['key'] = tableized + "." + colName;
        c['label'] = colName;
        c['sortable'] = true;
        if(colName != "id" && colName.lastIndexOf("_at") == -1)
        {
            c['editor'] = new YAHOO.widget.TextareaCellEditor({asyncSubmitter:myAsyncSubmitter});
        }
        f['key'] = tableized + "." + colName;
    }
           
    var element = document.getElementsByTagName('meta')[1];
    auth_token = element.content;       
    YAHOO.util.Connect.initHeader('X-CSRF-Token', auth_token, true);
    myDataSource = new YAHOO.util.DataSource("/admin/db/" + tName + ".json");
    myDataSource.responseType = YAHOO.util.DataSource.TYPE_JSON;
    myDataSource.connXhrMode = "queueRequests";
    myDataSource.responseSchema = {
        resultsList: "results",
        fields: fs
    };
    
    var oConfigs = {
    selectionMode:"single",
            paginator: new YAHOO.widget.Paginator({
                rowsPerPage: 15
            })
    };

    myDataTable = new YAHOO.widget.DataTable("gridYui", columns, myDataSource, oConfigs);
    
    var highlightEditableCell = function(oArgs) {
        var elCell = oArgs.target;
        if(YAHOO.util.Dom.hasClass(elCell, "yui-dt-editable")) {
            this.highlightCell(elCell);
        }
    };
    
    var pressed = function(oArgs){
      alert("Pressed! " + oArgs) ;
    };

    myDataTable.subscribe("cellMouseoverEvent", highlightEditableCell);
    myDataTable.subscribe("cellMouseoutEvent", myDataTable.onEventUnhighlightCell);
    myDataTable.subscribe("cellClickEvent", myDataTable.onEventShowCellEditor);

    YAHOO.util.Dom.setStyle('deleteRow', 'display', 'block');
    YAHOO.util.Dom.setStyle('deleteRowId', 'display', 'block');
            
    return {
        oDS: myDataSource,
        oDT: myDataTable
    };

}

function deleteARow(){


    
}
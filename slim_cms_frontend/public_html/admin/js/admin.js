/*control-panel.js */

$(document).ready(function() {

    /************************************************************************************/
	//Datatable for the judging-checklist-list table
    // Setup - add a text input to each footer cell
    $('#judging-checklist-list thead tr.data-filter th').each( function () {
        var judging_checklist_list_title = $('#judging-checklist-list thead tr.data-filter th').eq( $(this).index() ).text();
        $(this).html( '<input type="text" placeholder="Search '+judging_checklist_list_title+'" />' );
    } );
 
    // DataTable
    var judging_checklist_list_table = $('#judging-checklist-list').DataTable( {
        dom: 'T<"clear">lfrtip',
        	"tableTools": {
            "sSwfPath": "/admin/dataTables/extensions/TableTools/swf/copy_csv_xls_pdf.swf"
        },
        "pageLength": 25,
        "lengthMenu": [[10,25,50,100,-1],[10,25,50,100,"All"]]

    } );
     
    // Apply the filter
    $("#judging-checklist-list thead tr.data-filter input").on( 'keyup change', function () {
        judging_checklist_list_table
            .column( $(this).parent().index()+':visible' )
            .search( this.value )
            .draw();
    });
    
    
    /************************************************************************************/
	//Datatable for the judging-judge-list table
    // Setup - add a text input to each footer cell
    $('#judging-judge-list thead tr.data-filter th').each( function () {
        var judging_judge_list_title = $('#judging-judge-list thead tr.data-filter th').eq( $(this).index() ).text();
        $(this).html( '<input type="text" placeholder="Search '+judging_judge_list_title+'" />' );
    } );
 
    // DataTable
    var judging_judge_list_table = $('#judging-judge-list').DataTable( {
        dom: 'T<"clear">lfrtip',
        	"tableTools": {
            "sSwfPath": "/admin/dataTables/extensions/TableTools/swf/copy_csv_xls_pdf.swf"
        },
        "pageLength": 25,
        "lengthMenu": [[10,25,50,100,-1],[10,25,50,100,"All"]]

    } );
     
    // Apply the filter
    $("#judging-judge-list thead tr.data-filter input").on( 'keyup change', function () {
        judging_judge_list_table
            .column( $(this).parent().index()+':visible' )
            .search( this.value )
            .draw();
    });
    
    
    /************************************************************************************/
    //Datatable for the dashboard-client-checklist table
    // Setup - add a text input to each footer cell
    $('#dashboard-client-checklist thead tr.data-filter th').each( function () {
        var dashboard_client_checklist_title = $('#dashboard-client-checklist thead tr.data-filter th').eq( $(this).index() ).text();
        $(this).html( '<input type="text" placeholder="Search '+dashboard_client_checklist_title+'" />' );
    } );
 
    // DataTable 
    var dashboard_client_checklist_table = $('#dashboard-client-checklist').DataTable( {
        dom: 'T<"clear">lfrtip',
        	"tableTools": {
            "sSwfPath": "/admin/dataTables/extensions/TableTools/swf/copy_csv_xls_pdf.swf"
        },
        "pageLength": 25,
        "lengthMenu": [[10,25,50,100,-1],[10,25,50,100,"All"]]

    } );
     
    // Apply the filter
    $("#dashboard-client-checklist thead tr.data-filter input").on( 'keyup change', function () {
        dashboard_client_checklist_table
            .column( $(this).parent().index()+':visible' )
            .search( this.value )
            .draw();
    });
    
    /************************************************************************************/
    //Datatable for the table-client-contact-list
    // Setup - add a text input to each footer cell
    $('#table-client-contact-list thead tr.data-filter th').each( function () {
        var table_client_contact_list_title = $('#table-client-contact-list thead tr.data-filter th').eq( $(this).index() ).text();
        $(this).html( '<input type="text" placeholder="Search '+table_client_contact_list_title+'" />' );
    } );
 
    // DataTable 
    var table_client_contact_list = $('#table-client-contact-list').DataTable( {
        dom: 'T<"clear">lfrtip',
        	"tableTools": {
            "sSwfPath": "/admin/dataTables/extensions/TableTools/swf/copy_csv_xls_pdf.swf"
        },
        "pageLength": 25,
        "lengthMenu": [[10,25,50,100,-1],[10,25,50,100,"All"]]

    } );
     
    // Apply the filter
    $("#table-client-contact-list thead tr.data-filter input").on( 'keyup change', function () {
        table_client_contact_list
            .column( $(this).parent().index()+':visible' )
            .search( this.value )
            .draw();
    });
    
    /************************************************************************************/
    //Datatable for the table-client-account-checklist
    // Setup - add a text input to each footer cell
    $('#table-client-account-checklist thead tr.data-filter th').each( function () {
        var table_client_account_checklist_title = $('#table-client-account-checklist thead tr.data-filter th').eq( $(this).index() ).text();
        $(this).html( '<input type="text" placeholder="Search '+table_client_account_checklist_title+'" />' );
    } );
 
    // DataTable 
    var table_client_account_checklist = $('#table-client-account-checklist').DataTable( {
        dom: 'T<"clear">lfrtip',
        	"tableTools": {
            "sSwfPath": "/admin/dataTables/extensions/TableTools/swf/copy_csv_xls_pdf.swf"
        },
        "pageLength": 25,
        "lengthMenu": [[10,25,50,100,-1],[10,25,50,100,"All"]]

    } );
     
    // Apply the filter
    $("#table-client-account-checklist thead tr.data-filter input").on( 'keyup change', function () {
        table_client_account_checklist
            .column( $(this).parent().index()+':visible' )
            .search( this.value )
            .draw();
    });
    
    
    /************************************************************************************/
    //Datatable for the table-client-account-notes
    // Setup - add a text input to each footer cell
    $('#table-client-account-notes thead tr.data-filter th').each( function () {
        var table_client_account_notes_title = $('#table-client-account-notes thead tr.data-filter th').eq( $(this).index() ).text();
        $(this).html( '<input type="text" placeholder="Search '+table_client_account_notes_title+'" />' );
    } );
 
    // DataTable 
    var table_client_account_notes = $('#table-client-account-notes').DataTable( {
        dom: 'T<"clear">lfrtip',
        	"tableTools": {
            "sSwfPath": "/admin/dataTables/extensions/TableTools/swf/copy_csv_xls_pdf.swf"
        },
        "pageLength": 25,
        "lengthMenu": [[10,25,50,100,-1],[10,25,50,100,"All"]]

    } );
     
    // Apply the filter
    $("#table-client-account-notes thead tr.data-filter input").on( 'keyup change', function () {
        table_client_account_notes
            .column( $(this).parent().index()+':visible' )
            .search( this.value )
            .draw();
    });
    
    
    /************************************************************************************/
    //Datatable for the table-client-account-list
    // Setup - add a text input to each footer cell
    $('#client-account-list-table thead tr.data-filter th').each( function () {
        var client_account_list_table_title = $('#client-account-list-table thead tr.data-filter th').eq( $(this).index() ).text();
        $(this).html( '<input type="text" placeholder="Search '+client_account_list_table_title+'" />' );
    } );
 
    // DataTable 
    var client_account_list_table = $('#client-account-list-table').DataTable( {
        dom: 'T<"clear">lfrtip',
        	"tableTools": {
            "sSwfPath": "/admin/dataTables/extensions/TableTools/swf/copy_csv_xls_pdf.swf"
        },
        "pageLength": 25,
        "lengthMenu": [[10,25,50,100,-1],[10,25,50,100,"All"]]

    } );
     
    // Apply the filter
    $("#client-account-list-table thead tr.data-filter input").on( 'keyup change', function () {
        client_account_list_table
            .column( $(this).parent().index()+':visible' )
            .search( this.value )
            .draw();
    });
    
    /************************************************************************************/
    //Datatable for the table-client-account-emails
    // Setup - add a text input to each footer cell
    $('#table-client-account-emails thead tr.data-filter th').each( function () {
        var table_client_account_emails_title = $('#table-client-account-emails thead tr.data-filter th').eq( $(this).index() ).text();
        $(this).html( '<input type="text" placeholder="Search '+table_client_account_emails_title+'" />' );
    } );
 
    // DataTable 
    var table_client_account_emails = $('#table-client-account-emails').DataTable( {
        dom: 'T<"clear">lfrtip',
        	"tableTools": {
            "sSwfPath": "/admin/dataTables/extensions/TableTools/swf/copy_csv_xls_pdf.swf"
        },
        "pageLength": 25,
        "lengthMenu": [[10,25,50,100,-1],[10,25,50,100,"All"]]

    } );
     
    // Apply the filter
    $("#table-client-account-emails thead tr.data-filter input").on( 'keyup change', function () {
        table_client_account_emails
            .column( $(this).parent().index()+':visible' )
            .search( this.value )
            .draw();
    });
    
    /************************************************************************************/
    //Datatable for the table-client-account-invoices
    // Setup - add a text input to each footer cell
    $('#table-client-account-invoices thead tr.data-filter th').each( function () {
        var table_client_account_invoices_title = $('#table-client-account-invoices thead tr.data-filter th').eq( $(this).index() ).text();
        $(this).html( '<input type="text" placeholder="Search '+table_client_account_invoices_title+'" />' );
    } );
 
    // DataTable 
    var table_client_account_invoices = $('#table-client-account-invoices').DataTable( {
        dom: 'T<"clear">lfrtip',
        	"tableTools": {
            "sSwfPath": "/admin/dataTables/extensions/TableTools/swf/copy_csv_xls_pdf.swf"
        },
        "pageLength": 25,
        "lengthMenu": [[10,25,50,100,-1],[10,25,50,100,"All"]]

    } );
     
    // Apply the filter
    $("#table-client-account-invoices thead tr.data-filter input").on( 'keyup change', function () {
        table_client_account_invoices
            .column( $(this).parent().index()+':visible' )
            .search( this.value )
            .draw();
    });   
    
    /************************************************************************************/
    //Datatable for the table-client-account-transactions
    // Setup - add a text input to each footer cell
    $('#table-client-account-transactions thead tr.data-filter th').each( function () {
        var table_client_account_transactions_title = $('#table-client-account-transactions thead tr.data-filter th').eq( $(this).index() ).text();
        $(this).html( '<input type="text" placeholder="Search '+table_client_account_transactions_title+'" />' );
    } );
 
    // DataTable 
    var table_client_account_transactions = $('#table-client-account-transactions').DataTable( {
        dom: 'T<"clear">lfrtip',
        	"tableTools": {
            "sSwfPath": "/admin/dataTables/extensions/TableTools/swf/copy_csv_xls_pdf.swf"
        },
        "pageLength": 25,
        "lengthMenu": [[10,25,50,100,-1],[10,25,50,100,"All"]]

    } );
     
    // Apply the filter
    $("#table-client-account-transactions thead tr.data-filter input").on( 'keyup change', function () {
        table_client_account_transactions
            .column( $(this).parent().index()+':visible' )
            .search( this.value )
            .draw();
    });  
    
    /************************************************************************************/
    //Datatable for the table-client-account-transactions
    // Setup - add a text input to each footer cell
    $('#generic-list-table thead tr.data-filter th').each( function () {
        var generic_list_table_title = $('#generic-list-table thead tr.data-filter th').eq( $(this).index() ).text();
        $(this).html( '<input type="text" placeholder="Search '+generic_list_table_title+'" />' );
    } );
 
    // DataTable 
    var generic_list_table = $('#generic-list-table').DataTable( {
        dom: 'T<"clear">lfrtip',
        	"tableTools": {
            "sSwfPath": "/admin/dataTables/extensions/TableTools/swf/copy_csv_xls_pdf.swf"
        },
        "pageLength": 25,
        "lengthMenu": [[10,25,50,100,-1],[10,25,50,100,"All"]]

    } );
      
     
    // Apply the filter
    $("#generic-list-table thead tr.data-filter input").on( 'keyup change', function () {
        generic_list_table
            .column( $(this).parent().index()+':visible' )
            .search( this.value )
            .draw();
    });

    $('.admin.template-add').click(function() {
        var target = $(this).data('target');
        var template = $(this).data('template');

        //Make the clone
        var result = $(template).clone(true).appendTo(target);
        $(result).removeClass('template');
        $(result).find(' :input').prop('disabled',false);

    });

    $('.admin.template-delete').click(function() {
        var target = $(this).data('target');
        $(this).closest(target).remove();
    });

});


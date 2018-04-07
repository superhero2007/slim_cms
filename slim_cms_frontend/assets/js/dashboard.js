/*dashboard.js */
if (!String.prototype.startsWith) {
    String.prototype.startsWith = function(searchString, position) {
        position = position || 0;
        return this.substr(position, searchString.length) === searchString;
    };
}

$(document).ready(function() {

    /************************************************************************************/
    //Generic Data Table
    // Setup - add a text input to each footer cell
    $('.admin-datatable thead tr.data-filter th.filter').each(function() {
        var admin_data_table_title = $('.admin-datatable thead tr.data-filter th').eq($(this).index()).text();
        $(this).html('<input type="text" placeholder="Filter ' + admin_data_table_title + '" class="form-control input-sm datatable_input_col_search" />');
    });

    // DataTable 
    var admin_data_table = $('.admin-datatable').DataTable({
        'lengthMenu': [
            [10, 25, 50, 100, 200, -1],
            [10, 25, 50, 100, 200, "All"]
        ],
        deferRender: true,
        processing: true,
        buttons: ['copyHtml5', 'csvHtml5', 'excelHtml5', 'pdfHtml5'],
        'aoColumnDefs': [
            { 'bSearchable': false, 'aTargets': 'action-col' },
            { 'bSortable': false, 'aTargets': 'action-col' }
        ]
    });

    admin_data_table.buttons().container()
        .appendTo($('.col-sm-6:eq(1)', admin_data_table.table().container()));

    // Apply the filter
    $('.admin-datatable thead tr.data-filter input').on('keyup change', function() {
        admin_data_table.column($(this).parent().index() + ':visible').search(this.value).draw();
    });


    //Toggle the filtering panel in and out of view
    $('.toggle-filter-panel').click(function(e) {
        e.preventDefault();
        $('.filter-results-panel').slideToggle('slow');
    });

    //Chosen Support
    $('.chosen-select').chosen();

    //CountTo
    $('.countto-timer').each(startCountToCounter);

    function startCountToCounter(options) {
        $(this).countTo({
            formatter: function(value, options) {
                switch ($(this).data('custom-formatter')) {
                    case 'comma':
                        value = value.toFixed(options.decimals).toString().replace(/\B(?=(\d{3})+(?!\d))/g, ',');
                        break;
                    default:
                        value = value.toFixed(options.decimals);
                        break;
                }
                return value;
            }
        });
    }

    //DateTimePicker
    $('.gbc-date-time-picker').datetimepicker({
        locale: ($(this).data('locale') != null ? $(this).data('locale') : 'en-AU'),
        format: ($(this).data('format') != null ? $(this).data('format') : 'L')
    });

    $('.analytics-date-filter-link').click(function(e) {
        e.preventDefault();

        var dateFilter = '';

        if ($('.analytics-date-filter-form #from-date').val() != 'undefined' && $('.analytics-date-filter-form #from-date').val() != '') {
            dateFilter += "&from=" + $('.analytics-date-filter-form #from-date').val().replace(/\//g, '-');
        }

        if ($('.analytics-date-filter-form #to-date').val() != 'undefined' && $('.analytics-date-filter-form #to-date').val() != '') {
            dateFilter += "&to=" + $('.analytics-date-filter-form #to-date').val().replace(/\//g, '-');;
        }

        //console.log("Setting URL to: " + this.href + dateFilter);

        window.location.replace(this.href + dateFilter);
    });

    $('.compare-assessments.checkbox').click(function() {
        //count checkbox options
        var checkedCount = $('.compare-assessments.checkbox:checked').length;

        if (checkedCount == 0) {
            $('#submit-compare-options').removeClass('btn-success');
            $('#submit-compare-options').addClass('disabled');
        } else {
            $('#submit-compare-options').addClass('btn-success');
            $('#submit-compare-options').removeClass('disabled');
        }
    });

    $('#submit-compare-options').click(function() {
        $('.compare-form-checkbox').remove();

        $("input[name='compare-assessments-[]']:checked").each(function() {
            $('#compare-form').append('<input type="hidden" class="compare-form-checkbox" name="compare_client_checklist_id[]" value="' + $(this).val() + '" /> ');
        });

        $('#compare-form').submit();
    });

});

/***** AJAX Datatables *****/
$(document).ready(ajaxDataTables);

function ajaxDataTables() {
    $('.table.ajax-datatable').each(function() {
        var $element = $(this);
        var url = !$element.data('query-id') ? $element.data('query-url') : '/api/v1/storedQuery/' + $element.data('query-id');
        var timestamp = $element.data('timestamp');
        var hash = $element.data('hash');
        var key = $element.data('key');
        $.ajax({
            type: 'GET',
            url: url,
            data: null,
            success: function(data) {
                //console.log(url);
                //console.log(data);
                doDataTable($element, data);
            },
            beforeSend: function(request) {
                request.setRequestHeader('X-TIMESTAMP', timestamp);
                request.setRequestHeader('X-HASH', hash);
                request.setRequestHeader('X-PUBLIC', key);
            },
            error: function(xhr, error) {
                callback(jQuery.parseJSON(xhr.responseText));
            }
        });
    });
}

$(document).ready(ajaxApiDataTables);

function ajaxApiDataTables() {
    $('.table.ajax-api-datatable').each(function() {
        var $element = $(this);
        var timestamp = $element.data('timestamp');
        var hash = $element.data('hash');
        var key = $element.data('key');
        $.ajax({
            type: $element.data('ajax-method') != 'undefined' && $element.data('ajax-method') != '' ? $element.data('ajax-method') : 'GET',
            url: $element.data('ajax-url'),
            data: { 'data': $element.data('post-data') },
            success: function(jsonData) {
                doDataTable($element, jsonData);
            },
            beforeSend: function(request) {
                request.setRequestHeader('X-TIMESTAMP', timestamp);
                request.setRequestHeader('X-HASH', hash);
                request.setRequestHeader('X-PUBLIC', key);
            },
            error: function(xhr, error) {
                //console.log(jQuery.parseJSON(xhr.responseText));
            }
        });
    });
}


function doDataTable($element, data) {
    //Get the table header row as an array
    var tableHeaderDetailArray = $element.find('thead tr th');
    var tableHeaderArray = [];
    for (var i = 0; i < tableHeaderDetailArray.length; i++) {
        tableHeaderArray.push(tableHeaderDetailArray[i].innerHTML);
    }

    $.fn.DataTable.isDataTable($element) ? updateDataTable() : initializeDataTable();

    function initializeDataTable() {
        var dataTable = $element.DataTable({
            dom: '<"col-md-4"l><"col-md-4 text-center"B><"col-md-4"f><"col-md-12"t><"col-md-6"i><"col-md-6"pr>',
            buttons: ['copyHtml5', 'csvHtml5', 'excelHtml5', 'pdfHtml5'],
            lengthMenu: [
                [10, 25, 50, 100, 200, -1],
                [10, 25, 50, 100, 200, "All"]
            ],
            deferRender: true,
            processing: true,
            data: data.data,
            ordering: $element.data('order') == '-1' ? false : true,
            columns: getDisplayColumns($element.data('display'), tableHeaderArray)
        });
        dataTable.buttons().container().appendTo($('.col-sm-6:eq(1)', dataTable.table().container()));
    }

    function updateDataTable() {
        var dataTable = $element.DataTable({
            retrieve: true
        });

        dataTable.clear();
        dataTable.rows.add(data.data).draw();
    }
}

function getDisplayColumns(type, tableHeaderArray) {

    switch (type) {

        case 'year':
        case 'year_start':
            return [{
                    data: "client_checklist_id",
                    render: function(data, type, full, meta) {
                        return '<input type="checkbox" name="row-index[]" value="' + full.client_checklist_id + '" />';
                    },
                    orderable: false
                },
                {
                    data: "company_name",
                    render: function(data, type, full, meta) {
                        return '<a href="/members/dashboard/entry/view/?client_id=' + full.client_id + '&client_checklist_id=' + full.client_checklist_id + '" class="default-link">' + full.company_name + '</a>';
                    }
                },
                { data: "name" },
                {
                    data: {
                        _: "date_range_start_year",
                        order: "date_range_start"
                    }
                },
                { data: "status" }
            ];
            break;

        case 'year_finish':
            var columnArray = [{
                    data: "client_checklist_id",
                    render: function(data, type, full, meta) {
                        return '<input type="checkbox" name="row-index[]" value="' + full.client_checklist_id + '" />';
                    },
                    orderable: false
                },
                {
                    data: "company_name",
                    render: function(data, type, full, meta) {
                        return '<a href="/members/dashboard/entry/view/?client_id=' + full.client_id + '&client_checklist_id=' + full.client_checklist_id + '" class="default-link">' + full.company_name + '</a>';
                    }
                }
            ];

            //Checklist Name
            if (tableHeaderArray.indexOf('Entry') > 0) {
                columnArray.push({ data: "name" });
            }

            //Period
            if (tableHeaderArray.indexOf('Period') > 0) {
                columnArray.push({
                    data: {
                        _: "date_range_finish_year",
                        order: "date_range_finish"
                            /*sort: "date_range_finish" */
                    }
                });
            }

            //Progress
            if (tableHeaderArray.indexOf('Progress') > 0) {
                columnArray.push({
                    data: "progress",
                    render: function(data, type, full, meta) {
                        return full.completed != null ? '100%' : full.progress + '%';
                    }
                });
            }

            //Status
            if (tableHeaderArray.indexOf('Status') > 0) {
                columnArray.push({ data: "status" });
            }

            //Created
            if (tableHeaderArray.indexOf('Created') > 0) {
                columnArray.push({
                    data: {
                        _: "created",
                        order: "created_timestamp",
                        sort: "created_timestamp"
                    }
                });
            }

            //Completed
            if (tableHeaderArray.indexOf('Completed') > 0) {
                columnArray.push({
                    data: {
                        _: "completed",
                        order: "completed_timestamp",
                        sort: "completed_timestamp"
                    }
                });
            }

            //First Modified
            if (tableHeaderArray.indexOf('First Modified') > 0) {
                columnArray.push({
                    data: {
                        _: "first_modified",
                        order: "first_modified_timestamp",
                        sort: "first_modified_timestamp"
                    }
                });
            }

            //Last Modified
            if (tableHeaderArray.indexOf('Last Modified') > 0) {
                columnArray.push({
                    data: {
                        _: "last_modified",
                        order: "last_modified_timestamp",
                        sort: "last_modified_timestamp"
                    }
                });
            }

            return columnArray;
            break;

        case 'client':
            var columnArray = [{
                    data: "client_id",
                    render: function(data, type, full, meta) {
                        return '<input type="checkbox" name="row-index[]" value="' + full.client_id + '" />';
                    },
                    orderable: false
                },
                {
                    data: "company_name",
                    render: function(data, type, full, meta) {
                        return '<a href="/members/dashboard/account/view/?client_id=' + full.client_id + '" class="default-link">' + full.company_name + '</a>';
                    }
                }
            ];

            //City
            if (tableHeaderArray.indexOf('City') > 0) {
                columnArray.push({ data: "suburb" });
            }

            //State
            if (tableHeaderArray.indexOf('State') > 0) {
                columnArray.push({ data: "state" });
            }

            //Country
            if (tableHeaderArray.indexOf('Country') > 0) {
                columnArray.push({ data: "country" });
            }

            //Industry
            /* if (tableHeaderArray.indexOf('Industry') > 0) {
                columnArray.push({ data: "anzsic_industry" });
            }
            */

            //Created
            if (tableHeaderArray.indexOf('Created') > 0) {
                columnArray.push({
                    data: {
                        _: "created_date_time",
                        order: "created"
                    }
                });
            }

            //Last Active
            if (tableHeaderArray.indexOf('Last Active') > 0) {
                columnArray.push({
                    data: {
                        _: "last_active",
                        order: "last_active_timestamp",
                        sort: "last_active_timestamp"
                    }
                });
            }

            //Users
            if (tableHeaderArray.indexOf('Users') > 0) {
                columnArray.push({ data: "users" });
            }

            //Entries
            if (tableHeaderArray.indexOf('Entries') > 0) {
                columnArray.push({ data: "entries" });
            }

            return columnArray;

            break;

        case 'month_year':
            var columnArray = [{
                    data: "client_checklist_id",
                    render: function(data, type, full, meta) {
                        return '<input type="checkbox" name="row-index[]" value="' + full.client_checklist_id + '" />';
                    },
                    orderable: false
                },
                {
                    data: "company_name",
                    "render": function(data, type, full, meta) {
                        return '<a href="/members/dashboard/entry/view/?client_id=' + full.client_id + '&client_checklist_id=' + full.client_checklist_id + '" class="default-link">' + full.company_name + '</a>';
                    }
                },
                { data: "name" }
            ];

            //Period
            if (tableHeaderArray.indexOf('Period') > 0) {
                columnArray.push({
                    data: {
                        _: "date_range_start_month_year",
                        order: "date_range_start",
                        sort: "date_range_start"
                    }
                });
            }

            //Progress
            if (tableHeaderArray.indexOf('Progress') > 0) {
                columnArray.push({
                    data: "progress",
                    render: function(data, type, full, meta) {
                        return full.completed != null ? '100%' : full.progress + '%';
                    }
                });
            }

            //Status
            if (tableHeaderArray.indexOf('Status') > 0) {
                columnArray.push({ data: "status" });
            }

            return columnArray;
            break;


        case 'user_list':
            return [{
                    data: "client_id",
                    render: function(data, type, full, meta) {
                        return '<input type="checkbox" name="row-index[]" value="' + full.client_contact_id + '" />';
                    },
                    orderable: false
                },
                {
                    data: "user",
                    "render": function(data, type, full, meta) {
                        //return '<a href="/members/dashboard/user/view/?client_id=' + full.client_id + '&client_contact_id=' + full.client_contact_id + '" class="default-link">' + full.user + '</a>';
                        return full.user;
                    }
                },
                { data: "email" },
                {
                    data: "company_name",
                    render: function(data, type, full, meta) {
                        return '<a href="/members/dashboard/account/view/?client_id=' + full.client_id + '" class="default-link">' + full.company_name + '</a>';
                    }
                },
                {
                    data: {
                        _: "last_active",
                        order: "last_active_timestamp",
                        sort: "last_active_timestamp"
                    }
                }
            ];
            break;

        case 'user_log':
            var columnArray = [{
                    data: "user",
                    "render": function(data, type, full, meta) {
                        return '<a href="/members/dashboard/user/view/?client_id=' + full.client_id + '&client_contact_id=' + full.client_contact_id + '" class="default-link">' + full.user + '</a>';
                    }
                },
                {
                    data: "company_name",
                    "render": function(data, type, full, meta) {
                        return '<a href="/members/dashboard/account/view/?client_id=' + full.client_id + '" class="default-link">' + full.company_name + '</a>';
                    }
                },
                { data: "ip_address" },
                {
                    data: {
                        _: "date",
                        order: "timestamp",
                        sort: "timestamp"
                    }
                },
                { data: "request" }
            ];

            return columnArray;
            break;

        case 'month':
        default:
            return [{
                    data: "client_checklist_id",
                    render: function(data, type, full, meta) {
                        return '<input type="checkbox" name="row-index[]" value="' + full.client_checklist_id + '" />';
                    },
                    orderable: false
                },
                {
                    data: "company_name",
                    "render": function(data, type, full, meta) {
                        return '<a href="/members/dashboard/entry/view/?client_id=' + full.client_id + '&client_checklist_id=' + full.client_checklist_id + '" class="default-link">' + full.company_name + '</a>';
                    }
                },
                { data: "name" },
                {
                    data: {
                        _: "date_range_start_month_year",
                        order: "date_range_start",
                        sort: "date_range_start"
                    }
                },
                { data: "status" }
            ];
            break;

        case 'analytics-table':
            return [{
                    data: "company_name",
                    "render": function(data, type, full, meta) {
                        return '<a href="/members/dashboard/account/view/?client_id=' + full.client_id + '" class="default-link">' + full.company_name + '</a>';
                    }
                },
                {
                    data: "name",
                    "render": function(data, type, full, meta) {
                        return '<a href="/members/dashboard/entry/view/?client_id=' + full.client_id + '&client_checklist_id=' + full.client_checklist_id + '" class="default-link">' + full.name + '</a>';
                    }
                },
                { data: "question" },
                { data: "period" },
                {
                    data: "answer",
                    "render": function(data, type, full, meta) {
                        return full.rendering == 'url' ? '<a href="/download/?hash=' + full.arbitrary_value + '" class="default-link">' + full.answer + '</a>' : full.answer;
                    }
                }
            ];

            break;

        case 'metric':
            return [{
                    data: "metric_id",
                    render: function(data, type, full, meta) {
                        return '<input type="checkbox" name="row-index[]" value="' + full.metric_id + '" />';
                    }
                },
                { data: "metric" },
                { data: "metric_group_name" },
                { data: "default_unit" },
                { data: "other_units" }
            ];
            break;

        case 'emission_factors_list':
            return [
                { data: "category" },
                { data: "sub_category" },
                { data: "key" },
                { data: "factor" },
                { data: "unit" },
                { data: "default_unit" }
            ];
            break;

        case 'entry_answer_functions':
            return [
                { data: "type" },
                { data: "field" },
                { data: "pseudocode" }
            ];
            break;

        case 'entry_results':
            var columnArray = [];

            if (tableHeaderArray.indexOf('Order') > -1) {
                columnArray.push({
                    data: "page_order",
                    type: "num"
                });
            }
            if (tableHeaderArray.indexOf('Section') > -1) {
                columnArray.push({ data: "section" });
            }
            if (tableHeaderArray.indexOf('Question') > -1) {
                columnArray.push({ data: "question" });
            }
            if (tableHeaderArray.indexOf('Answer') > -1) {
                columnArray.push({
                    data: "answer",
                    "render": function(data, type, full, meta) {
                        if (full.rendering === 'url') {
                            return '<a href="' + full.answer + '" class="default-link">' + full.answer_label + '</a>';
                        } else {
                            return full.answer
                        }
                    }
                });
            }
            if (tableHeaderArray.indexOf('Group') > -1) {
                columnArray.push({ data: "group" });
            }

            return columnArray;
            break;

        case 'entry_results_group':
            return [
                { data: "section" },
                { data: "question" },
                {
                    data: "answer",
                    "render": function(data, type, full, meta) {
                        if (full.rendering === 'url') {
                            return '<a href="' + full.answer + '" class="default-link">' + full.answer_label + '</a>';
                        } else {
                            return full.answer
                        }
                    }
                },
                { data: "group" }
            ];
            break;

        case 'entry_variation':
            return [{
                    data: "company_name",
                    "render": function(data, type, full, meta) {
                        return '<a href="/members/dashboard/account/view/?client_id=' + full.client_id + '" class="default-link">' + full.company_name + '</a>';
                    }
                },
                { data: "section" },
                { data: "question" },
                {
                    data: "current_period",
                    "render": function(data, type, full, meta) {
                        return '<a href="/members/dashboard/entry/view/?client_id=' + full.client_id + '&client_checklist_id=' + full.client_checklist_id + '" class="default-link">' + full.current_period + '</a>';
                    }
                },
                { data: "current_value" },
                {
                    data: "previous_period",
                    "render": function(data, type, full, meta) {
                        return '<a href="/members/dashboard/entry/view/?client_id=' + full.client_id + '&client_checklist_id=' + full.sibling_client_checklist_id + '" class="default-link">' + full.previous_period + '</a>';
                    }
                },
                { data: "previous_value" },
                { data: "variation" }
            ];
            break;

        case 'client_metric_results':
            return [{
                    data: "Entity",
                    "render": function(data, type, full, meta) {
                        return '<a href="/members/dashboard/account/view/?client_id=' + full.client_id + '" class="default-link">' + full.Entity + '</a>';
                    }
                },
                {
                    "render": function(data, type, full, meta) {
                        return '<a href="/members/dashboard/entry/view/?client_id=' + full.client_id + '&client_checklist_id=' + full.client_checklist_id + '" class="default-link">' + full.Period + '</a>';
                    }
                },
                {
                    data: {
                        _: "Date",
                        order: "date_range_start",
                        sort: "date_range_start"
                    }
                },
                { data: "Metric Group" },
                { data: "Metric" },
                { data: "Value" },
                { data: "Unit" },
                { data: "Default Value" },
                { data: "Default Unit" },
                { data: "Justification" },
                { data: "Comment" }
            ];
            break;

        case 'client_metric_emissions':
            return [{
                    data: "company_name",
                    "render": function(data, type, full, meta) {
                        return '<a href="/members/dashboard/account/view/?client_id=' + full.client_id + '" class="default-link">' + full.company_name + '</a>';
                    }
                },
                {
                    "render": function(data, type, full, meta) {
                        return '<a href="/members/dashboard/entry/view/?client_id=' + full.client_id + '&client_checklist_id=' + full.client_checklist_id + '" class="default-link">' + full.date_range_start_month_year + '</a>';
                    }
                },
                {
                    data: {
                        _: "timestamp",
                        order: "timestamp",
                        sort: "timestamp"
                    }
                },
                { data: "value" },
                { data: "unit" },
                { data: "category" },
                { data: "type" },
                { data: "scope" }
            ];
            break;

        case 'dashboard_group':
            return [{
                    data: "user_defined_group_id",
                    render: function(data, type, full, meta) {
                        return '<input type="checkbox" name="row-index[]" value="' + full.user_defined_group_id + '" />';
                    },
                    orderable: false
                },
                { data: "hierarchy" }
            ];
            break;

        case 'client-results-metrics':
            return [{
                    data: {
                        _: "date_entered",
                        order: "timestamp",
                        sort: "timestamp"
                    }
                },
                { data: "company_name" },
                { data: "metric_group_name" },
                { data: "metric" },
                { data: "value" },
                { data: "metric_unit_type" },
                {
                    data: {
                        _: "date_range_start_month_year",
                        order: "date_range_start",
                        sort: "date_range_start"
                    }
                },
            ];
            break;

        case 'entry_status':
            var columnArray = [{
                    data: "client_checklist_id",
                    render: function(data, type, full, meta) {
                        return '<input type="checkbox" name="row-index[]" value="' + full.client_checklist_id + '" />';
                    },
                    orderable: false
                },
                {
                    data: "company_name",
                    "render": function(data, type, full, meta) {
                        return '<a href="/members/dashboard/entry/view/?client_id=' + full.client_id + '&client_checklist_id=' + full.client_checklist_id + '" class="default-link">' + full.company_name + '</a>';
                    }
                },
                { data: "name" }
            ];

            //Score
            if (tableHeaderArray.indexOf('Score') > 0) {
                columnArray.push({
                    data: {
                        _: "score",
                        order: "score_decimal",
                        sort: "score_decimal"
                    }
                });
            }

            //Started
            if (tableHeaderArray.indexOf('Started') > 0) {
                columnArray.push({
                    data: {
                        _: "created_date",
                        order: "created_timestamp",
                        sort: "created_timestamp"
                    }
                });
            }

            //Finished
            if (tableHeaderArray.indexOf('Finished') > 0) {
                columnArray.push({
                    data: {
                        _: "completed_date",
                        order: "completed_timestamp",
                        sort: "completed_timestamp"
                    }
                });
            }

            //Period
            if (tableHeaderArray.indexOf('Period') > 0) {
                columnArray.push({
                    data: {
                        _: "date_range_start_month_year",
                        order: "date_range_start",
                        sort: "date_range_start"
                    }
                });
            }

            //Progress
            if (tableHeaderArray.indexOf('Progress') > 0) {
                columnArray.push({
                    data: "progress",
                    render: function(data, type, full, meta) {
                        return full.completed != null ? '100%' : full.progress + '%';
                    }
                });
            }

            //Status
            if (tableHeaderArray.indexOf('Status') > 0) {
                columnArray.push({ data: "status" });
            }

            return columnArray;
            break;
    }

}

/*** Data Action Button ***/
$(document).ready(function() {
    $('.btn.dashboard-button.action').click(function() {

        //Get the form
        form = $(this).parents('form:first');

        //Get the action field
        var action = typeof $(this).data('type') != 'undefined' ? $(this) : form.find(':input[name="action"] option:selected');
        var command = action.data('type') === 'action' ? action.val() : action.data('type');

        //Check that the action has been selected
        if (action == 'undefined') {
            $.notify({ message: 'No action selected.' }, { 'status': 'danger' });
            return;
        }

        switch (command) {

            case 'add':
                addItem();
                break;

            case 'edit':
                editItem();
                break;

            case 'compare':
                compareItem();
                break;

            default:
                postItem();
                break;
        }

        function addItem() {
            window.location = $(action).data('link');
            return;
        }

        function editItem() {

            if (form.find(':input[name^="row-index"]:checked').length != 1) {
                $.notify({ message: '1 item must be selected.' }, { 'status': 'danger' });
                return;
            } else {
                window.location = $(action).data('link') + $(form).find(':input[name^="row-index"]:checked').val();
            }

            return;
        }

        function compareItem() {

            if (form.find(':input[name^="row-index"]:checked').length < 1) {
                $.notify({ message: '1 or more items must be selected.' }, { 'status': 'danger' });
                return;
            } else {
                $("select[name=action] option:selected").prop("selected", false)
                form.attr('action', location.protocol + '//' + location.host + location.pathname + 'compare/');
                form.submit();
            }
        }

        function postItem() {

            if (form.find(':input[name^="row-index"]:checked').length === 0) {
                $.notify({ message: 'No items selected.' }, { 'status': 'danger' });
                return;
            }

            var itemCount = form.find(':input[name^="row-index"]:checked').length;
            var itemCountString = itemCount == 1 ? "item" : "items";

            //Now confirm
            var result = confirm("Are you sure you want to complete the action '" + (typeof $(action).data('prompt') != 'undefined' ? $(action).data('prompt') : $(action).text()) + "' on " + itemCount + " " + itemCountString + "?");
            if (result) {
                form.submit();
            }

            return;
        }
    });
});

$(document).ready(function() {
    $('[data-action="submit"]').click(function(e) {
        e.preventDefault();
        form = $(this).parents('form:first');
        form.submit();
    });
});

//AJAX ChartsJS
$(document).ready(ajaxChartJs);

function ajaxChartJs() {
    $('.chartjs.ajax-chart').each(function() {
        var container = $(this);
        var canvas = $(this).find('.chartjs');
        var timestamp = $(canvas).data('timestamp');
        var hash = $(canvas).data('hash');
        var key = $(canvas).data('key');
        $.ajax({
            type: 'GET',
            url: '/api/v1/storedQuery/' + $(canvas).data('query-id'),
            data: null,
            success: function(jsonData) {
                //drawChart(jsonData);
                doAjaxChart(container, jsonData)
            },
            beforeSend: function(request) {
                request.setRequestHeader('X-TIMESTAMP', timestamp);
                request.setRequestHeader('X-HASH', hash);
                request.setRequestHeader('X-PUBLIC', key);
            },
            error: function(xhr, error) {
                callback(jQuery.parseJSON(xhr.responseText));
            }
        });
    });
}

function doAjaxChart(element, jsonData) {
    var container = element;
    var canvas = container.find('.chartjs');
    var ctx = $(canvas)[0].getContext("2d");
    var timestamp = $(canvas).data('timestamp');
    var hash = $(canvas).data('hash');
    var key = $(canvas).data('key');
    var dataOptions = $(canvas).data('data-options');
    var chartOptions = $(canvas).data('chart-options');
    if (jsonData.data.length > 0) {
        drawChart(jsonData);
    }

    function drawChart(data) {
        chartType = data.data[0].hasOwnProperty('chart') ? data.data[0].chart : $(canvas).data('type');
        formattedData = formatData(data.data, chartType);
        options = setChartOptions(chartType);
        var chart = new Chart(ctx, {
            type: chartType,
            data: formattedData,
            options: options,
            onComplete: $(container).addClass('completed') //remove the spinner
        });
    }

    function setChartOptions(chartType) {
        var options = {};

        switch (chartType) {
            case 'pie':

                options = {
                    tooltips: {
                        callbacks: {
                            label: function(tooltipItem, data) {
                                var allData = data.datasets[tooltipItem.datasetIndex].data;
                                var tooltipLabel = data.labels[tooltipItem.index];
                                var tooltipData = allData[tooltipItem.index];
                                var total = 0;
                                for (var i in allData) {
                                    total += parseFloat(allData[i]);
                                }

                                var tooltipPercentage = Math.round((tooltipData / total) * 100);
                                return tooltipLabel + ': ' + tooltipData + ' (' + tooltipPercentage + '%)';
                            }
                        }
                    }
                };

                break;

            case 'line':

                options = {
                    scales: {
                        yAxes: [{
                            ticks: {
                                suggestedMin: 0
                            }
                        }]
                    }
                };

                break;
        }

        $.extend(options, chartOptions);
        //console.log(options);

        return options;
    }

    function formatData(jsonData, chartType) {
        var labels = [];
        var data = [];
        var datasets = [];
        var colors = [];
        var index = 0;

        switch (chartType) {
            case 'line':
                //Get the labels
                for (var key in jsonData) {
                    if (jsonData.hasOwnProperty(key)) {
                        if (jsonData[key].hasOwnProperty('label')) {
                            labels.push(jsonData[key]['label']);
                        }
                    }
                }

                //Get the keys
                keys = [];
                for (i = 0; i < jsonData.length; i++) {
                    keys = Object.keys(jsonData[i]);
                }

                for (j = 0; j < keys.length; j++) {
                    if (keys[j].startsWith('data')) {
                        data = [];
                        label = '';

                        for (var key in jsonData) {
                            if (jsonData.hasOwnProperty(key)) {
                                if (jsonData[key].hasOwnProperty(keys[j])) {
                                    data.push(jsonData[key][keys[j]]);
                                }

                                if (jsonData[key].hasOwnProperty('series' + keys[j].split('data')[1])) {
                                    label = jsonData[key]['series' + keys[j].split('data')[1]];
                                }
                            }
                        }

                        //Get the default dataObject
                        var dataObject = {
                            'label': label,
                            'data': data,
                            'borderColor': getHexColor(index),
                            'pointRadius': 0
                        };

                        //Merge any data-attribute options
                        $.extend(dataObject, dataOptions);
                        datasets.push(dataObject);

                        index++;
                    }
                }

                formattedData = { 'labels': labels, 'datasets': datasets };
                return formattedData;

                break;

            case 'bar':
                //Get the labels
                for (var key in jsonData) {
                    if (jsonData.hasOwnProperty(key)) {
                        if (jsonData[key].hasOwnProperty('label')) {
                            labels.push(jsonData[key]['label']);
                        }
                    }
                }

                //Get the keys
                keys = [];
                for (i = 0; i < jsonData.length; i++) {
                    keys = Object.keys(jsonData[i]);
                }

                for (j = 0; j < keys.length; j++) {
                    if (keys[j].startsWith('data')) {
                        data = [];
                        label = '';

                        for (var key in jsonData) {
                            if (jsonData.hasOwnProperty(key)) {
                                if (jsonData[key].hasOwnProperty(keys[j])) {
                                    data.push(jsonData[key][keys[j]]);
                                }

                                if (jsonData[key].hasOwnProperty('series' + keys[j].split('data')[1])) {
                                    label = jsonData[key]['series' + keys[j].split('data')[1]];
                                }
                            }
                        }
                        //Get the default dataObject
                        var dataObject = {
                            'label': label,
                            'data': data,
                            'backgroundColor': getHexColor(index)
                        };

                        //Merge any data-attribute options
                        $.extend(dataObject, dataOptions);
                        datasets.push(dataObject);
                        index++;
                    }
                }

                formattedData = { 'labels': labels, 'datasets': datasets };
                return formattedData;

                break;

            case 'pie':
            default:
                for (var key in jsonData) {
                    if (jsonData.hasOwnProperty(key)) {
                        if (jsonData[key].hasOwnProperty('label')) {
                            labels.push(jsonData[key]['label']);
                        }
                        if (jsonData[key].hasOwnProperty('data')) {
                            data.push(jsonData[key]['data']);
                            colors.push(getHexColor(index));
                        }
                    }
                    index++;
                }
                //Get the default dataObject
                var dataObject = {
                    'data': data,
                    'backgroundColor': colors
                };

                //Merge any data-attribute options
                $.extend(dataObject, dataOptions);
                datasets.push(dataObject);

                formattedData = { 'labels': labels, 'datasets': datasets };
                return formattedData;
                break;
        }
    }

    function getHexColor(index) {
        //Default Colours
        var colors = ['#3366CC', '#DC3912', '#FF9900', '#109618', '#990099', '#3B3EAC', '#0099C6', '#DD4477', '#66AA00', '#B82E2E', '#316395', '#994499', '#22AA99', '#AAAA11', '#6633CC', '#E67300', '#8B0707', '#329262', '#5574A6', '#3B3EAC'];

        //Check for user colours
        if ($(canvas).data('colors') != 'undefined' && $(canvas).data('colors') != '') {
            colors = $(canvas).data('colors').split(',');
        }

        //In case the colour index is out of range
        var returnColor = '#' + Math.floor(Math.random() * 16777215).toString(16);

        if (colors[index] != 'undefined') {
            returnColor = colors[index];
        }
        return returnColor;
    }
}

//Ajax Buttons
$(document).ready(ajaxButtons);

function ajaxButtons() {
    $('.btn[data-button-type="ajax"]').click(function(e) {
        e.preventDefault();
        var $button = $(this);
        var url = $('.jsonData[data-filter-permalink]').data('filter-permalink');
        url += (url.indexOf('?') > 0 ? $button.attr('href').replace('?', '&') : $button.attr('href')) + "&download-mode=ajax";
        window.location = url;
        return;
    });
}

$(document).ready(function() {
    if ($('.dashboard.form.analytics').length > 0) {
        analytics();
    }
});

function analytics() {
    $table = $('.table.analytics.datatable');
    doDataTable($table, { data: null });

    var $checklist = $('.dashboard.form.analytics select[name="checklist_id"]');
    var $question = $('.dashboard.form.analytics select[name="question_id"]');
    var $submitAnalytics = $('.dashboard.form.analytics [data-action="submit-analytics"]');
    var $filtered_client_array = $('.dashboard.form.analytics input[name="filtered_client_array"]').val();
    var $filtered_client_checklist_array = $('.dashboard.form.analytics input[name="filtered_client_checklist_array"]').val();

    //Set the data fields on change and on load
    setQueryFilter();
    $checklist.change(function(e) {
        setQueryFilter();
    });

    function setQueryFilter() {
        if ($checklist.val() != '') {
            //Remove existing select options
            $question.find('option:gt(0)').remove().end();

            //Checklist is set, get the questions
            getQuestions($checklist.val(), function(response) {
                //get the groups
                var optGroups = [];
                for (var i = 0; i < response.questions.length; i++) {
                    if (optGroups.indexOf(response.questions[i].section) < 0) {
                        optGroups.push(response.questions[i].section);
                    }
                }

                for (var i = 0; i < optGroups.length; i++) {
                    $group = $('<optgroup label="' + optGroups[i] + '">');
                    for (var j = 0; j < response.questions.length; j++) {
                        if (response.questions[j].section === optGroups[i]) {
                            $group.append($("<option></option>").attr("value", response.questions[j].question_id).attr("data-type", response.questions[j].type).attr("data-output", response.questions[j].output).text(response.questions[j].question));
                        }
                    }
                    $question.append($group);
                }

                //On complete, bind the chosen JS to the select
                $question.trigger("chosen:updated");
            });

        } else {
            //Remove questions when there is no checklist selected
            $question.find('option[value!=""]').remove();
            $question.trigger("chosen:updated");
        }
    }

    //Check the form feilds are set before submit
    $submitAnalytics.click(function(e) {
        e.preventDefault();
        $checklist.val() === '' || $question.val() === '' ? $.notify({ message: 'Entry and Question must be selected.' }, { 'status': 'danger' }) : getAnalyticsChart();
    });

    function getQuestions(checklist_id, callback) {
        var $dataNode = $('.dashboard.analytics');
        var timestamp = $dataNode.data('timestamp');
        var hash = $dataNode.data('hash');
        var key = $dataNode.data('key');
        $.ajax({
            type: 'POST',
            url: '/api/v1/analytics/checklist/' + checklist_id + '/question/',
            data: {
                'additional_values': $dataNode.data('additional-values') ? true : false
            },
            success: function(jsonData) {
                callback(jsonData);
            },
            beforeSend: function(request) {
                request.setRequestHeader('X-TIMESTAMP', timestamp);
                request.setRequestHeader('X-HASH', hash);
                request.setRequestHeader('X-PUBLIC', key);
            },
            error: function(xhr, error) {
                callback(jQuery.parseJSON(xhr.responseText));
            }
        });
    }

    function getAnalyticsChart() {
        $chart = $('.dashboard.analytics.chartjs');
        $tmpCanvas = $chart.find('.chartjs').clone();
        $chart.find('.chartjs').remove();
        $chart.append($tmpCanvas);
        var $canvas = $chart.find('.chartjs');
        var timestamp = $canvas.data('timestamp');
        var hash = $canvas.data('hash');
        var key = $canvas.data('key');
        $.ajax({
            type: 'POST',
            url: '/api/v1/analytics/chart/checklist/' + $checklist.val() + '/question/' + $question.val() + '/',
            data: {
                'type': $question.find(':selected').data('type'),
                'output': $question.find(':selected').data('output'),
                'filtered_client_array': $filtered_client_array,
                'filtered_client_checklist_array': $filtered_client_checklist_array
            },
            success: function(jsonData) {
                chartType = jsonData.data[0].hasOwnProperty('chart') ? jsonData.data[0].chart : 'null';
                if (chartType != 'null') {
                    $canvas.show();
                    doAjaxChart($chart, jsonData);
                } else {
                    $canvas.hide();
                }
                getAnalyticsTable();
            },
            beforeSend: function(request) {
                request.setRequestHeader('X-TIMESTAMP', timestamp);
                request.setRequestHeader('X-HASH', hash);
                request.setRequestHeader('X-PUBLIC', key);
            },
            error: function(xhr, error) {
                //console.log(jQuery.parseJSON(xhr.responseText));
            }
        });
    }

    function getAnalyticsTable() {
        var timestamp = $table.data('timestamp');
        var hash = $table.data('hash');
        var key = $table.data('key');
        $.ajax({
            type: 'POST',
            url: '/api/v1/analytics/table/checklist/' + $checklist.val() + '/question/' + $question.val() + '/',
            data: {
                'type': $question.find(':selected').data('type'),
                'output': $question.find(':selected').data('output'),
                'filtered_client_array': $filtered_client_array,
                'filtered_client_checklist_array': $filtered_client_checklist_array
            },
            success: function(jsonData) {
                doDataTable($table, jsonData);
            },
            beforeSend: function(request) {
                request.setRequestHeader('X-TIMESTAMP', timestamp);
                request.setRequestHeader('X-HASH', hash);
                request.setRequestHeader('X-PUBLIC', key);
            },
            error: function(xhr, error) {
                //console.log(jQuery.parseJSON(xhr.responseText));
            }
        });
    }
}

$(document).ready(function() {
    $('.dashboard.leaflet-map').each(function() {
        doLeafletMap($(this).attr('id'));
    });
});

function doLeafletMap(id) {

    //Get the Map Settings
    $element = $('#' + id);
    var providers = getLealetMapProviders();
    var mapCenterLat = typeof $element.data('center-lat') != 'undefined' ? $element.data('center-lat') : 0;
    var mapCenterLng = typeof $element.data('center-lng') != 'undefined' ? $element.data('center-lng') : 0;
    var mapCenter = [mapCenterLat, mapCenterLng];
    var mapZoom = typeof $element.data('zoom') != 'undefined' ? $element.data('zoom') : 2;
    var mapMinZoom = typeof $element.data('min-zoom') != 'undefined' ? $element.data('min-zoom') : 2;
    var mapMaxZoom = typeof $element.data('max-zoom') != 'undefined' ? $element.data('max-zoom') : 17;
    var mapType = typeof $element.data('map-type') != 'undefined' ? $element.data('max-type') : 'clients';

    //Control Layers
    var controlLayers = typeof $element.data('map-layers') != 'undefined' ? $element.data('map-layers').split(",") : null;

    ///Create the map with the settigns
    var map = L.map(id, {
        fullscreenControl: true,
        fullscreenControlOptions: {
            position: 'topleft'
        },
        center: mapCenter,
        zoom: mapZoom,
        minZoom: mapMinZoom,
        maxZoom: mapMaxZoom
    });

    L.Icon.Default.imagePath = "/images/";

    //Add the location control
    lc = L.control.locate({
        follow: true,
        strings: {
            title: "Show me where I am"
        }
    }).addTo(map);

    //Add the layer as a marker cluster
    if (mapType === 'clients') {
        var data = $element.data('map-data');
        var cluster = L.markerClusterGroup();
        cluster.addLayer(getMarkerLayer(data));
        var overlayLayers = { "Sites": cluster };
        addOverlayLayersToMap(overlayLayers, map);
    }

    function addOverlayLayersToMap(overlayLayers, map) {
        for (var prop in overlayLayers) {
            map.addLayer(overlayLayers[prop]);
        }
        return;
    }

    //Add the Base Maps and Base Map Control
    var layers = [];
    for (var providerId in providers) {
        layers.push(providers[providerId]);
    }
    var iconCtrlLayers = L.control.iconLayers(layers).addTo(map);
    var ctrlLayers = {};

    //Get any control layers
    if (controlLayers != null && controlLayers.length > 0) {
        (function loopControlLayers(i) {
            switch (controlLayers[i]) {
                case 'GDACS':
                    gdacsLayer(function(response) {
                        ctrlLayers['Global Disasters'] = response;
                        i < (controlLayers.length - 1) ? loopControlLayers(i + 1) : addControlLayers(ctrlLayers);
                    });
                    break;
                case 'AusEarthquakeRisk':
                    ausEarthquakeRiskLayer(function(response) {
                        ctrlLayers['Australian Earthquake Risk'] = response;
                        i < (controlLayers.length - 1) ? loopControlLayers(i + 1) : addControlLayers(ctrlLayers);
                    });
                    break;
            }
        })(0);
    }

    function addControlLayers(layers) {
        L.control.layers(null, layers).addTo(map);
    }

    //GDACS Layer
    function gdacsLayer(callback) {
        var timestamp = $element.data('timestamp');
        var hash = $element.data('hash');
        var key = $element.data('key');
        $.ajax({
            type: 'GET',
            url: '/api/v1/gdacs/',
            data: null,
            success: function(jsonData) {
                var layer = L.geoJson(jsonData.data, {
                    pointToLayer: function(feature, latlng) {
                        return L.circleMarker(latlng, feature.properties.style);
                    },

                    onEachFeature: function(feature, layer) {
                        layer.bindPopup(
                            '<div class="leaflet-marker-label">' +
                            '<p class="label-name disasters">' + feature.properties.name + '</p>' +
                            '<p class="label-content disasters">' + feature.properties.description + '</p>' +
                            '<p class="label-content disasters"><a href="' + feature.properties.link + '" target="_blank">More information</a></p>' +
                            '</div>'
                        );
                    }
                });

                callback(layer);
            },
            beforeSend: function(request) {
                request.setRequestHeader('X-TIMESTAMP', timestamp);
                request.setRequestHeader('X-HASH', hash);
                request.setRequestHeader('X-PUBLIC', key);
            },
            error: function(xhr, error) {
                //console.log(jQuery.parseJSON(xhr.responseText));
            }
        });
    }

    function ausEarthquakeRiskLayer(callback) {
        $.getJSON("/js/aus-earthquake-risk.geojson", function(json) {
            var layer = L.geoJson(json, {

                onEachFeature: function(feature, layer) {
                    var popupContent = getFeaturePopupTable(feature);
                    layer.bindPopup(popupContent);
                },
                style: style
            });
            callback(layer);
        });
    }

    //Get the color for the geojson that has been added to the map
    //expects a whole number between 0 and 100 (percentage)
    function getColor(d) {
        return d > 90 ? '#800026' :
            d > 80 ? '#bd0026' :
            d > 70 ? '#e31a1c' :
            d > 60 ? '#fc4e2a' :
            d > 50 ? '#fd8d3c' :
            d > 40 ? '#feb24c' :
            d > 30 ? '#fed976' :
            d > 20 ? '#ffeda0' :
            d > 10 ? '#ffffcc' :
            '#ffffff';
    }

    function style(feature) {
        return {
            fillColor: getColor(
                riskval2percent(feature.properties.RISKVAL)
            ),
            weight: 1,
            opacity: 1,
            color: 'white',
            dashArray: '3',
            fillOpacity: 0.6
        };
    }

    function riskval2percent(riskval) {
        return riskval === '> 0.10' ? 75 :
            riskval === '0.05 - 0.10' ? 50 :
            25;

    }

    function getFeaturePopupTable(feature) {
        html = '';

        html += '<table class="table table-striped table-bordered">';
        html += '<tr><th>Attribute</th><th>Value</th></tr>';
        for (var key in feature.properties) {
            if (feature.properties.hasOwnProperty(key)) {
                html += '<tr><td>' + key + '</td><td>' + feature.properties[key] + '</td></tr>';
            }
        }
        html += '</table>';

        return html;
    }

    return;
}

//Get the layer Data
function getMarkerLayer(data) {
    var layerData = L.geoJson(data, {
        onEachFeature: function(feature, layer) {
            layer.bindPopup(
                '<div class="leaflet-marker-label">' +
                '<p class="label-name client">' + feature.properties.name + '</p>' +
                '<p class="label-content client">' +
                '<a href="/members/dashboard/account/view/?client_id=' + feature.properties.client_id + '">More Information</a>' +
                '</p>' +
                '</div>'
            );
        }
    });

    return layerData;
}



function getLealetMapProviders() {
    /***** Map Types *****/
    var providers = {};
    var iconPath = '/themes/angle/vendor/leaflet/plugins/leaflet.iconlayers/examples/';

    providers['Esri_Street'] = {
        title: 'Street',
        icon: iconPath + 'icons/esri_street.png',
        layer: L.tileLayer('https://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer/tile/{z}/{y}/{x}', {
            attribution: 'Tiles &copy; Esri &mdash; Source: Esri, DeLorme, NAVTEQ, USGS, Intermap, iPC, NRCAN, Esri Japan, METI, Esri China (Hong Kong), Esri (Thailand), TomTom, 2012'
        })
    };

    providers['Esri_Satellite'] = {
        title: 'Satellite',
        icon: iconPath + 'icons/esri_satellite.png',
        layer: L.tileLayer('https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}', {
            attribution: 'Tiles &copy; Esri &mdash; Source: Esri, i-cubed, USDA, USGS, AEX, GeoEye, Getmapping, Aerogrid, IGN, IGP, UPR-EGP, and the GIS User Community'
        })
    };
    /*
    providers['OpenTopoMap'] = {
        title: 'Topographic',
        icon: iconPath + 'icons/esri_topographic.png',
        layer: L.tileLayer('https://{s}.tile.opentopomap.org/{z}/{x}/{y}.png', {
            maxZoom: 17,
            attribution: 'Map data: &copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>, <a href="http://viewfinderpanoramas.org">SRTM</a> | Map style: &copy; <a href="https://opentopomap.org">OpenTopoMap</a> (<a href="https://creativecommons.org/licenses/by-sa/3.0/">CC-BY-SA</a>)'
        })
    };

    providers['Stamen_Toner'] = {
        title: 'Contrast Dark',
        icon: iconPath + 'icons/stamen_toner.png',
        layer: L.tileLayer('https://stamen-tiles-{s}.a.ssl.fastly.net/toner/{z}/{x}/{y}.png', {
            attribution: 'Map tiles by <a href="http://stamen.com">Stamen Design</a>, <a href="http://creativecommons.org/licenses/by/3.0">CC BY 3.0</a> &mdash; Map data &copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>',
            subdomains: 'abcd',
            minZoom: 0,
            maxZoom: 20,
            ext: 'png'
        })
    };

    providers['Stamen_Toner_Light'] = {
        title: 'Contrast Light',
        icon: iconPath + 'icons/stamen_toner_light.png',
        layer: L.tileLayer('https://stamen-tiles-{s}.a.ssl.fastly.net/toner-lite/{z}/{x}/{y}.png', {
            attribution: 'Map tiles by <a href="http://stamen.com">Stamen Design</a>, <a href="http://creativecommons.org/licenses/by/3.0">CC BY 3.0</a> &mdash; Map data &copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>',
            subdomains: 'abcd',
            minZoom: 0,
            maxZoom: 20,
            ext: 'png'
        })
    };
    */

    return providers;
}

$(document).ready(resultFilter);

function resultFilter() {

    //The filters data
    var filters = [];
    var setFilters = [];

    //Call the ajax function to get the filter options
    $('.dashboard.result-filter').each(function() {
        getFilterOptions($(this), function(data) {
            filters = data;
            setFilterFieldOptions();
            setPostPackFilterFields();
        });
        setFilters = $(this).data('json-post');
        setFilters = setFilters.setFilters;
    });

    $(document).on('change', '.result-filter.filter-field', function() {
        setQueryFieldOptions($(this));
        setSearchFieldOptions($(this));
    });

    //Add a new row in the filter panel
    $('#add-filter-row').click(function(e) {
        e.preventDefault();
        addResultFilterRow();
    });

    //Delete the current row in the filter panel
    $(document).on('click', '.remove-filter-row', function(e) {
        e.preventDefault();
        $(e.target).closest('.row.inline-form-container').remove();

        //Update Row Indexes
        for (var i = 0; i < $('#data-filter-container .inline-form-container').length; i++) {
            setRowIndex($('#data-filter-container .inline-form-container').eq(i));
        }
    });

    function setRowIndex($row) {
        //Udate the index of the fields
        $row.find('.filter-field').attr('name', 'filter-field[' + $row.index() + ']');
        $row.find('.filter-query').attr('name', 'filter-type[' + $row.index() + ']');
        $row.find('.filter-search.select').attr('name', 'filter-value[' + $row.index() + '][]');
        $row.find('.filter-search.text').attr('name', 'filter-value[' + $row.index() + ']');
    }

    function addResultFilterRow() {
        $('#data-filter-container').append($('#data-filter-template-row').html());
        $('#data-filter-container .inline-form-container:last').find('.chosen-select-dynamic').chosen();
        $row = $('#data-filter-container .inline-form-container:last');
        setRowIndex($row);

        return $row;
    }

    function setPostPackFilterFields() {
        if (typeof setFilters != 'undefined' && setFilters.hasOwnProperty("filter-field")) {

            if (setFilters["filter-field"].length > 0) {
                for (var i = 0; i < setFilters["filter-field"].length; i++) {
                    $row = addResultFilterRow();

                    //Set the filter field
                    $filterField = $row.find('select.result-filter.filter-field');
                    $filterField.val(setFilters["filter-field"][i]);
                    $filterField.trigger("chosen:updated");

                    //Now set the query field otions
                    $queryField = setQueryFieldOptions($filterField);
                    $queryField.val(setFilters["filter-type"][i]);
                    $queryField.trigger("chosen:updated");

                    //Now set the search value
                    $searchField = setSearchFieldOptions($filterField);
                    if (Object.prototype.toString.call(setFilters["filter-value"][i]) === '[object Array]') {
                        for (var j = 0; j < setFilters["filter-value"][i].length; j++) {
                            $searchField.find('option[value="' + setFilters["filter-value"][i][j] + '"]').attr('selected', 'selected');
                        }
                    } else {
                        $searchField.val(setFilters["filter-value"][i]);
                    }
                    $searchField.trigger("chosen:updated");
                }
            }
        }
    }

    function setFilterFieldOptions() {
        $('.result-filter.filter-field').each(function() {
            $filterField = $(this);

            for (var i = 0; i < filters.data.groups.length; i++) {
                filterGroup = filters.data.groups[i];
                $group = $('<optgroup label="' + filterGroup.description + '">');
                for (var j = 0; j < filterGroup.fields.length; j++) {
                    $group.append($("<option></option>").attr("value", filterGroup.fields[j].id).attr("data-type", filterGroup.fields[j].type).text(filterGroup.fields[j].label));
                }
                $filterField.append($group);
            }

            //On complete, bind the chosen JS to the select
            $filterField.trigger("chosen:updated");

        });
    }

    //Given filter field dropdown, find the associated query field an set the options
    function setQueryFieldOptions($filterField) {
        $queryField = $filterField.closest('.filter-field.group-row').find('select.result-filter.filter-query');

        //Remove existing select options
        $queryField.find('option:gt(0)').remove().end();

        for (var i = 0; i < filters.data.queries.length; i++) {
            if (filters.data.queries[i].type === $filterField.find(':selected').data('type')) {
                $queryField.append($("<option></option>").attr("value", filters.data.queries[i].filter_query_id).attr("data-type", filters.data.queries[i].type).text(filters.data.queries[i].explanation));
            }
        }

        //On complete, bind the chosen JS to the select
        $queryField.trigger("chosen:updated");
        return $queryField;
    }

    function setSearchFieldOptions($filterField) {
        $queryField = $filterField.closest('.filter-field.group-row').find('select.result-filter.filter-field');
        $searchTextField = $filterField.closest('.filter-field.group-row').find('.result-filter.filter-search.text');
        $searchSelectField = $filterField.closest('.filter-field.group-row').find('.result-filter.filter-search.select');

        if ($filterField.find(':selected').data('type') === 'select') {
            //Hide the text field
            $searchTextField.closest('.search.text').addClass('hidden');
            $searchTextField.prop('disabled', true);

            //Show the select field
            $searchSelectField.closest('.search.select').removeClass('hidden');
            $searchSelectField.prop('disabled', false);

            //Add the options to the select list
            for (var i = 0; i < filters.data.groups.length; i++) {
                filterGroup = filters.data.groups[i];
                for (var j = 0; j < filterGroup.fields.length; j++) {
                    if (filterGroup.fields[j].id === $filterField.val()) {
                        if (filterGroup.fields[j].hasOwnProperty('options') && filterGroup.fields[j].options.length > 0) {
                            for (var k = 0; k < filterGroup.fields[j].options.length; k++) {
                                option = filterGroup.fields[j].options[k];
                                $searchSelectField.append($("<option></option>").attr("value", option.id).text(option.label));
                            }
                        }
                    }
                }
            }

            $searchSelectField.trigger("chosen:updated");
        } else {
            //Hide the select field
            $searchSelectField.closest('.search.select').addClass('hidden');
            $searchSelectField.prop('disabled', true);
            $searchSelectField.trigger("chosen:updated");

            //Show the search field
            $searchTextField.closest('.search.text').removeClass('hidden');
            $searchTextField.prop('disabled', false);
        }

        return $filterField.find(':selected').data('type') === 'select' ? $searchSelectField : $searchTextField;
    }

    //Ajax function to get the filter options
    function getFilterOptions($element, callback) {
        var timestamp = $element.data('timestamp');
        var hash = $element.data('hash');
        var key = $element.data('key');
        $.ajax({
            type: 'POST',
            url: '/api/v1/dashboard/result-filter/',
            data: {
                'data': $element.data('post-data')
            },
            success: function(jsonData) {
                //console.log(jsonData);
                callback(jsonData);
            },
            beforeSend: function(request) {
                request.setRequestHeader('X-TIMESTAMP', timestamp);
                request.setRequestHeader('X-HASH', hash);
                request.setRequestHeader('X-PUBLIC', key);
            },
            error: function(xhr, error) {
                //console.log(jQuery.parseJSON(xhr.responseText));
            }
        });
    }

}


$(document).ready(populateDynamicSelect);

function populateDynamicSelect() {
    var dataType = '';
    var options = {};

    //Call the ajax function to get the filter options
    $('.chosen-select-dynamic.ajax-populate').each(function() {
        var $element = $(this);
        dataType = $element.data('type');

        getDynamicSelectOptions($element, function(data) {
            setDynamicSelectOptions($element, data.data);
        });
    });

    function setDynamicSelectOptions($element, data) {
        $element.find('option:gt(0)').remove().end();

        for (var i = 0; i < data.length; i++) {
            if ($element.data('selected').toString() === data[i].option_value.toString()) {
                $element.append($("<option></option>").attr("value", data[i].option_value).attr("selected", "selected").text(data[i].option_label));
            } else {
                $element.append($("<option></option>").attr("value", data[i].option_value).text(data[i].option_label));
            }
        }

        //On complete, bind the chosen JS to the select
        $element.chosen();
    }

    //Ajax function to get the filter options
    function getDynamicSelectOptions($element, callback) {
        var timestamp = $element.data('timestamp');
        var hash = $element.data('hash');
        var key = $element.data('key');
        $.ajax({
            type: 'POST',
            url: '/api/v1/dashboard/' + dataType + '/',
            data: {
                'data': $element.data('post-data')
            },
            success: function(jsonData) {
                callback(jsonData);
            },
            beforeSend: function(request) {
                request.setRequestHeader('X-TIMESTAMP', timestamp);
                request.setRequestHeader('X-HASH', hash);
                request.setRequestHeader('X-PUBLIC', key);
            },
            error: function(xhr, error) {
                //console.log(jQuery.parseJSON(xhr.responseText));
            }
        });
    }
}

$(document).ready(uniqueUsernameLookup);

function uniqueUsernameLookup() {
    window.Parsley.addValidator('uniqueUserLookup', {
        validateString: function(value, requirment, instance) {
            $element = instance.$element;
            var timestamp = $element.data('timestamp');
            var hash = $element.data('hash');
            var key = $element.data('key');
            var xhr = $.ajax({
                type: 'GET',
                url: '/api/v1/unique/user/' + $element.val(),
                beforeSend: function(request) {
                    request.setRequestHeader('X-TIMESTAMP', timestamp);
                    request.setRequestHeader('X-HASH', hash);
                    request.setRequestHeader('X-PUBLIC', key);
                }
            });

            return xhr.then(function(json) {
                if (!json.unique && $element.val() != $element.data('selected').toString()) {
                    return $.Deferred().reject('This email address has already been registered.');
                }
            });
        },
        messages: {
            en: 'This email address has already been registered.'
        }
    });
}

//Notify Messages
$(document).ready(notifyMessage);

function notifyMessage() {
    var status = { "success": "success", "warning": "warning", "error": "danger" };

    $('.notify-message').each(function() {
        $.notify({ message: $(this).data('message') }, { 'status': status[$(this).data('type')] });
        return;
    });
}

$(document).ready(setDisabledInputs);

function setDisabledInputs() {

    //Load
    $('.panel-collapse.collapse:not(".in")').each(function() {
        $(this).find(':input').prop('disabled', true);
    });

    //Collapse
    $('.panel-collapse.collapse').on('hidden.bs.collapse', function() {
        $(this).find(':input').prop('disabled', true);
    });

    //Expand
    $('.panel-collapse.collapse').on('shown.bs.collapse', function() {
        $(this).find(':input').prop('disabled', false);
    });

}

$(document).ready(toggleTableSelectors);

function toggleTableSelectors() {
    $(':input[name="row-index-toggle"]').change(function() {
        if ($(this).is(":checked")) {
            $(this).attr('data-status', 'on');
            $(this).closest('.table.ajax-datatable').find(':input[type="checkbox"]').prop('checked', true);
        } else {
            $(this).attr('data-status', 'off');
            $(this).closest('.table.ajax-datatable').find(':input[type="checkbox"]').prop('checked', false);
        }
    });
}

//ClassyLoader Plugin
$('[data-classyloader]').each(initClassyLoader);

function initClassyLoader() {
    var options = $(this).data();
    $(this).ClassyLoader(options);
}

/***** Tooltip ******/
$(document).ready(function() {
    $('[data-toggle="tooltip"]').tooltip();
    $('[rel="tooltip"]').tooltip();
});

/**
 * Chart JS Static
 * Run chart JS using data inside data attributes
 */
function staticChartJs() {
    $('.chart-js.static').each(function() {
        //Chart Settings
        var type = $(this).data('type') || 'pie';
        var labels = $(this).data('labels') || [];
        var data = $(this).data('data') || [];
        var colours = $(this).data('colours') || [];
        var modifier = $(this).data('modifier') || null;
        var colourArray = ['#3366CC', '#DC3912', '#FF9900', '#109618', '#990099', '#3B3EAC', '#0099C6', '#DD4477', '#66AA00', '#B82E2E', '#316395', '#994499', '#22AA99', '#AAAA11', '#6633CC', '#E67300', '#8B0707', '#329262', '#5574A6', '#3B3EAC'];

        //Get chart colours
        for (var i = 0; i < data.length; i++) {
            colours.push(colourArray[i] != 'undefined' ? colourArray[i] : '#' + Math.floor(Math.random() * 16777215).toString(16));
        }

        //Set the data values
        for (var i = 0; i < data.length; i++) {
            switch (modifier) {
                case 'abs':
                    data[i] = Math.abs(data[i]);
                    break;
                default:
                    data[i] = data[i];
                    break;
            }
        }

        //Options //
        var options = {
            maintainAspectRatio: false,
            responsiveAnimationDuration: 500,
            responsive: true
        }

        //Canvas
        var ctx = $(this)[0].getContext("2d");

        function getData() {
            switch (type) {
                case 'line':
                    return data;
                    break;

                default:
                    return [{
                        data: data,
                        backgroundColor: colours
                    }];
                    break;
            }
        }

        //Data
        var data = {
            labels: labels,
            datasets: getData(),
            options: options
        }

        //Create Chart
        var chart = new Chart(ctx, {
            type: type,
            data: data
        });
    });
}

$(document).ready(staticChartJs);

/**
 * Data Table Static
 * Run Data Table on existing table
 */
function staticDataTable() {
    $('.data-table.static').each(function() {
        dataTable = $(this).DataTable({
            dom: '<"col-md-4"l><"col-md-4 text-center"B><"col-md-4"f><"col-md-12"t><"col-md-6"i><"col-md-6"pr>',
            buttons: ['copy', 'excel', 'csv', 'pdf'],
            lengthMenu: [
                [10, 25, 50, 100, 200, -1],
                [10, 25, 50, 100, 200, "All"]
            ],
            order: [
                [$(this).data('order-col') || 0, 'asc']
            ]
        });
        dataTable.buttons().container().appendTo($('.col-sm-6:eq(1)', dataTable.table().container()));
    });
}

$(document).ready(staticDataTable);
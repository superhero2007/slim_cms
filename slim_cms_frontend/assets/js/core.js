// Body Wrap
var screenRes = $(window).width(),
    screenHeight = $(window).height(),
    html = $('html');

$(".body-wrap").css("min-height", screenHeight).queue(function() {});
$(window).resize(function() {
    screenHeight = $(window).height();
    $(".body-wrap").css("min-height", screenHeight);
});

/*core JS */
if (!String.prototype.startsWith) {
    String.prototype.startsWith = function(searchString, position) {
        position = position || 0;
        return this.substr(position, searchString.length) === searchString;
    };
}

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

/**
 *  Form Actions
 */
$('#entry-submit, .buttons.navigation-buttons .assessment-footer-buttons, .entry-save-page').click(function(e) {
    e.preventDefault();
    $('fieldset.entry.question.dependent-question[data-triggered="false"]').each(function() {
        $(this).find(':input').prop('disabled', true);
    });
    $('#action').val($(this).data('action'));
    $('#entry-form').submit();
});

$('.submit-form-button').click(function(e) {
    e.preventDefault();
    $(this).parents('form').submit();
});

/**
 *  Form Question Triggering
 */ //

function updateDependentContent() {
    //Trigger Questions
    $('fieldset.entry.question.dependent-question').each(function() {
        $(this).find('.dependency[data-triggered="1"]').length > 0 ? $(this).attr('data-triggered', 'true').slideDown('1000').find(':input').prop('disabled', false).trigger('chosen:updated') : $(this).attr('data-triggered', 'false').slideUp('1000').find(':input').prop('disabled', true).trigger('chosen:updated');
    });

    //Trigger Question Other Field
    $('fieldset.entry.question .question-other').each(function() {
        $(this).attr('data-triggered') == '0' ? $(this).slideUp('1000').prop('disabled', true).parent('.question').find('.counter-message').slideUp('1000') : $(this).slideDown('1000').prop('disabled', false).parent('.question').find('.counter-message').slideDown('1000');
    });
}

//Select Trigger Check //
function updateSelectTrigger($element) {
    if ($element.hasClass('hasChildren')) {
        $element.find('option').each(function() {
            $('.dependency[data-question-id="' + $element.data('question-id') + '"][data-answer-id="' + $(this).val() + '"][data-index="' + $element.data('index') + '"]').attr('data-triggered', $(this).is(':selected') ? '1' : '0');
        });
    }
}

//Radio Button, Checkbox Click Trigger Check
function updateCheckedTrigger($element) {
    $('input[name="' + $element[0].name + '"]').each(function() {
        if ($(this).hasClass('hasChildren') || $(this).hasClass('checkboxOther')) {
            $('.dependency[data-question-id="' + $(this).data('question-id') + '"][data-answer-id="' + $(this).data('answer-id') + '"][data-index="' + $(this).data('index') + '"]').attr('data-triggered', $(this).is(':checked') ? '1' : '0');
            $('.question-other[data-question-id="' + $(this).data('question-id') + '"][data-answer-id="' + $(this).data('answer-id') + '"][data-index="' + $(this).data('index') + '"]').attr('data-triggered', $(this).is(':checked') ? '1' : '0');
        }
    });
}

//Toggle Form Fields
$(document).ready(function() {
    $('.entry.page .toggle-form-fields').click(function(e) {
        e.preventDefault();
        $($(this)).siblings().removeClass('active');
        $($(this)).addClass('active');
        $('.question-container:not(.' + $(this).data('target') + '),.formGroup:not(.' + $(this).data('target') + ')').toggleClass('hidden');
    });
});

//Form Load 
$(document).ready(function() {
    $('.entry.page select').each(function() {
        updateSelectTrigger($(this));
    });

    $('.entry.page input[type="radio"],[type="checkbox"]').click(function() {
        updateCheckedTrigger($(this));
    });

    updateDependentContent();
});

//Select Question Change Trigger
$(document).on('change', '.entry.page select', function() {
    updateSelectTrigger($(this));
    updateDependentContent();
});

//Radio Button, Checkbox Question Click Trigger
$(document).on('click', '.entry.page input[type="radio"],[type="checkbox"]', function() {
    updateCheckedTrigger($(this));
    updateDependentContent();
});

/***
 * Field Permissions
 */
/*
$(document).ready(function() {
    //Set to readonly
    $('.question-container.question[data-permission="read-only"] :input').attr('readonly', 'readonly');
});
*/

/**
 * Report Reapeatable
 */
var reportRepeatable = (function() {

    var init = function() {
        bindEvents();
    }

    var bindEvents = function() {
        $('.reportContainer .repeatable .add').click(function(e) {
            e.preventDefault();
            duplicate($(this));
        });
    }

    var duplicate = function($e) {
        $clone = $e.parents('.repeatable')
            .find('.repeatable.template')
            .clone()
            .removeClass('template')
            .removeClass('hidden')
            .addClass('duplicate')
            .appendTo($e.parents('.repeatable')
                .find('.repeatable.target')
            );
        $clone.find(':input').prop('disabled', false);
        setEvents($clone);
    }

    var setEvents = function($e) {
        $e.find('.date-time-picker.day').datetimepicker({ locale: 'en-au', format: 'DD/MM/YYYY' });
    }

    var disable = function($e) {
        $e.hide().find(':input').attr('disabled', 'disabled');
    }

    return {
        init: init
    }
})();
$(function() { reportRepeatable.init() });

/**
 * Form Group Reapeatable
 */
$(document).ready(function() {
    setFormGroup();
});

function setFormGroup() {
    //Template rows
    $('.entry.formGroup .formRow.template').find(':input[data-type="question"],:input[data-type="question-other"]').prop('disabled', true).val('').trigger('chosen:updated');

    //Add Repeatable
    $('.entry.formGroup .repeatable.add').click(function(e) {
        e.preventDefault();
        $formGroup = $(this).parents('.entry.formGroup');
        $form = $formGroup.closest('form');
        max_rows = parseInt($formGroup.attr('max_rows'));

        if (max_rows == 0 || $formGroup.find('.formRow').length < max_rows) {
            $form.closest('form').parsley().destroy();
            if ($formGroup.find('.formRow.template').length == 0) {
                $formRow = $formGroup.find('.formRow').last().clone();
                setFieldEvents($formRow);
                $formRow.find(':input[data-type="question"],:input[data-type="question-other"]').prop('disabled', false).prop('checked', false).trigger('chosen:updated');
                $formRow.find('.dependency[data-page-id="' + $formGroup.data('page-id') + '"], input[data-answer-type="question-other"]').attr('data-triggered', '0');
                $formRow.find(':input[data-type="question"]:not([type="checkbox"],[type="radio"]), :input[data-type="question-other"]').val(''); //All but checkbox
                GBCFileUpload.clear($formRow.find('.bimp.file-upload'));
                $formRow.insertAfter($formGroup.find('.formRow').last());
                updateDependentContent();
            } else {
                $formGroup.find('.formRow.template').show().removeClass('template').find(':input[data-type="question"],:input[data-type="question-other"]').prop('disabled', false).trigger('chosen:updated');
            }
            $form.closest('form').parsley();
        } else {
            alert("A maximum of " + max_rows + (max_rows == 1 ? " row is" : " rows are") + " permitted.");
        }
        setRowIndex($formGroup);
    });

    //Delete Repeatable  
    $(document).on('click', '.entry.formGroup .repeatable.delete', function(e) {
        e.preventDefault();
        $formGroup = $(this).parents('.entry.formGroup');
        $formRow = $(this).parents('.formRow');
        $form = $formGroup.closest('form');
        min_rows = parseInt($formGroup.attr('min_rows'));

        if ($formGroup.find('.formRow').length > min_rows) {
            $form.parsley().destroy();
            result = confirm("Are you sure you want to delete this row?");
            if (result) $formRow.hide('slow', function() {
                $formGroup.find('.formRow').length > 1 ? $formRow.remove() : $formRow.addClass('template').find(':input[data-type="question"],:input[data-type="question-other"]').val('').prop('disabled', true);
                setRowIndex($formGroup);
            });
            $form.parsley();
        } else {
            alert("At least " + min_rows + (min_rows == 1 ? " row is" : " rows are") + " required.");
        }
        GBCFileUpload.clear($formRow.find('.bimp.file-upload'));
    });

    //Set field events
    function setFieldEvents($element) {
        $element.find('.chosen-container').remove();
        $element.find('.date-time-picker.day').datetimepicker({ locale: 'en-au', format: 'DD/MM/YYYY' });
        $element.find('.chosen-select').chosen();
        if($element.find('.bimp.file-upload').length) {
            GBCFileUpload.init($element.find('.bimp.file-upload'));
        }
    }

    //Set the input names
    function setInputNames($element, index) {
        $element.find(':input[data-type="question"],:input[data-type="question-other"]').each(function() {
            index = index != undefined ? index : parseInt($(this).attr('data-index'));
            name = $(this).data('type') + '[' + $(this).data('question-id') + ']' + '[' + (index + 1) + ']';
            name += ($.inArray($(this).data('answer-type'), ['checkbox', 'checkbox-other', 'drop-down-list']) == -1 ? '[' + $(this).data('answer-id') + ']' : '[]');
            $(this).attr('name', name).attr('data-index', (index + 1)).data('index', (index + 1)).attr('data-parsley-errors-container', '.entry.question.question-id-' + $(this).data('question-id') + '-' + (index + 1) + ' .error-message');
            $(this).closest('.entry.question.form-group.question-id-' + $(this).data('question-id') + '-' + index).removeClass('question-id-' + $(this).data('question-id') + '-' + index).addClass('question-id-' + $(this).data('question-id') + '-' + (index + 1));
            $(this).closest('fieldset').find('.dependency').attr('data-index', (index + 1));
            $element.find('.bimp.file-upload').attr('data-index', (index + 1)); //File Upload
            $element.find('.file-delete-button .delete').attr('data-index', (index + 1)); //File Upload
        });
    }

    //Set the order of rows
    function setRowIndex($formGroup) {
        $formGroup.find('.formRow').each(function(index) {
            setInputNames($(this), index);
            $(this).find('.repeatable.order').each(function() {
                $(this).html(index + 1);
            });
        });
    }

    //Set sortable where applicable
    $('.repeatable.sortable .list').each(function() {
        $formGroup = $(this).parents('.entry.formGroup');
        Sortable.create($(this)[0], {
            handle: '.repeatable.move',
            animation: 300,
            onEnd: function() {
                setRowIndex($formGroup);
            }
        });
    });
}

/**
 *  Slider input (Range & Percent)
 */
$(document).ready(function() {
    $('.slider.slider-percent').bootstrapSlider({
        formatter: function(value) {
            return value + '%';
        },
        tooltip: 'always'
    });

    $('.slider.slider-range').bootstrapSlider({
        formatter: function(value) {
            var element = $(':input[data-slider-id="' + $(this).attr("id") + '"]');
            return value + " " + $(element).data('unit');
        },
        tooltip: 'always'
    });
});

/**
 *  File Upload Scripting
 */
var GBCFileUpload = (function() {
    'use strict';
    var url = '/upload/';

    var init = function($e) {
        var formData = new FormData();
        formData.append('action', 'upload');
        var $container = $e.closest('.file-upload-container');
        var $file = $container.find(':input[data-type="question"]');

        //Set delete event
        $container.find('.file-delete-button .delete').on('click', function() {
            deleteFile($(this));
        });

        //Check if there is already a valid file
        if ($file.val().length > 0) {
            $container.find('.file-name-status').html('<a href="/download/?hash=' + $file.val() + '" class="default-link">' + $file.data('name') + ($file.data('size').toString().length > 0 ? ' (' + bytesToSize($file.data('size')) + ')' : '') + '</a>');
            $container.find('.file-delete-button').addClass('in');
            $container.find('.progress .progress-bar').css('width', '100%');
        } else {
            $container.find('.file-upload-button').addClass('in');
        }

        $e.fileupload({
            url: url,
            dataType: 'json',
            autoUpload: false,
            formData: formData,
            done: function(e, data) {
                //Set the display file name
                $container.find('.file-name-status').html('<a href="/download/?hash=' + data.result.files[0].hash + '" class="default-link">' + data.result.files[0].name + ' (' + bytesToSize(data.result.files[0].size) + ')</a>');
                $file.val(data.result.files[0].hash);
                $file.attr('data-name', data.result.files[0].name);
                $file.attr('data-size', data.result.files[0].size);
                $container.find('.file-upload-button').toggleClass('in');
                $container.find('.file-delete-button').toggleClass('in');
            },
            fail: function(e, data) {
                $container.find('.file-name-status').html(data.errorThrown);
            },
            progress: function(e, data) {
                var progress = parseInt(data.loaded / data.total * 100, 10);
                $container.find('.progress .progress-bar').css(
                    'width',
                    progress + '%'
                );
                $container.find('.file-name-status').html(progress + '%');
            },
            add: function(e, data) {
                var valid = validateUploadData(data);
                if (valid == true) {
                    data.submit();
                } else {
                    $(this).closest('.file-upload-container').find('.file-name-status').html(valid);
                    data = [];
                }
            }
        }).prop('disabled', !$.support.fileInput).parent().addClass($.support.fileInput ? undefined : 'disabled');
    }

    var deleteFile = function($e) {
        var result = confirm("Are you sure you want to delete this file?");
        if (result) {
            var $container = $e.closest('.file-upload-container');
            var $file = $container.find(':input[data-type="question"]');

            $.ajax({
                type: "POST",
                url: '/upload/',
                data: { 'action': 'delete', 'hash': $file.val() },
                success: function(data) {
                    if (data.response[0].error == 'false') {
                        $e.val('');
                        $file.attr('data-name', '').attr('data-size', '').val('');
                        $container.find('.file-name-status').html('');
                        $container.find('.file-delete-button').toggleClass('in');
                        $container.find('.file-upload-button').toggleClass('in');
                        $container.find('.progress .progress-bar').css('width', '0%');
                    }
                },
                dataType: 'json'
            });
        }
        return;
    }

    var clear = function($e) {
        var $container = $e.closest('.file-upload-container');
        $e.val('');
        var $file = $container.find(':input[data-type="question"]');
        $file.attr('data-name', '').attr('data-size', '').val('');
        $container.find('.file-name-status').html('');
        $container.find('.file-delete-button').removeClass('in');
        $container.find('.file-upload-button').addClass('in');
        $container.find('.progress .progress-bar').css('width', '0%');
        return;
    }

    var bytesToSize = function(bytes) {
        bytes = parseInt(bytes);
        var sizes = ['Bytes', 'KB', 'MB', 'GB', 'TB'];
        if (bytes === 0) return '0 Byte';
        var i = parseInt(Math.floor(Math.log(bytes) / Math.log(1024)));
        return Math.round(bytes / Math.pow(1024, i), 2) + ' ' + sizes[i];
    };

    var validateUploadData = function(data) {
        var valid = true;
        var extensions = ["jpg", "jpeg", "txt", "png", "pdf", "gif", "eps", "doc", "docx", "xls", "xlsx", "mp4", "mov", "tiff", "msg", "htm", "html", "eml", "zip"];
        var maxSize = 52428800; //50MB

        //Check file size
        if (data.originalFiles[0].size > maxSize) {
            valid = 'File exceeds maximum limit of ' + bytesToSize(maxSize) + '.';
        }

        //Check file extension
        var ext = data.originalFiles[0].name.split('.').pop();
        if (extensions.indexOf(ext.toLowerCase()) == -1) {
            valid = 'File type not allowed.';
        }

        return valid;
    };

    return {
        init: init,
        deleteFile: deleteFile,
        clear: clear
    }
})();

//Intialize file upload
$('.file-upload-container.file-upload .bimp.file-upload').each(function() {
    GBCFileUpload.init($(this));
});

// Date Picker
// Month
$('.entry.question .date-time-picker.month').datetimepicker({
    locale: 'en-au',
    format: 'MMMM GGGG'
});

// Quarter
$('.entry.question .date-time-picker.quarter').datetimepicker({
    locale: 'en-au',
    format: 'MMMM GGGG'
});

// Day (Regular)
$('.entry.question .date-time-picker.day').datetimepicker({
    locale: 'en-au',
    format: 'DD/MM/YYYY'
});

// Day (Regular) //Non Entry
$('.date-time-picker.day').datetimepicker({
    locale: 'en-au',
    format: 'DD/MM/YYYY'
});

//ClassyLoader Plugin
$('.classyloader').each(initClassyLoader);

function initClassyLoader() {
    var $element = $(this),
        options = $element.data();
    options.percentage > 0 ? $element.ClassyLoader(options) : null;

}

//Equal Height Children
$(document).ready(equaliseChildren);
$(window).on('resize', equaliseChildren);

function equaliseChildren() {
    $(".equalize-children").each(function() {
        $(".equalize-children").children().height('auto');
        var maxHeight = 0;
        $(this).children().each(function() {
            maxHeight = $(this).height() > maxHeight ? $(this).height() : maxHeight;
        });
        $(".equalize-children").children().height(maxHeight);
    });
}

//AJAX Datatables
$(document).ready(ajaxDataTables);

function ajaxDataTables() {
    $('.table.ajax-datatable').each(function() {

        //Get the table header row as an array
        var tableHeaderDetailArray = $(this).find('thead tr th');
        var tableHeaderArray = [];
        for (var i = 0; i < tableHeaderDetailArray.length; i++) {
            tableHeaderArray.push(tableHeaderDetailArray[i].innerHTML);
        }

        var dataTable = $(this).DataTable({
            dom: '<"col-md-4"l><"col-md-4 text-center"B><"col-md-4"f><"col-md-12"t><"col-md-6"i><"col-md-6"pr>',
            buttons: ['copy', 'excel', 'csv', 'pdf'],
            lengthMenu: [
                [10, 25, 50, 100, 200, -1],
                [10, 25, 50, 100, 200, "All"]
            ],
            deferRender: true,
            processing: true,
            ajax: function(data, callback, settings) {
                var timestamp = $(this).data('timestamp');
                var hash = $(this).data('hash');
                var key = $(this).data('key');
                $.ajax({
                    type: 'GET',
                    url: '/api/v1/storedQuery/' + $(this).data('query-id'),
                    data: null,
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
                        callback(jQuery.parseJSON(xhr.responseText));
                    }
                });
            },
            columns: getDisplayColumns($(this).data('display'), tableHeaderArray)
        });
        dataTable.buttons().container().appendTo($('.col-sm-6:eq(1)', dataTable.table().container()));
    });
}

function getDisplayColumns(type, tableHeaderArray) {
    switch (type) {

        case 'year':
        case 'year_start':
            return [{
                    data: "company_name",
                    render: function(data, type, full, meta) {
                        return full.status === 'Locked' ? full.company_name : '<a href="/members/entry/' + full.client_checklist_id + '/" class="default-link">' + full.company_name + '</a>';
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
            return [{
                    data: "company_name",
                    render: function(data, type, full, meta) {
                        return full.status === 'Locked' ? full.company_name : '<a href="/members/entry/' + full.client_checklist_id + '/" class="default-link">' + full.company_name + '</a>';
                    }
                },
                { data: "name" },
                {
                    data: {
                        _: "date_range_finish_year",
                        order: "date_range_finish"
                    }
                },
                { data: "status" }
            ];
            break;

        case 'month_year':
            return [{
                    data: "company_name",
                    "render": function(data, type, full, meta) {
                        return full.status === 'Locked' ? full.company_name : '<a href="/members/entry/' + full.client_checklist_id + '/" class="default-link">' + full.company_name + '</a>';
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

        case 'entry_variation':
            return [
                { data: "section" },
                { data: "question" },
                { data: "current_period" },
                { data: "current_value" },
                { data: "previous_period" },
                { data: "previous_value" },
                { data: "variation" }
            ];
            break;

        case 'analytics-table':
            return [
                { data: "name" },
                { data: "question" },
                { data: "period" },
                { data: "answer" }
            ];

            break;

        case 'month':
        default:
            var columnArray = [{
                data: "company_name",
                "render": function(data, type, full, meta) {
                    return full.status === 'Locked' ? full.company_name : '<a href="/members/entry/' + full.client_checklist_id + '/" class="default-link">' + full.company_name + '</a>';
                }
            }];

            //Entry
            if (tableHeaderArray.indexOf('Entry') > 0) {
                columnArray.push({ data: "name" });
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

            //Status
            if (tableHeaderArray.indexOf('Status') > 0) {
                columnArray.push({ data: "status" });
            }

            return columnArray;
            break;
    }

}

//Metric Variation
$(document).ready(function() {

    //Load
    $('.entry .metric.active .metric-value').each(function() {
        updateMetricVariation($(this).data('metric-id'));
    });

    //Change
    $('.entry .metric.active .metric-value').focusout(function() {
        updateMetricVariation($(this).data('metric-id'));
    });
});

//On Metric Index Change
$('.entry.metric-group .metric-type').change(function() {
    var metric_id = $(this).data('metric-id');
    var metric_type_id = $(this).val();
    var previousMonth = $('.metric-variation-data[data-metric-id="' + metric_id + '"][data-metric-unit-type-id="' + metric_type_id + '"][data-key="previous_month"]');
    var previousYear = $('.metric-variation-data[data-metric-id="' + metric_id + '"][data-metric-unit-type-id="' + metric_type_id + '"][data-key="previous_year"]');
    var currentFyAu = $('.metric-variation-data[data-metric-id="' + metric_id + '"][data-metric-unit-type-id="' + metric_type_id + '"][data-key="current_fy_au"]');

    //Update previous values
    if (previousMonth.data('value') !== '') {
        $('.metric-id-' + metric_id + '.previous-month').html(previousMonth.data('value').toLocaleString('en-AU', { maximumFractionDigits: 2 }) + ' ' + previousMonth.data('metric-unit-type'));
    }

    if (previousYear.data('value') !== '') {
        $('.metric-id-' + metric_id + '.previous-year').html(previousYear.data('value').toLocaleString('en-AU', { maximumFractionDigits: 2 }) + ' ' + previousMonth.data('metric-unit-type'));
    }

    if (currentFyAu.data('value') !== '') {
        $('.metric-id-' + metric_id + '.current-fy-au').html(currentFyAu.data('value').toLocaleString('en-AU', { maximumFractionDigits: 2 }) + ' ' + previousMonth.data('metric-unit-type'));
    }

    //Now previous results have been updated we check the variation allowance
    updateMetricVariation(metric_id);
});

function updateMetricVariation(metric_id) {
    //
    var metric_type_id = $('.metric-' + metric_id + '.metric-type').val();
    var metricVariationData = $('.metric-variation-data[data-metric-id="' + metric_id + '"][data-metric-unit-type-id="' + metric_type_id + '"][data-key="previous_year"]');
    var maxVariation = parseFloat(metricVariationData.data('metric-max-variation'));

    if (!isNaN(maxVariation) && Math.abs(maxVariation) > 0) {
        var previousValue = parseFloat(metricVariationData.data('value'));
        var currentValue = parseFloat($('.metric-' + metric_id + '.metric-value').val());
        var percentageChange = Math.round(((currentValue - previousValue) / previousValue) * 100);
        var absPercentageChange = Math.abs(percentageChange);
        absPercentageChange >= Math.abs(maxVariation) ? showVariation() : hideVariation();

        function hideVariation() {
            $('.metric-id-' + metric_id + '-variation').slideUp('2000');
            $('.metric-id-' + metric_id + '-variation').find(':input').prop('disabled', true);
        }

        function showVariation() {
            $('.metric-id-' + metric_id + '-variation').slideDown('2000');
            $('.metric-id-' + metric_id + '-variation .percentage-change').html((absPercentageChange === Infinity ? "100" : absPercentageChange) + "% " + (percentageChange < 0 ? "less" : "more"));
            $('.metric-id-' + metric_id + '-variation').find(':input').prop('disabled', false);
            $('.metric-id-' + metric_id + '-variation .previous-period').html(metricVariationData.data('previous-year'));
        }
    }

    return;
}

//Dynamic Assessment Content
$('.entry.question.repeatable.control .add-button').on('click', function() {

    //Get the repeatable item and the target
    var repeatable = $(this).closest('.entry.question.repeatable.control').next('.entry.question.repeatable.template');
    //console.log(repeatable);
    var target = repeatable.data('target');

    //Make the clone
    $(repeatable).clone(true).appendTo(target);
    //Set the new classes
    $(target + ' .entry.question.repeatable').addClass('duplicate');
    $(target + ' .entry.question.repeatable').removeClass('template');
    $(target + ' .entry.question.repeatable.duplicate');
    $(target + ' .entry.question.repeatable.duplicate :input').prop('disabled', false);
});

$('.entry.question.repeatable .delete-button').on('click', function() {
    var result = confirm("Are you sure you want to delete this item?");
    if (result) {
        $(this).closest('.entry.question.repeatable.duplicate').remove();
    }
    return;
});

//****** AFFIX Sidebar ********//
$(document).ready(function() {
    if ($('.entry.steps.pages').length) {
        //Scroll 
        $(window).scroll(function() {
            setScrollSpy();
        });

        //Resize
        $(window).resize(function() {
            setScrollSpy();
        });

        //Load
        setScrollSpy();
    }
});

function setScrollSpy() {
    var sideBar = '.entry.steps.pages';
    var entryContainer = '.load-entry-container';
    var topPadding = 25;
    var sideBarDistanceFromTop = $(entryContainer).offset().top - ($(window).scrollTop());
    var sideBarBottom = $(sideBar).offset().top + $(sideBar).height();
    var entryContainerBottom = $(entryContainer).offset().top + $(entryContainer).height();

    if (($(sideBar).height() < $(entryContainer).height()) && ($(sideBar).height() < ($(window).height() - topPadding))) {

        //Disable affix when scroll is above element
        if ((sideBarDistanceFromTop - topPadding) > 0) {
            $(sideBar).removeClass('affix');
            $(sideBar).css('top', '');
        } else {
            $(sideBar).css('top', topPadding + 'px');
            $(sideBar).addClass('affix');
        }
    }

    //Set the width of the sidebar
    $(sideBar).width($(sideBar).parent().width());

    return;
}

/***** Toggle Trigger *****/
$(document).ready(function() {
    $('.entry.toggle').bootstrapSwitch();
});

/***** Popovers *****/
$(document).ready(function() {
    $('[data-toggle="popover"]').popover();
});

/***** Tooltip ******/
$(document).ready(function() {
    $('[data-toggle="tooltip"]').tooltip();
    $('[rel="tooltip"]').tooltip();
});

/***** Metric Filter ******/
$(document).ready(function() {
    var filterMetrics = function(e) {
        filter = e;
        $('.metric.active fieldset.entry.metric-group.metric').each(function() {
            metric = $(this);
            if (metric.data('metric-label').toLowerCase().indexOf(filter.target.value.toLowerCase()) === -1) {
                $(metric).attr('data-status', 'hidden').parent().attr('data-status', 'hidden').hide();
            } else {
                $(metric).attr('data-status', 'visible').parent().attr('data-status', 'visible').show();
            }

            if ($('.metric.active .entry.metric-group.metric[data-metric-group="' + metric.data('metric-group') + '"][data-status="visible"]').length < 1) {
                $('.entry.metric-group.metric-group-id-' + metric.data('metric-group')).parent().hide();
            } else {
                $('.entry.metric-group.metric-group-id-' + metric.data('metric-group')).parent().show();
            }
        });
    }

    $('[data-action="metric-filter"]').keyup(function(e) {
        setTimeout(function() { filterMetrics(e); }, 10);
    });

});


/**** Entry Form Change Warning ****/
var formHasChanged = false;
var submitted = false;

$(document).on('change', '.load-entry-container input, .load-entry-container select, .load-entry-container textarea', function(e) {
    element = $(this);
    if (element.data('form-modified') === false) {
        return;
    }
    formHasChanged = true;
});

$(document).ready(function() {
    window.onbeforeunload = function(e) {
        if (formHasChanged && !submitted) {
            var message = "You have not saved your changes.",
                e = e || window.event;
            if (e) {
                e.returnValue = message;
            }
            return message;
        }
    }
    $("form").submit(function() {
        submitted = true;
    });
});


/**** Sub Metric Content ****/
//Dynamic Assessment Content
$(document).ready(function() {
    $('.entry .metric .add-sub-metric').on('click', function() {

        //Get the repeatable item and the target
        var repeatable = $(this).closest('.entry.metric').find('.sub-metric.repeatable.template');
        //console.log(repeatable);
        var target = repeatable.data('target');
        //console.log(target);

        //Make the clone
        $(repeatable).clone(true).appendTo(target);
        //Set the new classes
        $(target + ' .sub-metric.repeatable').addClass('duplicate');
        $(target + ' .sub-metric.repeatable').removeClass('template');
        $(target + ' .sub-metric.repeatable.duplicate');
        $(target + ' .sub-metric.repeatable.duplicate :input').prop('disabled', false);
        updateSubMetricHeaders();
    });

    $('.sub-metric.repeatable .delete-button').on('click', function() {
        var result = confirm("Are you sure you want to delete this item?");
        if (result) {
            $(this).closest('.sub-metric.repeatable.duplicate').remove();
        }
        updateSubMetricHeaders();
        return;
    });

    function updateSubMetricHeaders() {
        $('.entry.sub-metric-container').each(function() {
            if ($(this).find('.sub-metric.repeatable.duplicate').length > 0) {
                $(this).show();
            } else {
                $(this).hide();
            }
        });
    }
    updateSubMetricHeaders();
});

/**
 * Chart JS Static
 * Run chart JS using data inside data attributes
 */
function staticChartJs() {
    $('.chart-js.static').each(function() {
        //Chart Settings
        var type = $(this).data('type') || 'pie';
        //var labels = $(this).data('labels').length ? $(this).data('labels') : [];
        var backgroundColourOpacity = $(this).data('background-colour-opacity') || '100';
        var data = $(this).data('data') || [];
        var colours = $(this).data('colours') || [];
        var modifier = $(this).data('modifier') || null;
        var legend = $(this).attr('data-legend') ? Boolean($(this).data('legend')) : true;
        console.log(legend);
        var colourArray = ['#3366CC', '#DC3912', '#FF9900', '#109618', '#990099', '#3B3EAC', '#0099C6', '#DD4477', '#66AA00', '#B82E2E', '#316395', '#994499', '#22AA99', '#AAAA11', '#6633CC', '#E67300', '#8B0707', '#329262', '#5574A6', '#3B3EAC'];

        //Get chart colours
        for (var i = 0; i < data.length; i++) {
            colours.push(typeof colourArray[i] != 'undefined' ? colourArray[i] : '#' + Math.floor(Math.random() * 16777215).toString(16));
            colours[i] = convertHex(colours[i], backgroundColourOpacity);
        }

        //Change the hex to rbga for alpha (opacity)
        function convertHex(hex, opacity) {
            hex = hex.toString().replace('#', '');
            r = parseInt(hex.substring(0, 2), 16);
            g = parseInt(hex.substring(2, 4), 16);
            b = parseInt(hex.substring(4, 6), 16);

            result = 'rgba(' + r + ',' + g + ',' + b + ',' + parseInt(opacity) / 100 + ')';
            return result;
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

        var options = {
            maintainAspectRatio: false,
            responsiveAnimationDuration: 500,
            responsive: true
        }

        //Canvas
        var ctx = $(this)[0].getContext("2d");

        //Set the data structure
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
            labels: $(this).data('labels'),
            datasets: getData(),
            options: options
        }

        //Create Chart
        var chart = new Chart(ctx, {
            type: type,
            data: data,
            options: {
                legend: {
                   display: legend
                }
            }
        });
    });
}

$(document).ready(staticChartJs);


//AJAX Datatables
$(document).ready(ajaxChartJs);

function ajaxChartJs() {
    $('.chartjs.ajax-chart').each(function() {
        var container = $(this);
        var canvas = $(this).find('.chartjs');
        var ctx = $(canvas)[0].getContext("2d");
        var timestamp = $(canvas).data('timestamp');
        var hash = $(canvas).data('hash');
        var key = $(canvas).data('key');
        var dataOptions = $(canvas).data('data-options');
        var chartOptions = $(canvas).data('chart-options');
        $.ajax({
            type: 'GET',
            url: '/api/v1/storedQuery/' + $(canvas).data('query-id'),
            data: null,
            success: function(jsonData) {
                drawChart(jsonData);
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

        function drawChart(data) {
            data = formatData(data.data);
            options = setChartOptions();
            var chart = new Chart(ctx, {
                type: $(canvas).data('type'),
                data: data,
                options: options,
                onComplete: $(container).addClass('completed') //remove the spinner
            });
        }

        function setChartOptions() {
            var options = {};

            switch ($(canvas).data('type')) {
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

            $.extend(options, dataOptions);

            return options;
        }

        function formatData(jsonData) {
            var labels = [];
            var data = [];
            var datasets = [];
            var colors = [];
            var index = 0;

            switch ($(canvas).data('type')) {
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
                                'borderColor': getHexColor(index)
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

    });
}

//Countable for text areas
$(document).ready(countable);

function countable() {
    $('.countable').each(function() {
        var field = $(this);
        Countable.live($(this)[0], function(counter) {
            $('.' + $(field).data('answer-id') + '.counter-message .word-counter .counter').html(counter.words);
        });
    });
}

//Print Page 
$(document).ready(function() {
    $('.js-print').click(function(e) {
        e.preventDefault();
        window.print();
    });
});

//Auto Calculate Function 
$(document).ready(autoCalculate);

function buildIndexedQuestion(field, index) {
    field = field.split('][');
    question = (field[0] ? field[0] : '') + '][' + index + '][' + (field[1] ? field[1] : '');
    return question;
}

function autoCalculate() {

    //Each data-calculate
    $('[data-calculation]').each(function() {
        var $field = $(this);
        var index = $field.data('index') ? $field.data('index') : 0;
        $field.prop('readonly', 'readonly');
        var calculate = $field.data('calculation').split("|");

        //Loop the calculation
        for (var i = 0; i < calculate.length; i++) {
            if (calculate[i].indexOf('question') > -1) {
                //Set the change event for each
                $('input[name="' + buildIndexedQuestion(calculate[i], index) + '"]').change(function() {
                    var calculation = '';
                    for (var j = 0; j < calculate.length; j++) {
                        calculation += calculate[j].indexOf('question') > -1 ? ($('input[name="' + buildIndexedQuestion(calculate[j], index) + '"]').val() === '' ? 0 : $('input[name="' + buildIndexedQuestion(calculate[j], index) + '"]').val()) : calculate[j];
                    }
                    try {
                        //console.log('Calculation: ' + calculation + ' = ' + roundToTwo(parseFloat(math.eval(calculation))));
                        $field.val(roundToTwo(parseFloat(math.eval(calculation))));
                        $field.change();
                    } catch (e) {
                        //console.log('Error: ' + calculation);
                        $field.val(0);
                        $field.change();
                    }

                    function roundToTwo(num) {
                        return +(Math.round(num + "e+2") + "e-2");
                    }
                });
            }
        }
    });
}

//TWE Metric Functions
//Auto Calculate Function
$(document).ready(metricControls);

function metricControls() {

    //Disable the fields that aren't required on load
    $('.entry .metric.disabled').each(function() {
        $(this).find(':input').prop('disabled', true);
    });

    $('.metric-settings.switch').on('switchChange.bootstrapSwitch', function(event, state) {
        var state = state;
        $metricSettingSwitch = $(this);
        $metric = $('.metric[data-metric-id="' + $metricSettingSwitch.data('metric-id') + '"]');
        state ? enableMetric($metric) : disableMetric($metric);

        $.ajax({
            type: "POST",
            data: {
                'action': 'updateClient2Metric',
                'metric_id': $metricSettingSwitch.data('metric-id'),
                'client_id': $metricSettingSwitch.data('client-id'),
                'post_type': 'ajax',
                'status': state ? 'delete' : 'insert'
            },
            success: function(data) {
                //console.log(data);
            }
        });
    });

    function disableMetric($metric) {
        $metric.slideUp('slow', function() {
            $metric.removeClass('active');
            $metric.addClass('disabled');
            $metric.find(':input').prop('disabled', true);
            updateMetricGroupHeader($metric);
        });
    }

    function enableMetric($metric) {
        $metric.slideDown('slow', function() {
            $metric.removeClass('disabled');
            $metric.addClass('active');
            $metric.find('.metric-input-container :input').prop('disabled', false);
            updateMetricGroupHeader($metric);
        });
    }

    function updateMetricGroupHeader($metric) {
        //Get the metric group
        $metricGroup = $metric.find('fieldset').data('metric-group');
        $metricGroupContainer = $('.metric[data-metric-type="metric-group"][data-metric-group="' + $metricGroup + '"]');

        //Find the metric group fieldset, then get the parent header
        if ($('.metric.active[data-metric-type="metric"][data-metric-group="' + $metricGroup + '"]').length > 0) {
            $metricGroupContainer.slideDown('slow', function() {
                $metricGroupContainer.removeClass('disabled');
                $metricGroupContainer.addClass('active');
            });
        } else {
            $metricGroupContainer.slideUp('slow', function() {
                $metricGroupContainer.removeClass('active');
                $metricGroupContainer.addClass('disabled');
            });
        }
    }
}

/**=========================================================
 * Module: notify.js
 * Create toggleable notifications that fade out automatically.
 * Based on Notify addon from UIKit (http://getuikit.com/docs/addons_notify.html)
 * [data-toggle="notify"]
 * [data-options="options in json format" ]
 =========================================================*/

(function($, window, document) {
    'use strict';

    var Selector = '[data-notify]',
        autoloadSelector = '[data-onload]',
        doc = $(document);


    $(function() {

        $(Selector).each(function() {

            var $this = $(this),
                onload = $this.data('onload');

            if (onload !== undefined) {
                setTimeout(function() {
                    notifyNow($this);
                }, 800);
            }

            $this.on('click', function(e) {
                e.preventDefault();
                notifyNow($this);
            });

        });

    });

    function notifyNow($element) {
        var message = $element.data('message'),
            options = $element.data('options');

        if (!message)
            $.error('Notify: No message specified');

        $.notify(message, options || {});
    }


}(jQuery, window, document));


/**
 * Notify Addon definition as jQuery plugin
 * Adapted version to work with Bootstrap classes
 * More information http://getuikit.com/docs/addons_notify.html
 */

(function($, window, document) {

    var containers = {},
        messages = {},

        notify = function(options) {

            if ($.type(options) == 'string') {
                options = { message: options };
            }

            if (arguments[1]) {
                options = $.extend(options, $.type(arguments[1]) == 'string' ? { status: arguments[1] } : arguments[1]);
            }

            return (new Message(options)).show();
        },
        closeAll = function(group, instantly) {
            if (group) {
                for (var id in messages) { if (group === messages[id].group) messages[id].close(instantly); }
            } else {
                for (var id in messages) { messages[id].close(instantly); }
            }
        };

    var Message = function(options) {

        var $this = this;

        this.options = $.extend({}, Message.defaults, options);

        this.uuid = "ID" + (new Date().getTime()) + "RAND" + (Math.ceil(Math.random() * 100000));
        this.element = $([
            '<div class="uk-notify-message alert-dismissable">',
            '<a class="close">&times;</a>',
            '<div>' + this.options.message + '</div>',
            '</div>'

        ].join('')).data("notifyMessage", this);

        // status
        if (this.options.status) {
            this.element.addClass('alert alert-' + this.options.status);
            this.currentstatus = this.options.status;
        }

        this.group = this.options.group;

        messages[this.uuid] = this;

        if (!containers[this.options.pos]) {
            containers[this.options.pos] = $('<div class="uk-notify uk-notify-' + this.options.pos + '"></div>').appendTo('body').on("click", ".uk-notify-message", function() {
                $(this).data("notifyMessage").close();
            });
        }
    };


    $.extend(Message.prototype, {

        uuid: false,
        element: false,
        timout: false,
        currentstatus: "",
        group: false,

        show: function() {

            if (this.element.is(":visible")) return;

            var $this = this;

            containers[this.options.pos].show().prepend(this.element);

            var marginbottom = parseInt(this.element.css("margin-bottom"), 10);

            this.element.css({ "opacity": 0, "margin-top": -1 * this.element.outerHeight(), "margin-bottom": 0 }).animate({ "opacity": 1, "margin-top": 0, "margin-bottom": marginbottom }, function() {

                if ($this.options.timeout) {

                    var closefn = function() { $this.close(); };

                    $this.timeout = setTimeout(closefn, $this.options.timeout);

                    $this.element.hover(
                        function() { clearTimeout($this.timeout); },
                        function() { $this.timeout = setTimeout(closefn, $this.options.timeout); }
                    );
                }

            });

            return this;
        },

        close: function(instantly) {

            var $this = this,
                finalize = function() {
                    $this.element.remove();

                    if (!containers[$this.options.pos].children().length) {
                        containers[$this.options.pos].hide();
                    }

                    delete messages[$this.uuid];
                };

            if (this.timeout) clearTimeout(this.timeout);

            if (instantly) {
                finalize();
            } else {
                this.element.animate({ "opacity": 0, "margin-top": -1 * this.element.outerHeight(), "margin-bottom": 0 }, function() {
                    finalize();
                });
            }
        },

        content: function(html) {

            var container = this.element.find(">div");

            if (!html) {
                return container.html();
            }

            container.html(html);

            return this;
        },

        status: function(status) {

            if (!status) {
                return this.currentstatus;
            }

            this.element.removeClass('alert alert-' + this.currentstatus).addClass('alert alert-' + status);

            this.currentstatus = status;

            return this;
        }
    });

    Message.defaults = {
        message: "",
        status: "normal",
        timeout: 5000,
        group: null,
        pos: 'top-center'
    };


    $["notify"] = notify;
    $["notify"].message = Message;
    $["notify"].closeAll = closeAll;

    return notify;

}(jQuery, window, document));


//Notify Messages
$(document).ready(notifyMessage);

function notifyMessage() {
    var status = { "success": "success", "warning": "warning", "error": "danger" };

    $('.notify-message').each(function() {
        $.notify({ message: $(this).data('message') }, { 'status': status[$(this).data('type')] });
        return;
    });
}

//Analytics
$(document).ready(analytics);

function analytics() {
    $table = $('.table.analytics.datatable');
    doDataTable($table, { data: null });

    var $checklist = $('.form.analytics select[name="checklist_id"]');
    var $question = $('.form.analytics select[name="question_id"]');
    var $submit = $('.form.analytics [data-action="get-analytics"]');
    var $client_array = $('.form.analytics input[name="client_array"]').val();
    var $client_checklist_array = $('.form.analytics input[name="client_checklist_array"]').val();

    //Set the data fields on change or load
    setQueryFilter();
    $checklist.change(function(e) {
        setQueryFilter();
    });

    question_id = getParameterByName('question_id');

    function setQueryFilter() {
        if ($checklist.length > 0 && $checklist.val() != '') {
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
                            $option = $("<option></option>").attr("value", response.questions[j].question_id).attr("data-type", response.questions[j].type).attr("data-output", response.questions[j].output).text(response.questions[j].question);
                            if (question_id === response.questions[j].question_id) {
                                $option.attr('selected', 'selected');
                            }
                            $group.append($option);
                        }
                    }
                    $question.append($group);
                }

                //On complete, bind the chosen JS to the select
                $question.trigger("chosen:updated");

                //Submit if using query_string
                if (question_id != null) {
                    $submit.trigger('click');
                    question_id = null;
                }
            });

        } else {
            //Remove questions when there is no checklist selected
            $question.find('option[value!=""]').remove();
            $question.trigger("chosen:updated");
        }
    }

    //Check the form feilds are set before submit
    $submit.click(function(e) {
        e.preventDefault();
        $checklist.val() === '' || $question.val() === '' ? $.notify({ message: 'Entry and Question must be selected.' }, { 'status': 'danger' }) : getAnalytics();
    });

    function getQuestions(checklist_id, callback) {
        var $dataNode = $('.analytics-api');
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

    function getAnalytics() {
        var $dataNode = $('.analytics-api');
        switch ($dataNode.data('mode')) {
            case 'benchmark':
                getBenchmarkAnalytics();
                break;
            default:
                getClassicAnalytics();
                break;
        }
    }

    function getClassicAnalytics() {
        $chart = $('.analytics.chartjs');
        $tableContainer = $('.analytics.data-table');
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
                'filtered_client_array': $client_array,
                'filtered_client_checklist_array': $client_checklist_array
            },
            success: function(jsonData) {
                chartType = jsonData.data[0].hasOwnProperty('chart') ? jsonData.data[0].chart : 'null';
                if (chartType != 'null') {
                    $chart.show();
                    doAjaxChart($chart, jsonData);
                } else {
                    $chart.hide();
                }
                getAnalyticsTable();
            },
            beforeSend: function(request) {
                request.setRequestHeader('X-TIMESTAMP', timestamp);
                request.setRequestHeader('X-HASH', hash);
                request.setRequestHeader('X-PUBLIC', key);
            },
            error: function(xhr, error) {}
        });

        function getAnalyticsTable() {
            $.ajax({
                type: 'POST',
                url: '/api/v1/analytics/table/checklist/' + $checklist.val() + '/question/' + $question.val() + '/',
                data: {
                    'type': $question.find(':selected').data('type'),
                    'output': $question.find(':selected').data('output'),
                    'filtered_client_array': $client_array,
                    'filtered_client_checklist_array': $client_checklist_array
                },
                success: function(jsonData) {
                    if (jsonData.data.length > 0) {
                        $tableContainer.show();
                        doDataTable($table, jsonData);
                    } else {
                        $tableContainer.hide();
                    }
                },
                beforeSend: function(request) {
                    request.setRequestHeader('X-TIMESTAMP', timestamp);
                    request.setRequestHeader('X-HASH', hash);
                    request.setRequestHeader('X-PUBLIC', key);
                },
                error: function(xhr, error) {}
            });
        }
    }

    /**
     * Benchmark Analytics 
     */
    function getBenchmarkAnalytics() {
        $chart = $('.analytics.chartjs');
        $.ajax({
            type: 'POST',
            url: '/api/v1/analytics/benchmark/checklist/' + $checklist.val() + '/question/' + $question.val() + '/',
            data: { 'client_id': $('.form.analytics input[name="client_id"]').val() },
            success: function(response) {
                console.log(response)
                buildAnalyticsBenchmarkTable(response);
                buildAnalyticsBenchmarkChart();
            },
            beforeSend: function(request) {
                request.setRequestHeader('X-TIMESTAMP', $chart.find('.chartjs').data('timestamp'));
                request.setRequestHeader('X-HASH', $chart.find('.chartjs').data('hash'));
                request.setRequestHeader('X-PUBLIC', $chart.find('.chartjs').data('key'));
            },
            error: function(xhr, error) {}
        });

        return;
    }

    //
    function buildAnalyticsBenchmarkChart() {
        $chart = $('.analytics.chartjs');
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
                'filtered_client_array': $client_array,
                'filtered_client_checklist_array': $client_checklist_array,
                'benchmark': true
            },
            success: function(jsonData) {
                chartType = jsonData.data[0].hasOwnProperty('chart') ? jsonData.data[0].chart : 'null';
                if (chartType != 'null') {
                    $chart.show();
                    doAjaxChart($chart, jsonData);
                } else {
                    $chart.hide();
                }
            },
            beforeSend: function(request) {
                request.setRequestHeader('X-TIMESTAMP', timestamp);
                request.setRequestHeader('X-HASH', hash);
                request.setRequestHeader('X-PUBLIC', key);
            },
            error: function(xhr, error) {}
        });
    }

    //
    function buildAnalyticsBenchmarkTable(response) {
        var periods = getPeriods();
        var answerType = getAnswerType();
        var multipleAnswer = getMultipleAnswer();
        var headers = getHeaders();

        function getPeriods() {
            var periods = [];
            for (var i = 0; i < response.data.results.length; i++) {
                if (response.data.results[i].year && periods.indexOf(response.data.results[i].year) < 0) {
                    periods.push(response.data.results[i].year);
                }
            }

            periods.sort(function(a, b) { return b - a });
            return periods;
        }

        function getAnswerType() {
            return response.data.answers[0].answer_type ? response.data.answers[0].answer_type : null;
        }

        function getMultipleAnswer() {
            return response.data.answers[0].multiple_answer && response.data.answers[0].multiple_answer.toString() == '1' ? true : false;
        }

        function getHeaders() {
            return [{ title: 'Period' }, { title: 'Your Response' }, { title: 'Benchmark' }];
        }

        function getBenchmark(benchmark, period) {
            total = 0;

            for (var i = 0; i < response.data.benchmarks.length; i++) {
                if (response.data.benchmarks[i].year == benchmark.year) {
                    total += response.data.benchmarks[i].count;
                }
            }

            return total > 0 ? Math.round((benchmark.count / total) * 100) : null;
        }

        function constructBenchmarkTable() {
            $table = $('.analytics.benchmark .table').empty();
            var row = '';
            var cell = '';

            //Header  
            row = '<thead><tr>';
            for (var i = 0; i < headers.length; i++) {
                row += '<th>' + headers[i].title + '</th>';
            }
            row += '</tr></thead>';
            $table.append(row);

            //Body 
            $table.append('<tbody>');
            for (var i = 0; i < periods.length; i++) {
                row = '<tr><td>' + periods[i] + '</td>';

                //Results
                row += '<td>';
                for (var j = 0; j < response.data.answers.length; j++) {
                    for (var k = 0; k < response.data.results.length; k++) {
                        if (response.data.answers[j].answer_id == response.data.results[k].answer_id && response.data.results[k].year == periods[i]) {
                            switch (response.data.results[k].answer_type) {
                                case 'range':
                                    row += '<div class="answer">' + response.data.results[k].arbitrary_value + response.data.answers[j].range_unit + '</div>';
                                    break;

                                case 'percent':
                                    row += '<div class="answer">' + response.data.results[k].arbitrary_value + '%' + '</div>';
                                    break;

                                case 'checkbox':
                                case 'checkbox-other':
                                case 'drop-down-list':
                                    row += '<div class="answer">' + response.data.results[k].string + '</div>';
                                    break;

                                default:
                                    row += '<div class="answer">' + response.data.results[k].arbitrary_value + '</div>';
                                    break;
                            }
                        }
                    }
                }
                row += '</td>';

                //Benchmarks
                row += '<td>';
                for (var j = 0; j < response.data.benchmarks.length; j++) {
                    if (response.data.benchmarks[j].year == periods[i]) {
                        for (var k = 0; k < response.data.answers.length; k++) {
                            if (response.data.answers[k].answer_id == response.data.benchmarks[j].answer_id) {
                                switch (response.data.answers[k].answer_type) {

                                    case 'range':
                                        row += '<div class="row answer">' + '<div class="col-md-3">Min:</div>' + '<div class="col-md-2 text-right">' + response.data.benchmarks[j].min + ' ' + response.data.answers[k].range_unit + '</div></div>';
                                        row += '<div class="row answer">' + '<div class="col-md-3">Max:</div>' + '<div class="col-md-2 text-right">' + response.data.benchmarks[j].max + ' ' + response.data.answers[k].range_unit + '</div></div>';
                                        row += '<div class="row answer">' + '<div class="col-md-3">Avg:</div>' + '<div class="col-md-2 text-right">' + response.data.benchmarks[j].avg + ' ' + response.data.answers[k].range_unit + '</div></div>';
                                        break;

                                    case 'percent':
                                        row += '<div class="row answer">' + '<div class="col-md-3">Min:</div>' + '<div class="col-md-2 text-right">' + response.data.benchmarks[j].min + '%' + '</div></div>';
                                        row += '<div class="row answer">' + '<div class="col-md-3">Max:</div>' + '<div class="col-md-2 text-right">' + response.data.benchmarks[j].max + '%' + '</div></div>';
                                        row += '<div class="row answer">' + '<div class="col-md-3">Avg:</div>' + '<div class="col-md-2 text-right">' + response.data.benchmarks[j].avg + '%' + '</div></div>';
                                        break;

                                    case 'int':
                                    case 'float':
                                        row += '<div class="row answer">' + '<div class="col-md-3">Min:</div>' + '<div class="col-md-2 text-right">' + response.data.benchmarks[j].min + '</div></div>';
                                        row += '<div class="row answer">' + '<div class="col-md-3">Max:</div>' + '<div class="col-md-2 text-right">' + response.data.benchmarks[j].max + '</div></div>';
                                        row += '<div class="row answer">' + '<div class="col-md-3">Avg:</div>' + '<div class="col-md-2 text-right">' + response.data.benchmarks[j].avg + '</div></div>';
                                        break;

                                    case 'text':
                                    case 'textarea':
                                        row += '<div class="row answer"><div class="col-md-12">' + 'N/A' + '</div></div>';
                                        break;

                                    case 'checkbox':
                                    case 'checkbox-other':
                                    case 'drop-down-list':
                                        var benchmark = getBenchmark(response.data.benchmarks[j], periods[i]);
                                        row += '<div class="row answer">' + '<div class="col-md-8">' + (response.data.answers[k].answer_string ? response.data.answers[k].answer_string : 'N/A') + '</div><div col-md-2 text-right">' + (benchmark ? benchmark + '%' : 'N/A') + '</div></div>';
                                        break;

                                    default:
                                        row += '<div class="row answer">' + '<div class="col-md-12">' + (response.data.answers[k].arbitrary_value ? response.data.answers[k].arbitrary_value : 'N/A') + '</div></div>';
                                        break;
                                }
                            }
                        }
                    }
                }
                row += '</td></tr>';
                $table.append(row);
            }
            $table.append('</tbody>');
        }
        constructBenchmarkTable();
    }

    return;
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
            buttons: ['copy', 'excel', 'csv', 'pdf'],
            lengthMenu: [
                [10, 25, 50, 100, 200, -1],
                [10, 25, 50, 100, 200, "All"]
            ],
            deferRender: true,
            processing: true,
            data: data.data,
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

//Chosen Support
$('.chosen-select').chosen();

//Legacy Assessment JS
$(document).ready(function() {
    $(".assessment-instructions-help").click(function(e) {
        e.preventDefault();
        wLeft = window.screenLeft ? window.screenLeft : window.screenX;
        wTop = window.screenTop ? window.screenTop : window.screenY;

        var left = wLeft + (window.innerWidth / 2) - (400 / 2);
        var top = wTop + (window.innerHeight / 2) - (400 / 2);
        window.open("/_help/assessment-instructions.html", "", "width=400, height=400, left=" + left + ", top=" + top + ", location=no, menubar=no, resizable=no");
    });
});

$(document).ready(function() {
    if ($('p.error').length) {
        errorLocation = $('p.error').first().position().top;
        $('html, body').animate({ scrollTop: errorLocation - 20 }, 1000);
    }
});

$(document).ready(function() {
    $('.closeall').click(function() {
        $('.panel-collapse.in')
            .collapse('hide');
    });
    $('.openall').click(function() {
        $('.panel-collapse:not(".in")')
            .collapse('show');
    });
});

//Google Maps
$(document).ready(function() {
    $('.google-maps-canvas').each(function(index, element) {
        initialize(element);
    });

    function initialize(element) {

        var point = { lat: $(element).data('lat'), lng: $(element).data('lng') };
        var map = new google.maps.Map(element, {
            zoom: $(element).data('zoom'),
            center: point
        });
        var marker = new google.maps.Marker({
            position: point,
            map: map
        });

        var contentString = '<div class="info-window-content"><h2>' + $(element).data('title') + '</h2></div>';

        var infowindow = new google.maps.InfoWindow({
            content: contentString
        });

        google.maps.event.addListener(marker, 'click', function() {
            infowindow.open(map, marker);
        });
    }
});

//GHG Tracker
$(document).ready(function() {

    $('.ghg-line-chart').each(function(index, element) {
        ghgLineChart(element);
        entry();
    });

    function entry() {
        if ($('p.error').length) {
            errorLocation = $('p.error').first().position().top;
            $('html, body').animate({ scrollTop: errorLocation - 20 }, 1000);
        } else {
            assessmentLocation = $('#ghg-assessment-container').position().top;
            $('html, body').animate({ scrollTop: assessmentLocation - 20 }, 1000);
        }

        $('#submit-assessment').click(function(e) {
            e.preventDefault();
            $('#single-page').val('true');
            $('#action').val('next');
            $('#checklist').submit();
        });

        $(function() {

            var selectedDate;

            function getDate(question_id) {

                var selectedYear = $("#date-month-year-question-" + question_id).val();
                var selectedMonth = '';

                switch ($("#date-month-period-question-" + question_id).val()) {
                    case '1':
                        selectedMonth = '-01-01';
                        break;
                    case '2':
                        selectedMonth = '-02-01';
                        break;
                    case '3':
                        selectedMonth = '-03-01';
                        break;
                    case '4':
                        selectedMonth = '-04-01';
                        break;
                    case '5':
                        selectedMonth = '-05-01';
                        break;
                    case '6':
                        selectedMonth = '-06-01';
                        break;
                    case '7':
                        selectedMonth = '-07-01';
                        break;
                    case '8':
                        selectedMonth = '-08-01';
                        break;
                    case '9':
                        selectedMonth = '-09-01';
                        break;
                    case '10':
                        selectedMonth = '-10-01';
                        break;
                    case '11':
                        selectedMonth = '-11-01';
                        break;
                    case '12':
                        selectedMonth = '-12-01';
                        break;

                }

                return (selectedYear + selectedMonth);
            }

            //Set the default

            //If date has not been set yet
            if ($("#question-13321-31853").val() == '') {
                selectedDate = getDate(13321);
                $("#question-13321-31853").val(selectedDate);
            } else {
                var year = $("#question-13321-31853").val().substring(0, 4);
                $("#date-month-year-question-13321").val(year);

                var month = $("#question-13321-31853").val().substring(5, 7);
                switch (month) {
                    case '01':
                        $("#date-month-period-question-13321").val('1');
                        break;
                    case '02':
                        $("#date-month-period-question-13321").val('2');
                        break;
                    case '03':
                        $("#date-month-period-question-13321").val('3');
                        break;
                    case '04':
                        $("#date-month-period-question-13321").val('4');
                        break;
                    case '05':
                        $("#date-month-period-question-13321").val('5');
                        break;
                    case '06':
                        $("#date-month-period-question-13321").val('6');
                        break;
                    case '07':
                        $("#date-month-period-question-13321").val('7');
                        break;
                    case '08':
                        $("#date-month-period-question-13321").val('8');
                        break;
                    case '09':
                        $("#date-month-period-question-13321").val('9');
                        break;
                    case '10':
                        $("#date-month-period-question-13321").val('10');
                        break;
                    case '11':
                        $("#date-month-period-question-13321").val('11');
                        break;
                    case '12':
                        $("#date-month-period-question-13321").val('12');
                        break;
                }
            }

            //On Year Change
            $("#date-month-year-question-13321").change(function() {
                selectedDate = getDate(13321);
                $("#question-13321-31853").val(selectedDate);
            });

            //On Period Change
            $("#date-month-period-question-13321").change(function() {
                selectedDate = getDate(13321);
                $("#question-13321-31853").val(selectedDate);
            });

        });

    }

    function ghgLineChart(element) {
        var canvas = $(element).find('.canvas');
        var dataSeries = $(element).data('series');

        var labels = new Array();
        var values = new Array();

        for (i = 0; i < dataSeries.data.length; i++) {
            labels.push(dataSeries.data[i].date);
            values.push(dataSeries.data[i].value);
        }

        var data = {
            labels: labels,
            datasets: [{
                label: "Tonnes CO2e",
                backgroundColor: "rgba(45,141,214,0.4)",
                borderColor: "#3498db",
                data: values
            }]
        }

        new Chart($(canvas)[0].getContext('2d'), {
            type: "line",
            data: data,
        });
    }
});

/* Leaflet Map */
$(document).ready(function() {
    $('.leaflet-map').each(function() {
        leafletMap($(this));
    });
});

function leafletMap(e) {

    //Element
    e.css('height', e.data('height') || '500px');
    e.css('width', e.data('width') || '500px');

    //Images
    L.Icon.Default.imagePath = '/images/';

    ///Map
    var map = L.map(e[0], {
        center: [e.data('lat') || 0, e.data('lng') || 0],
        zoom: e.data('zoom') || 2,
        minZoom: e.data('min-zoom') || 2,
        maxZoom: e.data('max-zoom') || 20
    });

    //Base Maps
    var providers = {
        'Esri_Street': {
            title: 'Street',
            icon: '/images/esri_street.png',
            layer: L.tileLayer('https://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer/tile/{z}/{y}/{x}', {
                attribution: 'Tiles &copy; Esri &mdash; Source: Esri, DeLorme, NAVTEQ, USGS, Intermap, iPC, NRCAN, Esri Japan, METI, Esri China (Hong Kong), Esri (Thailand), TomTom, 2012'
            })
        },
        'Esri_Satellite': {
            title: 'Satellite',
            icon: '/images/esri_satellite.png',
            layer: L.tileLayer('https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}', {
                attribution: 'Tiles &copy; Esri &mdash; Source: Esri, i-cubed, USDA, USGS, AEX, GeoEye, Getmapping, Aerogrid, IGN, IGP, UPR-EGP, and the GIS User Community'
            })
        },
        'OpenTopoMap': {
            title: 'Topographic',
            icon: '/images/esri_topographic.png',
            layer: L.tileLayer('https://{s}.tile.opentopomap.org/{z}/{x}/{y}.png', {
                maxZoom: 17,
                attribution: 'Map data: &copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>, <a href="http://viewfinderpanoramas.org">SRTM</a> | Map style: &copy; <a href="https://opentopomap.org">OpenTopoMap</a> (<a href="https://creativecommons.org/licenses/by-sa/3.0/">CC-BY-SA</a>)'
            })
        },
        'Stamen_Toner': {
            title: 'Contrast Dark',
            icon: '/images/stamen_toner.png',
            layer: L.tileLayer('https://stamen-tiles-{s}.a.ssl.fastly.net/toner/{z}/{x}/{y}.png', {
                attribution: 'Map tiles by <a href="http://stamen.com">Stamen Design</a>, <a href="http://creativecommons.org/licenses/by/3.0">CC BY 3.0</a> &mdash; Map data &copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>',
                subdomains: 'abcd',
                minZoom: 0,
                maxZoom: 20,
                ext: 'png'
            })
        },
        'Stamen_Toner_Light': {
            title: 'Contrast Light',
            icon: '/images/stamen_toner_light.png',
            layer: L.tileLayer('https://stamen-tiles-{s}.a.ssl.fastly.net/toner-lite/{z}/{x}/{y}.png', {
                attribution: 'Map tiles by <a href="http://stamen.com">Stamen Design</a>, <a href="http://creativecommons.org/licenses/by/3.0">CC BY 3.0</a> &mdash; Map data &copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>',
                subdomains: 'abcd',
                minZoom: 0,
                maxZoom: 20,
                ext: 'png'
            })
        }
    };

    var layers = [];
    for (var provider in providers) {
        layers.push(providers[provider]);
    }

    //Controls
    map.addControl(new L.control.iconLayers(layers));
    map.addControl(new L.Control.Fullscreen());
    map.addControl(new L.control.locate({ follow: true, strings: { title: "Your Location" } }));

    //Single Marker
    if (e.data('marker')) {
        L.marker([e.data('marker').lat || 0, e.data('marker').lng || 0])
            .addTo(map).bindPopup('<strong>' + e.data('marker').title || '' + '</strong>')
            .openPopup();
    }

    return;
}

//Value set control
$(document).ready(function() {
    $('[data-setvalue="true"]').click(function(e) {
        $($(this).data('target')).attr('value', $(this).data('value'));
    });
});

//Link After Control
$(document).ready(function() {
    $("[data-scroll-to]").each(function(index) {
        $("html,body").animate({
            scrollTop: $($(this).data('scroll-to')).offset().top - 20
        }, 'slow');
    });
});

//Make Center Plugin
$(document).ready(function() {
    $(".make-me-center").makemecenter({ is_animate: true, is_onload: false });
});

function getParameterByName(name, url) {
    if (!url) url = window.location.href;
    name = name.toString().replace(/[\[\]]/g, "\\$&");
    var regex = new RegExp("[?&]" + name + "(=([^&#]*)|&|#|$)"),
        results = regex.exec(url);
    if (!results) return null;
    if (!results[2]) return '';
    return decodeURIComponent(results[2].toString().replace(/\+/g, " "));
}

/**
 * Data Table Static
 * Run Data Table on existing table //
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

/**
 * Data Confirm
 * 
 * A simple javascript confirmation
 */
$('[data-confirm]').click(function(e) {
    if(!confirm($(this).data('confirm')))
        e.preventDefault();
});

/**
 * Result Filter
 */

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
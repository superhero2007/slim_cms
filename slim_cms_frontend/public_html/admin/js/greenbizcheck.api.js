//GreenBizCheck API
$(document).ready(function() {
    $('.api-import-form').submit(function(e) {
        e.preventDefault();
        processApiRequest(e);
    });
});

function updateResultsPanel(position, finish, data) {
    //Clear the existing results panel
    if ($('.api-import-results').html() === '') {
        $('.api-import-results').html('<div class="progress-bar" style="width:100%; height:20px; overflow:hidden; border:1px solid black; margin-top:20px; margin-bottom:20px;"><div class="progress" style="width:0%; height:100%; overflow:hidden; background-color:blue;"/></div><div class="percentage-container"></div>');
    }
    $('.progress-bar .progress').css('width', ((position / (finish - 1) * 100) + '%'));
    $('.percentage-container').html('Progress: ' + position + ' out of ' + (finish - 1) + ' (' + (position / (finish - 1) * 100).toFixed(2) + '%)');
    data.position = position;

    console.log(data);

    return;
}

function processApiRequest(importForm) {

    $('.api-import-results').html('');
    file = $('.file-upload-input');
    var acceptableFileTypes = ['csv'];
    //var acceptableFileNames = ['client', 'client_checklist', 'client_result', 'additional_value', 'client_metric', 'metric_import'];
    var ext = file[0].files[0].name.split('.').pop();
    var name = file[0].files[0].name.split('.').shift();

    //Check the file extension
    if (acceptableFileTypes.indexOf(ext.toLowerCase()) == -1) {
        $('.api-import-results').html('<p>File Type Not Allowed. Must be one of the following formats: ' + acceptableFileTypes.toString() + '</p>');
        return;
    }

    //Check the file name
    //if (acceptableFileNames.indexOf(name.toLowerCase()) == -1) {
    //    $('.api-import-results').html('<p>File Name Not Allowed. Must be one of the following formats: ' + acceptableFileNames.toString() + '</p>');
    //    return;
    //}

    getFileData(file[0].files[0], function(data) {
        switch (name) {
            case 'client':
                uploadClientData(data);
                break;

            case 'client_checklist':
                uploadClientChecklistData(data);
                break;

            case 'client_result':
                uploadClientResultData(data);
                break;

            case 'additional_value':
                uploadAdditionalValueData(data);
                break;

            case 'client_metric':
                uploadClientMetricData(data);
                break;

            case 'metric_import':
                importClientMetricData(data);
                break;

            default:
                importData(data);
                break;
        }
    });

    return;
}

/***************
 *
 * Import Data
 *
 */
function importData(data) {
    (function processRow(i) {
        doAjaxCall('POST', '/api/v1/import/', data[i], function(response) {
            updateResultsPanel(i, data.length, response);
            (i < (data.length - 1)) ? processRow((i + 1)): null;
        });
    })(0);
}

/***************
 *
 * Upload Client Data
 *
 */
function uploadClientData(data) {
    (function loopData(i) {
        //Internal Client
        if (data[i].hasOwnProperty('client_id')) {
            getClientId(data[i].client_id, function(client_id) {
                if (client_id > 0) {
                    updateClient(client_id, data[i], function(jsonData) {
                        updateResultsPanel(i, data.length, jsonData);
                        (i < (data.length - 1)) ? loopData((i + 1)): null;
                    });
                } else {
                    updateResultsPanel(i, data.length, { code: "404", status: "Not found", data: data[i] });
                    (i < (data.length - 1)) ? loopData((i + 1)): null;
                }
            });
        }
        //External Client
        else if (data[i].hasOwnProperty('external_client_id') && data[i].hasOwnProperty('client_type_id')) {
            getExternalClientId(data[i].external_client_id, data[i].client_type_id, function(client_id) {
                if (client_id > 0) {
                    updateClient(client_id, data[i], function(jsonData) {
                        updateResultsPanel(i, data.length, jsonData);
                        (i < (data.length - 1)) ? loopData((i + 1)): null;
                    });
                } else {
                    setClient(data[i], function(jsonData) {
                        updateResultsPanel(i, data.length, jsonData);
                        (i < (data.length - 1)) ? loopData((i + 1)): null;
                    });
                }
            });
        } else {
            updateResultsPanel(i, data.length, { code: "404", status: "Invalid data", data: data[i] });
            (i < (data.length - 1)) ? loopData((i + 1)): null;
        }
    })(0);
}

/***************
 *
 * Upload Client Checklist Data
 *
 */
function uploadClientChecklistData(data) {
    (function loopData(i) {
        //Internal Client Checklist
        if (data[i].hasOwnProperty('client_id') && data[i].hasOwnProperty('client_checklist_id')) {
            getClientChecklistId(data[i].client_id, data[i].client_checklist_id, function(client_id, client_checklist_id) {

                //Update client_checklist
                if (client_id > 0 && client_checklist_id > 0) {
                    updateClientChecklist(client_id, client_checklist_id, data[i], function(jsonData) {
                        updateResultsPanel(i, data.length, jsonData);
                        (i < (data.length - 1)) ? loopData((i + 1)): null;
                    });
                } else {
                    updateResultsPanel(i, data.length, { code: "404", status: "Invalid Client ID", data: data[i] });
                    (i < (data.length - 1)) ? loopData((i + 1)): null;
                }
            });
        }
        //External Client Checklist
        else if (data[i].hasOwnProperty('external_client_id') && data[i].hasOwnProperty('external_client_checklist_id') && data[i].hasOwnProperty('client_type_id')) {
            getExternalClientChecklistId(data[i].external_client_id, data[i].external_client_checklist_id, data[i].client_type_id, function(client_id, client_checklist_id) {

                //Update client_checklist
                if (client_id > 0 && client_checklist_id > 0) {
                    updateClientChecklist(client_id, client_checklist_id, data[i], function(jsonData) {
                        updateResultsPanel(i, data.length, jsonData);
                        (i < (data.length - 1)) ? loopData((i + 1)): null;
                    });

                    //Insert client_checklist
                } else if (client_id > 0) {
                    setClientChecklist(client_id, data[i], function(jsonData) {
                        updateResultsPanel(i, data.length, jsonData);
                        (i < (data.length - 1)) ? loopData((i + 1)): null;
                    });
                } else {
                    updateResultsPanel(i, data.length, { code: "404", status: "Invalid Client ID", data: data[i] });
                    (i < (data.length - 1)) ? loopData((i + 1)): null;
                }
            });
        } else if (data[i].hasOwnProperty('client_id')) {
            getClientId(data[i].client_id, function(client_id) {
                if (client_id > 0) {
                    setClientChecklist(client_id, data[i], function(jsonData) {
                        updateResultsPanel(i, data.length, jsonData);
                        (i < (data.length - 1)) ? loopData((i + 1)): null;
                    });
                } else {
                    updateResultsPanel(i, data.length, { code: "404", status: "Invalid Client ID", data: data[i] });
                    (i < (data.length - 1)) ? loopData((i + 1)): null;
                }
            });
        } else {
            updateResultsPanel(i, data.length, { code: "404", status: "Invalid Data", data: data[i] });
            (i < (data.length - 1)) ? loopData((i + 1)): null;
        }
    })(0);
}

/***************
 *
 * Upload Client Result
 *
 */
function uploadClientResultData(data) {
    (function loopData(i) {
        //Internal Client Checklist
        if (data[i].hasOwnProperty('client_id') && data[i].hasOwnProperty('client_checklist_id') && data[i].hasOwnProperty('question_id') && data[i].hasOwnProperty('answer_id')) {
            getClientChecklistId(data[i].client_id, data[i].client_checklist_id, function(client_id, client_checklist_id) {

                //Insert the client result
                if (client_id > 0 && client_checklist_id > 0) {
                    setClientResult(client_id, client_checklist_id, data[i], function(jsonData) {
                        updateResultsPanel(i, data.length, jsonData);
                        (i < (data.length - 1)) ? loopData((i + 1)): null;
                    });
                } else {
                    updateResultsPanel(i, data.length, { code: "404", status: "Invalid Client ID", data: data[i] });
                    (i < (data.length - 1)) ? loopData((i + 1)): null;
                }
            });
        }
        //External Client Result
        else if (data[i].hasOwnProperty('external_client_id') && data[i].hasOwnProperty('external_client_checklist_id') && data[i].hasOwnProperty('client_type_id') && (data[i].hasOwnProperty('external_answer_id') || data[i].hasOwnProperty('external_question_id'))) {
            getExternalClientChecklistId(data[i].external_client_id, data[i].external_client_checklist_id, data[i].client_type_id, function(client_id, client_checklist_id) {

                //Insert the client result
                if (client_id > 0 && client_checklist_id > 0) {
                    setClientResult(client_id, client_checklist_id, data[i], function(jsonData) {
                        updateResultsPanel(i, data.length, jsonData);
                        (i < (data.length - 1)) ? loopData((i + 1)): null;
                    });

                } else {
                    updateResultsPanel(i, data.length, { code: "404", status: "Invalid Client ID, Client Checklist ID", data: data[i] });
                    (i < (data.length - 1)) ? loopData((i + 1)): null;
                }
            });
        } else {
            updateResultsPanel(i, data.length, { code: "404", status: "Invalid Data", data: data[i] });
            (i < (data.length - 1)) ? loopData((i + 1)): null;
        }
    })(0);
}


/***************
 *
 * Upload Client Metric
 *
 */
function uploadClientMetricData(data) {
    (function loopData(i) {
        //Internal Client Checklist
        if (data[i].hasOwnProperty('client_id') && data[i].hasOwnProperty('client_checklist_id') && data[i].hasOwnProperty('client_metric_id')) {
            getClientChecklistId(data[i].client_id, data[i].client_checklist_id, function(client_id, client_checklist_id) {

                //Insert the client metric
                if (client_id > 0 && client_checklist_id > 0) {
                    setClientMetric(client_id, client_checklist_id, data[i], function(jsonData) {
                        updateResultsPanel(i, data.length, jsonData);
                        //setTimeout((i < (data.length -1)) ? loopData((i+1)) : null, 10);
                        (i < (data.length - 1)) ? loopData((i + 1)): null;
                    });
                } else {
                    updateResultsPanel(i, data.length, { code: "404", status: "Invalid Client ID", data: data[i] });
                    //setTimeout((i < (data.length -1)) ? loopData((i+1)) : null, 10);
                    (i < (data.length - 1)) ? loopData((i + 1)): null;
                }
            });
        }
        //External Client Metric
        else if (data[i].hasOwnProperty('external_client_id') && data[i].hasOwnProperty('external_client_checklist_id') && data[i].hasOwnProperty('client_type_id') && data[i].hasOwnProperty('external_metric_id')) {
            getExternalClientChecklistId(data[i].external_client_id, data[i].external_client_checklist_id, data[i].client_type_id, function(client_id, client_checklist_id) {

                //Insert the client result
                if (client_id > 0 && client_checklist_id > 0) {
                    setClientMetric(client_id, client_checklist_id, data[i], function(jsonData) {
                        updateResultsPanel(i, data.length, jsonData);
                        //setTimeout((i < (data.length -1)) ? loopData((i+1)) : null, 10);
                        (i < (data.length - 1)) ? loopData((i + 1)): null;
                    });

                } else {
                    updateResultsPanel(i, data.length, { code: "404", status: "Invalid Client ID, Client Checklist ID", data: data[i] });
                    //setTimeout((i < (data.length -1)) ? loopData((i+1)) : null, 10);
                    (i < (data.length - 1)) ? loopData((i + 1)): null;
                }
            });
        } else {
            updateResultsPanel(i, data.length, { code: "404", status: "Invalid Data", data: data[i] });
            //setTimeout((i < (data.length -1)) ? loopData((i+1)) : null, 10);
            (i < (data.length - 1)) ? loopData((i + 1)): null;
        }
    })(0);
}


/***************
 *
 * Upload Additional Value
 *
 */
function uploadAdditionalValueData(data) {
    (function loopData(i) {
        //Internal Client Checklist
        if (data[i].hasOwnProperty('client_id') && data[i].hasOwnProperty('client_checklist_id') && data[i].hasOwnProperty('key') && data[i].hasOwnProperty('value')) {
            getClientChecklistId(data[i].client_id, data[i].client_checklist_id, function(client_id, client_checklist_id) {

                //Insert the client result
                if (client_id > 0 && client_checklist_id > 0) {
                    setAdditionalValue(client_id, client_checklist_id, data[i], function(jsonData) {
                        updateResultsPanel(i, data.length, jsonData);
                        (i < (data.length - 1)) ? loopData((i + 1)): null;
                    });
                } else {
                    updateResultsPanel(i, data.length, { code: "404", status: "Invalid Client ID", data: data[i] });
                    (i < (data.length - 1)) ? loopData((i + 1)): null;
                }
            });
        }
        //External Client Result
        else if (data[i].hasOwnProperty('external_client_id') && data[i].hasOwnProperty('external_client_checklist_id') && data[i].hasOwnProperty('client_type_id') && data[i].hasOwnProperty('key')) {
            getExternalClientChecklistId(data[i].external_client_id, data[i].external_client_checklist_id, data[i].client_type_id, function(client_id, client_checklist_id) {

                //Insert the client result
                if (client_id > 0 && client_checklist_id > 0) {
                    setAdditionalValue(client_id, client_checklist_id, data[i], function(jsonData) {
                        updateResultsPanel(i, data.length, jsonData);
                        (i < (data.length - 1)) ? loopData((i + 1)): null;
                    });

                } else {
                    updateResultsPanel(i, data.length, { code: "404", status: "Invalid Client ID, Client Checklist ID", data: data[i] });
                    (i < (data.length - 1)) ? loopData((i + 1)): null;
                }
            });
        } else {
            updateResultsPanel(i, data.length, { code: "404", status: "Invalid Data", data: data[i] });
            (i < (data.length - 1)) ? loopData((i + 1)): null;
        }
    })(0);
}

/***************
 *
 * Import Client Metric
 *
 */
function importClientMetricData(data) {
    (function loopData(i) {
        //Check for a checklist_id and entity name
        if (data[i].hasOwnProperty('checklist_id') && data[i].hasOwnProperty('entity')) {
            getClientsByCompanyName(data[i].entity, function(jsonData) {
                if (jsonData > 0) {
                    data[i].client_id = jsonData;

                    //Get the metric
                    getMetricsByName(data[i].checklist_id, data[i].metric, function(jsonData) {
                        if (jsonData > 0) {
                            data[i].metric_id = jsonData;

                            //Get the metric unit type
                            getMetricUnitTypesByName(data[i].metric_unit_type, function(jsonData) {
                                if (jsonData > 0) {
                                    data[i].metric_unit_type_id = jsonData;

                                    //Get the client_checklist by date
                                    getClientChecklistsByDate(data[i].client_id, data[i].checklist_id, data[i].date_range_start, function(jsonData) {
                                        if (jsonData > 0) {
                                            data[i].client_checklist_id = jsonData;
                                            //Now insert the metric
                                            setClientMetric(data[i].client_id, data[i].client_checklist_id, data[i], function(jsonData) {
                                                updateResultsPanel(i, data.length, jsonData);
                                                (i < (data.length - 1)) ? loopData((i + 1)): null;
                                            });
                                        } else {
                                            //Create the checklist
                                            setClientChecklist(data[i].client_id, data[i], function(jsonData) {
                                                data[i].client_checklist_id = jsonData.client_checklist_id;
                                                updateResultsPanel(i, data.length, jsonData);

                                                //Now insert the metric
                                                if (data[i].client_checklist_id > 0) {
                                                    setClientMetric(data[i].client_id, data[i].client_checklist_id, data[i], function(jsonData) {
                                                        updateResultsPanel(i, data.length, jsonData);
                                                        (i < (data.length - 1)) ? loopData((i + 1)): null;
                                                    });
                                                } else {
                                                    updateResultsPanel(i, data.length, 'Error: No client_checklist_id');
                                                }
                                            });
                                        }
                                    });
                                } else {
                                    updateResultsPanel(i, data.length, "Error: Can't find metric unit type - ".data[i].metric_unit_type);
                                    (i < (data.length - 1)) ? loopData((i + 1)): null;
                                }
                            });

                        } else {
                            updateResultsPanel(i, data.length, "Error: Can't find metric by name - ".data[i].metric);
                            (i < (data.length - 1)) ? loopData((i + 1)): null;
                        }
                    });
                } else {
                    updateResultsPanel(i, data.length, data);
                    (i < (data.length - 1)) ? loopData((i + 1)): null;
                }
            });
        } else {
            updateResultsPanel(i, data.length, data);
            (i < (data.length - 1)) ? loopData((i + 1)): null;
        }

    })(0);
}


/***************
 *
 * API Calls
 *
 */

//POST: Set Client
function setClient(data, callback) {
    doAjaxCall('POST', '/api/v1/clients/', data, function(jsonData) {
        callback(jsonData);
    });
}

//PUT: Update Client using client_id
function updateClient(client_id, data, callback) {
    doAjaxCall('PUT', '/api/v1/clients/' + client_id, data, function(jsonData) {
        callback(jsonData);
    });
}

//GET: Lookup Client ID with external_client_id and client_type_id
function getClientId(client_id, callback) {
    doAjaxCall('GET', '/api/v1/clients/' + client_id, null, function(jsonData) {
        callback(jsonData.clients.length > 0 && jsonData.clients[0].hasOwnProperty('client_id') ? jsonData.clients[0].client_id : 0);
    });
}

//GET: Lookup Client ID with external_client_id and client_type_id
function getExternalClientId(external_client_id, client_type_id, callback) {
    doAjaxCall('GET', '/api/v1/api/maps/clients/' + external_client_id + '/' + client_type_id, null, function(jsonData) {
        callback(jsonData.clients.length > 0 && jsonData.clients[0].hasOwnProperty('client_id') ? jsonData.clients[0].client_id : 0);
    });
}

//POST: Set Client Checklist using client_id
function setClientChecklist(client_id, data, callback) {
    doAjaxCall('POST', '/api/v1/clients/' + client_id + '/checklists/', data, function(jsonData) {
        callback(jsonData)
    });
}

//PUT: Update Client Checklist using client_id
function updateClientChecklist(client_id, client_checklist_id, data, callback) {
    doAjaxCall('PUT', '/api/v1/clients/' + client_id + '/checklists/' + client_checklist_id, data, function(jsonData) {
        callback(jsonData);
    });
}

//GET: Lookup Client Checklist ID with external_client_id and client_type_id
function getClientChecklistId(client_id, client_checklist_id, callback) {
    doAjaxCall('GET', '/api/v1/api/clients/' + client_id + '/' + client_checklist_id, null, function(jsonData) {
        callback(jsonData.clientChecklists.length > 0 && jsonData.clients[0].hasOwnProperty('client_checklist_id') ? jsonData.clientChecklists[0].client_checklist_id : 0);
    });
}

//GET: Lookup Client Checklist ID with external_client_id, external_client_checklist_id and client_type_id
function getExternalClientChecklistId(external_client_id, external_client_checklist_id, client_type_id, callback) {
    getExternalClientId(external_client_id, client_type_id, function(client_id) {
        doAjaxCall('GET', '/api/v1/api/maps/clientchecklists/' + client_id + '/' + external_client_checklist_id, null, function(jsonData) {
            callback(client_id, jsonData.clientChecklists.length > 0 && jsonData.clientChecklists[0].hasOwnProperty('client_checklist_id') ? jsonData.clientChecklists[0].client_checklist_id : 0);
        });
    });
}

//POST: Set Client Result using client_id and client_checklist_id
function setClientResult(client_id, client_checklist_id, data, callback) {
    doAjaxCall('POST', '/api/v1/clients/' + client_id + '/checklists/' + client_checklist_id + '/clientresults/', data, function(jsonData) {
        callback(jsonData)
    });
}

//POST: Set Client Metric using client_id and client_checklist_id
function setClientMetric(client_id, client_checklist_id, data, callback) {
    doAjaxCall('POST', '/api/v1/clients/' + client_id + '/checklists/' + client_checklist_id + '/clientmetrics/', data, function(jsonData) {
        callback(jsonData)
    });
}

//POST: Set Additional Value using client_id
function setAdditionalValue(client_id, client_checklist_id, data, callback) {
    doAjaxCall('POST', '/api/v1/clients/' + client_id + '/checklists/' + client_checklist_id + '/additionalvalues/', data, function(jsonData) {
        callback(jsonData)
    });
}

//GET: Lookup Client ID with entity name
function getClientsByCompanyName(entity, callback) {
    doAjaxCall('GET', encodeURI('/api/v1/clients?company_name=' + entity), null, function(jsonData) {
        callback(jsonData.clients.length > 0 && jsonData.clients[0].hasOwnProperty('client_id') ? jsonData.clients[0].client_id : 0);
    });
}

//GET: Lookup metric with entity name
function getMetricsByName($checklist_id, name, callback) {
    doAjaxCall('GET', '/api/v1/checklists/' + $checklist_id + '/metrics?name=' + name, null, function(jsonData) {
        callback(jsonData.metrics.length > 0 && jsonData.metrics[0].hasOwnProperty('metric_id') ? jsonData.metrics[0].metric_id : 0);
    });
}

//GET: Lookup metric unit types with entity name
function getMetricUnitTypesByName(name, callback) {
    doAjaxCall('GET', '/api/v1/checklists/metricUnitTypes?name=' + name, null, function(jsonData) {
        callback(jsonData.metricUnitTypes.length > 0 && jsonData.metricUnitTypes[0].hasOwnProperty('metric_unit_type_id') ? jsonData.metricUnitTypes[0].metric_unit_type_id : 0);
    });
}

//GET: Lookup metric unit types with entity name
function getClientChecklistsByDate(client_id, checklist_id, date_range_start, callback) {
    doAjaxCall('GET', '/api/v1/clients/' + client_id + '/checklist/' + checklist_id + '/date?date_range_start=' + date_range_start, null, function(jsonData) {
        callback(jsonData.clientChecklists.length > 0 && jsonData.clientChecklists[0].hasOwnProperty('client_checklist_id') ? jsonData.clientChecklists[0].client_checklist_id : 0);
    });
}


/**************
 * 
 * Read CSV File into array
 *
 */
function getFileData(file, callback) {
    var data = [];
    var reader = new FileReader();

    reader.onload = function(event) {
        var csv = Papa.parse(event.target.result);
        csvData = csv.data;
        var headerRow = csvData[0];
        for (var i = 1; i < csvData.length; i++) {
            var rowData = {};
            for (var j = 0; j < csvData[i].length; j++) {
                rowData[headerRow[j]] = csvData[i][j];
            }
            data.push(rowData);
        }
        callback(data);
    };

    reader.onerror = function() {
        alert('Unable to read ' + file.fileName);
    };

    reader.readAsText(file);
}

var getMicrotime = function(get_as_float) {

    var now = new Date().getTime() / 1000;
    var s = parseInt(now, 10);

    return (get_as_float) ? now : (Math.round((now - s) * 1000) / 1000) + ' ' + s;
};

var getHMAC = function(publicKey, timestamp, privateKey) {
    var shaObj = new jsSHA("SHA-256", "TEXT");
    shaObj.setHMACKey(privateKey, "TEXT");
    shaObj.update(publicKey + timestamp);
    var hmac = shaObj.getHMAC("HEX");
    return hmac.toString();
};

/**************
 * 
 *AJAX Requests
 *
 */
//Get Data
function doAjaxCall(type, path, data, callback) {
    var timestamp = getMicrotime(true).toString();
    var publicKey = $('.pub_key').val();
    var privateKey = $('.prv_key').val();

    $.ajax({
        type: type,
        url: path,
        data: data,
        success: function(jsonData) {
            callback(jsonData)
        },
        beforeSend: function(request) {
            request.setRequestHeader('X-TIMESTAMP', timestamp);
            request.setRequestHeader('X-HASH', getHMAC(publicKey, timestamp, privateKey));
            request.setRequestHeader('X-PUBLIC', publicKey);
        },
        error: function(xhr, error) {
            //Send response on fail for user feedback and script continuation
            callback(jQuery.parseJSON(xhr.responseText));
        }
    });
}
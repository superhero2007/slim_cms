/**
 * GreenBizCheck API
 */

var GreenBizCheck = (function () {

    var totalRows = 0,
        clientTypeId,
        checklistId,
        importProfileMap;

    var getCookie = function (name) {
        var value = "; " + document.cookie;
        var parts = value.split("; " + name + "=");
        if (parts.length === 2) {
            return parts.pop().split(";").shift();
        }
    };

    //API Functions
    var api = axios.create({
        baseURL: $('.api.import').data('url'),
        headers: {
            'Authorization': 'Bearer ' + getCookie("gbc_token"),
            'Content-Type': 'multipart/form-data'
        }
    });

    //API Functions
    var findVendorResult = function (checklist_id, question_id) {
        return api.get('/checklists/' + checklist_id + '/clientChecklists/results?question_id=' + question_id)
            .then(function (response) { return response.data; });
    };
    var get = function (path) {
        return api.get(path)
            .then(function (response) { return response.data; });
    };

    var findClientChecklist = function (checklist_id, question_id, value) {
        return api.get('/checklists/' + checklist_id + '/clientChecklists/results?question_id=' + question_id + '&value=' + value + '&not_status=4')
            .then(function (response) { return (response.data.length && response.data[0].client_checklist_id ? getClientChecklists(checklist_id, response.data[0].client_checklist_id) : response); });
    };

    var findClientResult = function (checklist_id, question_id, value) {
        return api.get('/checklists/' + checklist_id + '/clientChecklists/results?question_id=' + question_id + '&value=' + value + '&not_status=4')
            .then(function (response) { return response; });
    };

    var getClientChecklists = function (checklist_id, client_checklist_id) {
        return api.get('/checklists/' + checklist_id + '/clientChecklists/' + client_checklist_id)
            .then(function (response) { return response; });
    };

    var getClient = function (client_id) {
        return api.get('/clients/' + client_id)
            .then(function (response) { return response; });
    };

    var setClientChecklist = function (client_id, data) {
        return api.post('/clients/' + client_id + '/checklists', data)
            .then(function (response) { return response; });
    };

    var findClient = function (client_type_id, company_name) {
        return api.get('/clients?client_type_id=' + client_type_id + '&company_name=' + company_name + '&not_status=3')
            .then(function (response) { return response; });
    };

    var getClientResult = function (client_id, client_checklist_id, question_id, answer_id, index) {
        var url = '/clients/' + client_id + '/checklists/' + client_checklist_id + '/results?question_id=' + question_id
            + (typeof answer_id !== 'undefined' ? '&answer_id=' + answer_id : '')
            + (typeof index !== 'undefined' ? '&index=' + index : '');

        return api.get(url)
            .then(function (response) { return response; });
    };

    var setClient = function (data) {
        return api.post('/clients', data)
            .then(function (response) { return response; });
    };

    var setClientResult = function (client_id, client_checklist_id, data) {
        return api.post('/clients/' + client_id + '/checklists/' + client_checklist_id + '/results', data)
            .then(function (response) { return response; });
    };

    var deleteClientResult = function (client_id, client_checklist_id, index, question_id, answer_id) {
        var url = '/clients/' + client_id + '/checklists/' + client_checklist_id + '/results?delete=true'
            + (typeof question_id !== 'undefined' ? '&question_id=' + question_id : '')
            + (typeof answer_id !== 'undefined' && answer_id !== null ? '&answer_id=' + answer_id : '')
            + (typeof index !== 'undefined' ? '&index=' + index : '');

        return api.delete(url)
            .then(function (response) { return response; });
    };

    var getQuestions = function (checklist_id, question_id) {
        return api.get('/checklists/' + checklist_id + '/questions/' + question_id)
            .then(function (response) { return response; });
    };

    var getAnswers = function (checklist_id, question_id) {
        return api.get('/checklists/' + checklist_id + '/questions/' + question_id + '/answers')
            .then(function (response) { return response; });
    };

    var getQuestionAnswers = function (checklist_id, question_id) {
        var url = '/checklists/' + checklist_id + '/questionAnswers'
            + (typeof question_id !== 'undefined' ? '?question_id=' + question_id : '');
        return api.get(url)
            .then(function (response) { return response; });
    };

    var objectToFormData = function (data) {
        var form = new FormData();
        var keys = Object.keys(data);
        for (var i = 0; i < keys.length; i++) {
            form.append(keys[i], data[keys[i]]);
        }
        return form;
    };

    var setClientAndChecklist = function (client_type_id, company_name, checklist_id) {
        return setClient(objectToFormData({ client_type_id: client_type_id, company_name: company_name }))
            .then(function (response) {
                return setClientChecklist(response.data[0].client_id, objectToFormData({ checklist_id: checklist_id, client_id: response.data[0].client_id }))
            })
    };

    var getFeedbackValues = function (keyFields, data) {
        var error = '';
        for (var property in keyFields) {
            error += ' ' + keyFields[property].description + ': ' + data[keyFields[property].column] + ';';
        }
        return error;
    }

    var getOrSetClientChecklist = function (sheet, data, keyFields, createRecord) {
        return new Promise(function (resolve, reject) {
            findClientChecklist(checklistId, keyFields['lookup'].question_id, data[keyFields['lookup'].column])
                .then(function (response) {
                    if (response.data.length) ui.setFeedback('<div class="row bg-success">Found existing record for:' + getFeedbackValues(keyFields, data) + '</div>');
                    return response.data.length ? response.data[0] : null;
                })
                .then(function (clientChecklist) {
                    if (clientChecklist) return clientChecklist;
                    if (!createRecord) throw 'Could not find existing record for:' + getFeedbackValues(keyFields, data);
                    return null;
                })
                .then(function (clientChecklist) {
                    if (clientChecklist) return clientChecklist;


                    return findClient(clientTypeId, data[keyFields['company_name'].column])
                        .then(function (response) {
                            if (response.data.length) {
                                return setClientChecklist(response.data[0].client_id, objectToFormData({ checklist_id: checklistId, client_id: response.data[0].client_id }))
                                    .then(function (response) {
                                        if (response.data.length) ui.setFeedback('<div class="row bg-success">Created new record for:' + getFeedbackValues(keyFields, data) + '</div>');
                                        return response.data.length ? response.data[0] : null;
                                    });
                            }
                        });
                })
                .then(function (clientChecklist) {
                    if (clientChecklist) return clientChecklist;

                    return setClientAndChecklist(clientTypeId, data[keyFields['company_name'].column], checklistId)
                        .then(function (response) {
                            if (response.data.length) ui.setFeedback('<div class="row bg-success">Created new record for:' + getFeedbackValues(keyFields, data) + '</div>');
                            return response.data.length ? response.data[0] : null;
                        });
                })
                .then(function (clientChecklist) {
                    resolve(clientChecklist);
                })
                .catch(function (error) {
                    reject(error);
                })
        });
    };

    var convertWorkbookToArray = function (workbook) {
        var data = [];
        return new Promise(function (resolve, reject) {
            for (var i = 0; i < workbook.SheetNames.length; i++) {
                var sheet = {};
                var convert_data = [];
                // sheet[workbook.SheetNames[i]] = XLSX.utils.sheet_to_json(workbook.Sheets[workbook.SheetNames[i]], { header: 'A' });
                convert_data = XLSX.utils.sheet_to_json(workbook.Sheets[workbook.SheetNames[i]], { header: 'A' });
                for (var k = 0; k < convert_data.length; k++) {
                    for (var j in convert_data[k]) {
                        convert_data[k][j] = convert_data[k][j].latinise();
                    }
                }
                sheet[workbook.SheetNames[i]] = convert_data;
                data.push(sheet);
            }
            resolve(data);
        });
    };

    var setTotalRows = function (value) {
        totalRows = value;
        return;
    };

    var getTotalRows = function (data) {
        var rowCount = 0;
        for (var i = 0; i < data.length; i++) {
            for (var sheet in data[i]) {
                rowCount += data[i][sheet].length;
            }
        }

        return rowCount;
    };

    var setImportProfileMap = function (value) {
        importProfileMap = value;
        return;
    };

    var setChecklistId = function (value) {
        checklistId = value;
        return;
    };

    var setClientTypeId = function (value) {
        clientTypeId = value;
        return;
    };

    var getKeyFields = function (sheet) {
        var keyFields = [];
        for (var i = 0; i < importProfileMap.length; i++) {
            if (importProfileMap[i].sheet === sheet && importProfileMap[i].key != null) {
                keyFields[importProfileMap[i].key] = importProfileMap[i];
            }
        }

        return keyFields;
    };

    var getDateFromString = function (value, format) {
        var date = null;
        format = format ? format : "AU";

        switch (format) {
            case "US":
                date = new Date(value);
                if (date == "Invalid Date") {
                    var dateParts = value.split("/");
                    date = new Date(dateParts[1] + "/" + dateParts[0] + "/" + dateParts[2]);
                }
                break;

            case "AU":
            default:
                var dateParts = value.split("/");
                date = new Date(dateParts[1] + "/" + dateParts[0] + "/" + dateParts[2]);
                if (date == "Invalid Date") {
                    date = new Date(value);
                }
                break;
        }

        var dd = date.getDate();
        var mm = date.getMonth() + 1;
        var yyyy = date.getFullYear();

        dd = dd < 10 ? "0" + dd : dd;
        mm = mm < 10 ? "0" + mm : mm;

        var dateString = dd + "/" + mm + "/" + yyyy;
        return isNaN(date.getTime()) ? [null] : [dateString];
    };

    var formatCountryString = function (value) {
        var countries = {
            'Central African Republic': 'Central African Republic (CAR)',
            'Macedonia': 'Macedonia (FYROM)',
            'Myanmar': 'Myanmar (Burma)',
            'United Arab Emirates': 'United Arab Emirates (UAE)',
            'United Kingdom': 'United Kingdom (UK)',
            'United States of America': 'United States of America (USA)',
            'United States': 'United States of America (USA)',
            'USA': 'United States of America (USA)',
            'US': 'United States of America (USA)',
            'Vatican City': 'Vatican City (Holy See)'
        };

        for (var country in countries) {
            if (country.toLowerCase() == value.trim().toLowerCase()) {
                value = countries[country];
                break;
            }
        }

        return [value];
    };

    var applyImportMethod = function (value, method) {
        switch (method) {
            case "split-comma": return value.split(",");
            case "date": return getDateFromString(value);
            case "date-us": return getDateFromString(value, "US");
            case "country": return formatCountryString(value);
            default: return [value];
        }
    };

    var checkImportPriority = function (client_id, client_checklist_id, question_id, answer_id, index, priority) {
        return new Promise(function (resolve, reject) {
            if (priority == 1) {
                resolve(true);
            } else {
                return getClientResult(client_id, client_checklist_id, question_id, answer_id, index)
                    .then(function (response) {
                        resolve(!response.data.length ? true : false);
                    });
            }
        });
    };

    var findMatchingAnswer = function (answers, value) {
        switch (answers.length) {
            case 0: return false;
            case 1: return answers[0];
            default:
                for (i = 0; i < answers.length; i++) {
                    if (answers[i].string.trim().toLowerCase() == value.trim().toLowerCase()) { return answers[i]; }
                }
        }

        return false;
    };

    var updateFeedback = function (clientChecklist, question, response) {
        var messageType = (response.hasOwnProperty('statusText') ? 'success' : 'warning')

        var feedback = '<div class="row bg-' + messageType + '">' + clientChecklist['company_name'] + ' > ' + question['question'] + ' > ' +
            (response.hasOwnProperty('statusText') ? response.data[0].arbitrary_value + ' > ' + response.statusText : response) +
            '</div>';

        return ui.setFeedback(feedback);
    };

    var reportProgress = function (progress) {
        return ui.setProgress(Math.round((progress / totalRows) * 100));
    };

    var processData = function (data, method, createRecord, firstRow) {
        var method = method ? method : 'row'; //Default processes by row
        var createRecord = createRecord ? createRecord : false; //Default doesn't create new record
        var seedRow = firstRow ? firstRow : 1; //Default allows for header row

        switch (method) {
            case 'sheet':
                return processDataBySheet(data, createRecord);
                break;
            case 'row':
            default:
                return processDataByRow(data, createRecord, seedRow);
                break;
        }
        return;
    };

    var processDataBySheet = function (data, createRecord) {
        setTotalRows(importProfileMap.length);
        return new Promise(function (resolve, reject) {
            var sheet = Object.keys(data[data.length - 1])[0];
            var keyFields = getKeyFields(sheet);
            getOrSetClientChecklist(sheet, data[data.length - 1][sheet][0], keyFields, createRecord)
                .then(function (clientChecklist) {
                    return getClient(clientChecklist['client_id'])
                        .then(function (client) {
                            clientChecklist['company_name'] = client.data.length ? client.data[0]['company_name'] : '';
                            return clientChecklist;
                        })
                })
                .then(function (clientChecklist) {
                    return processSheet(clientChecklist, data);
                })
                .catch(function (error) {
                    ui.setFeedback('<div class="row bg-danger">' + error + '</div>');
                })
                .then(function (response) {
                    resolve(reportProgress(totalRows));
                })
        });
    }

    var processSheet = function (clientChecklist, data) {
        return new Promise(function (resolve, reject) {
            var progress = 0;
            console.log(data);
            (getMap = function (i) {
                value = getCellFromWorkbook(data, importProfileMap[i].sheet, importProfileMap[i].row, importProfileMap[i].column);
                if (value) {
                    processQuestion(clientChecklist, importProfileMap[i], value)
                        .catch(function (error) {
                            ui.setFeedback('<div class="row bg-danger">' + error + '</div>');
                        })
                        .then(function () {
                            reportProgress(progress++);
                            i < importProfileMap.length - 1 ? getMap(i + 1) : resolve(reportProgress(totalRows));
                        });
                } else {
                    reportProgress(progress++);
                    i < importProfileMap.length - 1 ? getMap(i + 1) : resolve(reportProgress(totalRows));
                }
            })(0);
        });
    }

    var getCellFromWorkbook = function (data, sheet, row, col) {
        var value = null;
        if (row && col) {
            for (var i = 0; i < data.length; i++) {
                if (data[i][sheet]) {
                    for (var j = 0; j < data[i][sheet].length; j++) {
                        if (data[i][sheet][j][col] && data[i][sheet][j]["__rowNum__"] == row - 1) {
                            value = data[i][sheet][j][col];
                            break;
                        }
                    }
                }
            }
        }
        return value;
    }

    var processDataByRow = function (data, createRecord, seedRow) {
        return new Promise(function (resolve, reject) {
            var progress = 1;
            setTotalRows(getTotalRows(data));
            (getSheet = function (i) {
                var sheet = Object.keys(data[i])[0];
                var keyFields = getKeyFields(sheet);
                (getRow = function (j) {
                    getOrSetClientChecklist(sheet, data[i][sheet][j], keyFields, createRecord)
                        .then(function (clientChecklist) {
                            return getClient(clientChecklist['client_id'])
                                .then(function (client) {
                                    clientChecklist['company_name'] = client.data.length ? client.data[0]['company_name'] : '';
                                    return clientChecklist;
                                })
                        })
                        .then(function (clientChecklist) {
                            return processRow(clientChecklist, sheet, data[i][sheet][j]);
                        })
                        .catch(function (error) {
                            ui.setFeedback('<div class="row bg-danger">' + error + '</div>');
                        })
                        .then(function (response) {
                            reportProgress(progress++);
                            j < data[i][sheet].length - 1 ? getRow(j + 1) : (i < data.length - 1 ? getSheet(i + 1) : resolve(reportProgress(totalRows)));
                        });
                })(seedRow);
            })(0);
        });
    }

    var processRow = function (clientChecklist, sheet, row) {
        return new Promise(function (resolve, reject) {
            (getMap = function (i) {
                if (importProfileMap[i]['sheet'] == sheet && row.hasOwnProperty(importProfileMap[i]['column']) && importProfileMap[i]['question_id']) {
                    return processQuestion(clientChecklist, importProfileMap[i], row[importProfileMap[i]['column']])
                        .then(function (response) {
                            i < importProfileMap.length - 1 ? getMap(i + 1) : resolve();
                        });
                }
                else { i < importProfileMap.length - 1 ? getMap(i + 1) : resolve(); }
            })(0);
        });
    };

    var processQuestion = function (clientChecklist, map, value) {
        return new Promise(function (resolve, reject) {
            return getQuestionAnswers(checklistId, map['question_id'])
                .then(function (response) {
                    if (!response.data.length) return reject('No matching question.');
                    return resolve(processAnswers(clientChecklist, map, response.data[0], value));
                });
        });
    };

    var processAnswers = function (clientChecklist, map, question, value) {
        return new Promise(function (resolve, reject) {
            var index = value['index'] ? value['index'] : map['index'];
            var values = applyImportMethod((value['value'] ? value['value'] : value), map['method']);

            (getValue = function (i) {
                return new Promise(function (resolve, reject) {
                    values[i] = values[i].toString().trim(); //Trim white space
                    var answer = findMatchingAnswer(question.answers, values[i]);
                    if (!answer || values[i] === null) return reject('No matching answer.');

                    //Set Index
                    index = i > 0 ? index + 1 : index;

                    return checkImportPriority(clientChecklist['client_id'], clientChecklist['client_checklist_id'], question['question_id'], answer['answer_id'], index, map['priority'])
                        .then(function (hasPriority) {
                            if (!hasPriority) {
                                return reject('Rejected on priority.');
                            } else {
                                return deleteClientResult(clientChecklist['client_id'], clientChecklist['client_checklist_id'], index, answer['question_id'], (question['multiple_answer'] ? answer['answer_id'] : null))
                                    .then(function (response) {
                                        var result = objectToFormData({ 'question_id': answer['question_id'], 'answer_id': answer['answer_id'], 'arbitrary_value': values[i], 'index': index });
                                        return setClientResult(clientChecklist['client_id'], clientChecklist['client_checklist_id'], result);
                                    })
                                    .then(function (response) {
                                        resolve(response);
                                    });
                            }
                        })
                })
                    //Report the response or error
                    .then(function (response) {
                        updateFeedback(clientChecklist, question, response);
                    })
                    .catch(function (error) {
                        updateFeedback(clientChecklist, question, error);
                    })
                    .then(function (response) {
                        i < values.length - 1 ? getValue(i + 1) : resolve();
                    });
            })(0);
        });
    };

    return {
        get: get,
        setImportProfileMap: setImportProfileMap,
        setChecklistId: setChecklistId,
        setClientTypeId: setClientTypeId,
        convertWorkbookToArray: convertWorkbookToArray,
        findClientResult: findClientResult,
        processData: processData,
        findVendorResult: findVendorResult
    }

})();

/**
*  Set the UI
*/
$(function () { ui.init() });

var ui = (function () {

    function getClientTypeId() {
        return $('.api.import select[name="client_type_id"]').find(':selected').val();
    }

    function getChecklistId() {
        return $('.api.import select[name="checklist_id"]').find(':selected').val();
    }

    function getImportProfileId() {
        return $('.api.import select[name="import_profile_id"]').find(':selected').val();
    }

    function getDataFile() {
        return $('.api.import #data-file')[0].files[0];
    }

    var init = function () {
        bindFunctions();
        setClientTypes();
        setChecklists();
    }

    var bindFunctions = function () {
        $('.api.import select[name="checklist_id"]').change(setImportProfiles);
        $('.api.import .start-import').click(startImport);
    }

    var setClientTypes = function () {

        GreenBizCheck.get('/clients/types?sort=client_type')
            .then(function (clientTypes) {
                $('.api.import select[name="client_type_id"]').each(function () {
                    $select = $(this);
                    $(this).empty().append($('<option>', { value: null, text: '-- Select --' }));
                    $.each(clientTypes, function (i, clientType) {
                        $select.append($('<option>', {
                            value: clientType.client_type_id,
                            text: clientType.client_type
                        }));
                    });
                });
            });
    }

    var setChecklists = function () {
        GreenBizCheck.get('/checklists?sort=name')
            .then(function (checklists) {
                $('.api.import select[name="checklist_id"]').each(function () {
                    $select = $(this);
                    $(this).empty().append($('<option>', { value: null, text: '-- Select --' }));
                    $.each(checklists, function (i, checklist) {
                        $select.append($('<option>', {
                            value: checklist.checklist_id,
                            text: checklist.name
                        }));
                    });
                });
            });
    }

    var setImportProfiles = function () {
        GreenBizCheck.get('/checklists/' + getChecklistId() + '/importProfiles')
            .then(function (profiles) {
                $('.api.import select[name="import_profile_id"]').each(function () {
                    $select = $(this);
                    $select.empty().append($('<option>', { value: null, text: '-- Select --' }));
                    $.each(profiles, function (i, profile) {
                        $select.append($('<option>', {
                            value: profile.import_profile_id,
                            text: profile.name
                        }));
                    });
                });
            });
    }

    var startImport = function () {
        setProgress(0);
        setFeedback();

        GreenBizCheck.get('/checklists/' + getChecklistId() + '/importProfiles/' + getImportProfileId() + '/maps')
            .then(function (importProfileMap) {
                getFile(function (workbook) {
                    ui.setFeedback('Formatting data for import...');
                    switch (getImportProfileId()) {

                        //Vendor Master
                        case '1':
                            vendorMaster.init(workbook, getClientTypeId(), getChecklistId(), importProfileMap);
                            break;

                        //Survey Monkey
                        case '2':
                            surveyMonkey.init(workbook, getClientTypeId(), getChecklistId(), importProfileMap);
                            break;

                        //ncSheet
                        case '3':
                            ncSheet.init(workbook, getClientTypeId(), getChecklistId(), importProfileMap);
                            break;

                        //Excel Questionnaire
                        case '4':
                            excelQuestionnaire.init(workbook, getClientTypeId(), getChecklistId(), importProfileMap);
                            break;

                        // Vendor Sales Data
                        case '5':
                            vendorSales.init(workbook, getClientTypeId(), getChecklistId(), importProfileMap);
                            break;

                        //Vendor Spend Data
                        case '6':
                            vendorSpend.init(workbook, getClientTypeId(), getChecklistId(), importProfileMap);
                            break;

                        //Sedex Audit Report Data
                        case '7':
                            sedexAduit.init(workbook, getClientTypeId(), getChecklistId(), importProfileMap);
                            break;

                        //Sedex Lapsed Date
                        case '8':
                            sedexLapsedDate.init(workbook, getClientTypeId(), getChecklistId(), importProfileMap);
                            break;

                        //Sedex SAQ
                        case '9':
                            sedexSAQ.init(workbook, getClientTypeId(), getChecklistId(), importProfileMap);
                            break;

                        //Individual Timber Data Sheets Data
                        case '10':
                            individualTimber.init(workbook, getClientTypeId(), getChecklistId(), importProfileMap);
                            break;
                    }
                });
            });
    }

    var getFile = function (callback) {
        var reader = new FileReader();
        reader.onload = function (e) {
            var data = e.target.result;
            var workbook = XLSX.read(data, { type: 'binary' });
            callback(workbook);
        };

        reader.readAsBinaryString(getDataFile());
    }

    var setProgress = function (progress) {
        progress = progress > 100 ? 100 : progress;
        $('.api.import .progress-bar').attr('aria-valuenow', progress).attr('style', 'width:' + progress + '%').find('.import-progress').html(progress);
    }

    var setFeedback = function (feedback) {
        return !feedback ? $('.api.import .import-feedback').empty() : $('.api.import .import-feedback').prepend(feedback);
    }

    var setTimeRemaining = function (timeRemaining) {
        return !timeRemaining ? $('.api.import .import-time').html() : $('.api.import .import-feedback').append(feedback);
    }

    return {
        init: init,
        setProgress: setProgress,
        setFeedback: setFeedback
    }

})();

// Prepare Vendor Master Data
var vendorMaster = (function () {
    var init = function (workbook, clientTypeId, checklistId, importProfileMap) {
        return GreenBizCheck.convertWorkbookToArray(workbook)
            .then(formatYesNoStrings)
            .then(setDuplicateRecordType)
            .then(function (data) {
                console.log('Vendor Master', data);
                GreenBizCheck.setClientTypeId(clientTypeId);
                GreenBizCheck.setChecklistId(checklistId);
                GreenBizCheck.setImportProfileMap(importProfileMap);
                GreenBizCheck.processData(data, 'row', true);
            });
    }

    var setDuplicateRecordType = function (data) {
        var sheet = 'MF', mapsTo = 'E', primaryKey = 'A', vendorNumberColumn = 'C', keepers = ['C', 'D', 'E'];

        for (var i = 0; i < data.length; i++) {
            if (data[i][sheet]) {
                for (var j = 0; j < data[i][sheet].length; j++) {
                    if (data[i][sheet][j][mapsTo] && j) {

                        var masterRecord = findObjectInArray(data[i][sheet][j][mapsTo], data[i][sheet], vendorNumberColumn);
                        data[i][sheet][j] = mergeObjectProperties(data[i][sheet][j], masterRecord, keepers);
                        data[i][sheet][j] = setResultIndex(data[i][sheet][j], keepers, j);
                    }
                }
            }
        }

        return data;
    }

    var formatYesNoStrings = function (data) {
        var sheet = "PLF", columns = ['D', 'E', 'AC'];

        for (var i = 0; i < data.length; i++) {
            if (data[i][sheet]) {
                for (var j = 1; j < data[i][sheet].length; j++) {
                    for (var k = 0; k < columns.length; k++) {
                        if (data[i][sheet][j][columns[k]]) {
                            var answer = data[i][sheet][j][columns[k]].toLowerCase();
                            switch (answer) {
                                case 'y':
                                    data[i][sheet][j][columns[k]] = 'Yes';
                                    break;
                                case 'n':
                                    data[i][sheet][j][columns[k]] = 'No';
                                    break;
                            }
                        }
                    }
                }
            }
        }

        return data;
    }

    var setResultIndex = function (object, properties, index) {
        for (var property in object)
            if (properties.indexOf(property) != -1)
                object[property] = { index: index, value: object[property] };

        return object;
    }

    var findObjectInArray = function (needle, hayStack, property) {
        object = null;

        for (var i = 0; i < hayStack.length; i++) {
            if (hayStack[i][property] && hayStack[i][property] == needle) {
                object = hayStack[i];
                break;
            }
        }

        return object;
    }

    var mergeObjectProperties = function (object, templateObject, keepers) {
        for (var property in object)
            if (keepers.indexOf(property) == -1)
                if (templateObject[property])
                    object[property] = templateObject[property];

        return object;
    }

    return {
        init: init
    }

})();

// Prepare Survey Monkey Data
var surveyMonkey = (function () {
    var init = function (workbook, clientTypeId, checklistId, importProfileMap) {
        return GreenBizCheck.convertWorkbookToArray(workbook)
            .then(removeBlankRows)
            .then(formatLengthOfRelationship)
            .then(changeNotKnownAnswers)
            .then(changeSeveralFields)
            .then(function (data) {
                console.log('Survey Monkey', data);
                GreenBizCheck.setClientTypeId(clientTypeId);
                GreenBizCheck.setChecklistId(checklistId);
                GreenBizCheck.setImportProfileMap(importProfileMap);
                GreenBizCheck.processData(data, 'row');
            });

    }

    var removeBlankRows = function (data) {
        var sheet = 'Survey Monkey', emailAddressColumn = 'F';

        for (var i = 0; i < data.length; i++)
            if (data[i][sheet])
                for (var j = data[i][sheet].length - 1; j > 0; j--)
                    if (!data[i][sheet][j][emailAddressColumn])
                        data[i][sheet].splice(j, 1);

        return data;
    }

    var formatLengthOfRelationship = function (data) {
        var sheet = 'Survey Monkey', lengthOfRelationshipColumn = 'BO', lastUpdatedColumn = 'D';

        for (var i = 0; i < data.length; i++) {
            if (data[i][sheet]) {
                for (var j = data[i][sheet].length - 1; j > 0; j--) {
                    if (data[i][sheet][j][lengthOfRelationshipColumn] && data[i][sheet][j][lastUpdatedColumn]) {
                        var lastUpdated = new Date(data[i][sheet][j][lastUpdatedColumn]);
                        var lengthOfRelationship = data[i][sheet][j][lengthOfRelationshipColumn];
                        if (lengthOfRelationship != "<1") {
                            lastUpdated.setFullYear(lastUpdated.getFullYear() - lengthOfRelationship);
                        }
                        data[i][sheet][j][lengthOfRelationshipColumn] = (lastUpdated.getMonth() + 1) + "/" + lastUpdated.getDate() + "/" + lastUpdated.getFullYear();
                    }
                }
            }
        }

        return data;
    }

    var changeNotKnownAnswers = function (data) {
        var sheet = 'Survey Monkey', notKnownColumns = ['BQ', 'BR', 'BS', 'BT', 'BU', 'BV', 'BW'];
        for (var i = 0; i < data.length; i++) {
            if (data[i][sheet]) {
                for (var j = data[i][sheet].length - 1; j > 0; j--) {
                    for (var k = 0; k < notKnownColumns.length; k++) {
                        if (data[i][sheet][j][notKnownColumns[k]] && data[i][sheet][j][notKnownColumns[k]] === "Not Known") {
                            data[i][sheet][j][notKnownColumns[k]] = "Not sure";
                        }
                    }
                }
            }
        }

        return data;
    }
    var changeSeveralFields = function (data) {
        var sheet = 'Survey Monkey';
        var fristCondition = false, secondCondition = false, thirdCondiion = false;
        for (var i = 0; i < data.length; i++) {
            if (data[i][sheet]) {
                for (var j = data[i][sheet].length - 1; j > 0; j--) {

                    if (data[i][sheet][j]['AIG'] === 'Yes') {
                        data[i][sheet][j]['AIG'] = 'Labour Standards';
                        fristCondition = true;
                    } else {
                        data[i][sheet][j]['AIG'] = '';
                        fristCondition = false;
                    }

                    if (data[i][sheet][j]['AIJ'] === 'Yes') {
                        data[i][sheet][j]['AIJ'] = 'Environment';
                        secondCondition = true;
                    } else {
                        data[i][sheet][j]['AIJ'] = '';
                        secondCondition = false;
                    }

                    if (data[i][sheet][j]['IE'] === 'Yes' || data[i][sheet][j]['ME'] === 'Yes' || data[i][sheet][j]['PV'] === 'Yes' || data[i][sheet][j]['SD'] === 'Yes') {
                        data[i][sheet][j]['IE'] = 'Bribery & Corruption';
                        thirdCondiion = true;
                    } else {
                        thirdCondiion = false;
                    }

                    if (!fristCondition && !secondCondition && !thirdCondiion) {
                        data[i][sheet][j]['BAA'] = 'No';
                    }
                    if (fristCondition || secondCondition || thirdCondiion) {
                        data[i][sheet][j]['BAA'] = 'Partial';
                    }

                    var commaData = [];
                    if (data[i][sheet][j]['P']) {
                        commaData = data[i][sheet][j]['P'];
                    }
                    if (data[i][sheet][j]['Q']) {
                        commaData = commaData + "," + data[i][sheet][j]['Q'];
                    }
                    if (data[i][sheet][j]['R']) {
                        commaData = commaData + "," + data[i][sheet][j]['R'];
                    }
                    if (data[i][sheet][j]['S']) {
                        commaData = commaData + "," + data[i][sheet][j]['S'];
                    }
                    if (data[i][sheet][j]['T']) {
                        commaData = commaData + "," + data[i][sheet][j]['T'];
                    }
                    data[i][sheet][j]['P'] = commaData;

                    if (data[i][sheet][j]['DX'] === 'Yes' || data[i][sheet][j]['EG'] === 'Yes' || data[i][sheet][j]['EP'] === 'Yes') {
                        data[i][sheet][j]['DX'] = 'Labour Standards';
                    }

                    if (data[i][sheet][j]['FI'] === 'Yes' || data[i][sheet][j]['JI'] === 'Yes' ||
                        data[i][sheet][j]['MZ'] === 'Yes' || data[i][sheet][j]['SI'] === 'Yes') {
                        data[i][sheet][j]['FI'] = 'Environment';
                    }

                    if (data[i][sheet][j]['EX'] === 'Yes' || data[i][sheet][j]['IO'] === 'Yes' ||
                        data[i][sheet][j]['MO'] === 'Yes' || data[i][sheet][j]['TQ'] === 'Yes' ||
                        data[i][sheet][j]['EY'] === 'Yes' || data[i][sheet][j]['IP'] === 'Yes' ||
                        data[i][sheet][j]['MP'] === 'Yes' || data[i][sheet][j]['TR'] === 'Yes') {

                        data[i][sheet][j]['EX'] = 'Animal Welfare';

                    }
                    if (data[i][sheet][j]['IC'] === 'Yes' || data[i][sheet][j]['MC'] === 'Yes' ||
                        data[i][sheet][j]['PT'] === 'Yes' || data[i][sheet][j]['SB'] === 'Yes') {

                        data[i][sheet][j]['IC'] = 'Animal Welfare';

                    }

                    if (data[i][sheet][j]['AIF'] === 'Yes') {
                        data[i][sheet][j]['AIF'] = 'Labour Standards';

                    }

                    if (data[i][sheet][j]['AII'] === 'Yes') {
                        data[i][sheet][j]['AII'] = 'Environment';

                    }
                }
            }
        }
        return data;
    }
    return {
        init: init
    }
})();

// Prepare NC Sheet Data
var ncSheet = (function () {
    var init = function (workbook, clientTypeId, checklistId, importProfileMap) {
        return GreenBizCheck.convertWorkbookToArray(workbook)
            .then(function (data) {
                return formatNCSheet(checklistId, data);
            })
            .then(function (data) {
                console.log('NC Sheet', data);
                GreenBizCheck.setClientTypeId(clientTypeId);
                GreenBizCheck.setChecklistId(checklistId);
                GreenBizCheck.setImportProfileMap(importProfileMap);
                GreenBizCheck.processData(data, 'row', true);
            });
    }

    var formatNCSheet = function (checklistId, data) {
        var sheet = 'NC Sheet', identifiers = ['A', 'D'], factoryId = 'B', factoryIdQuestion = '15747';

        return new Promise(function (resolve, reject) {
            (getSheet = function (i) {
                (getRow = function (j) {
                    return GreenBizCheck.findClientResult(checklistId, factoryIdQuestion, data[i][sheet][j][factoryId])
                        .then(function (response) {
                            index = response.data.length ? response.data[0].index : j;
                            data[i][sheet][j] = setResultIndex(data[i][sheet][j], identifiers, index);
                        })
                        .then(function () {
                            j < data[i][sheet].length - 1 ? getRow(j + 1) : i < data.length - 1 ? getSheet(i + 1) : resolve(data);
                        });
                })(1);
            })(0);
        });

    }

    var setResultIndex = function (object, properties, index) {
        for (var property in object)
            if (properties.indexOf(property) == -1)
                object[property] = { index: index, value: object[property] };

        return object;
    }

    return {
        init: init
    }
})();

//Group array by field
var groupBy = function (array, f) {
    var groups = {};
    array.forEach(function (o) {
        var group = JSON.stringify(f(o));
        groups[group] = groups[group] || [];
        groups[group].push(o);
    });
    return Object.keys(groups).map(function (group) {
        return groups[group];
    })
};

// Prepare Excel Questionnaire Data
var excelQuestionnaire = (function () {
    var init = function (workbook, clientTypeId, checklistId, importProfileMap) {
        return GreenBizCheck.convertWorkbookToArray(workbook)
            .then(setVendorInformation)
            .then(setAddress)
            .then(setPercentBusiness)
            .then(setBusinessRelationship)
            .then(function (data) {
                console.log('Excel Questionnaire', data);
                GreenBizCheck.setClientTypeId(clientTypeId);
                GreenBizCheck.setChecklistId(checklistId);
                GreenBizCheck.setImportProfileMap(importProfileMap);
                GreenBizCheck.processData(data, 'sheet', true);
            });
    }

    var setVendorInformation = function (data) {
        var vendorInfo = getVendorInfo();
        data.push({ 'Vendor Info': [{ 'A': vendorInfo[0], 'B': vendorInfo[2], 'C': vendorInfo[1], '__rowNum__': -1 }] });

        return data;
    }

    var getVendorInfo = function (data) {
        var vendorInfo, file = $('.api.import #data-file')[0].files[0];
        vendorInfo = file.name.split('.');

        return vendorInfo;
    }

    var setAddress = function (data) {
        var sheet = 'Vendor Profile', addressCol = 'E', addressFields = [7, 8], address = [];
        for (var i = 0; i < data.length; i++) {
            if (data[i][sheet]) {
                for (var j = data[i][sheet].length - 1; j > 0; j--) {
                    var index = addressFields.indexOf(data[i][sheet][j]["__rowNum__"] + 1);
                    if (index > -1 && data[i][sheet][j][addressCol]) {
                        address.unshift(data[i][sheet][j][addressCol]);
                    }

                    if (index == 0) {
                        data[i][sheet][j][addressCol] = address.join(", ");
                    }
                }
            }
        }

        return data;
    }

    var setPercentBusiness = function (data) {
        var sheet = 'Vendor Profile', col = 'D', row = 26;
        for (var i = 0; i < data.length; i++) {
            if (data[i][sheet]) {
                for (var j = data[i][sheet].length - 1; j > 0; j--) {
                    if (data[i][sheet][j]["__rowNum__"] == row - 1) {
                        data[i][sheet][j][col] = parseInt(data[i][sheet][j][col]);
                        break;
                    }
                }
            }
        }
        return data;
    }

    var setBusinessRelationship = function (data) {
        var sheet = 'Vendor Profile', col = 'F', row = 24;
        for (var i = 0; i < data.length; i++) {
            if (data[i][sheet]) {
                for (var j = data[i][sheet].length - 1; j > 0; j--) {
                    if (data[i][sheet][j]["__rowNum__"] == row - 1) {
                        var date = new Date();
                        date.setFullYear(date.getFullYear() - parseInt(data[i][sheet][j][col]));
                        data[i][sheet][j][col] = (date.getDate()) + '/' + (date.getMonth() + 1) + '/' + (date.getFullYear());
                        break;
                    }
                }
            }
        }
        return data;
    }

    return {
        init: init
    }
})();

// Prepare Vendor Spend Data
var vendorSpend = (function () {
    var init = function (workbook, clientTypeId, checklistId, importProfileMap) {
        return GreenBizCheck.convertWorkbookToArray(workbook)
            .then(formatVendorSpend)
            .then(function (data) {
                console.log('Vendor Spend', data);
                setPaymentsLastColumn(importProfileMap);
                GreenBizCheck.setClientTypeId(clientTypeId);
                GreenBizCheck.setChecklistId(checklistId);
                GreenBizCheck.setImportProfileMap(importProfileMap);
                GreenBizCheck.processData(data, 'row');
            });
    }
    var formatVendorSpend = function (data) {
        var sheet = 'Sheet1', allData = [], sumData = [], vendor_result = [], client_checklist_id = [];
        var result = groupBy(data[0][sheet], function (item) {
            return [item.B];
        });
        sumData[0] = { A: result[0][0].A, B: result[0][0].B, H: result[0][0].H, I: result[0][0].I }
        for (var i = 1; i < result.length; i++) {
            var lastSum = 0, preSum = 0;
            result[i].map(function (ii) {
                var currentNow = moment();
                var dateVal = moment(ii.D, 'DD-MM-YYYY');
                if (currentNow.diff(dateVal, 'months') <= 12) {
                    lastSum = parseFloat(lastSum) + parseFloat(ii.H);
                }
                if (currentNow.diff(dateVal, 'months') > 12 && currentNow.diff(dateVal, 'months') <= 24) {
                    preSum = parseFloat(lastSum) + parseFloat(ii.H);
                }
            });
            sumData[i] = { A: result[i][0].A, B: result[i][0].B, H: parseFloat(lastSum).toFixed(2), I: parseFloat(preSum).toFixed(2) };
        }

        return new Promise(function (resolve, reject) {
            /** find all vendor result Checklist_id = 144 Question ID = 15693 */
            var Checklist_id = 144, Question_ID = 15693;
            GreenBizCheck.findVendorResult(Checklist_id, Question_ID).then(function (response) {
                vendor_result = response;
                client_checklist_id = vendor_result.filter(function (vendor_item) {
                    for (var index = 1; index < result.length; index++) {
                        if (result[index][0].B === vendor_item.arbitrary_value) {
                            return vendor_item.client_checklist_id;
                        }
                    }
                });
                // [12345,2344435,234345]
                var duplicated_vendorNumber = groupBy(client_checklist_id, function (item) {
                    return [item.client_checklist_id];
                });
                duplicated_vendorNumber.map(function (vendor) {
                    if (vendor.length > 1) {
                        var new_vendor = { A: '', B: '', H: 0, I: 0 };
                        vendor.map(function (item) {
                            for (var index = 1; index < sumData.length; index++) {
                                if (sumData[index].B === item.arbitrary_value) {
                                    new_vendor.A = sumData[index].A;
                                    new_vendor.B = sumData[index].B;
                                    new_vendor.H = (parseFloat(new_vendor.H) + parseFloat(sumData[index].H)).toString();
                                    new_vendor.I = (parseFloat(new_vendor.I) + parseFloat(sumData[index].I)).toString();
                                    sumData.splice(index, 1);
                                }
                            }
                        });
                        sumData.push(new_vendor);
                    }

                })

                allData.push({ Sheet1: sumData });
                resolve(allData);
            });
        })
    }

    var setPaymentsLastColumn = function (map) {
        var paymentsLastQuestionId = '15730', newColumn = 'I';

        for (var i = 0; i < map.length; i++)
            if (map[i].question_id == paymentsLastQuestionId)
                map[i].column = newColumn;

        return map;
    }

    return {
        init: init
    }
})();

// Prepare Vendor Sales Data
var vendorSales = (function () {
    var init = function (workbook, clientTypeId, checklistId, importProfileMap) {
        return GreenBizCheck.convertWorkbookToArray(workbook)
            .then(setSeasons)
            .then(formatSales)
            .then(updateColumns)
            .then(function (data) {
                console.log('Sales and Received Data', data);
                GreenBizCheck.setClientTypeId(clientTypeId);
                GreenBizCheck.setChecklistId(checklistId);
                GreenBizCheck.setImportProfileMap(importProfileMap);
                GreenBizCheck.processData(data, 'row');
            });
    }

    var updateColumns = function (data) {
        var sheet = 'Sales and Received Data', seasonColumn = 'E', salesLastColumn = 'I', receivedLastColumn = 'J', salesCurrentColumn = 'F', receivedCurrentColumn = 'G';
        for (var i = 0; i < data.length; i++) {
            if (data[i][sheet]) {
                for (var j = data[i][sheet].length - 1; j > 1; j--) {
                    if (data[i][sheet][j][seasonColumn] == 'last') {
                        data[i][sheet][j][salesLastColumn] = data[i][sheet][j][salesCurrentColumn];
                        data[i][sheet][j][receivedLastColumn] = data[i][sheet][j][receivedCurrentColumn];
                        delete data[i][sheet][j][salesCurrentColumn];
                        delete data[i][sheet][j][receivedCurrentColumn];
                    }
                }
            }
        }

        return data;
    }

    var setSeasons = function (data) {
        var sheet = 'Sales and Received Data', seasonColumn = 'E', seasons = getSeasons(data);

        var seasonLength = seasons.length;
        for (var i = 0; i < data.length; i++) {
            if (data[i][sheet]) {
                for (var j = data[i][sheet].length - 1; j > 0; j--) {
                    var seasonRank = seasons.indexOf(data[i][sheet][j][seasonColumn]);
                    if (seasonRank > -1 && seasonRank >= seasonLength - 2 && seasonRank <= seasonLength - 1) {
                        data[i][sheet][j][seasonColumn] = 'current';
                    } else if (seasonRank > -1 && seasonRank >= seasonLength - 4 && seasonRank <= seasonLength - 3) {
                        data[i][sheet][j][seasonColumn] = 'last';
                    } else {
                        delete data[i][sheet][j];
                    }
                }
            }
        }

        return data;
    }

    var getSeasons = function (data) {
        var sheet = 'Sales and Received Data', seasonColumn = 'E', seasons = [];
        for (var i = 0; i < data.length; i++)
            if (data[i][sheet])
                for (var j = 1; j < data[i][sheet].length; j++)
                    seasons.indexOf(data[i][sheet][j][seasonColumn]) === -1 ? seasons.push(data[i][sheet][j][seasonColumn]) : null;

        seasons.sort(sortSeasons);
        return seasons;
    }

    var sortSeasons = function (a, b) {
        var seasonOrder = ['W', 'S'];
        var aVal = a.substring(1).concat(seasonOrder.indexOf(a.substring(0, 1)));
        var bVal = b.substring(1).concat(seasonOrder.indexOf(b.substring(0, 1)));
        return aVal > bVal ? 1 : -1;
    }

    var formatSales = function (data) {
        var sheet = 'Sales and Received Data', allData = [], sumData = [], periods = {};

        // for (var ii = data[0][sheet].length - 1; ii > 0; ii--) {
        //     var temp = data[0][sheet][ii]['D'].split('-');
        //     data[0][sheet][ii]['D'] = temp[1];
        // }

        var result = groupBy(data[0][sheet], function (item) {
            return [item.H, item.E];
        });
        sumData[0] = { D: result[0][0].D, E: result[0][0].E, F: result[0][0].F, G: result[0][0].G, H: result[0][0].H };
        for (var i = 1; i < result.length; i++) {
            var salesSum = 0, costsSum = 0;
            result[i].map(function (ii) {
                salesSum = parseFloat(salesSum) + parseFloat(ii.F) || 0;
                costsSum = parseFloat(costsSum) + parseFloat(ii.G) || 0;

            });
            var companyName = result[i][0].D.toString().replace(result[i][0].H + '-', '');
            sumData[i] = { D: companyName, E: result[i][0].E, F: parseFloat(salesSum).toFixed(2), G: parseFloat(costsSum).toFixed(2), H: result[i][0].H };
        }
        return new Promise(function (resolve, reject) {
            /** find all vendor result Checklist_id = 144 Question ID = 15693 */
            var Checklist_id = 144, Question_ID = 15693;
            GreenBizCheck.findVendorResult(Checklist_id, Question_ID).then(function (response) {
                vendor_result = response;
                client_checklist_id = vendor_result.filter(function (vendor_item) {
                    for (var index = 1; index < sumData.length; index++) {
                        if (sumData[index].H === vendor_item.arbitrary_value) {
                            return vendor_item.client_checklist_id;
                        }
                    }
                });
                // [12345,2344435,234345]
                var duplicated_vendorNumber = groupBy(client_checklist_id, function (item) {
                    return [item.client_checklist_id];
                });
                duplicated_vendorNumber.map(function (vendor) {
                    if (vendor.length > 1) {
                        var new_vendor = { D: "", E: "", F: 0, G: 0, H: "" };
                        vendor.map(function (item) {
                            for (var index = 1; index < sumData.length; index++) {
                                if (sumData[index].H === item.arbitrary_value) {
                                    new_vendor.D = sumData[index].D;
                                    new_vendor.E = sumData[index].E;
                                    new_vendor.F = (parseFloat(new_vendor.F) + parseFloat(sumData[index].F)).toString();
                                    new_vendor.G = (parseFloat(new_vendor.G) + parseFloat(sumData[index].G)).toString();
                                    new_vendor.H = sumData[index].H;
                                    sumData.splice(index, 1);

                                }
                            }
                        });
                        sumData.push(new_vendor);
                    }

                })

                allData.push({ 'Sales and Received Data': sumData });
                resolve(allData);
            });
        })

    }

    return {
        init: init
    }
})();

//Sedex Audit Report Data
var sedexAduit = (function () {
    var init = function (workbook, clientTypeId, checklistId, importProfileMap) {
        return GreenBizCheck.convertWorkbookToArray(workbook)
            .then(function (data) {
                return formatSedexData(checklistId, data);
            })
            .then(function (data) {
                console.log('Sedex Data', data);
                GreenBizCheck.setClientTypeId(clientTypeId);
                GreenBizCheck.setChecklistId(checklistId);
                GreenBizCheck.setImportProfileMap(importProfileMap);
                GreenBizCheck.processData(data, 'row');
            });
    }

    var formatSedexData = function (checklistId, data) {
        var sheet = 'NC ISSUES LOG', issueCode = 'AE', issueCodeQuestion = '15798', identifiers = ['E', 'F'];

        return new Promise(function (resolve, reject) {
            (getSheet = function (i) {
                (getRow = function (j) {
                    return GreenBizCheck.findClientResult(checklistId, issueCodeQuestion, data[i][sheet][j][issueCode])
                        .then(function (response) {
                            index = response.data.length ? response.data[0].index : j;
                            data[i][sheet][j] = setResultIndex(data[i][sheet][j], identifiers, index);
                        })
                        .then(function () {
                            j < data[i][sheet].length - 1 ? getRow(j + 1) : i < data.length - 1 ? getSheet(i + 1) : resolve(data);
                        });
                })(1);
            })(0);
        });
    }

    var setResultIndex = function (object, properties, index) {
        for (var property in object) {
            if (object[property]) {
                if (properties.indexOf(property) == -1) {
                    object[property] = { index: index, value: object[property] };
                }
            } else {
                delete object[property];
            }
        }

        return object;
    }

    return {
        init: init
    }
})();

//Sedex Lapsed Date Data
var sedexLapsedDate = (function () {
    var init = function (workbook, clientTypeId, checklistId, importProfileMap) {
        return GreenBizCheck.convertWorkbookToArray(workbook)
            .then(setLapsedDate)
            .then(function (data) {
                console.log('Sedex Lapsed Date Data', data);
                GreenBizCheck.setClientTypeId(clientTypeId);
                GreenBizCheck.setChecklistId(checklistId);
                GreenBizCheck.setImportProfileMap(importProfileMap);
                GreenBizCheck.processData(data, 'row');
            });
    }

    var setLapsedDate = function (data) {
        var sheet = '014lapsedSuppliers';
        for (var i = 0; i < data.length; i++) {
            if (data[i][sheet]) {
                for (var j = data[i][sheet].length - 1; j > 0; j--) {
                    var currentNow = moment();
                    currentNow.add(data[i][sheet][j]['N'], 'days');
                    data[i][sheet][j]['N'] = currentNow.format('DD/MM/YYYY')
                }
            }
        }
        return data;
    }

    return {
        init: init
    }
})();

//Sedex SAQ Data
var sedexSAQ = (function () {
    var init = function (workbook, clientTypeId, checklistId, importProfileMap) {
        return GreenBizCheck.convertWorkbookToArray(workbook)
            .then(setCompleted)
            .then(function (data) {
                console.log('Sedex SAQ Data', data);
                GreenBizCheck.setClientTypeId(clientTypeId);
                GreenBizCheck.setChecklistId(checklistId);
                GreenBizCheck.setImportProfileMap(importProfileMap);
                GreenBizCheck.processData(data, 'row');
            });
    }

    var setCompleted = function (data) {
        var sheet = '015SuppliersSelfAssessmentProgr';

        for (var i = 0; i < data.length; i++) {
            if (data[i][sheet]) {
                for (var j = data[i][sheet].length - 1; j > 0; j--) {
                    if (data[i][sheet][j]['P'] > 97) {
                        data[i][sheet][j]['P'] = 'Yes';
                    } else {
                        data[i][sheet][j]['P'] = 'No'
                    }
                }
            }
        }
        return data;
    }

    return {
        init: init
    }
})();

//Individual Timber Data Sheets Data
var individualTimber = (function () {
    var init = function (workbook, clientTypeId, checklistId, importProfileMap) {
        GreenBizCheck.setClientTypeId(clientTypeId);
        GreenBizCheck.setChecklistId(checklistId);
        GreenBizCheck.setImportProfileMap(importProfileMap);

        return GreenBizCheck.convertWorkbookToArray(workbook)
            .then(setRequiredTabs)
            .then(setVendorInformation)
            .then(setNotCovered)
            .then(getTimberDataSheet)
            .then(function (data) {
                ui.setFeedback('<p>Initiating 3 stage process...</p>');
                console.log('Stage 1/3 Timber Data Sheet', data);
                ui.setFeedback('<p>Stage 1/3 Timber Data Sheet</p>');
                return GreenBizCheck.processData(data, 'sheet', true);
            })
            .then(function () {
                return GreenBizCheck.convertWorkbookToArray(workbook)
                    .then(setRequiredTabs)
                    .then(getTimberSupplyChain)
                    .then(function (data) {
                        console.log('Stage 2/3 Timber Supply Chain', data);
                        ui.setFeedback('<p>Stage 2/3 Timber Supply Chain</p>');
                        return GreenBizCheck.processData(data);
                    });
            })
            .then(function () {
                return GreenBizCheck.convertWorkbookToArray(workbook)
                    .then(setRequiredTabs)
                    .then(getPurchaseOrders)
                    .then(function (data) {
                        console.log('Stage 3/3 Purchase Orders', data);
                        ui.setFeedback('<p>Stage 3/3 Purchase Orders</p>');
                        return GreenBizCheck.processData(data);
                    });
            })
    }

    var setRequiredTabs = function (data) {
        var sheet = "Timber Data Sheet", requiredTabs = [];

        for (var i = 0; i < data.length; i++) {
            if (data[i][sheet]) {
                requiredTabs.push(data[i]);
            }
        }

        return requiredTabs;
    }

    var getTimberDataSheet = function (data) {
        var sheet = "Timber Data Sheet", firstRow = 1, lastRow = 14, newSheet = [];
        for (var i = 0; i < data.length; i++) {
            if (data[i][sheet]) {
                newSheet.push(data[i][sheet][0]);
                for (var j = 1; j < data[i][sheet].length; j++) {
                    if (data[i][sheet][j]['__rowNum__'] > firstRow - 2 && data[i][sheet][j]['__rowNum__'] < lastRow) {
                        if (data[i][sheet][j]['__rowNum__'] == 8) {
                            data[i][sheet][j] = setTimberStandardName(data[i][sheet][j]);
                        }
                        newSheet.push(data[i][sheet][j]);
                    }
                }
                data[i] = { "Timber Data Sheet": newSheet };
            }
        }

        return data;
    }

    var setTimberStandardName = function (row) {
        var standardColumn = 'H';

        switch (row[standardColumn]) {
            case 'FSC':
                row[standardColumn] = 'FSC (Forest Stewardship Council)';
                break;

            case 'PEFC':
                row[standardColumn] = 'PEFC (Programme for the Endorsement of Forest Certification)';
                break;

            case 'FLEGT':
                row[standardColumn] = 'FLEGT (Forest Law Enforcement, Governance, and Trade)';
                break;
        }

        return row;
    }

    var getTimberSupplyChain = function (data) {
        var sheet = "Timber Data Sheet", firstRow = 19, newSheet = [], identifiers = ['AA', 'AB'];
        var ethicalSourcingId = getEthicalSourcingId();
        var companyName = getCompanyName();

        for (var i = 0; i < data.length; i++) {
            if (data[i][sheet]) {
                newSheet.push(data[i][sheet][0]);
                for (var j = 1; j < data[i][sheet].length; j++) {
                    if (data[i][sheet][j]['__rowNum__'] > firstRow - 2) {
                        if (data[i][sheet][j]['A'] && data[i][sheet][j]['A'].toLowerCase().trim() == "add more rows as required") {
                            break;
                        } else {
                            if (data[i][sheet][j]['B'] && data[i][sheet][j]['B'] != "Drop down") {
                                data[i][sheet][j]['AA'] = ethicalSourcingId;
                                data[i][sheet][j]['AB'] = companyName;
                                data[i][sheet][j]['AC'] = data[i][sheet][j]['F'] ? 'Yes' : 'No';
                                data[i][sheet][j] = setResultIndex(data[i][sheet][j], identifiers, j);
                                newSheet.push(data[i][sheet][j]);
                            }
                        }
                    }
                }
                data[i] = { "Timber Supply Chain": newSheet };
            }
        }

        return data;
    }

    var getPurchaseOrders = function (data) {
        var sheet = "Timber Data Sheet", key = 'A', val = "Order Number", newSheet = [], identifiers = ['AA', 'AB'];
        var ethicalSourcingId = getEthicalSourcingId();
        var companyName = getCompanyName();

        for (var i = 0; i < data.length; i++) {
            if (data[i][sheet]) {
                newSheet.push(data[i][sheet][0]);
                var firstRow = (findIndexOfObjectInArray(data[i][sheet], key, val) + 1);
                for (var j = 1; j < data[i][sheet].length; j++) {
                    if (j >= firstRow) {
                        if (data[i][sheet][j]['A'] && data[i][sheet][j]['A'].toLowerCase().trim() == "add more rows as required") {
                            break;
                        } else {
                            data[i][sheet][j]['AA'] = ethicalSourcingId;
                            data[i][sheet][j]['AB'] = companyName;
                            data[i][sheet][j] = setResultIndex(data[i][sheet][j], identifiers, j);
                            newSheet.push(data[i][sheet][j]);
                        }
                    }
                }
                data[i] = { "Purchase Orders": newSheet };
            }
        }

        return data;
    }

    var setResultIndex = function (object, properties, index) {
        for (var property in object) {
            if (object[property]) {
                if (properties.indexOf(property) == -1) {
                    object[property] = { index: index, value: object[property] };
                }
            } else {
                delete object[property];
            }
        }

        return object;
    }

    var setNotCovered = function (data) {
        var sheet = 'Timber Data Sheet', row = 14, col = 'AD', key = "__rowNum__";

        for (var i = 0; i < data.length; i++) {
            if (data[i][sheet]) {
                var index = findIndexOfObjectInArray(data[i][sheet], key, row - 1);
                if (index) {
                    data[i][sheet][index][col] = 'Yes';
                } else {
                    data[i][sheet].push({ "AD": "No", "__rowNum__": row - 1 });
                }
            }
        }

        return data;
    }

    var findIndexOfObjectInArray = function (array, key, val) {
        index = null;

        for (var i = 0; i < array.length; i++) {
            if (array[i][key] && array[i][key] == val) {
                index = i;
                break;
            }
        }

        return index;
    }

    var setVendorInformation = function (data) {
        var sheet = 'Timber Data Sheet';
        var ethicalSourcingId = getEthicalSourcingId();
        var companyName = getCompanyName();
        data.push({ 'Vendor Info': [{ 'A': ethicalSourcingId, 'B': companyName, '__rowNum__': -1 }] });

        return data;
    }

    var getEthicalSourcingId = function (data) {
        var ethicalSourcingId, file = $('.api.import #data-file')[0].files[0];
        ethicalSourcingId = file.name.substring(0, 8);
        return ethicalSourcingId;
    }

    var getCompanyName = function (data) {
        var companyName, file = $('.api.import #data-file')[0].files[0];
        if (file.name.indexOf('-') > -1) {
            companyName = file.name.split('-')[0].substring(9).trim();
        } else {
            companyName = file.name.split('.')[0].substring(9).trim();
        }

        return companyName;
    }

    return {
        init: init
    }
})();
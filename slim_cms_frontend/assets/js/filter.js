/**
 * Filter Results
 */

var Filter = function () {
    "use strict";

    var init = function () {
        bindEvents();
    };

    var bindEvents = function() {
        $('.filter-results .add-filter').click(addFilter);
        $(document).on('click', '.filter-results .delete-filter', deleteFilter);
        $('.filter-results .apply-filter').click(applyFilter);
    };

    var addFilter = function(e) {
        var filter = $(this).closest('.filter-container').find('.template .filter-row').clone().appendTo($(this).closest('.filter-container').find('.filters'));
        filter.find('fieldset').prop('disabled', false);
    };

    var deleteFilter = function(e) {
        $(this).closest('.filter-row').remove();
    };

    var applyFilter = function() {

    };

    return {
        init: init
    };
}();

$(document).ready(Filter.init());


$(document).ready(function() {
    if ($("#savings-calc").length) {
        savingsCalculator();
    }
});

function savingsCalculator() {

    savingscalc = new Object();
    savingscalc.form = document.getElementById('savings-calc');

    savingscalc.init = function() {

        $("#savings-calc :input").change(function() {
            savingscalc.calculate();
        });

        savingscalc.calculate();
    }

    savingscalc.calculate = function() {
        document.getElementById('air-con').style.display = (document.getElementById('air-con-on').checked ? '' : 'none');
        var e = new Number($('#electricity-bill').val() / $('#electricity-bill-period').val() * 12);
        var cpc = new Number($('#percent-computers-left-on').val() || 100 / 100);
        var aco = document.getElementById('air-con-on').checked;
        var ht = new Number(24 - $('#hot-day-temp').val());
        ht = (ht < 0 ? 0 : ht);
        var ct = new Number($('#cold-day-temp').val() - 20);
        ct = (ct < 0 ? 0 : ct);
        var lpc = new Number($('#percent-efficient-lighting').val() / 100);
        var apc = new Number($('#percent-appliances-left-on').val() / 100);

        if (isNaN(e)) {
            $('electricity-bill').val('');
        }

        var wh = new Number(2310);
        var yh = new Number(8760);
        var ih = yh - wh;
        var c = (e * 0.18) * (ih / yh) * cpc;
        if (aco) {
            var ac = (e * 0.35 * 0.08 * ht / 2) + (e * 0.35 * 0.08 * ct / 2);
        } else {
            ac = 0;
        }
        var l = (e * 0.25 * 0.8) * (1 - lpc);
        var a = (e * 0.09) * (ih / yh) * apc;
        var savings = Math.round((c + ac + l + a) * 0.575);

        var psavings = (savings < 0 ? 0 : savings * 1.5);
        psavings = Math.round(e * 0.125 > psavings ? e * 0.125 : psavings);

        document.getElementById('savings').innerHTML = savingscalc.formatNumber((savings < 0 ? 0 : savings));
        document.getElementById('potential-savings').innerHTML = savingscalc.formatNumber(psavings);

        var showSuggestions = false;
        var suggestions = '<ul class="basic-list">';

        if (cpc > 0.7) {
            showSuggestions = true;
            suggestions += '<li>Turn off every PC, computer screen, printer, photocopier, scanner, etc. when the office is closed</li>';
        }
        if (aco && (ht > 0 || ct > 0)) {
            showSuggestions = true;
            suggestions += '<li>Set the air-con to min. 24&#176;C (75&#176;F) max. / 20&#176;C (68&#176;F) on warm / cold days respectively</li>';
        }
        if (lpc < 0.6) {
            showSuggestions = true;
            suggestions += '<li>Replace inefficient lighting with energy efficient lighting</li>';
        }
        if (apc > 0.6) {
            showSuggestions = true;
            suggestions += '<li>Turn off all appliances</li>';
        }
        suggestions += '</ul>';
        if (showSuggestions) {
            document.getElementById('suggestions').innerHTML = suggestions;
        } else {
            document.getElementById('suggestions').innerHTML = '<p>No suggestions.</p>';
        }
    }

    savingscalc.formatNumber = function(nStr) {
        nStr += '';
        x = nStr.split('.');
        x1 = x[0];
        x2 = x.length > 1 ? '.' + x[1] : '';
        var rgx = /(\d+)(\d{3})/;
        while (rgx.test(x1)) {
            x1 = x1.replace(rgx, '$1' + ',' + '$2');
        }
        return x1 + x2;
    }

    savingscalc.init();
}
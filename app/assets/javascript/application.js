//= require jquery
//= require jquery_ujs
//= require rules
//= require Chart.min
//= require players
//= require competitions
//= require organizers
//= require sorttable
//= require bootstrap

function renderRecentChart(results, resultKey, destId, title) {
    var stages = [];
    var datasets = [];
    var buckets = results[resultKey+"_buckets"];
    var day_keys = buckets["labels"];
    var day_values = buckets["values"];
    var backgroundColors = [];
    for(var k=0;k<day_keys.length;k++) {
        stages.push(day_keys[k]);
        backgroundColors.push("#00a");
    }
    datasets.push({
        label: title,
        data: day_values,
        backgroundColor: backgroundColors,
    });
    var ctx = document.getElementById(destId);
    var chart = new Chart(ctx, {
        type: 'bar',
        data: {
            labels: stages,
            datasets: datasets
        },
        options: {
            scales: {
                y: {
                    beginAtZero: true,
                }
            }
        }
    });
}
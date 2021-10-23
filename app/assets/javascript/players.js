function loadBatch(records) {
    console.log("records: "+records.length);
    var labels = [];
    var hits = [];
    var kills = [];
    var deaths = [];
    var assists = [];
    records.forEach(function(e) {
        labels.push(e["created_at"]);
        hits.push(e["hits"]);
        kills.push(e["kills"]);
        deaths.push(e["deaths"]);
        assists.push(e["assists"]);
    });
    var ctx = document.getElementById('player_chart');
    var chart = new Chart(ctx, {
        type: 'line',
        data: {
            labels: labels,
            datasets: [
                { label: "hits", data: hits },
                { label: "kills", data: kills },
                { label: "deaths", data: deaths },
                { label: "assists", data: assists },
            ]
        }
    });
}

function loadRecentPlayers(results) {
    var stages = [];
    var datasets = [];
    var buckets = results["player_buckets"];
    var day_keys = buckets["labels"];
    var day_values = buckets["values"];
    var backgroundColors = [];
    for(var k=0;k<day_keys.length;k++) {
        stages.push(day_keys[k]);
        backgroundColors.push("#00a");
    }
    datasets.push({
        label: 'Players Created',
        data: day_values,
        backgroundColor: backgroundColors,
    });
    var ctx = document.getElementById('players_created');
    var chart = new Chart(ctx, {
        type: 'bar',
        data: {
            labels: stages,
            datasets: datasets
        },
        options: {
            scales: {
                x: {
                    type: 'time'
                },
                y: {
                    beginAtZero: true,
                }
            }
        }
    });
}
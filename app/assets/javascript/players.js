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
    renderRecentChart(results, "player", "players_created", "Players Created");
}
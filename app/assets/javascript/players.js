function loadBatch(records) {
    console.log("records: "+records.length);
    var labels = [];
    var hits = [];
    var kills = [];
    var deaths = [];
    var assists = [];
    var scores = [];
    const reducer = (acc, val) => acc + val;
    var totalHits = records.map(e => e["hits"]).reduce(reducer);
    records.forEach(function(e) {
        labels.push(e["created_at"]);
        hits.push(e["hits"]);
        kills.push(e["kills"]);
        deaths.push(e["deaths"]);
        assists.push(e["assists"]);
        scores.push(3*e["kills"]-3*e["deaths"]+e["assists"]+5*e["hits"]/totalHits);
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

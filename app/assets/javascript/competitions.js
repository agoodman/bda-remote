function loadCumulative(records) {
    console.log("records: "+records.length);
    var labels = [];
    var hits = [];
    var kills = [];
    var deaths = [];
    var assists = [];
    records.forEach(function(e) {
        labels.push(e["created_at"]);
        hits.push(e["hits"]+hits.length==0?0:hits[hits.length-1]);
        kills.push(e["kills"]+kills.length==0?0:kills[kills.length-1]);
        deaths.push(e["deaths"]+deaths.length==0?0:deaths[deaths.length-1]);
        assists.push(e["assists"]+assists.length==0?0:assists[assists.length-1]);
    });
    var ctx = document.getElementById('competition_chart');
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

function loadVesselRanks(results) {
    console.log("vesselRanks: "+results.length);
    var colors = ["#000", "#f00", "#0f0", "#00f", "#fff", "#ff0", "#0ff"];
    var colorIndex = 0;
    var stages = [];
    var labels = [];
    var datasets = [];
    results.forEach(function(e) {
        // console.log("vessel: "+e["name"]+", ranks: "+e["ranks"]);
        labels.push(e["name"]);
        datasets.push({
            label: e["name"],
            data: e["ranks"],
            fill: false,
            backgroundColor: colors[colorIndex],
            borderColor: colors[colorIndex]
        });
        colorIndex = (colorIndex + 1) % colors.length;
    });
    for(var k=0;k<datasets[0].data.length;k++) {
        stages.push(k);
    }
    var ctx = document.getElementById('competition_chart');
    var chart = new Chart(ctx, {
        type: 'line',
        data: {
            labels: stages,
            datasets: datasets
        }
    });
}

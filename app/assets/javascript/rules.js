$(document).ready(function() {
    $("#rule_strategy").on("change", function (e) {
        var strategy = $("#rule_strategy option:selected").val();
        console.log("selected strategy: " + strategy);
        $("#new_rule fieldset").hide();
        if(strategy.endsWith("property")) {
            $('#property').show();
        }
        else if(strategy.endsWith("part_exists")) {
            $('#part_exists').show();
        }
    });
});

$(document).ready(function() {
    $("#rule_strategy").on("change", function (e) {
        var strategy = $("#rule_strategy option:selected").val();
        $("#new_rule fieldset").hide();
        if(strategy.endsWith("property")) {
            $('#property').show();
        }
        else if(strategy.endsWith("exists")) {
            $('#part_exists').show();
        }
        else if(strategy.endsWith("contains")) {
            $('#part_set_contains').show();
        }
        else if(strategy.endsWith("count")) {
            $('#part_count').show();
        }
    });
});

$(document).ready(function() {
    $("#rule_strategy").on("change", function (e) {
        var strategy = $("#rule_strategy option:selected").val();
        $("#new_rule fieldset").hide();
        if(strategy.endsWith("property")) {
            $('#property').show();
        }
        else if(strategy.endsWith("set_count")) {
            $('#part_set_count').show();
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
        else if(strategy.endsWith("ship_cost")) {
            $('#ship_cost').show();
        }
        else if(strategy.endsWith("ship_mass")) {
            $('#ship_mass').show();
        }
        else if(strategy.endsWith("ship_points")) {
            $('#ship_points').show();
        }
        else if(strategy.endsWith("ship_size")) {
            $('#ship_size').show();
        }
        else if(strategy.endsWith("ship_type")) {
            $('#ship_type').show();
        }
    });
});

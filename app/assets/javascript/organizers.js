$(document).ready(function() {
    $("#add_organizer").on("click", function (e) {
        $("#add_organizer").hide();
        $("#new_organizer").show();
    });
    $("#cancel_organizer").on("click", function (e) {
        $("#new_organizer").hide();
        $("#add_organizer").show();
    });
});

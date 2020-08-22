function applyFileSizeLimit() {
    var uploadField = document.getElementById("file");
    uploadField.onchange = function () {
        if (this.files[0].size > 5242880) {
            alert("File is too big! (Max 5MB)");
            this.value = "";
        }
    };
}
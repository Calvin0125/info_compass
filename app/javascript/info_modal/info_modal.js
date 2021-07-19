$(document).on("turbolinks:load", function() {
  if ($('#showInfoModal').length > 0) {
    new bootstrap.Modal($('#infoModal')).show();
  };
});

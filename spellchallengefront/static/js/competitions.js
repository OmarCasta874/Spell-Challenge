// Spell-Challenge - Teacher / Create Competiton
document.addEventListener('DOMContentLoaded', function () {
  var searchInput = document.getElementById('competitionSearch');
  var cards = document.querySelectorAll('.competition-card');

  if (searchInput) {
    searchInput.addEventListener('input', function () {
      var term = searchInput.value.trim().toLowerCase();
      cards.forEach(function (card) {
        var text = card.textContent.toLowerCase();
        var container = card.closest('.col-md-4');

        if (container) {
          container.style.display = text.includes(term) ? '': 'none';
        }
      });
    });
  }
});
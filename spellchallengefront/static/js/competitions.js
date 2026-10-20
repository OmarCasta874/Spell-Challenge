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

  var generalSpellingBee = document.getElementById('compGeneralSpellingBee');
  var wordList = document.getElementById('compWordList');
  var wordListContainer = document.getElementById('wordListContainer');

  if (generalSpellingBee && wordList && wordListContainer) {
    function updateCompetitionMode() {
      var isGeneral = generalSpellingBee.checked;

      if (isGeneral) {
        wordList.removeAttribute('required');
        wordList.required = false;
        wordList.disabled = true;
        wordList.value = '';
        wordListContainer.style.display = 'none';
      } else {
        wordList.disabled = false;
        wordList.setAttribute('required', '');
        wordList.required = true;
        wordListContainer.style.display = '';
      }
    }

    generalSpellingBee.addEventListener('change', updateCompetitionMode);
    updateCompetitionMode();
  }
});
// Spell-Challenge — Teacher / Competitions behavior
document.addEventListener('DOMContentLoaded', function () {

  /* 1) Filtro de búsqueda por nombre de competencia o grupo */
  var searchInput = document.getElementById('competitionSearch');
  var cards = document.querySelectorAll('.competition-card');

  if (searchInput) {
    searchInput.addEventListener('input', function () {
      var term = searchInput.value.trim().toLowerCase();
      cards.forEach(function (card) {
        var text = card.textContent.toLowerCase();
        card.closest('.col-md-4').style.display = text.includes(term) ? '' : 'none';
      });
    });
  }

  /* 2) Crear competencia: agrega una tarjeta "Upcoming" a la lista */
  var createModalEl = document.getElementById('createCompetitionModal');
  if (!createModalEl || typeof bootstrap === 'undefined') return;

  var createModal = bootstrap.Modal.getOrCreateInstance(createModalEl);
  var btnCreate = document.getElementById('btnCreateCompetition');
  var competitionsRow = document.getElementById('competitionsRow');
  var totalStat = document.getElementById('statTotal');
  var upcomingStat = document.getElementById('statUpcoming');
  var nextIndex = document.querySelectorAll('.competition-card').length + 1;

  if (btnCreate) {
    btnCreate.addEventListener('click', function () {
      var name = document.getElementById('compName').value.trim();
      var group = document.getElementById('compGroup');
      var startDate = document.getElementById('compStartDate').value;
      var startTime = document.getElementById('compStartTime').value;

      if (!name || !group.value) return;

      var groupLabel = group.options[group.selectedIndex].text;
      var dateLabel = startDate ? new Date(startDate + 'T00:00:00').toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' }) : 'TBD';
      var timeLabel = startTime || '--:--';

      var col = document.createElement('div');
      col.className = 'col-md-4';
      col.innerHTML =
        '<div class="competition-card">' +
          '<div class="d-flex justify-content-between align-items-start">' +
            '<h5>Competition #' + nextIndex + '</h5>' +
            '<span class="badge-status badge-upcoming">Upcoming</span>' +
          '</div>' +
          '<div class="comp-meta">' + escapeHtml(name) + '</div>' +
          '<div class="comp-meta">' + escapeHtml(groupLabel) + '</div>' +
          '<div class="comp-datetime"><span>' + dateLabel + '</span><span>' + timeLabel + '</span></div>' +
        '</div>';

      competitionsRow.appendChild(col);
      nextIndex += 1;

      if (totalStat) totalStat.textContent = (parseInt(totalStat.textContent, 10) || 0) + 1;
      if (upcomingStat) upcomingStat.textContent = (parseInt(upcomingStat.textContent, 10) || 0) + 1;

      document.getElementById('formCreateCompetition').reset();
      createModal.hide();
    });
  }

  function escapeHtml(str) {
    var div = document.createElement('div');
    div.textContent = str;
    return div.innerHTML;
  }
});

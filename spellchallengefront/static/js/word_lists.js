// Spell-Challenge — Teacher / Word Lists modals behavior
// Requiere Bootstrap 5 JS bundle ya cargado en teacher_base.html

document.addEventListener('DOMContentLoaded', function () {

  var createListModalEl = document.getElementById('createListModal');
  var manualListModalEl = document.getElementById('manualListModal');
  var excelListModalEl = document.getElementById('excelListModal');
  var addWordModalEl = document.getElementById('addWordModal');

  if (!createListModalEl || typeof bootstrap === 'undefined') return;

  var createListModal = bootstrap.Modal.getOrCreateInstance(createListModalEl);
  var manualListModal = bootstrap.Modal.getOrCreateInstance(manualListModalEl);
  var excelListModal = bootstrap.Modal.getOrCreateInstance(excelListModalEl);
  var addWordModal = bootstrap.Modal.getOrCreateInstance(addWordModalEl);

  /* 1) "How would you like to create your list?" -> abre el panel correcto */
  var choiceCards = createListModalEl.querySelectorAll('.choice-card');
  if (choiceCards[0]) {
    choiceCards[0].addEventListener('click', function () {
      createListModal.hide();
      manualListModal.show();
    });
  }
  if (choiceCards[1]) {
    choiceCards[1].addEventListener('click', function () {
      createListModal.hide();
      excelListModal.show();
    });
  }

  /* 2) Add Word -> agrega una fila a la tabla de palabras */
  var wordsBody = document.getElementById('wordsTableBody');
  var emptyRow = document.getElementById('emptyRow');
  var wordCountEl = document.getElementById('wordCount');
  var btnSaveWord = document.getElementById('btnSaveWord');
  var count = 0;

  if (btnSaveWord) {
    btnSaveWord.addEventListener('click', function () {
      var word = document.getElementById('wordText').value.trim();
      var meaning = document.getElementById('wordMeaning').value.trim();
      var pronunciation = document.getElementById('wordPronunciation').value.trim();

      if (!word || !meaning || !pronunciation) return;
      if (emptyRow) { emptyRow.remove(); emptyRow = null; }

      count += 1;
      wordCountEl.textContent = count;

      var tr = document.createElement('tr');
      tr.innerHTML =
        '<td>' + count + '</td>' +
        '<td>' + escapeHtml(word) + '</td>' +
        '<td>' + escapeHtml(meaning) + '</td>' +
        '<td>' + escapeHtml(pronunciation) + '</td>' +
        '<td class="d-flex gap-1">' +
          '<button type="button" class="btn btn-sm btn-pill-outline">VIEW</button>' +
          '<button type="button" class="btn btn-sm btn-pill-outline">EDIT</button>' +
          '<button type="button" class="btn btn-sm btn-pill-solid btn-remove-word">DELETE</button>' +
        '</td>';
      wordsBody.appendChild(tr);

      document.getElementById('formAddWord').reset();
      addWordModal.hide();
    });
  }

  /* Delegar el DELETE de cada fila agregada */
  if (wordsBody) {
    wordsBody.addEventListener('click', function (e) {
      if (e.target.classList.contains('btn-remove-word')) {
        e.target.closest('tr').remove();
        renumberRows();
      }
    });
  }

  function renumberRows() {
    var rows = wordsBody.querySelectorAll('tr');
    count = rows.length;
    rows.forEach(function (row, i) {
      row.children[0].textContent = i + 1;
    });
    wordCountEl.textContent = count;
    if (count === 0 && !document.getElementById('emptyRow')) {
      var tr = document.createElement('tr');
      tr.id = 'emptyRow';
      tr.innerHTML = '<td colspan="5" class="text-center text-muted py-4">No words added yet. Click "+ Add Word" to begin.</td>';
      wordsBody.appendChild(tr);
      emptyRow = tr;
    }
  }

  function escapeHtml(str) {
    var div = document.createElement('div');
    div.textContent = str;
    return div.innerHTML;
  }

  /* 3) Import from Excel: drag & drop + selección manual */
  var dropZone = document.getElementById('dropZone');
  var excelInput = document.getElementById('excelFileInput');
  var fileInfo = document.getElementById('fileInfo');
  var btnUploadExcel = document.getElementById('btnUploadExcel');

  function handleFile(file) {
    if (!file) return;
    fileInfo.textContent = 'Selected: ' + file.name;
    fileInfo.classList.remove('d-none');
    btnUploadExcel.disabled = false;
  }

  if (excelInput) {
    excelInput.addEventListener('change', function (e) {
      handleFile(e.target.files[0]);
    });
  }

  if (dropZone) {
    ['dragover', 'dragenter'].forEach(function (evt) {
      dropZone.addEventListener(evt, function (e) {
        e.preventDefault();
        dropZone.classList.add('dz-active');
      });
    });
    ['dragleave', 'drop'].forEach(function (evt) {
      dropZone.addEventListener(evt, function (e) {
        e.preventDefault();
        dropZone.classList.remove('dz-active');
      });
    });
    dropZone.addEventListener('drop', function (e) {
      var file = e.dataTransfer.files[0];
      excelInput.files = e.dataTransfer.files;
      handleFile(file);
    });
  }

  /* Al cerrar el panel manual o el de Excel, reabre el flujo desde "Create Word List" si el usuario quiere volver */
  [manualListModalEl, excelListModalEl, addWordModalEl].forEach(function (el) {
    el.addEventListener('hidden.bs.modal', function () {
      document.body.classList.remove('modal-open');
      var openModal = document.querySelector('.modal.show');
      if (openModal) document.body.classList.add('modal-open');
    });
  });
});

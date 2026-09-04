document.addEventListener('DOMContentLoaded', () => {
  // --- MANEJO DE PALABRAS MANUALES ---
  const wordList = [];
  const wordsTableBody = document.getElementById('wordsTableBody');
  const emptyRow = document.getElementById('emptyRow');
  const wordCountSpan = document.getElementById('wordCount');
  
  const btnSaveWord = document.getElementById('btnSaveWord');
  const addWordModalEl = document.getElementById('addWordModal');
  const addWordModal = new bootstrap.Modal(addWordModalEl);

  btnSaveWord.addEventListener('click', () => {
    const wordText = document.getElementById('wordText').value.trim();
    const wordMeaning = document.getElementById('wordMeaning').value.trim();
    const wordPronunciation = document.getElementById('wordPronunciation').value.trim();

    if (!wordText || !wordMeaning || !wordPronunciation) {
      alert('Please fill in all required fields for the word.');
      return;
    }

    // Agregar objeto al arreglo
    const newWord = {
      id: Date.now(),
      word: wordText,
      meaning: wordMeaning,
      pronunciation: wordPronunciation
    };
    wordList.push(newWord);

    renderWordsTable();

    // Limpiar formulario y cerrar submodal
    document.getElementById('formAddWord').reset();
    addWordModal.hide();
  });

  function renderWordsTable() {
    if (wordList.length === 0) {
      emptyRow.style.display = 'table-row';
      wordsTableBody.innerHTML = '';
      wordsTableBody.appendChild(emptyRow);
      wordCountSpan.textContent = '0';
      return;
    }

    wordsTableBody.innerHTML = '';
    wordList.forEach((item, index) => {
      const row = document.createElement('tr');
      row.innerHTML = `
        <td>${index + 1}</td>
        <td class="fw-bold">${escapeHtml(item.word)}</td>
        <td>${escapeHtml(item.meaning)}</td>
        <td class="text-muted"><em>${escapeHtml(item.pronunciation)}</em></td>
        <td>
          <button type="button" class="btn btn-sm btn-outline-danger" onclick="deleteWord(${item.id})">
            Delete
          </button>
        </td>
      `;
      wordsTableBody.appendChild(row);
    });

    wordCountSpan.textContent = wordList.length;
  }

  // Función global para eliminar una palabra de la lista
  window.deleteWord = function(id) {
    const index = wordList.findIndex(w => w.id === id);
    if (index !== -1) {
      wordList.splice(index, 1);
      renderWordsTable();
    }
  };

  function escapeHtml(text) {
    return text.replace(/[&<>"']/g, function(m) {
      return { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#039;' }[m];
    });
  }

  // --- MANEJO DE DRAG & DROP PARA EXCEL ---
  const dropZone = document.getElementById('dropZone');
  const excelFileInput = document.getElementById('excelFileInput');
  const fileInfo = document.getElementById('fileInfo');
  const btnUploadExcel = document.getElementById('btnUploadExcel');

  ['dragenter', 'dragover', 'dragleave', 'drop'].forEach(eventName => {
    dropZone.addEventListener(eventName, preventDefaults, false);
  });

  function preventDefaults(e) {
    e.preventDefault();
    e.stopPropagation();
  }

  ['dragenter', 'dragover'].forEach(eventName => {
    dropZone.addEventListener(eventName, () => dropZone.classList.add('bg-warning-subtle'), false);
  });

  ['dragleave', 'drop'].forEach(eventName => {
    dropZone.addEventListener(eventName, () => dropZone.classList.remove('bg-warning-subtle'), false);
  });

  dropZone.addEventListener('drop', (e) => {
    const dt = e.dataTransfer;
    const files = dt.files;
    handleExcelFiles(files);
  });

  excelFileInput.addEventListener('change', (e) => {
    handleExcelFiles(e.target.files);
  });

  function handleExcelFiles(files) {
    if (files.length > 0) {
      const file = files[0];
      if (file.name.endsWith('.xlsx') || file.name.endsWith('.xls')) {
        fileInfo.textContent = `Selected file: ${file.name}`;
        fileInfo.classList.remove('d-none');
        btnUploadExcel.removeAttribute('disabled');
      } else {
        alert('Please upload a valid Excel file (.xlsx or .xls).');
      }
    }
  }
});
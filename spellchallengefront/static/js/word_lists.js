console.log('WORD_LISTS.JS LOADED');
document.addEventListener('DOMContentLoaded', function () {
  // =====================================================
  // 1. REFERENCIAS A LOS MODALES
  // =====================================================
  const createListModalEl = document.getElementById('createListModal');
  const chooseMethodModalEl = document.getElementById('chooseMethodModal');
  const manualListModalEl = document.getElementById('manualListModal');
  const excelListModalEl = document.getElementById('excelListModal');
  const addWordModalEl = document.getElementById('addWordModal');

  if (typeof bootstrap === 'undefined' ||
      !createListModalEl ||
      !chooseMethodModalEl ||
      !manualListModalEl ||
      !excelListModalEl ||
      !addWordModalEl) {
    console.error('Word Lists: one or more modals are missing.');
    return;
  }

  const createListModal = bootstrap.Modal.getOrCreateInstance(createListModalEl);
  const chooseMethodModal = bootstrap.Modal.getOrCreateInstance(chooseMethodModalEl);
  const manualListModal = bootstrap.Modal.getOrCreateInstance(manualListModalEl);
  const excelListModal = bootstrap.Modal.getOrCreateInstance(excelListModalEl);
  const addWordModal = bootstrap.Modal.getOrCreateInstance(addWordModalEl);

  function switchModal(currentModal, currentModalElement, nextModal) {
    const activeElement = document.activeElement;

    if (activeElement && currentModalElement.contains(activeElement)) {
      activeElement.blur();
    }

    currentModalElement.addEventListener('hidden.bs.modal', function () {
      nextModal.show();
    }, { once: true });

    currentModal.hide();
  }

  // =====================================================
  // 2. FLUJO DE CREACIÓN DE LISTAS
  // =====================================================
  const newListName = document.getElementById('newListName');
  const listName = document.getElementById('listName');
  const continueButton = document.getElementById('btnContinueCreateList');

  if (continueButton) {
    continueButton.addEventListener('click', function (event) {
      event.preventDefault();
      event.stopPropagation();

      const name = newListName.value.trim();

      if (!name) {
        newListName.reportValidity();
        newListName.focus();
        return;
      }

      if (name.length > 30) {
        alert('The word list name cannot exceed 30 characters.');
        return;
      }

      listName.value = name;
      switchModal(createListModal, createListModalEl, chooseMethodModal);
    });
  }

  const choiceCards = chooseMethodModalEl.querySelectorAll('.choice-card');

  choiceCards.forEach(function (card) {
    function selectMethod() {
      const method = card.dataset.method;

      if (method === 'manual') {
        switchModal(
          chooseMethodModal,
          chooseMethodModalEl,
          manualListModal
        );
      } else if (method === 'excel') {
        switchModal(
          chooseMethodModal,
          chooseMethodModalEl,
          excelListModal
        );
      }
    }

    card.addEventListener('click', selectMethod);

    card.addEventListener('keydown', function (event) {
      if (event.key === 'Enter' || event.key === ' ') {
        event.preventDefault();
        selectMethod();
      }
    });
  });

  // =====================================================
  // 3. AGREGAR Y ELIMINAR PALABRAS
  // =====================================================
  const formAddWord = document.getElementById('formAddWord');
  const btnSaveWord = document.getElementById('btnSaveWord');
  const wordsBody = document.getElementById('wordsTableBody');
  const wordCountEl = document.getElementById('wordCount');

  const btnOpenAddWord = document.getElementById('btnOpenAddWord');

  if (btnOpenAddWord) {
    btnOpenAddWord.addEventListener('click', function () {
      switchModal(
        manualListModal,
        manualListModalEl,
        addWordModal
      );
    });
  }

  // Conserva los datos y archivos de cada palabra.
  let words = [];

  window.__wordListDebug = {
    getWords: () => words,
    getCount: () => words.length
  };

  function getWordFields() {
    return {
      significado: document.getElementById('wordText').value.trim(),
      definicion: document.getElementById('wordMeaning').value.trim(),
      ejemplo: document.getElementById('wordExample').value.trim(),
      pronunciacion: document.getElementById('wordPronunciation').value.trim(),
      categoria: document.getElementById('wordCategory').value,
      nivel: document.getElementById('wordLevel').value,
      imagen: document.getElementById('wordImage').files[0] || null,
      audio: document.getElementById('wordAudio').files[0] || null
    };
  }

  function renderWords() {
    wordsBody.innerHTML = '';

    if (words.length === 0) {
      const row = document.createElement('tr');
      row.id = 'emptyRow';

      const cell = document.createElement('td');
      cell.colSpan = 5;
      cell.className = 'text-center text-muted py-4';
      cell.textContent = 'No words added yet. Click "+ Add Word" to begin.';

      row.appendChild(cell);
      wordsBody.appendChild(row);
    } else {
      words.forEach(function (word, index) {
        const row = document.createElement('tr');

        [
          String(index + 1),
          word.significado,
          word.definicion,
          word.pronunciacion
        ].forEach(function (value) {
          const cell = document.createElement('td');
          cell.textContent = value;
          row.appendChild(cell);
        });

        const actionsCell = document.createElement('td');
        actionsCell.className = 'text-center';

        const deleteButton = document.createElement('button');
        deleteButton.type = 'button';
        deleteButton.className = 'btn btn-sm btn-pill-solid btn-remove-word';
        deleteButton.dataset.index = String(index);
        deleteButton.textContent = 'DELETE';

        actionsCell.appendChild(deleteButton);
        row.appendChild(actionsCell);
        wordsBody.appendChild(row);
      });
    }

    wordCountEl.textContent = words.length;

    // No permitir agregar más de 20 palabras.
    const addWordButton = document.getElementById('btnOpenAddWord');

    if (addWordButton) {
      addWordButton.disabled = words.length >= 20;
      addWordButton.title = words.length >= 20
        ? 'A list can contain a maximum of 20 words.'
        : '';
    }
  }

  if (btnSaveWord && formAddWord) {
    btnSaveWord.addEventListener('click', function () {

      if (!formAddWord.reportValidity()) {
        console.log('[TEST] Form validation failed');

        const invalidFields = formAddWord.querySelectorAll(':invalid');

        invalidFields.forEach(function (field) {
          console.log(
            '[INVALID FIELD',
            field.id,
            'Value:',
            field.value,
            'Required:',
            field.required
          );
        });

        return;
      }

      if (words.length >= 20) {
        alert('A word list can contain a maximum of 20 words.');
        return;
      }

      const word = getWordFields();

      if (word.significado.length > 50 ||
          word.definicion.length > 255 ||
          word.ejemplo.length > 255 ||
          word.pronunciacion.length > 100) {
        alert('One or more fields exceed their maximum length.');
        return;
      }

      words.push(word);

      renderWords();

      formAddWord.reset();
      switchModal(
        addWordModal,
        addWordModalEl,
        manualListModal
      );
    });
  }

  if (wordsBody) {
    wordsBody.addEventListener('click', function (event) {
      const deleteButton = event.target.closest('.btn-remove-word');

      if (!deleteButton) {
        return;
      }

      const index = Number(deleteButton.dataset.index);

      if (Number.isInteger(index) && index >= 0 && index < words.length) {
        words.splice(index, 1);
        renderWords();
      }
    });
  }

  // =====================================================
  // 4. GUARDAR LA LISTA EN DJANGO
  // =====================================================
  const formManualList = document.getElementById('formManualList');

  if (formManualList) {
    formManualList.addEventListener('submit', async function (event) {
      event.preventDefault();

      const name = listName.value.trim();

      if (!name) {
        alert('Please enter a name for the word list.');
        return;
      }

      console.log('Words before saving:',words);
      console.log('Word count:', words.length);

      console.log('[SAVE LIST] Total:',words.length, words);

      if (words.length < 1 || words.length > 20) {
        alert('Please add between 1 and 20 words before saving.');
        return;
      }

      const formData = new FormData(formManualList);
      formData.set('name', name);

      const wordData = words.map(function (word) {
        return {
          significado: word.significado,
          definicion: word.definicion,
          ejemplo: word.ejemplo,
          pronunciacion: word.pronunciacion,
          categoria: word.categoria,
          nivel: word.nivel
        };
      });

      formData.set('words', JSON.stringify(wordData));

      words.forEach(function (word, index) {
        if (word.imagen) {
          formData.append('word_image_' + index, word.imagen);
        }

        if (word.audio) {
          formData.append('word_audio_' + index, word.audio);
        }
      });

      const submitButton = formManualList.querySelector(
        '[type="submit"]'
      );

      if (submitButton) {
        submitButton.disabled = true;
        submitButton.textContent = 'Saving...';
      }

      try {
        const response = await fetch(formManualList.action, {
          method: 'POST',
          body: formData,
          credentials: 'same-origin'
        });

        if (!response.ok) {
          throw new Error('The server returned status ' + response.status);
        }

        // Django redirige a los detalles de la lista si se guardó,
        // o a Word Lists si ocurrió un error de validación.
        window.location.assign(response.url);
      } catch (error) {
        console.error('Error saving word list:', error);
        alert('The word list could not be saved. Please try again.');

        if (submitButton) {
          submitButton.disabled = false;
          submitButton.textContent = 'Save Word List';
        }
      }
    });
  }

  // =====================================================
  // 5. IMPORTACIÓN DE EXCEL (SOLO INTERFAZ POR AHORA)
  // =====================================================
  const dropZone = document.getElementById('dropZone');
  const excelInput = document.getElementById('excelFileInput');
  const fileInfo = document.getElementById('fileInfo');
  const btnUploadExcel = document.getElementById('btnUploadExcel');

  function handleExcelFile(file) {
    if (!file || !fileInfo || !btnUploadExcel) return;

    fileInfo.textContent = 'Selected: ' + file.name;
    fileInfo.classList.remove('d-none');

    // La importación todavía no está implementada.
    btnUploadExcel.disabled = false;
  }

  if (excelInput) {
    excelInput.addEventListener('change', function () {
      handleExcelFile(excelInput.files[0]);
    });
  }

  if (dropZone && excelInput) {
    ['dragover', 'dragenter'].forEach(function (eventName) {
      dropZone.addEventListener(eventName, function (event) {
        event.preventDefault();
        dropZone.classList.add('dz-active');
      });
    });

    ['dragleave', 'drop'].forEach(function (eventName) {
      dropZone.addEventListener(eventName, function (event) {
        event.preventDefault();
        dropZone.classList.remove('dz-active');
      });
    });

    dropZone.addEventListener('drop', function (event) {
      const file = event.dataTransfer.files[0];

      if (!file) return;

      const transfer = new DataTransfer();
      Array.from(event.dataTransfer.files).forEach(function (item) {
        transfer.items.add(item);
      });

      excelInput.files = transfer.files;
      handleExcelFile(file);
    });
  }
  renderWords();
});

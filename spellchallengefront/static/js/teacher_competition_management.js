document.addEventListener('DOMContentLoaded', function () {

    // INITIAL DATA

    let currentCategory = 'CAT11';
    let currentHive = null;
    let currentBeehivePage = 1;
    let currentWord = null;
    let currentWordHive = null;
    let currentEvaluation = null;

    const participantSelect = document.getElementById('participantSelect');
    const categorySelect = document.getElementById('wordLengthSelect');
    const grid = document.querySelector('.honeycomb-grid');

    const roundManagement = document.getElementById('roundManagement');
    const roundCategoryInput = document.getElementById('roundCategoryInput');

    const previousButton = document.getElementById('previousPageBtn');
    const nextButton = document.getElementById('nextPageBtn');
    const pageIndicator = document.getElementById('pageIndicator');

    const confirmModal = document.getElementById('confirmBeehiveModal');
    const wordModal = document.getElementById('wordModal');
    const evaluationModal = document.getElementById('evaluationModal');

    const saveEvaluationBtn = document.getElementById('saveEvaluationBtn');
    const openEvaluationBtn = document.getElementById('openEvaluationBtn');

    const managementContainer = document.getElementById('competitionManagement');

    const activeRoundId = roundManagement
        ? roundManagement.dataset.roundId
        : '';

    const activeRoundCategory = roundManagement
        ? roundManagement.dataset.roundCategory
        : '';

    const saveEvaluationUrl = managementContainer.dataset.saveUrl;

    const csrfToken = managementContainer.querySelector(
        'input[name="csrfmiddlewaretoken"]'
    ).value;

    let selectedSpellingResult = null;
    let selectedPronunciationResult = null;
    let isSavingEvaluation = false;

    if (!participantSelect || !categorySelect || !grid) {
        return;
    }

    // Normalize database identifiers for comparisons.
    const evaluations = Array.isArray(evaluationsData)
        ? evaluationsData
        : [];

    // PARTICIPANT AND EVALUATION HELPERS

    function getSelectedParticipant() {
        return participantSelect.value;
    }

    function getParticipantEvaluation(participantId) {
        return evaluations.find(
            evaluation =>
                String(evaluation.participante_id) === String(participantId) &&
                String(evaluation.ronda_id) === String(activeRoundId)
        ) || null;
    }

    function getBeehiveEvaluation(category, hiveNumber) {
        const normalizedRoundId = String(activeRoundId).trim();
        const normalizedHiveNumber = Number(hiveNumber);

        return evaluations.find(evaluation =>
                String(evaluation.ronda_id).trim() === normalizedRoundId &&
                String(evaluation.categoria_beehive).trim() === String(category).trim() &&
                Number(evaluation.beehive) === normalizedHiveNumber
        ) || null;
    }

    function getUsedBeehiveEvaluation(category, hiveNumber) {
        return evaluations.find(evaluation =>
            evaluation.categoria_beehive === category &&
            Number(evaluation.beehive) === Number(hiveNumber)
        ) || null;
    }

    function getCategoryWords() {
        return wordsByCategory[currentCategory] || [];
    }

    function getWordByCode(code) {
        return getCategoryWords().find(
            word => String(word.codigo) === String(code)
        ) || null;
    }

    function initRoundCategory() {

        if (!roundManagement) {
            return;
        }

        if (activeRoundId && activeRoundCategory) {
            currentCategory = activeRoundCategory;
            categorySelect.value = activeRoundCategory;
            categorySelect.disabled = true;

            if (roundCategoryInput) {
                roundCategoryInput.value = activeRoundCategory;
            }
        } else if (roundCategoryInput) {
            roundCategoryInput.value = categorySelect.value;
        }
    }

    // CATEGORY SELECTOR

    function initCategorySelector() {

        const availableCategories = Object.keys(wordsByCategory).filter(
            category =>
                wordsByCategory[category] &&
                wordsByCategory[category].length > 0
        );

        Array.from(categorySelect.options).forEach(option => {

            const category = option.value;
            const count = wordsByCategory[category]
                ? wordsByCategory[category].length
                : 0;

            const baseText = option.text.split(' (')[0];

            option.text = `${baseText} (${count} words)`;

            option.hidden = count === 0;
        });

        if (availableCategories.length > 0) {
            currentCategory = availableCategories[0];
            categorySelect.value = currentCategory;
        }
    }

    function filterBeehives() {

        currentCategory = categorySelect.value;
        currentHive = null;
        currentEvaluation = null;
        currentWord = null;

        if (roundCategoryInput) {
            roundCategoryInput.value = currentCategory;
        }

        renderBeehives();
    }

    // BEEHIVE PAGINATION

    function changeBeehivePage(direction) {

        const pages = grid.querySelectorAll('.honeycomb-page');

        const newPage = currentBeehivePage + direction;

        if (newPage < 1 || newPage > pages.length) {
            return;
        }

        pages.forEach(page => {

            page.classList.toggle(
                'active',
                Number(page.dataset.page) === newPage
            );

        });

        currentBeehivePage = newPage;

        previousButton.disabled = currentBeehivePage === 1;
        nextButton.disabled = currentBeehivePage === pages.length;

        pageIndicator.textContent =
            `Page ${currentBeehivePage} of ${pages.length}`;
    }

    // BEEHIVE GENERATION

    function renderBeehives() {

        const availableWords = getCategoryWords();

        console.log('[BEEHIVE INITIAL CHECK]', {
            activeRoundId: activeRoundId,
            currentCategory: currentCategory,
            availableWords: availableWords.length,
            selectedParticipant: getSelectedParticipant()
        });

        const totalBeehives = availableWords.length;

        const HIVES_PER_PAGE = 30;

        const totalPages = Math.max(
            1,
            Math.ceil(totalBeehives / HIVES_PER_PAGE)
        );

        grid.innerHTML = '';

        let globalHiveIndex = 0;

        const selectedParticipant = getSelectedParticipant();

        const participantEvaluation = selectedParticipant
            ? getParticipantEvaluation(selectedParticipant)
            : null;

        for (let pageNumber = 1; pageNumber <= totalPages; pageNumber++) {

            const page = document.createElement('div');

            page.className = 'honeycomb-page';
            page.dataset.page = pageNumber;

            if (pageNumber === 1) {
                page.classList.add('active');
            }

            const start = (pageNumber - 1) * HIVES_PER_PAGE;

            const end = Math.min(
                start + HIVES_PER_PAGE,
                totalBeehives
            );

            const rowSizes = [10, 9, 10, 1];

            let hiveIndex = start;
            let localNumber = 1;

            for (const rowSize of rowSizes) {

                if (hiveIndex >= end) {
                    break;
                }

                const row = document.createElement('div');
                row.className = 'honeycomb-row';

                const rowEnd = Math.min(
                    hiveIndex + rowSize,
                    end
                );

                for (; hiveIndex < rowEnd; hiveIndex++) {

                    globalHiveIndex++;

                    const hiveNumber = globalHiveIndex;

                    const evaluation = getBeehiveEvaluation(currentCategory, hiveNumber);
                    const usedEvaluation = getUsedBeehiveEvaluation(currentCategory, hiveNumber);

                    const isOccupied = usedEvaluation !== null;

                    const belongsToParticipant =
                        evaluation !== null &&
                        selectedParticipant &&
                        String(evaluation.participante_id).trim() === String(selectedParticipant).trim();

                    console.log('[BEEHIVE DEBUG]', {
                        activeRoundId: activeRoundId,
                        category: currentCategory,
                        hive: hiveNumber,
                        selectedParticipant: selectedParticipant,
                        evaluation: evaluation,
                        usedEvaluation: usedEvaluation,
                        isOccupied: isOccupied,
                        belongsToParticipant: belongsToParticipant
                    });

                    const beehiveItem = document.createElement('div');
                    beehiveItem.className = 'beehive-item';

                    const button = document.createElement('button');

                    button.type = 'button';
                    button.className = 'beehive-cell';

                    button.dataset.hive = hiveNumber;

                    button.style.setProperty(
                        '--hive-index',
                        localNumber
                    );

                    // Global numbering within the category.
                    button.innerHTML = `
                        <span class="beehive-number">
                            ${hiveNumber}
                        </span>
                    `;

                    // Disable occupied hives belonging to another student.
                    if (isOccupied && !belongsToParticipant) {

                        button.classList.add('beehive-disabled');
                        button.disabled = true;

                    }

                    // A participant can only have one evaluation.
                    if (
                        participantEvaluation &&
                        !belongsToParticipant
                    ) {

                        button.classList.add('beehive-disabled');
                        button.disabled = true;

                    }

                    // No hive can be selected without a participant.
                    if (!activeRoundId || !selectedParticipant) {
                        button.classList.add('beehive-disabled');
                        button.disabled = true;
                    }

                    if (belongsToParticipant) {
                        button.classList.add('beehive-assigned');
                    }

                    button.addEventListener('click', function () {

                        selectBeehive(hiveNumber);

                    });

                    beehiveItem.appendChild(button);

                    row.appendChild(beehiveItem);

                    localNumber++;
                }

                page.appendChild(row);
            }

            grid.appendChild(page);
        }

        currentBeehivePage = 1;

        previousButton.disabled = true;
        nextButton.disabled = totalPages <= 1;

        pageIndicator.textContent =
            `Page 1 of ${totalPages}`;

    }

    // PARTICIPANT SELECTION

    function handleParticipantChange() {

        const matricula = getSelectedParticipant();

        currentHive = null;
        currentEvaluation = null;
        currentWord = null;

        const existingEvaluation = matricula
            ? getParticipantEvaluation(matricula)
            : null;

        if (existingEvaluation) {

            // Return to the category where the student was evaluated.
            currentCategory = existingEvaluation.categoria_beehive;

            categorySelect.value = currentCategory;

            // Prevent assigning another category to this participant.
            categorySelect.disabled = true;

        } else {

            categorySelect.disabled = false;

        }

        renderBeehives();

    }

    // BEEHIVE SELECTION

    function selectBeehive(hiveNumber) {

        const participantId = getSelectedParticipant();

        if (!activeRoundId) {
            alert('Please start a round before evaluating participants.');
            return;
        }

        if (!participantId) {
            alert('Please select a participant first.');
            return;
        }

        currentHive = Number(hiveNumber);
        currentWordHive = null;

        const selectedHiveElement =
            document.getElementById('selectedHiveNum');

        selectedHiveElement.textContent = currentHive;

        currentEvaluation = getBeehiveEvaluation(
            currentCategory,
            currentHive
        );

        // Do not open a hive assigned to another participant.
        if (
            currentEvaluation &&
            String(currentEvaluation.participante_id).trim() !== String(participantId).trim()
        ) {
            alert('This Beehive is already assigned to another participant.');
            return;
        }

        const modalText = confirmModal.querySelector(
            '.beehive-modal-subtext'
        );

        if (currentEvaluation) {

            modalText.textContent =
                'This Beehive already belongs to you. You can review and edit its evaluation.';

        } else {

            modalText.textContent =
                'Do you want to assign this Beehive to the selected participant?';

        }

        confirmModal.classList.add('active');

    }

    // WORD MODAL

    function fitWordToModal() {

        const wordElement = document.querySelector('.word-modal-word');

        const containerElement =
            document.querySelector('.word-modal-inner');

        if (!wordElement || !containerElement) {
            return;
        }

        const maxFontSize = 57.6;
        const minFontSize = 20;

        const availableWidth = containerElement.clientWidth - 32;

        let fontSize = maxFontSize;

        wordElement.style.fontSize = fontSize + 'px';

        while (
            wordElement.scrollWidth > availableWidth &&
            fontSize > minFontSize
        ) {

            fontSize -= 2;

            wordElement.style.fontSize = fontSize + 'px';

        }

    }

    function updateSaveButtonState() {

        saveEvaluationBtn.disabled = (
            !selectedSpellingResult ||
            !selectedPronunciationResult ||
            !currentWord ||
            !currentHive ||
            !getSelectedParticipant() ||
            isSavingEvaluation
        );

    }

    function resetEvaluationButtons() {

        selectedSpellingResult = null;
        selectedPronunciationResult = null;

        evaluationModal.querySelectorAll('.evaluation-btn').forEach(button => {
            button.classList.remove('selected');
        });

        updateSaveButtonState();

    }

    function setEvaluationButtons(evaluation) {

        resetEvaluationButtons();

        if (!evaluation) {
            return;
        }

        selectedSpellingResult = evaluation.spelling_result;
        selectedPronunciationResult = evaluation.pronunciation_result;

        evaluationModal.querySelectorAll('.evaluation-btn').forEach(button => {

            const type = button.dataset.type;
            const result = button.dataset.result;

            if (
                (type === 'spelling' && result === selectedSpellingResult) ||
                (type === 'pronunciation' && result === selectedPronunciationResult)
            ) {
                button.classList.add('selected');
            }

        });

        updateSaveButtonState();

    }

    function enterBeehive() {

        if (!currentHive || !getSelectedParticipant()) {
            return;
        }

        closeModal('confirmBeehiveModal');

        let word = null;

        // Existing evaluation: retrieve its original word.
        if (currentEvaluation) {

            word = getWordByCode(currentEvaluation.palabra_id);

            if (!word) {

                alert(
                    'The word associated with this evaluation could not be found.'
                );

                return;
            }

        } else {

            // Exclude words already assigned in this competition.
            const assignedWordCodes = new Set(
                evaluations
                    .filter(
                        evaluation =>
                            String(evaluation.ronda_id) === String(activeRoundId) &&
                            evaluation.categoria_beehive === currentCategory
                    )
                    .map(evaluation => String(evaluation.palabra_id))
            );

            const availableWords = getCategoryWords().filter(
                item => !assignedWordCodes.has(String(item.codigo))
            );

            if (availableWords.length === 0) {

                alert(
                    'There are no more unused words available for this category.'
                );

                return;
            }

            const randomIndex = Math.floor(
                Math.random() * availableWords.length
            );

            word = availableWords[randomIndex];

        }

        currentWord = word;
        currentWordHive = currentHive;

        document.getElementById('currentWordText').textContent =
            word.texto;

        document.getElementById('currentWordDef').textContent =
            word.definicion || '';

        document.getElementById('currentWordExample').textContent =
            word.ejemplo || '';

        setEvaluationButtons(currentEvaluation);

        wordModal.classList.add('active');

        fitWordToModal();

    }
    
    // OPEN EVALUATION MODAL

    openEvaluationBtn.addEventListener('click', function () {

        if (!currentWord || !currentHive || !getSelectedParticipant()) {
            alert('Please open a Beehive first.');
            return;
        }

        setEvaluationButtons(currentEvaluation);

        evaluationModal.classList.add('active');

    });

    // EVALUATION BUTTONS

    evaluationModal.querySelectorAll('.evaluation-btn').forEach(button => {

        button.addEventListener('click', function () {

            const type = this.dataset.type;
            const result = this.dataset.result;

            document.querySelectorAll(
                `.evaluation-btn[data-type="${type}"]`
            ).forEach(option => {

                option.classList.remove('selected');

            });

            this.classList.add('selected');

            if (type === 'spelling') {
                selectedSpellingResult = result;
            }

            if (type === 'pronunciation') {
                selectedPronunciationResult = result;
            }

            updateSaveButtonState();

        });

    });

    // SAVE COMPETITION EVALUATION

    saveEvaluationBtn.addEventListener('click', async function () {

        const participantId = getSelectedParticipant();

        if (
            !participantId ||
            !activeRoundId ||
            !currentHive ||
            !currentWord ||
            currentWordHive !== currentHive ||
            !selectedSpellingResult ||
            !selectedPronunciationResult
        ) {
            alert('Please complete all evaluation fields and make sure a round is active.');
            return;
        }

        if (isSavingEvaluation) {
            return;
        }

        isSavingEvaluation = true;
        updateSaveButtonState();

        const formData = new URLSearchParams({
            participante_id: participantId,
            ronda_id: activeRoundId,
            palabra_codigo: currentWord.codigo,
            categoria_beehive: currentCategory,
            spelling_result: selectedSpellingResult,
            pronunciation_result: selectedPronunciationResult,
            beehive: currentHive
        });

        try {

            const response = await fetch(saveEvaluationUrl, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8',
                    'X-CSRFToken': csrfToken,
                    'X-Requested-With': 'XMLHttpRequest'
                },
                body: formData.toString()
            });

            const data = await response.json();

            if (!response.ok || !data.success) {
                throw new Error(
                    data.message || 'Unable to save the evaluation.'
                );
            }

            const savedEvaluation = {
                id: data.evaluation_id,
                participante_id: data.participante_id,
                ronda_id: data.ronda_id,
                alumno_id: data.alumno_id,
                palabra_id: data.palabra_codigo,
                categoria_beehive: data.categoria_beehive,
                beehive: data.beehive,
                spelling_result: data.spelling_result,
                pronunciation_result: data.pronunciation_result
            };

            const existingIndex = evaluations.findIndex(
                evaluation =>
                    String(evaluation.participante_id) === String(data.participante_id) &&
                    String(evaluation.ronda_id) === String(data.ronda_id)
            );

            if (existingIndex !== -1) {
                Object.assign(
                    evaluations[existingIndex],
                    savedEvaluation
                );
                currentEvaluation = evaluations[existingIndex];
            } else {
                evaluations.push(savedEvaluation);
                currentEvaluation = savedEvaluation;
            }

            closeModal('evaluationModal');
            renderBeehives();

            alert('Evaluation saved successfully.');

        } catch (error) {

            console.error('Evaluation save error:', error);

            alert(
                error.message ||
                'An error occurred while saving the evaluation.'
            );

        } finally {

            isSavingEvaluation = false;
            updateSaveButtonState();

        }

    });

    // ADD PARTICIPANTS MODAL

    function initParticipantModal() {

        const groupSelect = document.getElementById('participantGroup');
        const searchInput = document.getElementById('participantSearch');
        const participantsList = document.getElementById('participantsList');
        const emptyMessage = document.getElementById('participantsEmpty');
        const addButton = document.getElementById('addParticipantsBtn');

        // The participant modal may not exist in every competition state.
        if (
            !groupSelect ||
            !searchInput ||
            !participantsList ||
            !addButton
        ) {
            return;
        }

        function filterParticipants() {

            const selectedGroup = groupSelect.value.toLowerCase();
            const searchTerm = searchInput.value.trim().toLowerCase();

            const participantOptions = participantsList.querySelectorAll(
                '.res-participant-option'
            );

            let visibleCount = 0;

            participantOptions.forEach(option => {

                const participantGroup = (
                    option.dataset.group || ''
                ).toLowerCase();

                const participantName = (
                    option.dataset.name || ''
                ).toLowerCase();

                const participantEnrollment = (
                    option.dataset.enrollment || ''
                ).toLowerCase();

                const participantText = option.textContent.toLowerCase();

                const matchesGroup =
                    !selectedGroup ||
                    participantGroup === selectedGroup;

                const matchesSearch =
                    !searchTerm ||
                    participantName.includes(searchTerm) ||
                    participantEnrollment.includes(searchTerm) ||
                    participantText.includes(searchTerm);

                const isVisible = matchesGroup && matchesSearch;

                option.style.display = isVisible ? '' : 'none';

                if (isVisible) {
                    visibleCount++;
                }

            });

            if (emptyMessage) {
                emptyMessage.style.display =
                    visibleCount === 0 ? 'block' : 'none';
            }

        }

        function updateAddButton() {

            const selectedParticipants = participantsList.querySelectorAll(
                'input[name="participantes"]:checked'
            );

            addButton.disabled = selectedParticipants.length === 0;

        }

        groupSelect.addEventListener('change', filterParticipants);

        searchInput.addEventListener('input', filterParticipants);

        participantsList.addEventListener('change', function (event) {

            if (
                event.target.matches(
                    'input[name="participantes"]'
                )
            ) {
                updateAddButton();
            }

        });

        filterParticipants();
        updateAddButton();

    }

    // MODAL HELPERS

    function closeModal(id) {

        const modal = document.getElementById(id);

        if (modal) {
            modal.classList.remove('active');
        }

    }

    window.closeModal = closeModal;

    // EVENT LISTENERS

    participantSelect.addEventListener(
        'change',
        handleParticipantChange
    );

    categorySelect.addEventListener(
        'change',
        filterBeehives
    );

    previousButton.addEventListener(
        'click',
        function () {
            changeBeehivePage(-1);
        }
    );

    nextButton.addEventListener(
        'click',
        function () {
            changeBeehivePage(1);
        }
    );

    document.getElementById('confirmBeehiveBtn').addEventListener(
        'click',
        enterBeehive
    );

    // INITIALIZATION

    initCategorySelector();
    initRoundCategory();
    initParticipantModal();
    handleParticipantChange();
});
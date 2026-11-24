document.addEventListener('DOMContentLoaded', function () {

    // INITIAL DATA

    let currentCategory = 'CAT11';
    let currentHive = null;
    let currentBeehivePage = 1;
    let currentWord = null;
    let currentEvaluation = null;

    const participantSelect = document.getElementById('participantSelect');
    const categorySelect = document.getElementById('wordLengthSelect');
    const grid = document.querySelector('.honeycomb-grid');

    const previousButton = document.getElementById('previousPageBtn');
    const nextButton = document.getElementById('nextPageBtn');
    const pageIndicator = document.getElementById('pageIndicator');

    const confirmModal = document.getElementById('confirmBeehiveModal');
    const wordModal = document.getElementById('wordModal');

    const saveEvaluationBtn = document.getElementById('saveEvaluationBtn');

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

    function getParticipantEvaluation(matricula) {
        return evaluations.find(
            evaluation =>
                String(evaluation.alumno_id) === String(matricula)
        ) || null;
    }

    function getBeehiveEvaluation(category, hiveNumber) {
        return evaluations.find(
            evaluation =>
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

                    const evaluation = getBeehiveEvaluation(
                        currentCategory,
                        hiveNumber
                    );

                    const isOccupied = evaluation !== null;

                    const belongsToParticipant =
                        isOccupied &&
                        selectedParticipant &&
                        String(evaluation.alumno_id) ===
                        String(selectedParticipant);

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
                    if (!selectedParticipant) {
                        button.disabled = true;
                    }

                    if (belongsToParticipant) {
                        button.classList.add('beehive-assigned');
                    }

                    button.addEventListener('click', function () {

                        selectBeehive(hiveNumber);

                    });

                    row.appendChild(button);

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

        const matricula = getSelectedParticipant();

        if (!matricula) {
            alert('Please select a participant first.');
            return;
        }

        currentHive = Number(hiveNumber);

        const selectedHiveElement =
            document.getElementById('selectedHiveNum');

        selectedHiveElement.textContent = currentHive;

        currentEvaluation = getBeehiveEvaluation(
            currentCategory,
            currentHive
        );

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

    function resetEvaluationButtons() {

        document.querySelectorAll('.evaluation-btn').forEach(button => {

            button.classList.remove('selected');

        });

        // Saving will be connected after the backend action is implemented.
        saveEvaluationBtn.disabled = true;

    }

    function setEvaluationButtons(evaluation) {

        resetEvaluationButtons();

        if (!evaluation) {
            return;
        }

        document.querySelectorAll('.evaluation-btn').forEach(button => {

            const type = button.dataset.type;
            const result = button.dataset.result;

            if (
                type === 'spelling' &&
                result === evaluation.spelling_result
            ) {
                button.classList.add('selected');
            }

            if (
                type === 'pronunciation' &&
                result === evaluation.pronunciation_result
            ) {
                button.classList.add('selected');
            }

        });

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

    // EVALUATION BUTTONS

    document.querySelectorAll('.evaluation-btn').forEach(button => {

        button.addEventListener('click', function () {

            const type = this.dataset.type;
            const result = this.dataset.result;

            document.querySelectorAll(
                `.evaluation-btn[data-type="${type}"]`
            ).forEach(option => {

                option.classList.remove('selected');

            });

            this.classList.add('selected');

            // The save action will be connected in the next backend step.
            // Keep the button disabled until that action is available.
            saveEvaluationBtn.disabled = true;

        });

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

    initParticipantModal();

    handleParticipantChange();

});
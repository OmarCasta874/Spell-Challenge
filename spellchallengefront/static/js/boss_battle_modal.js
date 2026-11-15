(function () {
    'use strict';

    // GET HTML ELEMENTS

    const modal = document.getElementById('bossBattleModal');
    const battleForm = document.getElementById('bossBattleForm');
    const optionsContainer = document.getElementById('bossBattleOptions');

    const intro = document.getElementById('bossBattleIntro');
    const beginButton = document.getElementById('bossBattleBegin');

    let previousBodyOverflow = '';
    let battleToken = null;
    let isProcessing = false;
    let roundToken = null;

    // GET CSRF TOKEN

    function getCsrfToken() {

        const csrfInput = battleForm.querySelector(
            '[name=csrfmiddlewaretoken]'
        );

        return csrfInput ? csrfInput.value : '';
    }

    // UPDATE HEALTH BARS

    function updateHealthBars(kingBeeLives, beenaryLives) {

        const kingBeeLabel = document.getElementById('kingBeeLives');
        const beenaryLabel = document.getElementById('beenaryLives');

        const kingBeeHealth = document.getElementById('kingBeeHealth');
        const beenaryHealth = document.getElementById('beenaryHealth');

        if (kingBeeLabel) {
            kingBeeLabel.textContent = `${kingBeeLives} / 10`;
        }

        if (beenaryLabel) {
            beenaryLabel.textContent = `${beenaryLives} / 10`;
        }

        if (kingBeeHealth) {

            const percentage = (kingBeeLives / 10) * 100;

            kingBeeHealth.style.width = `${percentage}%`;

            kingBeeHealth.style.background =
                kingBeeLives <= 3 ? '#dc3545' : '#35a853';
        }

        if (beenaryHealth) {

            const percentage = (beenaryLives / 10) * 100;

            beenaryHealth.style.width = `${percentage}%`;

            beenaryHealth.style.background =
                beenaryLives <= 3 ? '#dc3545' : '#35a853';
        }
    }

    // UPDATE ROUND INFORMATION

    function updateRound(round, suddenDeath = false) {

        const roundLabel = document.getElementById(
            'bossBattleRound'
        );

        if (!roundLabel) return;

        if (suddenDeath) {

            const suddenDeathRound = round - 10;

            roundLabel.textContent = `SUDDEN DEATH - ROUND ${suddenDeathRound}`;

        } else {

            roundLabel.textContent = `ROUND ${round} / 10`;
        }
    }

    // DISPLAY FEEDBACK

    function showFeedback(message, correct = null) {

        const feedback = document.getElementById(
            'bossBattleFeedback'
        );

        if (!feedback) return;

        feedback.textContent = message;

        feedback.classList.remove(
            'correct',
            'incorrect'
        );

        if (correct === true) {

            feedback.classList.add('correct');

        } else if (correct === false) {

            feedback.classList.add('incorrect');
        }
    }

    // ANIMATE CHARACTER DAMAGE

    function animateDamage(characterId) {
        const character = document.getElementById(characterId);

        if (!character) return;

        character.classList.remove('damage-animation');

        void character.offsetWidth;

        character.classList.add('damage-animation');

        character.addEventListener(
            'animationend',
            function () {
                character.classList.remove('damage-animation');
            },
            { once: true}
        );
    }

    // RENDER MULTIPLE-CHOICE ANSWER OPTIONS 

    function renderAnswerOptions(options) {
        if (!optionsContainer) return;

        optionsContainer.innerHTML = '';

        if (
            !Array.isArray(options) ||
            options.length !== 4 ||
            options.some(function (option) {
                return typeof option !== 'string' || !option.trim();
            })
        ) {
            showFeedback('Unable to load answer options.');
            return;
        }

        options.forEach(function (option) {
            const button = document.createElement('button');

            button.type = 'button';
            button.className = 'boss-battle-option';
            button.textContent = option;

            button.addEventListener('click', function () {
                submitAnswer(option);
            });

            optionsContainer.appendChild(button);
        });
    }

    // RESET BATTLE DISPLAY

    function resetBattleDisplay() {
        const round = document.getElementById('bossBattleRound');
        const clue = document.getElementById('bossBattleClue');
        const feedback = document.getElementById('bossBattleFeedback');

        if (round) {
            round.textContent = 'PREPARING BATTLE...';
        }

        if (clue) {
            clue.textContent = 'Preparing your challenge...';
        }

        if (optionsContainer) {
            optionsContainer.innerHTML = '';
        }

        if (feedback) {
            feedback.textContent = '';
            feedback.classList.remove('correct', 'incorrect');
        }

        updateHealthBars(10, 10);

        battleToken = null;
        roundToken = null;
        isProcessing = false;
    }

    // START NEW BATTLE

    async function startBattle() {

        const startUrl = modal.dataset.startUrl;

        try {

            const response = await fetch(startUrl, {

                method: 'POST',

                headers: {
                    'X-CSRFToken': getCsrfToken(),
                    'X-Requested-With': 'XMLHttpRequest'
                },

                credentials: 'same-origin'
            });

            const data = await response.json();

            if (!response.ok || !data.success) {

                throw new Error(
                    data.message || 'Unable to start Boss Battle.'
                );
            }

            // SAVE BATTLE TOKEN

            if (!data.battle_token || !data.round_token) {
                throw new Error('Invalid battle session received from server.');
            }

            battleToken = data.battle_token;
            roundToken = data.round_token;

            // UPDATE INITIAL INFORMATION

            updateRound(data.round);

            updateHealthBars(data.king_bee_lives,data.beenary_lives);

            document.getElementById('bossBattleClue').textContent = data.clue;

            // DISPLAY ANSWER OPTIONS
            renderAnswerOptions(data.options);

        } catch (error) {

            showFeedback(
                error.message || 'An error occurred while starting the battle.'
            );

            document.getElementById(
                'bossBattleClue'
            ).textContent = 'Unable to load the challenge.';

        }
    }

    // BEGIN BOSS BATTLE AFTER INTRODUCTION 

    async function beginBossBattle() {
        if (isProcessing) return;

        intro.classList.remove('intro-active');
        intro.hidden = true;

        const gameplay = document.getElementById('bossBattleGameplay');

        if (gameplay) {
            gameplay.hidden = false;
        }

        resetBattleDisplay();

        await startBattle();
    }

    // SUBMIT STUDENT ANSWER

    async function submitAnswer(selectedAnswer) {

        if (isProcessing || !battleToken) return;

        const answer = selectedAnswer;

        if (!answer) {

            showFeedback('Please select an answer.');
            return;
        }

        isProcessing = true;

        if (!optionsContainer) return;

        const optionButtons = optionsContainer.querySelectorAll(
            '.boss-battle-option'
        );

        optionButtons.forEach(function (button) {
            button.disabled = true;
        });

        const answerUrl = modal.dataset.answerUrl;

        const formData = new URLSearchParams();

        formData.append('csrfmiddlewaretoken', getCsrfToken());
        formData.append('battle_token', battleToken);
        formData.append('round_token', roundToken);
        formData.append('answer', answer);

        try {

            const response = await fetch(answerUrl, {

                method: 'POST',

                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                    'X-CSRFToken': getCsrfToken(),
                    'X-Requested-With': 'XMLHttpRequest'
                },

                body: formData.toString(),

                credentials: 'same-origin'
            });

            const data = await response.json();

            if (!response.ok || !data.success) {

                throw new Error(
                    data.message || 'Unable to process your answer.'
                );
            }

            // UPDATE FEEDBACK

            showFeedback(data.feedback, data.correct);

            optionButtons.forEach(function (button) {
                if (button.textContent === answer) {
                    if (data.correct) {
                        button.classList.add('correct');
                    } else {
                        button.classList.add('incorrect');
                    }
                }
            });

            if (data.correct) {
                animateDamage('kingBeeImage');
            } else {
                animateDamage('beenaryImage');
            }

            roundToken = data.round_token || null;

            // UPDATE HEALTH

            updateHealthBars(data.king_bee_lives, data.beenary_lives);

            // CHECK BATTLE RESULT

            if (data.finished) {

                optionButtons.forEach(function (button) {
                    button.disabled = true;
                });

                if (data.result === 'victory') {

                    showFeedback(
                        `VICTORY! Beenary defeated King Bee! 👑 +${data.xp_earned} XP`,
                        true
                    );

                } else if (data.result === 'defeat') {

                    showFeedback(
                        'DEFEAT! King Bee has won the battle! +0 XP',
                        false
                    );

                } else {

                    showFeedback(
                        'The battle ended without a winner. +0 XP',
                        false
                    );
                }

                document.getElementById('bossBattleClue').textContent = 'Battle completed!';

                document.getElementById('bossBattleRound').textContent = 'BATTLE COMPLETED';

                battleToken = null;
                roundToken = null;
                return;
            }

            // LOAD NEXT ROUND

            updateRound(data.round, data.sudden_death);

            document.getElementById('bossBattleClue').textContent = data.clue;

            // DISPLAY NEXT ANSWER OPTIONS
            renderAnswerOptions(data.options);

        } catch (error) {

            // DISABLE ALL ANSWER OPTIONS
            optionButtons.forEach(function (button) {
                button.disabled = true;
            });

            showFeedback(
                'The battle could not be synchronized. Please close and reopen Boss Battle.'
            );

            battleToken = null;
            roundToken = null;

        } finally {

            isProcessing = false;
        }
    }

    // OPEN BOSS BATTLE

    function openBossBattle() {
        if (!modal) return;

        previousBodyOverflow = document.body.style.overflow;
        modal.classList.add('active');
        document.body.style.overflow = 'hidden';

        resetBattleDisplay();
        
        const gameplay = document.getElementById('bossBattleGameplay');

        if (gameplay) {
            gameplay.hidden = true;
        }

        if (intro) {
            intro.hidden = false;
            intro.classList.remove('intro-active');

            void intro.offsetWidth;

            intro.classList.add('intro-active');
        }
    }

    // CLOSE BOSS BATTLE

    function closeBossBattle() {

        if (!modal || isProcessing) return;

        modal.classList.remove('active');

        document.body.style.overflow = previousBodyOverflow;
    }

    // INITIALIZE EVENTS

    function initializeBossBattle() {

        if (!modal || !battleForm) return;

        if (beginButton) {
            beginButton.addEventListener('click', beginBossBattle);
        }

        // CLOSE WHEN CLICKING OUTSIDE THE MODAL

        modal.addEventListener('click', function (event) {

            if (event.target === modal) {
                closeBossBattle();
            }
        });

        // CLOSE WITH ESCAPE KEY

        document.addEventListener('keydown', function (event) {

            if (
                event.key === 'Escape' &&
                modal.classList.contains('active')
            ) {
                closeBossBattle();
            }
        });
    }

    // GLOBAL FUNCTIONS

    window.openBossBattle = openBossBattle;
    window.closeBossBattle = closeBossBattle;

    // DOM READY

    if (document.readyState === 'loading') {

        document.addEventListener(
            'DOMContentLoaded',
            initializeBossBattle
        );

    } else {
        initializeBossBattle();
    }
})();
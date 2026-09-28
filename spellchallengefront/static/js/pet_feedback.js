(function () {

    function initMascotFeedback() {

        if (!window.Mascot) {
            return false;
        }

        var STREAK_AT = 3;
        var streak = 0;

        window.MascotFeedback = {

            answer: function (isCorrect, name) {

                if (!isCorrect) {
                    streak = 0;

                    Mascot.show(
                        'Good try!',
                        'Give it another shot!'
                    );

                    return;
                }

                streak += 1;

                if (
                    streak >= STREAK_AT &&
                    streak % STREAK_AT === 0
                ) {
                    Mascot.show(
                        'What a streak!',
                        'Keep buzzing like that!'
                    );
                } else {
                    Mascot.show(
                        name ? 'Awesome, ' + name + '!' : 'Awesome!',
                        'Keep it up!'
                    );
                }
            },

            ready: function () {
                Mascot.show(
                    'Are you ready?',
                    "Let's go! You can do it!"
                );
            },

            resetStreak: function () {
                streak = 0;
            }
        };

        return true;
    }


    function waitForMascot() {

        if (initMascotFeedback()) {
            return;
        }

        setTimeout(waitForMascot, 50);
    }


    waitForMascot();

})();
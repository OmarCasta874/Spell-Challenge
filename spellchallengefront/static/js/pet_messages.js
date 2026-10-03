/* pet_messages.js */

(function () {

    function initMascot() {

        var root = document.getElementById('mascot-widget');
        if (!root) return;

        var bubble = root.querySelector('.mascot-bubble');
        var titleEl = root.querySelector('.mascot-title');
        var textEl = root.querySelector('.mascot-text');
        var img = root.querySelector('.mascot-img');
        var closeBtn = root.querySelector('.mascot-close');
        var last = null;

        function show(title, text) {
            titleEl.textContent = title;
            textEl.textContent = text || '';

            last = {
                title: title,
                text: text || ''
            };

            root.classList.add('is-active');

            bubble.hidden = false;

            bubble.classList.remove('is-visible');
            void bubble.offsetWidth;
            bubble.classList.add('is-visible');
        }

        function hide() {
            bubble.hidden = true;
            root.classList.remove('is-active');
        }

        closeBtn.addEventListener('click', hide);

        img.addEventListener('click', function () {
            if (!bubble.hidden) {
                hide();
            } else if (last) {
                show(last.title, last.text);
            }
        });

        window.Mascot = {
            show: show,
            hide: hide
        };

        if (root.dataset.title) {
            show(
                root.dataset.title,
                root.dataset.text
            );
        }
    }

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', initMascot);
    } else {
        initMascot();
    }

})();
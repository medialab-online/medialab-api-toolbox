const userMessagesContainer = document.querySelector('#messages');
const clearMessagesButton = document.querySelector('#clear-messages');

clearMessagesButton.addEventListener('click', () => {
    Array.from(userMessagesContainer.children).forEach((child) => child.remove());
    clearMessagesButton.style.display = 'none';
});

export default function displayUserMessage(...messages) {
    messages.reverse().forEach((message) => {
        console.log(message); // eslint-disable-line no-console

        let element;
        if (message instanceof Error) {
            element = document.createElement('p');
            element.classList.add('error');
            element.innerText = `Error: ${message.message || message}`;
        } else if (message instanceof URL) {
            element = document.createElement('a');
            element.target = '_blank';
            element.rel = 'noreferrer nofollow';
            element.href = message.href;
            element.innerText = message.href;
        } else if (typeof message === 'string') {
            element = document.createElement('p');
            element.innerText = message;
        } else {
            element = document.createElement('pre');
            element.innerHTML = syntaxHighlightJson(message);
        }

        userMessagesContainer.insertAdjacentElement('afterbegin', element);
    });

    clearMessagesButton.style.display = null;
}

/**
 * Credits to user123444555621 @Stack Overflow
 * https://stackoverflow.com/a/7220510
 */
function syntaxHighlightJson(data) {
    // eslint-disable-next-line max-len, no-useless-escape
    const propsRegex = /("(\\u[a-zA-Z0-9]{4}|\\[^u]|[^\\"])*"(\s*:)?|\b(true|false|null)\b|-?\d+(?:\.\d*)?(?:[eE][+\-]?\d+)?)/g;
    return JSON.stringify(data, null, 2)
        .replace(/&/g, '&amp;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
        .replace(propsRegex, (match) => {
            let cssClass = 'number';
            if (/^"/.test(match)) {
                if (/:$/.test(match)) {
                    cssClass = 'key';
                } else {
                    cssClass = 'string';
                }
            } else if (/true|false/.test(match)) {
                cssClass = 'boolean';
            } else if (/null/.test(match)) {
                cssClass = 'null';
            }
            return `<span class="${cssClass}">${match}</span>`;
        });
}

document.addEventListener('DOMContentLoaded', function() {
    // SVG icons
    const copyIcon = `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="M19,21H8V7H19M19,5H8A2,2 0 0,0 6,7V21A2,2 0 0,0 8,23H19A2,2 0 0,0 21,21V7A2,2 0 0,0 19,5M16,1H4A2,2 0 0,0 2,3V17H4V3H16V1Z"/></svg>`;
    const doneIcon = `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="M21,7L9,19L3.5,13.5L4.91,12.09L9,16.17L19.59,5.59L21,7Z"/></svg>`;

    // Add copy button to each blueprint render container
    document.querySelectorAll('.bue-render').forEach(function(container) {
        const textarea = container.querySelector('textarea');
        if (!textarea) return;

        const button = document.createElement('button');
        button.className = 'bue-copy-button';
        button.innerHTML = copyIcon;
        button.title = 'Copy blueprint';
        
        button.addEventListener('click', async function() {
            try {
                await navigator.clipboard.writeText(textarea.value);
                
                // Show success state
                button.classList.add('copied');
                button.innerHTML = doneIcon;
                
                // Reset after 2 seconds
                setTimeout(function() {
                    button.classList.remove('copied');
                    button.innerHTML = copyIcon;
                }, 2000);
            } catch (err) {
                console.error('Failed to copy text:', err);
            }
        });

        container.appendChild(button);
    });
});

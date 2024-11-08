// Configuration
const CONFIG = {
    testMode: true,
    testDate: new Date('2024-12-24'),
    forcedOpenDoors: []
};

// Audio setup
const AudioContext = window.AudioContext || window.webkitAudioContext;
const audioContext = new AudioContext();
const audioBuffers = {};

// State management
let openedDoors = [];
let locale = {};
let doorImages = {};

// Normalize opened doors data structure
function normalizeOpenedDoors(doors) {
    if (!doors) return [];
    
    if (Array.isArray(doors)) {
        return doors.flat().map(Number);
    }
    
    if (typeof doors === 'object') {
        return Object.values(doors).flat().map(Number);
    }
    
    return [];
}

// Audio handling functions
async function loadSound(url) {
    if (audioBuffers[url]) {
        return audioBuffers[url];
    }

    try {
        const response = await fetch(url);
        const arrayBuffer = await response.arrayBuffer();
        const audioBuffer = await audioContext.decodeAudioData(arrayBuffer);
        audioBuffers[url] = audioBuffer;
        return audioBuffer;
    } catch (error) {
        console.warn(`Failed to load audio: ${url}`, error);
        return null;
    }
}

async function playSound(url, volume = 1.0) {
    try {
        const buffer = await loadSound(url);
        if (buffer) {
            const source = audioContext.createBufferSource();
            const gainNode = audioContext.createGain();
            
            source.buffer = buffer;
            gainNode.gain.value = volume;
            
            source.connect(gainNode);
            gainNode.connect(audioContext.destination);
            
            source.start(0);
            return;
        }
    } catch (error) {
        console.warn('Audio playback failed', error);
    }
}

function playDoorOpenSound() {
    const randomNum = Math.floor(Math.random() * 6) + 1;
    const soundNum = randomNum.toString().padStart(2, '0');
    playSound(`./sounds/sound-${soundNum}.ogg`, 0.1)
        .catch(() => console.warn('Could not play door open sound'));
}

// UI handling functions
function showNotification(message, type = 'error') {
    const notification = document.querySelector('.notification');
    notification.textContent = message;
    notification.style.display = 'block';
    notification.className = `notification ${type}`;
    
    setTimeout(() => {
        notification.style.display = 'none';
    }, 3000);
}

function updateDoorContent(door) {
    const day = door.dataset.day;
    const content = door.querySelector('.door-content');
    
    if (doorImages[day]) {
        content.innerHTML = `
            <div class="gift-content">
                <img src="${doorImages[day]}" alt="Gift image" class="gift-image">
                <div class="sparkles">✨</div>
            </div>
        `;
    } else {
        content.innerHTML = `
            <div class="gift-content">
                <div class="gift-icon">🎁</div>
                <div class="sparkles">✨</div>
            </div>
        `;
    }
}

function isDoorAvailable(day) {
    const currentDay = CONFIG.testMode ? 
        CONFIG.testDate.getDate() : 
        (new Date().getMonth() === 11 ? new Date().getDate() : 0);
    
    return day <= currentDay || CONFIG.forcedOpenDoors.includes(day);
}

function handleDoorClick(door) {
    const day = parseInt(door.dataset.day);
    
    if (!isDoorAvailable(day)) {
        showNotification(locale.doorLocked || 'This door cannot be opened yet!', 'error');
        return;
    }
    
    if (openedDoors.includes(day)) {
        return;
    }
    
    playDoorOpenSound();
    door.classList.add('opening');
    createDoorParticles(door);
    
    setTimeout(() => {
        door.classList.add('opened');
        updateDoorContent(door);
        openedDoors.push(day);
        
        fetch(`https://${GetParentResourceName()}/openDoor`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({ day })
        });
    }, 500);
}

function createDoorParticles(door) {
    const rect = door.getBoundingClientRect();
    const particles = 20;
    
    for (let i = 0; i < particles; i++) {
        const particle = document.createElement('div');
        particle.className = 'particle';
        
        const angle = (i / particles) * 360;
        const velocity = 2 + Math.random() * 2;
        
        particle.style.left = `${rect.left + rect.width / 2}px`;
        particle.style.top = `${rect.top + rect.height / 2}px`;
        
        const animation = particle.animate([
            { transform: 'translate(0, 0) scale(1)' },
            {
                transform: `translate(${Math.cos(angle) * 100 * velocity}px, 
                           ${Math.sin(angle) * 100 * velocity}px) scale(0)`
            }
        ], {
            duration: 1000,
            easing: 'cubic-bezier(0.4, 0.0, 0.2, 1)'
        });
        
        document.body.appendChild(particle);
        animation.onfinish = () => particle.remove();
    }
}

// Initialize UI and event listeners
document.addEventListener('DOMContentLoaded', () => {
    const title = document.querySelector('#adventskalender-2024');
    const closeBtn = document.querySelector('.close-btn');
    
    if (title && locale.title) {
        title.textContent = locale.title;
    }
    
    if (closeBtn && locale.closeButton) {
        closeBtn.textContent = locale.closeButton;
    }
    
    // Door click handlers
    document.querySelectorAll('.door').forEach(door => {
        door.querySelector('.door-panel').addEventListener('click', () => handleDoorClick(door));
    });
    
    // Close button handler
    closeBtn.addEventListener('click', () => {
        fetch(`https://${GetParentResourceName()}/closeUI`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({})
        });
    });
    
    // Initialize forced open doors
    CONFIG.forcedOpenDoors.forEach(day => {
        if (!openedDoors.includes(day)) {
            const door = document.querySelector(`[data-day="${day}"]`);
            if (door) {
                door.classList.add('opened');
                updateDoorContent(door);
                openedDoors.push(day);
            }
        }
    });
    
    // Initialize previously opened doors
    openedDoors.forEach(day => {
        const door = document.querySelector(`[data-day="${day}"]`);
        if (door) {
            door.classList.add('opened');
            updateDoorContent(door);
        }
    });
});

// Message handler for NUI events
window.addEventListener('message', (event) => {
    const data = event.data;
    
    switch (data.type) {
        case 'showUI':
            document.body.style.display = 'flex';
            openedDoors = normalizeOpenedDoors(data.openedDoors);
            doorImages = data.doorImages || {};
            locale = data.locale || {};
            
            updateUIElements();
            initializeDoors();
            break;
            
        case 'hideUI':
            document.body.style.display = 'none';
            break;
            
        case 'doorOpened':
            handleDoorOpened(data.day);
            break;
            
        case 'showNotification':
            showNotification(data.message, data.notificationType);
            break;
    }
});

// Helper functions for message handler
function updateUIElements() {
    const title = document.querySelector('#adventskalender-2024');
    const closeBtn = document.querySelector('.close-btn');
    
    if (title && locale.title) {
        title.textContent = locale.title;
    }
    if (closeBtn && locale.closeButton) {
        closeBtn.textContent = locale.closeButton;
    }
}

function initializeDoors() {
    document.querySelectorAll('.door').forEach(door => {
        const day = door.dataset.day;
        const giftImage = door.querySelector('.gift-image');
        if (giftImage && doorImages[day]) {
            giftImage.src = doorImages[day];
            giftImage.style.opacity = '1';
        }
    });

    CONFIG.forcedOpenDoors.forEach(day => {
        if (!openedDoors.includes(day)) {
            const door = document.querySelector(`[data-day="${day}"]`);
            if (door) {
                door.classList.add('opened');
                updateDoorContent(door);
                openedDoors.push(day);
            }
        }
    });
    
    openedDoors.forEach(day => {
        const door = document.querySelector(`[data-day="${day}"]`);
        if (door) {
            door.classList.add('opened');
            updateDoorContent(door);
        }
    });
}

function handleDoorOpened(day) {
    const door = document.querySelector(`[data-day="${day}"]`);
    if (door) {
        door.classList.add('opening', 'opened');
        updateDoorContent(door);
        
        const giftImage = door.querySelector('.gift-image');
        if (giftImage && doorImages[day]) {
            giftImage.src = doorImages[day];
            giftImage.style.opacity = '1';
        }
    }
}

// Sound activation through user interaction
document.addEventListener('click', () => {
    if (audioContext.state === 'suspended') {
        audioContext.resume();
    }
}, { once: true });

// Test mode functions
if (CONFIG.testMode) {
    window.setTestDate = (date) => {
        CONFIG.testDate = new Date(date);
    };
    
    window.toggleTestMode = (enabled) => {
        CONFIG.testMode = enabled;
    };
    
    window.openDoorForTesting = (day) => {
        if (!CONFIG.forcedOpenDoors.includes(day)) {
            CONFIG.forcedOpenDoors.push(day);
        }
    };
}

// Escape key handler
document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape') {
        fetch(`https://${GetParentResourceName()}/closeUI`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({})
        });
    }
});
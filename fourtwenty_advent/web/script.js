// Configuration
const CONFIG = {
    testMode: false,
    testDate: new Date('2024-12-24'),
    forcedOpenDoors: []
};

// Debug logging
function debugLog(message, data = null) {
    return;
    console.log(`[Advent Calendar Debug] ${message}`);
    if (data) {
        console.log('[Debug Data]', data);
    }
}

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
    debugLog('Normalizing doors data', doors);
    
    if (!doors) {
        debugLog('No doors data provided, returning empty array');
        return [];
    }
    
    if (Array.isArray(doors)) {
        const normalized = doors.map(Number);
        debugLog('Normalized doors array', normalized);
        return normalized;
    }
    
    debugLog('Invalid doors data format, returning empty array');
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
    debugLog('Showing notification', { message, type });
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
    debugLog('Updating door content', { day });
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
    
    const available = day <= currentDay || CONFIG.forcedOpenDoors.includes(day);
    debugLog('Checking door availability', { day, currentDay, available });
    return available;
}

function handleDoorClick(door) {
    const day = parseInt(door.dataset.day);
    debugLog('Door clicked', { day });
    
    if (!isDoorAvailable(day)) {
        showNotification(locale.doorLocked || 'This door cannot be opened yet!', 'error');
        return;
    }
    
    if (openedDoors.includes(day)) {
        debugLog('Door already opened', { day });
        return;
    }
    
    debugLog('Opening door', { day });
    playDoorOpenSound();
    door.classList.add('opening');
    createDoorParticles(door);
    
    setTimeout(() => {
        door.classList.add('opened');
        updateDoorContent(door);
        openedDoors.push(day);
        debugLog('Door opened successfully', { day, openedDoors });
        
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
    debugLog('DOM Content Loaded');
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
        debugLog('Close button clicked');
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
    debugLog('Initializing previously opened doors', { openedDoors });
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
    debugLog('Received NUI message', { type: data.type });
    
    switch (data.type) {
        case 'showUI':
            document.body.style.display = 'flex';
            openedDoors = normalizeOpenedDoors(data.openedDoors);
            doorImages = data.doorImages || {};
            locale = data.locale || {};
            
            debugLog('UI shown with data', {
                openedDoors,
                doorImagesCount: Object.keys(doorImages).length,
                locale: Object.keys(locale)
            });
            
            updateUIElements();
            initializeDoors();
            break;
            
        case 'hideUI':
            document.body.style.display = 'none';
            debugLog('UI hidden');
            break;
            
        case 'doorOpened':
            debugLog('Door opened event received', { day: data.day });
            handleDoorOpened(data.day);
            break;
            
        case 'showNotification':
            debugLog('Show notification event received', {
                message: data.message,
                type: data.notificationType
            });
            showNotification(data.message, data.notificationType);
            break;
    }
});

// Helper functions for message handler
function updateUIElements() {
    debugLog('Updating UI elements');
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
    debugLog('Initializing doors');
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
    
    debugLog('Setting up opened doors', { openedDoors });
    openedDoors.forEach(day => {
        const door = document.querySelector(`[data-day="${day}"]`);
        if (door) {
            door.classList.add('opened');
            updateDoorContent(door);
        }
    });
}

function handleDoorOpened(day) {
    debugLog('Handling door opened', { day });
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
        debugLog('Escape key pressed, closing UI');
        fetch(`https://${GetParentResourceName()}/closeUI`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({})
        });
    }
});

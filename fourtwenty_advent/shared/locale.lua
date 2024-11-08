-- locale.lua
Locale = {}
Locale.Languages = {
    ['de'] = {
        ['command_description'] = 'Öffne den Adventskalender',
        ['door_already_opened'] = 'Du hast dieses Geschenk bereits geöffnet!',
        ['calendar_reset'] = 'Adventskalender wurde zurückgesetzt!',
        ['calendar_reset_player'] = 'Adventskalender für Spieler zurückgesetzt!',
        ['press_to_open'] = 'Drücke ~INPUT_CONTEXT~ um das Geschenk zu öffnen',
        ['opening_gift'] = 'Geschenk wird geöffnet...',
        ['gift_found'] = 'Du hast ein Geschenk gefunden!',
        ['door_locked'] = 'Diese Tür kann noch nicht geöffnet werden!',
        ['calendar_title'] = '🎄 Adventskalender 2024 🎄',
        ['close_button'] = 'X',
        ['success'] = 'Erfolg',
        ['error'] = 'Fehler',
        ['reward_money'] = 'Du hast %s$ gefunden!',
        ['reward_black_money'] = 'Du hast %s$ Schwarzgeld gefunden!',
        ['reward_bank'] = '%s$ wurden deinem Bankkonto gutgeschrieben!',
        ['reward_item'] = 'Du hast %sx %s gefunden!',
        ['reward_weapon'] = 'Du hast eine %s mit %s Schuss gefunden!'
    },
    ['en'] = {
        ['command_description'] = 'Open the Advent Calendar',
        ['door_already_opened'] = 'You have already opened this gift!',
        ['calendar_reset'] = 'Advent calendar has been reset!',
        ['calendar_reset_player'] = 'Advent calendar reset for player!',
        ['press_to_open'] = 'Press ~INPUT_CONTEXT~ to open the gift',
        ['opening_gift'] = 'Opening gift...',
        ['gift_found'] = 'You found a gift!',
        ['door_locked'] = 'This door cannot be opened yet!',
        ['calendar_title'] = '🎄 Advent Calendar 2024 🎄',
        ['close_button'] = 'X',
        ['success'] = 'Success',
        ['error'] = 'Error',
        ['reward_money'] = 'You found $%s!',
        ['reward_black_money'] = 'You found $%s in black money!',
        ['reward_bank'] = '$%s has been added to your bank account!',
        ['reward_item'] = 'You found %sx %s!',
        ['reward_weapon'] = 'You found a %s with %s ammunition!'
    }
}

Locale.CurrentLanguage = 'en'

function Locale.Translate(key, ...)
    local args = {...}
    local language = Locale.Languages[Locale.CurrentLanguage]
    
    if not language then
        print("Currently selected language " .. Locale.CurrentLanguage .. " not found. Please create it in locale.lua")
        language = Locale.Languages['en']
    end
    
    local translation = language[key]
    if not translation then
        return key
    end
    
    if #args > 0 then
        return string.format(translation, table.unpack(args))
    end

    return translation
end


function _U(key, ...)
    return Locale.Translate(key, ...)
end
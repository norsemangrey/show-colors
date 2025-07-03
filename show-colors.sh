#!/bin/bash

# Usage function
usage() {
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -d, --debug             Turns on debug output messages (if any)."
    echo "  -t, --theme [file]      Print theme codes and colors. Optionally specify a palette file."
    echo "  -v, --variations        Prints tables with variations of background/text combinations"
    echo "  -h, --help              Show this help message and exit."
    echo ""
    echo "This script displays ANSI color codes and their corresponding colors in your terminal."
    echo "It can also load custom color palettes from JSON files (specified with the -t option)."
    echo "The output includes foreground and background color codes, ANSI color representation,"
    echo "and, if a theme file is provided, the hexadecimal and RGB values of the colors."
    echo ""
    echo "Color codes in your terminal can be used to style text output. ANSI escape sequences"
    echo "are used to change text color, background color, and other attributes. The basic format"
    echo "for setting foreground and background colors is:"
    echo ""
    echo "  \\e[<foreground_code>;<background_code>m<text>\\e[0m"
    echo ""
    echo "where:"

    echo "  <foreground_code> is the ANSI code for the foreground color (e.g., 31 for red)."
    echo "  <background_code> is the ANSI code for the background color (e.g., 42 for green)."
    echo "  <text> is the text you want to color."
    echo "  \\e[0m resets the color back to the default."
    echo ""
    echo "Example: To print 'Hello' in red on a green background:"
    echo ""
    echo "  echo -e \"\\e[31;42mHello\\e[0m\""
    echo ""
    echo "The script outputs tables of color codes, which you can use in this manner. For example,"
    echo "if the script shows that the foreground code for 'blue' is 34 and the background code"
    echo "for 'yellow' is 43, you would use \\e[34;43m to get blue text on a yellow background."
    echo ""
    echo "Custom palettes should be JSON files with the following structure:"
    echo ""
    echo "{"
    echo "  \"name\": \"Palette Name\","
    echo "  \"black\": \"#000000\","
    echo "  \"red\": \"#FF0000\","
    echo "  \"green\": \"#00FF00\","
    echo "  \"yellow\": \"#FFFF00\","
    echo "  \"blue\": \"#0000FF\","
    echo "  \"purple\": \"#FF00FF\","
    echo "  \"cyan\": \"#00FFFF\","
    echo "  \"white\": \"#FFFFFF\","
    echo "  \"brightBlack\": \"#808080\","
    echo "  \"brightRed\": \"#FF8080\","
    echo "  \"brightGreen\": \"#80FF80\","
    echo "  \"brightYellow\": \"#FFFF80\","
    echo "  \"brightBlue\": \"#8080FF\","
    echo "  \"brightPurple\": \"#FF80FF\","
    echo "  \"brightCyan\": \"#80FFFF\","
    echo "  \"brightWhite\": \"#C0C0C0\","
    echo "  \"foreground\": \"#000000\","
    echo "  \"background\": \"#FFFFFF\""
    echo "}"
    echo ""
    echo "Where the color values are hexadecimal RGB codes (e.g., #FF0000 for red)."
    echo "Additional colors can be included without issue."
    echo ""
}

# Set palette default file name
paletteFile="16-ansi-color-palette.json"

# Parsed from command line arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -d|--debug)
            debug=true
            shift
            ;;
        -t|--theme)
            showTheme=true
            if [[ -n "$2" && ! "$2" =~ ^- ]]; then
                paletteFile="$2"
                shift
            fi
            shift
            ;;
        -v|--variations)
            showVariations=true
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo "Invalid option: $1" >&2
            usage
            exit 1
            ;;
    esac
done

# Define default colors sorted
sortedColors=(
    "black"
    "brightBlack"
    "red"
    "brightRed"
    "green"
    "brightGreen"
    "yellow"
    "brightYellow"
    "blue"
    "brightBlue"
    "purple"
    "brightPurple"
    "cyan"
    "brightCyan"
    "white"
    "brightWhite"
    "foreground"
    "background"
)

# Define test colors for variations
testColors=(
    "black"
    "brightBlack"
    "white"
    "brightWhite"
    "foreground"
    "background"
)

# Check if theme should be displayed and palette file exists
if [[ "${showTheme}" == true && -f "${paletteFile}" ]]; then

    # Extract the palette name
    paletteName=$(grep -oP '"name":\s*"\K[^"]+' "${paletteFile}")

    # Declare an associative array for colors
    declare -A themeColors

    # Read JSON file and parse colors into an associative array
    while IFS="": read -r line; do

        # Extract the key (color name)
        key=$(echo "${line}" | grep -o '"[a-zA-Z0-9]*"' | tr -d '"')

        # Extract the value (color code)
        value=$(echo "${line}" | grep -o '#[A-Fa-f0-9]*')

        # Store the color in the associative array if both are found
        if [[ -n "${key}" && -n "${value}" ]]; then

            # Set theme color value
            themeColors[$key]=$value

            # Add color name to the end of sorted colors if not included
            if [[ ! " ${sortedColors[*]} " =~ " ${key} " ]]; then
                sortedColors+=("${key}")
            fi

        fi

    done < "${paletteFile}" # Read from the specified palette file

else

    # Inform user if palette file doesn't exist
    if [[ ! -f "${paletteFile}" ]]; then

        echo "Error: Palette file '${paletteFile}' not found. Skipping theme codes and colors." >&2

    fi

    # Clear colors if theme not shown
    unset themeColors

fi

# Define ANSI color codes for foreground
declare -A ansiCodesFg=(
    [black]=30
    [red]=31
    [green]=32
    [yellow]=33
    [blue]=34
    [purple]=35
    [cyan]=36
    [white]=37
    [foreground]=39
    [brightBlack]=90
    [brightRed]=91
    [brightGreen]=92
    [brightYellow]=93
    [brightBlue]=94
    [brightPurple]=95
    [brightCyan]=96
    [brightWhite]=97
    [background]=99
)

# Define ANSI color codes for background
declare -A ansiCodesBg=(
    [black]=40
    [red]=41
    [green]=42
    [yellow]=43
    [blue]=44
    [purple]=45
    [cyan]=46
    [white]=47
    [foreground]=49
    [brightBlack]=100
    [brightRed]=101
    [brightGreen]=102
    [brightYellow]=103
    [brightBlue]=104
    [brightPurple]=105
    [brightCyan]=106
    [brightWhite]=107
    [background]=109
)


# Convert HEX color to RGB
hexToRgb() {

    # Remove '#' from hex color and convert hex digits to decimals
    local hex=${1:1}
    local r=$((16#${hex:0:2}))
    local g=$((16#${hex:2:2}))
    local b=$((16#${hex:4:2}))

    # Output RGB values
    echo "$r;$g;$b"

}

# Define ANSI escape codes for formatting
ansiUnderscore="\e[4m"
ansiClear="\e[0m"
ansiInvert="\e[7m"
ansiHidden="\e[8m"


# Set color table header texts
if [[ -n "${themeColors[*]}" ]]; then

    # With theme colors from file
    tableColors="${ansiUnderscore}Name${ansiClear}\t"\
"${ansiUnderscore}Code (FG)${ansiClear}\t"\
"${ansiUnderscore}Code (BG)${ansiClear}\t"\
"${ansiUnderscore}ANSI Color${ansiClear}\t"\
"${ansiUnderscore}Theme Hex${ansiClear}\t"\
"${ansiUnderscore}Theme RGB${ansiClear}\t"\
"${ansiUnderscore}Theme Color${ansiClear}\n"

else

    # System ANSI colors only
    tableColors="${ansiUnderscore}Name${ansiClear}\t"\
"${ansiUnderscore}Code (FG)${ansiClear}\t"\
"${ansiUnderscore}Code (BG)${ansiClear}\t"\
"${ansiUnderscore}ANSI Color${ansiClear}\n"

fi

# Set background and foreground variation tables header names
tableBackground="${ansiUnderscore}Black (30)${ansiClear}\t"\
"${ansiUnderscore}Black (90)${ansiClear}\t"\
"${ansiUnderscore}White (37)${ansiClear}\t"\
"${ansiUnderscore}White (97)${ansiClear}\t"\
"${ansiUnderscore}Default (39)${ansiClear}\t"\
"${ansiUnderscore}Default (99)${ansiClear}\n"

tableForeground="${ansiUnderscore}Black (40)${ansiClear}\t"\
"${ansiUnderscore}Black (100)${ansiClear}\t"\
"${ansiUnderscore}White (47)${ansiClear}\t"\
"${ansiUnderscore}White (107)${ansiClear}\t"\
"${ansiUnderscore}Default (49)${ansiClear}\t"\
"${ansiUnderscore}Default (109)${ansiClear}\n"

# Loop through sorted colors to build the color table
for color in "${sortedColors[@]}"; do

    # Set background and foreground codes for the color
    codeBg=${ansiCodesBg[$color]}
    codeFg=${ansiCodesFg[$color]}

    # ANSI escape for background and foreground color
    ansiColorBg="\e[${codeBg}m"
    ansiColorFg="\e[${codeFg}m"

    # Check if the color is "foreground", then use escape code to invert it
    if [[ "$color" == "foreground" ]]; then

        # Invert background color for foreground
        ansiColorBgCorr="${ansiInvert}"

    else

        # Normal background color
        ansiColorBgCorr="${ansiColorBg}"

    fi

    # Define colored section for table
    ansiColor="${ansiColorBgCorr}     ${ansiClear}"

    # Resolve HEX and RGB codes and colors if theme colors is set
    if [[ -n "${themeColors[*]}" && "${themeColors[$color]}" ]]; then

        # Get hex value or set to N/A
        hex=${themeColors[$color]:-"N/A"}

        # Convert hex to RGB
        rgbValues=$(hexToRgb "$hex")

        # Format RGB string
        rgb="rgb(${rgbValues//;/,})"

        # Define hex color for display
        hexColor="\e[48;2;${rgbValues}m     ${ansiClear}"

        # Append row to table data
        tableColors+="${color}\t${codeFg}\t${codeBg}\t${ansiColor}\t${hex}\t${rgb}\t${hexColor}\n"

    else

        # Append row to table data
        tableColors+="${color}\t${codeFg}\t${codeBg}\t${ansiColor}\n"

    fi

    # Construct line for current color in variations tables if it has a code and enabled
    if [[ "${codeFg}" && "${codeBg}" && "${showVariations}" == true ]]; then

        # Initialize for new line
        backgroundLine=
        foregroundLine=

        # Loop through test colors for variations
        for testColor in "${testColors[@]}"; do

            # Set colors and correct for inverted foreground/background
            if [[ "$testColor" == "background" ]]; then
                if [[ "$color" == "background" ]]; then
                    ansiColorBgTestFg="${ansiHidden}"
                    ansiColorBgTestBg="${ansiColorBg}"
                    ansiColorFgTestBg="${ansiHidden}"
                    ansiColorFgTestFg="${ansiColorFg}"
                else
                    ansiColorBgTestFg="${ansiInvert}"
                    ansiColorBgTestBg="\e[${ansiCodesFg[$color]}m"
                    ansiColorFgTestBg="\e[${ansiCodesBg[$testColor]}m"
                    ansiColorFgTestFg="${ansiColorFg}"
                fi
            elif [[ "$testColor" == "foreground" ]]; then
                if [[ "$color" == "foreground" ]]; then
                    ansiColorBgTestFg="${ansiHidden}"
                    ansiColorBgTestBg="${ansiInvert}"
                    ansiColorFgTestBg="${ansiHidden}"
                    ansiColorFgTestFg="${ansiInvert}"
                else
                    ansiColorBgTestFg="\e[${ansiCodesFg[$testColor]}m"
                    ansiColorBgTestBg="${ansiColorBg}"
                    ansiColorFgTestBg="${ansiInvert}"
                    ansiColorFgTestFg="\e[${ansiCodesBg[$color]}m"
                fi
            else
                if [[ "$color" == "foreground" ]]; then
                    ansiColorBgTestFg="\e[${ansiCodesBg[$testColor]}m${ansiInvert}"
                    ansiColorBgTestBg="\e[${ansiCodesFg[$color]}m"
                    ansiColorFgTestBg="\e[${ansiCodesFg[$testColor]}m${ansiInvert}"
                    ansiColorFgTestFg="\e[${ansiCodesBg[$color]}m"
                else
                    ansiColorBgTestFg="\e[${ansiCodesFg[$testColor]}m"
                    ansiColorBgTestBg="${ansiColorBg}"
                    ansiColorFgTestBg="\e[${ansiCodesBg[$testColor]}m"
                    ansiColorFgTestFg="${ansiColorFg}"
                fi
            fi

            # Construct background and foreground lines for variations
            backgroundLine+="${ansiColorBgTestBg}${ansiColorBgTestFg}  Test Text  ${ansiClear}\t"
            foregroundLine+="${ansiColorFgTestBg}${ansiColorFgTestFg}  Test Text  ${ansiClear}\t"

        done

        # Append lines to respective tables
        tableBackground+="${backgroundLine}\n"
        tableForeground+="${foregroundLine}\n"

    fi

done

echo ""

# Print the terminal type
echo -e "Terminal: \e[3m${TERM}\e[0m"

# Print the theme name if set
if [[ -n "${paletteName}" ]]; then

    echo -e "Theme: \e[3m${paletteName}\e[0m"

fi

echo ""

# Print the ansi/hex color table
echo -e "${tableColors}" | column -t -s $'\t'

echo ""

# Print the variations tables if enabled
if [[ "${showVariations}" == true ]]; then

    echo -e "\e[3mBackground Color Variations Table\e[0m"

    echo ""

    # Print the background variations table
    echo -e "${tableBackground}" | column -t -s $'\t'

    echo ""

    echo -e "\e[3mText Color Variations Table\e[0m"

    echo ""

    # Print the text variations table
    echo -e "${tableForeground}" | column -t -s $'\t'

    echo ""

fi

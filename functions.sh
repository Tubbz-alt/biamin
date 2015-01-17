########################################################################
#                                                                      #
#                          1. FUNCTIONS                                #
#                    All program functions go here!                    #


# PRE-CLEANUP tidying function for buggy custom maps
# Used in MapCreate(), GX_Place(), NewSector()
CustomMapError() { 
    local ERROR_MAP=$1
    clear
    echo "Whoops! There is an error with your map file!
Either it contains unknown characters or it uses incorrect whitespace.
Recognized characters are: x . T @ H C
Please run game with --map argument to create a new template as a guide.

What to do?
1) rename $ERROR_MAP to ${ERROR_MAP}.error or
2) delete template file CUSTOM.map (deletion is irrevocable)."
    read -n 1 -p "Please select 1 or 2: " MAP_CLEAN_OPTS 2>&1
    case "$MAP_CLEAN_OPTS" in
	1 ) mv "${ERROR_MAP}" "${ERROR_MAP}.error" ;
	    echo -e "\nCustom map file moved to ${ERROR_MAP}.error" ;;
	2 ) rm -f "${ERROR_MAP}" ;
	    echo -e "\nCustom map deleted!" ;;
	* ) Die "\nBad option! Quitting.." ;;
    esac
    sleep 4
}


#-----------------------------------------------------------------------
# SaveCurrentSheet()
# Saves current game values to CHARSHEET file (overwriting)
#-----------------------------------------------------------------------
SaveCurrentSheet() { 
    echo "CHARACTER: $CHAR
RACE: $CHAR_RACE
BATTLES: $CHAR_BATTLES
EXPERIENCE: $CHAR_EXP
LOCATION: $CHAR_GPS
HEALTH: $CHAR_HEALTH
ITEMS: $CHAR_ITEMS
KILLS: $CHAR_KILLS
HOME: $CHAR_HOME
GOLD: $CHAR_GOLD
TOBACCO: $CHAR_TOBACCO
FOOD: $CHAR_FOOD
BBSMSG: $BBSMSG
VAL_GOLD: $VAL_GOLD
VAL_TOBACCO: $VAL_TOBACCO
VAL_CHANGE: $VAL_CHANGE
STARVATION: $STARVATION
TURN: $TURN
INV_ALMANAC: $INV_ALMANAC" > "$CHARSHEET"
}

#-----------------------------------------------------------------------
# Intro()
# Intro function basically gets the game going
# Used: runtime section. 
#-----------------------------------------------------------------------
Intro() { 
    SHORTNAME=$(Capitalize "$CHAR")  # Create capitalized FIGHT CHAR name
    MapCreate                        # Create session map in $MAP  
    HotzonesDistribute "$CHAR_ITEMS" # Place items randomly in map
    WORLDCHANGE_COUNTDOWN=0          # WorldChange Counter (0 or negative value allow changes)    
    WorldPriceFixing                 # Set all prices
    GX_Intro 60                      # With countdown 60 seconds
    NODICE=1                         # Do not roll on first section after loading/starting a game in NewSector()
}

################### GAME SYSTEM #################

#-----------------------------------------------------------------------
# Reseed RANDOM. Needed only once at start, so moved to separate section
case "$OSTYPE" in
    openbsd* ) RANDOM=$(date '+%S') ;;
    *)         RANDOM=$(date '+%N') ;;
esac

# TODO:
#  ? Move it to runtime section
#  ? Make separate file with system-depended things
#  ? Use /dev/random or /dev/urandom
#-----------------------------------------------------------------------
# SEED=$(head -1 /dev/urandom | od -N 1 | awk '{ print $2 }'| sed s/^0*//)
# RANDOM=$SEED
# Suggestion from: http://tldp.org/LDP/abs/html/randomvar.html
#-----------------------------------------------------------------------

#-----------------------------------------------------------------------
# RollDice()
# Arguments: $DICE_SIZE (int)
# Used: RollForEvent(), RollForHealing(), etc
#-----------------------------------------------------------------------
RollDice() {     
    DICE_SIZE=$1         # DICE_SIZE used in RollForEvent()
    DICE=$((RANDOM%$DICE_SIZE+1))
}

#-----------------------------------------------------------------------
# RollDice()
# Temp wrapper for RollDice()
# Arguments: $DICE_SIZE (int)
# Used: RollForEvent(), RollForHealing(), etc
#-----------------------------------------------------------------------
RollDice2() { RollDice $1 ; echo "$DICE" ; } 

#-----------------------------------------------------------------------
# DisplayCharsheet() 
# Display character sheet.
# Used: NewSector(), FightMode()
#-----------------------------------------------------------------------
DisplayCharsheet() { 
    local MURDERSCORE=$(bc <<< "if ($CHAR_KILLS > 0) {scale=zero; 100 * $CHAR_KILLS/$CHAR_BATTLES } else 0" ) # kill/fight percentage
    local RACE=$(Capitalize "$CHAR_RACE_STR")   # Capitalize
    local CHARSHEET_INV_STR="$CHAR_GOLD Gold, $CHAR_TOBACCO Tobacco, $CHAR_FOOD Food" # Create Inventory string 
    (( INV_ALMANAC == 1 )) && CHARSHEET_INV_STR+=", Almanac" # Add below as necessary..
    GX_CharSheet
    cat <<EOF
 Character:                 $CHAR ($RACE)
 Health Points:             $CHAR_HEALTH
 Experience Points:         $CHAR_EXP
 Current Location:          $CHAR_GPS ($PLACE)
 Number of Battles:         $CHAR_BATTLES
 Enemies Slain:             $CHAR_KILLS ($MURDERSCORE%)
 Items found:               $CHAR_ITEMS of $MAX_ITEMS
 Special Skills:            Healing $HEALING, Strength $STRENGTH, Accuracy $ACCURACY, Flee $FLEE
 Inventory:                 $CHARSHEET_INV_STR
 Current Date:              $BIAMIN_DATE_STR
 
EOF

    case "$INV_ALMANAC" in		# Define prompt
	1) MakePrompt '(D)isplay Race Info;(A)lmanac;(C)ontinue;(Q)uit'  ;; # Player has    Almanac
	*) MakePrompt '(D)isplay Race Info;(A)ny key to continue;(Q)uit' ;; # Player hasn't Almanac
    esac
    case $(Read) in
	d | D ) GX_Races && PressAnyKey ;;
	a | A ) ((INV_ALMANAC)) && Almanac ;;
	q | Q ) CleanUp ;;
    esac
}


# GAME ACTION: REST
RollForHealing() { # Used in Rest()
    RollDice 6
    echo -e "Rolling for healing: D6 <= $HEALING\nROLL D6: $DICE"
    if ((DICE > HEALING)) ; then
	echo "$2"
    else
	(( CHAR_HEALTH += $1 ))
	echo "You slept well and gained $1 Health."
    fi
    Sleep 2
}   # Return to Rest()

#-----------------------------------------------------------------------
# Rest()
# Game balancing can also be done here, if you think players receive
# too much/little health by resting.
# Arguments: $SCENARIO(char)
# Used: NewSector()
#-----------------------------------------------------------------------
Rest() {  
    PLAYER_RESTING=1 # Set flag for FightMode()
    RollDice 100
    GX_Rest
    echo "$HR"
    case "$1" in
	H ) if (( CHAR_HEALTH < 100 )); then
		CHAR_HEALTH=100
		echo "You slept well in your own bed. Health restored to 100."
	    else
		echo "You slept well in your own bed, and woke up to a beautiful day."
	    fi
	    ;;
	x ) RollForEvent 60 "fight" && FightMode || (( PLAYER_RESTING != 3 )) && RollForHealing 5  "The terrors of the mountains kept you awake all night.." ;;
	. ) RollForEvent 30 "fight" && FightMode || (( PLAYER_RESTING != 3 )) && RollForHealing 10 "The dangers of the roads gave you little sleep if any.." ;;
	T ) RollForEvent 15 "fight" && FightMode || (( PLAYER_RESTING != 3 )) && RollForHealing 15 "The vices of town life kept you up all night.." ;;
	@ ) RollForEvent 35 "fight" && FightMode || (( PLAYER_RESTING != 3 )) && RollForHealing 5  "Possibly dangerous wood owls kept you awake all night.." ;;
	C ) RollForEvent 5  "fight" && FightMode || (( PLAYER_RESTING != 3 )) && RollForHealing 35 "Rowdy castle soldiers on a drinking binge kept you awake.." ;;
    esac
    unset PLAYER_RESTING # Reset flag
    Sleep 2
}   # Return to NewSector()

# THE GAME LOOP

#-----------------------------------------------------------------------
# RollForEvent()
# Arguments: $DICE_SIZE(int), $EVENT(string)
# Used: Rest(), CheckForFight()
#-----------------------------------------------------------------------
RollForEvent() {     
    echo -e "Rolling for $2: D${DICE_SIZE} <= $1\nD${DICE_SIZE}: $DICE" 
    Sleep 1.5
    (( DICE <= $1 )) && return 0 || return 1
}   # Return to NewSector() or Rest()


#-----------------------------------------------------------------------
# ColorConfig()
# Define colors and escape sequences
# Arguments: $COLOR (int)
#-----------------------------------------------------------------------
ColorConfig() {
    case "$1" in
	1 ) echo "Enabling color for maps!" ;;
	0 ) echo "Enabling old black-and-white version!" ;;
	* ) echo -en "\nWe need to configure terminal colors for the map!
Please note that a colored symbol is easier to see on the world map.
Back in a minute was designed for white text on black background.
Does \033[1;33mthis text appear yellow\033[0m without any funny characters?
Do you want color? [Y/N]: "
	    case $(Read) in
		n | N ) COLOR=0 ; echo -e "\nDisabling color! Edit $GAMEDIR/config to change this setting.";;
		* )     COLOR=1 ; echo -e "\nEnabling color!" ;;
	    esac
	    # BUG! Falls in OpenBSD. TODO replace to awk. #kstn
	    sed -i"~" "/^COLOR:/s/^.*$/COLOR: $COLOR/g" "$GAMEDIR/config" # MacOS fix http://stackoverflow.com/questions/7573368/in-place-edits-with-sed-on-os-x
	    Sleep 2;;
    esac
    if ((COLOR == 1)) ; then
	YELLOW='\033[1;33m' # Used in MapNav() and GX_Map()
	RESET='\033[0;39m'
    fi
    # Define escape sequences
    # TODO replace to tput or similar
    CLEAR_LINE="\e[1K\e[80D" # \e[1K - erase to the start of line \e[80D - move cursor 80 columns backward
}
#                           END FUNCTIONS                              #
#                                                                      #
#                                                                      #
########################################################################


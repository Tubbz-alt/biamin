########################################################################
#                             BiaminSetup                              #
#                    Load charsheet or make new char                   #

# Set abilities according to race (each equal to 12) + string var used frequently
RACES=(
    "Race   Healing Strength Accuracy Flee Offset_Gold Offset_Tobacco" # Dummy - we haven't RACE == 0
    "human  3       3        3        3     2          -3"
    "elf    4       3        4        1    -3           2" 
    "dwarf  2       5        3        2     2          -3"
    "hobbit 4       1        4        3    -3           2"
)

#-----------------------------------------------------------------------
# BiaminSetup_SetRaceAbilities()
# Load race abilities from $RACES
# Arguments: $CHAR_RACE (int)
#-----------------------------------------------------------------------
BiaminSetup_SetRaceAbilities() {
    read -r CHAR_RACE_STR HEALING STRENGTH ACCURACY FLEE OFFSET_GOLD OFFSET_TOBACCO <<< ${RACES[$1]}
}

#-----------------------------------------------------------------------
# BiaminSetup_SetItemsAbilities
# Load bonuses from magic items (items defined in Items.sh)
# Arguments: $CHAR_ITEMS (int)
#-----------------------------------------------------------------------
BiaminSetup_SetItemsAbilities() {
    HaveItem "$EMERALD_OF_NARCOLEPSY" && ((HEALING++))
    HaveItem "$FAST_MAGIC_BOOTS"      && ((FLEE++))
    HaveItem "$TWO_HANDED_BROADSWORD" && ((STRENGTH++))
    HaveItem "$STEADY_HAND_BREW"      && ((ACCURACY++))
}

#-----------------------------------------------------------------------
# BiaminSetup_UpdateOldSaves()
# Sequence for updating older charsheets to later additions (compatibility)
# Arguments: $CHARSHEET(string)
# Used: BiaminSetup_LoadCharsheet()
#-----------------------------------------------------------------------
BiaminSetup_UpdateOldSaves() {	
    grep -Eq '^HOME:' "$1"        || echo "HOME: $START_LOCATION" >> $1
    grep -Eq '^GOLD:' "$1"        || echo "GOLD: 10" >> $1
    grep -Eq '^TOBACCO:' "$1"     || echo "TOBACCO: 10" >> $1
    grep -Eq '^FOOD:' "$1"        || echo "FOOD: 10" >> $1
    grep -Eq '^BBSMSG:' "$1"      || echo "BBSMSG: 0" >> $1
    grep -Eq '^STARVATION:' "$1"  || echo "STARVATION: 0" >> $1
    # TODO use  OFFSET_{GOLD,TOBACCO} 
    grep -Eq '^VAL_GOLD:' "$1"    || echo "VAL_GOLD: 1" >> $1
    grep -Eq '^VAL_TOBACCO:' "$1" || echo "VAL_TOBACCO: 1" >> $1
    grep -Eq '^VAL_CHANGE:' "$1"  || echo "VAL_CHANGE: 0.25" >> $1
    # Time 
    grep -Eq '^TURN:' "$1"        || echo "TURN: $(TurnFromDate)" >> $1
    # Almanac
    grep -Eq '^ALMANAC:' "$1"     || echo "ALMANAC: 0" >> $1
}

#-----------------------------------------------------------------------
# BiaminSetup_SanityCheck()
# Checks if $1 in GPS format ([A-R][1-15])
# Arguments: $CHAR_LOC(string)
# Used: BiaminSetup_LoadCharsheet()
#-----------------------------------------------------------------------
BiaminSetup_SanityCheck(){
    local CHAR_LOC_LEN CHAR_LOC_X CHAR_LOC_Y
    read CHAR_LOC_LEN CHAR_LOC_X CHAR_LOC_Y <<< $(awk '{print length($0) " " substr($0,0,1) " " substr($0,2)}' <<< "$1")
    (( CHAR_LOC_LEN < 1 )) && Die " Error! Too less characters in $CHAR_LOC\n Start location is 2-3 alphanumeric chars [A-R][1-15], e.g. C2 or P13"
    (( CHAR_LOC_LEN > 3 )) && Die " Error! Too many characters in $CHAR_LOC\n Start location is 2-3 alphanumeric chars [A-R][1-15], e.g. C2 or P13"
    echo -n "Sanity check.."
    case "$CHAR_LOC_X" in
	A | B | C | D | E | F | G | H | I | J | K | L | M | N | O | P | Q | R ) echo -n ".." ;;
	* ) Die "\n Error! Start location X-Axis $CHAR_LOC_X must be a CAPITAL alphanumeric A-R letter!" ;;
    esac
    case "$CHAR_LOC_Y" in
	1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 | 12 | 13 | 14 | 15 ) echo ".. Done!" ;;
	* ) Die "\n Error! Start location Y-Axis $CHAR_LOC_Y is too big or too small!";;
    esac
    # End of SANITY check, everything okay!
    CHAR_GPS="$1"
    CHAR_HOME="$1"
}

BiaminSetup_LoadCharsheet() {
    echo -en " Welcome back, $CHAR!\n Loading character sheet ..." # -n for 80x24, DO NOT REMOVE IT #kstn	
    BiaminSetup_UpdateOldSaves "$CHARSHEET"
	local CHAR_TMP=$(awk '
                  { 
                   if (/^CHARACTER:/)  { RLENGTH = match($0,/: /);
                  	                 CHARACTER = substr($0, RLENGTH+2); }
                   if (/^RACE:/)       { RACE= $2 }
                   if (/^BATTLES:/)    { BATTLES = $2 }
                   if (/^EXPERIENCE:/) { EXPERIENCE = $2 }
                   if (/^LOCATION:/)   { LOCATION = $2 }
                   if (/^HEALTH:/)     { HEALTH = $2 }
                   if (/^ITEMS:/)      { ITEMS = $2 }
                   if (/^KILLS:/)      { KILLS = $2 }
                   if (/^HOME:/)       { HOME = $2 }
                   if (/^GOLD:/)       { GOLD = $2 }
                   if (/^TOBACCO:/)    { TOBACCO = $2 }
                   if (/^FOOD:/)       { FOOD = $2 }
                   if (/^BBSMSG:/)     { BBSMSG = $2 }
                   if (/^VAL_GOLD:/)   { VAL_GOLD = $2 }
                   if (/^VAL_TOBACCO:/){ VAL_TOBACCO = $2 }
                   if (/^VAL_CHANGE:/) { VAL_CHANGE = $2 }
                   if (/^STARVATION:/) { STARVATION = $2 }
                   if (/^TURN:/)        { TURN= $2 }
                   if (/^ALMANAC:/)     { ALMANAC = $2 }
                 }
                 END { 
                 print CHARACTER ";" RACE ";" BATTLES ";" EXPERIENCE ";" LOCATION ";" HEALTH ";" ITEMS ";" KILLS ";" HOME ";" GOLD ";" TOBACCO ";" FOOD ";" BBSMSG ";" VAL_GOLD ";" VAL_TOBACCO ";" VAL_CHANGE ";" STARVATION ";" TURN ";" ALMANAC ";"
                 }' $CHARSHEET )
	IFS=";" read -r CHAR CHAR_RACE CHAR_BATTLES CHAR_EXP CHAR_GPS CHAR_HEALTH CHAR_ITEMS CHAR_KILLS CHAR_HOME CHAR_GOLD CHAR_TOBACCO CHAR_FOOD BBSMSG VAL_GOLD VAL_TOBACCO VAL_CHANGE STARVATION TURN ALMANAC <<< "$CHAR_TMP"
	unset CHAR_TMP
    # If character is dead, don't fool around..
    (( CHAR_HEALTH <= 0 )) && Die "\nWhoops!\n $CHAR's health is $CHAR_HEALTH!\nThis game does not support necromancy, sorry!"
}

#-----------------------------------------------------------------------
# BiaminSetup_MakeBaseChar()
# Sketch. Main idea is to exclude BiaminSetup_UpdateOldSaves() but
# make basic char with default settings (gold, values, food, etc) and
# then BiaminSetup_LoadCharsheet() or BiaminSetup_MakeNewChar()
#-----------------------------------------------------------------------
BiaminSetup_MakeBaseChar() {
# CHARACTER: $CHAR
# RACE: $CHAR_RACE
    CHAR_BATTLES=0
# EXPERIENCE: $CHAR_EXP
    CHAR_GPS="$START_LOCATION"
    CHAR_HEALTH=100
    CHAR_ITEMS=0
    CHAR_KILLS=0
    CHAR_HOME="$START_LOCATION"
# GOLD: $CHAR_GOLD
# TOBACCO: $CHAR_TOBACCO
    CHAR_FOOD=$( bc <<< "$(RollDice2 16) + 4" ) # Determine initial food stock (D16 + 4) - player has 5 food minimum
    BBSMSG=0
    VAL_GOLD=1 	                # Initial Value of Currencies
    VAL_TOBACCO=1	        # Initial Value of Currencies
    VAL_CHANGE=0.25	        # Initial Value of Currencies
    STARVATION=0
    TURN=$(TurnFromDate)	# Count turn from current date
    ALMANAC=0 			# Locked by-default
}

BiaminSetup_MakeNewChar() {
	echo " $CHAR is a new character!"
	CHAR_BATTLES=0
	CHAR_EXP=0
	CHAR_HEALTH=100
	CHAR_ITEMS=0
	CHAR_KILLS=0
	BBSMSG=0
	STARVATION=0;
	TURN=$(TurnFromDate) # Player starts from translated _real date_. Afterwards, turns increment.
	ALMANAC=0
	GX_Races
	read -sn 1 -p " Select character race (1-4): " CHAR_RACE 2>&1

	# IDEA - why not difference all 4 races by various tobacco/gold offsets ? #kstn
	#            gold            tobacco                                      # Good idea, implement it
	#             \/                /\                                        # as long as u detail the math
	# dwarves |  most         | the smallest                                  # below :) - Sigge
	# man     |  more         | smaller
	# elves   |  smaller      | more
	# hobbits |  the smallest | most
	#             
	case "$CHAR_RACE" in
	    2 ) echo "You chose to be an ELF"                 && OFFSET_GOLD=-3 && OFFSET_TOBACCO=2 ;;
	    3 ) echo "You chose to be a DWARF"                && OFFSET_GOLD=2 && OFFSET_TOBACCO=-3 ;;
	    4 ) echo "You chose to be a HOBBIT"               && OFFSET_GOLD=-3 && OFFSET_TOBACCO=2 ;;
	    * ) CHAR_RACE=1 && echo "You chose to be a HUMAN" && OFFSET_GOLD=2 && OFFSET_TOBACCO=-3 ;;
	esac

	# WEALTH formula = D20 + (D6 * CLASS OFFSET)
	CHAR_GOLD=$(    bc <<< "var = ( $(RollDice2 20) + ($OFFSET_GOLD    * $(RollDice2 6)) ); if (var > 0) var else 0" )
	CHAR_TOBACCO=$( bc <<< "var = ( $(RollDice2 20) + ($OFFSET_TOBACCO * $(RollDice2 6)) ); if (var > 0) var else 0" )

	# Determine initial food stock (D16 + 4) - player has 5 food minimum
	CHAR_FOOD=$( bc <<< "$(RollDice2 16) + 4" )
	# Set initial Value of Currencies
	VAL_GOLD=1
	VAL_TOBACCO=1
	VAL_CHANGE=0.25
	
	# Add location info
	CHAR_GPS="$START_LOCATION"
	CHAR_HOME="$START_LOCATION"
	# If there IS a CUSTOM.map file, ask where the player would like to start
	# TODO move it to LoadCustomMap()
	if [[ "$CUSTOM_MAP" ]] ; then
	    START_LOCATION=$(awk '{ if (/^START LOCATION:/) { print $2; exit; } print "'$START_LOCATION'"; }' <<< "$CUSTOM_MAP" )
	    read -p " HOME location for custom maps (ENTER for default $START_LOCATION): " CHAR_LOC 2>&1
	    [[ ! -z "$CHAR_LOC" ]] && BiaminSetup_SanityCheck "$CHAR_LOC" 	# Use user input as start location.. but first SANITY CHECK
	fi
	echo " Creating fresh character sheet for $CHAR ..."
	SaveCurrentSheet
}

#-----------------------------------------------------------------------
# BiaminSetup()
# Gets char name and load charsheet or make new char
# Used: runtime.sh
# TODO: Argumens: $CHAR(string)
#-----------------------------------------------------------------------
BiaminSetup() { 
    # Set CHARSHEET variable to gamedir/char.sheet (lowercase)
    CHARSHEET="$GAMEDIR/$(echo "$CHAR" | tr '[:upper:]' '[:lower:]' | tr -d " ").sheet"
    if [[ -f "$CHARSHEET" ]] ; then
	BiaminSetup_LoadCharsheet
    else
	BiaminSetup_MakeNewChar
    fi
    sleep 2
    BiaminSetup_SetRaceAbilities  "$CHAR_RACE"
    BiaminSetup_SetItemsAbilities "$CHAR_ITEMS"
    # If Cheating is disabled (in CONFIGURATION) restrict health to 150
    (( DISABLE_CHEATS == 1 )) && (( CHAR_HEALTH >= 150 )) && CHAR_HEALTH=150
}
#                                                                      #
#                                                                      #
########################################################################


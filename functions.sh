########################################################################
#                                                                      #
#                          1. FUNCTIONS                                #
#                    All program functions go here!                    #

Die() { echo -e "$1" && exit 1 ;}

Capitalize() { awk '{ print substr(toupper($0), 1,1) substr($0, 2); }' <<< "$*" ;} # Capitalize $1

Toupper() { awk '{ print toupper($0); }' <<< "$*" ;} # Convert $* to uppercase

Strlen() { awk '{print length($0);}' <<< "$*" ;} # Return lenght of string $*. "Strlen" is traditional name :)

MvAddStr() { tput cup "$1" "$2"; printf "%s" "$3"; } # move cursor to $1 $2 and print $3. "mvaddstr" is name similar function from ncurses.h

#-----------------------------------------------------------------------
# Ordial()
# Add postfix to $1 (NUMBER)
# Arguments: $1(int)
#-----------------------------------------------------------------------
Ordial() { 
    grep -Eq '[^1]?1$'  <<< "$1" && echo "${1}st" && return 0
    grep -Eq '[^1]?2$'  <<< "$1" && echo "${1}nd" && return 0
    grep -Eq '[^1]?3$'  <<< "$1" && echo "${1}rd" && return 0
    grep -Eq '^[0-9]+$' <<< "$1" && echo "${1}th" && return 0
    Die "Bug in Ordial with ARG $1"
}

#-----------------------------------------------------------------------
# MakePrompt()
# Make centered to 79px promt from $@. Arguments should be separated by ';'
# Arguments: $PROMPT(string)
#-----------------------------------------------------------------------
MakePrompt() { 
    awk '   BEGIN { FS =";" }
        {
            MAXLEN = 79;
            COUNT = NF; 
            for ( i=1; i<= NF; i++ ) { STRLEN += length($i); }
            if ( STRLEN > MAXLEN ) { exit 1 ; }
            SPACES = MAXLEN - STRLEN;
            REMAINDER = SPACES % (NF + 1 ) ;
            SPACER = (SPACES - REMAINDER ) / (NF + 1) ;
            if ( REMAINDER % 2  == 1 ) { REMAINDER -= 1 ; }
            SPACES_IN = REMAINDER / 2 ;
            while (SPACES_IN-- > 0 ) { INTRO = INTRO " "; }
            while (SPACER-- > 0 ) { SEPARATOR = SEPARATOR " " }
            STR = INTRO; 
            for ( i=1; i<=NF; i++ ) { STR = STR SEPARATOR $i; }
            STR = STR SEPARATOR INTRO
        }
        END { printf STR; }' <<< "$@" || Die "Too long promt >>>$*<<<"
#BACKUP END { print STR; }' <<< "$@" || Die "Too long promt >>>$*<<<"
}

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
    (( TURN == 0 )) && TodaysDate    # Fetch today's date in Warhammer calendar (Used in DisplayCharsheet() and FightMode() )
    MapCreate                        # Create session map in $MAP  
    HotzonesDistribute "$CHAR_ITEMS" # Place items randomly in map
    WORLDCHANGE_COUNTDOWN=0          # WorldChange Counter (0 or negative value allow changes)    
    WorldPriceFixing                 # Set all prices
    GX_Intro                         # With countdown
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
    MURDERSCORE=$(bc <<< "if ($CHAR_KILLS > 0) {scale=zero; 100 * $CHAR_KILLS/$CHAR_BATTLES } else 0" ) # kill/fight percentage
    local RACE=$(Capitalize "$CHAR_RACE_STR") # Capitalize
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
 Inventory:                 $CHAR_GOLD Gold, $CHAR_TOBACCO Tobacco, $CHAR_FOOD Food
 Current Date:              $TODAYS_DATE_STR
 Turn (DEBUG):              $TURN (don't forget to remove it :) ) 
 Biamin Date:               $BIAMIN_DATE_STR
EOF
    case "$INV_ALMANAC" in		# Define prompt
	1) MakePrompt '(D)isplay Race Info;(A)lmanac;(C)ontinue;(Q)uit'  ;; # Player has "unlocked" Almanac
	*) MakePrompt '(D)isplay Race Info;(A)ny key to continue;(Q)uit' ;; # Player does not have Almanac
    esac
    case $(Read) in
	d | D ) GX_Races && PressAnyKey ;;
	a | A ) ((INV_ALMANAC)) && Almanac ;;
	q | Q ) CleanUp ;;
    esac
}

#-----------------------------------------------------------------------
# Death()
# Used: FightMode()
# TODO: also should be used in check-for-starvation
#-----------------------------------------------------------------------
Death() { 
    GX_Death
    echo " The $BIAMIN_DATE_STR:"
    echo " In such a short life, this sorry $CHAR_RACE_STR gained $CHAR_EXP Experience Points."
    local COUNTDOWN=20
    while (( COUNTDOWN > 0 )); do
	echo -en "${CLEAR_LINE} We honor $CHAR with $COUNTDOWN secs silence." 
    	read -sn 1 -t 1 && break || ((COUNTDOWN--))
    done
    unset COUNTDOWN 
    #echo "$CHAR_EXP;$CHAR;$CHAR_RACE;$CHAR_BATTLES;$CHAR_KILLS;$CHAR_ITEMS;$TODAYS_DATE;$TODAYS_MONTH;$TODAYS_YEAR" >> "$HIGHSCORE"
    echo "$CHAR_EXP;$CHAR;$CHAR_RACE;$CHAR_BATTLES;$CHAR_KILLS;$CHAR_ITEMS;$DAY;$MONTH;$(Ordial $YEAR)" >> "$HIGHSCORE"
    rm -f "$CHARSHEET" # A sense of loss is important for gameplay:)
    unset CHARSHEET CHAR CHAR_RACE CHAR_HEALTH CHAR_EXP CHAR_GPS SCENARIO CHAR_BATTLES CHAR_KILLS CHAR_ITEMS # Zombie fix     # Do we need it ????
    # TODO: add showing Highscore list here
    CleanUp
}

# GAME ACTION: REST
RollForHealing() { # Used in Rest()
    RollDice 6
    echo -e "Rolling for healing: D6 <= $HEALING\nROLL D6: $DICE"
    # TODO!!! Check it - ( (( CHAR_HEALTH += $1 )) && echo "You slept well and gained $1 Health." ) - shouldn't that be not () but {} ??? #kstn
    ((DICE > HEALING)) && echo "$2" || ( (( CHAR_HEALTH += $1 )) && echo "You slept well and gained $1 Health." )
    ((TURN++))
    sleep 2
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
	    ((TURN++))
	    ;;
	x ) RollForEvent 60 "fight" && FightMode || [ -n $DICE ] && [[ $DICE != 111 ]] && RollForHealing 5  "The terrors of the mountains kept you awake all night.." ;;
	. ) RollForEvent 30 "fight" && FightMode || [ -n $DICE ] && [[ $DICE != 111 ]] && RollForHealing 10 "The dangers of the roads gave you little sleep if any.." ;;
	T ) RollForEvent 15 "fight" && FightMode || [ -n $DICE ] && [[ $DICE != 111 ]] && RollForHealing 15 "The vices of town life kept you up all night.." ;;
	@ ) RollForEvent 35 "fight" && FightMode || [ -n $DICE ] && [[ $DICE != 111 ]] && RollForHealing 5  "Possibly dangerous wood owls kept you awake all night.." ;;
	C ) RollForEvent 5  "fight" && FightMode || [ -n $DICE ] && [[ $DICE != 111 ]] && RollForHealing 35 "Rowdy castle soldiers on a drinking binge kept you awake.." ;;
    esac
    unset PLAYER_RESTING # Reset flag
    sleep 2
}   # Return to NewSector()

# THE GAME LOOP


#-----------------------------------------------------------------------
# RollForEvent()
# Arguments: $DICE_SIZE(int), $EVENT(string)
# Used: Rest(), CheckForFight()
#-----------------------------------------------------------------------
RollForEvent() {     
    echo -e "Rolling for $2: D${DICE_SIZE} <= $1\nD${DICE_SIZE}: $DICE" 
    sleep 2
    (( DICE <= $1 )) && return 0 || return 1
}   # Return to NewSector() or Rest()

#-----------------------------------------------------------------------
# Marketplace_Merchant()
# Used: GoIntoTown()
#-----------------------------------------------------------------------
Marketplace_Merchant() {
    # If this is a "freshly entered" town, re-do prices
    if [ -z "$MERCHANT" ] || [ "$MERCHANT" != "$CHAR_GPS" ] ; then
	# "Name" the current merchant as char GPS location
	MERCHANT="$CHAR_GPS"

	# Set prices at defaults
    MERCHANT_FxG=$PRICE_FxG && MERCHANT_FxT=$PRICE_FxT && MERCHANT_GxT=$PRICE_GxT && MERCHANT_GxF=$PRICE_GxF && MERCHANT_TxG=$PRICE_TxG && MERCHANT_TxF=$PRICE_TxF
    
	# Create semi-random profit/discount margin
	RollDice 3
	local MERCHANT_MARGIN=$(( bc <<< "scale=2;$DICE*$VAL_CHANGE" ))

	# Add positive and negative margins to..
	RollDice 3
	case "$DICE" in                                                               # Merchant WANTS to buy and only reluctantly sells:
	    1 ) MERCHANT_FxG=$(( bc <<< "scale=2;$MERCHANT_FxG+$MERCHANT_MARGIN" ))   # Food (player's cost in gold purchasing food)
			MERCHANT_GxF=$(( bc <<< "scale=2;$MERCHANT_GxF-$MERCHANT_MARGIN" ))   # Food (player's discount in food purchasing gold) 
			MERCHANT_FxT=$(( bc <<< "scale=2;$MERCHANT_FxT+$MERCHANT_MARGIN" ))
			MERCHANT_TxF=$(( bc <<< "scale=2;$MERCHANT_TxF-$MERCHANT_MARGIN" ))
			MERCHANT_FxI=$(( bc <<< "scale=2;$MERCHANT_FxI+$MERCHANT_MARGIN" ))
			MERCHANT_IxF=$(( bc <<< "scale=2;$MERCHANT_IxF-$MERCHANT_MARGIN" )) ;;
		2 ) MERCHANT_TxG=$(( bc <<< "scale=2;$MERCHANT_TxG+$MERCHANT_MARGIN" ))   # Tobacco (player's cost in gold purchasing tobacco)
			MERCHANT_GxT=$(( bc <<< "scale=2;$MERCHANT_GxT-$MERCHANT_MARGIN" ))   # Tobacco (player's discount in tobacco purchasing gold) 
			MERCHANT_TxF=$(( bc <<< "scale=2;$MERCHANT_TxF+$MERCHANT_MARGIN" ))
			MERCHANT_FxT=$(( bc <<< "scale=2;$MERCHANT_FxT-$MERCHANT_MARGIN" ))
			MERCHANT_TxI=$(( bc <<< "scale=2;$MERCHANT_TxI+$MERCHANT_MARGIN" ))
			MERCHANT_IxT=$(( bc <<< "scale=2;$MERCHANT_IxT-$MERCHANT_MARGIN" )) ;;
		3 ) MERCHANT_GxF=$(( bc <<< "scale=2;$MERCHANT_GxF+$MERCHANT_MARGIN" ))   # Gold (player's cost in food purchasing gold)
			MERCHANT_FxG=$(( bc <<< "scale=2;$MERCHANT_FxG-$MERCHANT_MARGIN" ))   # Gold (player's discount in gold purchasing food)
			MERCHANT_GxT=$(( bc <<< "scale=2;$MERCHANT_GxT+$MERCHANT_MARGIN" ))
			MERCHANT_TxG=$(( bc <<< "scale=2;$MERCHANT_TxG-$MERCHANT_MARGIN" ))
			MERCHANT_GxI=$(( bc <<< "scale=2;$MERCHANT_GxI+$MERCHANT_MARGIN" ))
			MERCHANT_IxG=$(( bc <<< "scale=2;$MERCHANT_IxG-$MERCHANT_MARGIN" )) ;;
	esac
	
	# Merchant sell this item (but will buy e.g. fur, tusks etc.)
	RollDice 4
	case "$DICE" in
		1 ) MERCHANT_ITEM="Health Potion (5 HP)" ;;
		2 ) MERCHANT_ITEM="Health Potion (10 HP)" ;;
		3 ) MERCHANT_ITEM="Health Potion (15 HP)" ;;
		4 ) MERCHANT_ITEM="Health Potion (20 HP)" ;;
	esac
	(( ALMANAC == 0 )) && MERCHANT_ITEM="Almanac"	
	fi
    # Merchant Loop
    while (true) ; do
	GX_Marketplace_Merchant
	local M_Y=4
	local MERCHANT_MSG=("" "weather-beaten Traveller!" "galant Elf of the Forests!" "fierce master Dwarf!" "young master Hobbit!") # [0] is dummy
	tput sc && MvAddStr $M_Y 4 "Oye there, ${MERCHANT_MSG[$CHAR_RACE]}"
	local MERCHANT_MSG=( "" "" "" "" "" "Me and my Caravan travel far and wide" "to provide the Finest Merchandise" "in the Realm, and at the best"
	    "possible prices! I buy everything" "and sell only the best, 'tis true!" "What are you looking for?" )  && (( M_Y++ )) # [0-4] are dummies
	while (( M_Y <= 10 )) ; do
	    MvAddStr $M_Y 4 "${MERCHANT_MSG[$M_Y]}"
	    (( M_Y++ ))
	done
	tput rc
	local MERCHANDISE && local MERCHANTVAR
	read -sn 1 -p "$(MakePrompt '(F)ood;(T)obacco;(G)old;(I)tems;(N)othing')" MERCHANTVAR 2>&1
	GX_Marketplace_Merchant
	tput sc
    case "$MERCHANTVAR" in
	    F | f ) MERCHANDISE="Food"
				MvAddStr 7 4 "$MERCHANT_FxG Gold or $MERCHANT_FxT Tobacco."           # FxG, FxT (sell for gold/tobacco)
				MvAddStr 10 4 "for $MERCHANT_GxF Gold or $MERCHANT_TxF Tobacco each!" # GxF, TxF (buy  for food/tobacco)
				;;
	    T | t ) MERCHANDISE="Tobacco"
				MvAddStr 7 4 "$MERCHANT_TxG Gold or $MERCHANT_TxF Food."              # TxG, TxF
				MvAddStr 10 4 "for $MERCHANT_GxT Gold or $MERCHANT_FxT Food each!"    # GxT, FxT
				;;
	    G | g )	MERCHANDISE="Gold"
				MvAddStr 7 4 "$MERCHANT_GxT Tobacco or $MERCHANT_GxF Food."           # GxT, GxF
				MvAddStr 10 4 "for $MERCHANT_TxG Tobacco or $MERCHANT_FxG Food each!" # TxG, FxG
				;;
	    I | i ) MERCHANDISE="Item" ;;
	    * ) break ;;
	esac
	GX_Marketplace_Merchant
	if [ "$MERCHANDISE" = "Item" ] ; then
	    MvAddStr 4 4 "You are in for a treat! I managed to"
	    MvAddStr 5 4 "acquire a very rare and valuable"
	    MvAddStr 6 4 "$MERCHANT_ITEM, which can be yours"
	    MvAddStr 7 4 "for just $MERCHANT_IxG Gold or $MERCHANT_IxF Tobacco!"
	    MvAddStr 9 4 "Or I can buy any item you have for $MERCHANT_GxI a piece."
	else
	    MvAddStr 4 4 "But of course! Here are my prices:"
	    MvAddStr 6 4 "I sell 1 $MERCHANDISE to you for"
	    MvAddStr 9 4 "Or I can buy 1 $MERCHANDISE from you,"
	fi
	MvAddStr 10 4 "Are you buying or selling?"
	read -sn 1 -p "$(MakePrompt '(B)uying;(S)elling;(J)ust Looking')" MERCHANTVAR 2>&1
	GX_Marketplace_Merchant
	    case "$MERCHANDISE" in
		b | B ) local TODO ;; # Add buying logic (from grocer)
		s | S ) local TODO ;; # Add selling logic (more or less equiv.)
	    esac    
	fi
	tput rc
    done
} # Return to Marketplace

#-----------------------------------------------------------------------
# Marketplace_Grocer()
# Used: GoIntoTown()
# IDEA:
# ? Add stealing from market??? 
#   Good idea, but we'd have to arrange a fight and new enemy type (shopkeep)..
#   Or he call the police (the guards?) and they throw player from town? (kstn)
#-----------------------------------------------------------------------
Marketplace_Grocer() { 
    # The PRICE of units are set in WorldPriceFixing()
    while (true); do
	GX_Marketplace_Grocer
	tput sc                                      # save cursor position
	MvAddStr 10 4 "1 FOOD costs $PRICE_FxG Gold" # move to y=10, x=4 ( upper left corner is 0 0 )
	MvAddStr 11 4  "or $PRICE_FxT Tobacco.\""    # move to y=11, x=4 ( upper left corner is 0 0 )
	tput rc                                      # restore cursor position
	echo "Welcome to my shoppe, stranger! We have the right prices for you .." # Will be in GX_..
	echo "You currently have $CHAR_GOLD Gold, $CHAR_TOBACCO Tobacco and $CHAR_FOOD Food in your inventory"
	MakePrompt 'Trade for (G)old;Trade for (T)obacco;(L)eave'
	case $(Read) in
	    g | G )
		GX_Marketplace_Grocer
		read -p "How many food items do you want to buy? " QUANTITY 2>&1
		# TODO check for QUANTITY - if falls if QUANTITY != [0-9]+
		# TODO Perhaps this could help: stackoverflow.com/questions/806906/how-do-i-test-if-a-variable-is-a-number-in-bash
		local COST=$( bc <<< "$PRICE_FxG * $QUANTITY" )
		if (( $(bc <<< "$CHAR_GOLD > $COST") )); then
		    CHAR_GOLD=$(bc <<< "$CHAR_GOLD - $COST")
		    CHAR_FOOD=$(bc <<< "${CHAR_FOOD} + ${QUANTITY}")
		    echo "You bought $QUANTITY food for $COST Gold, and you have $CHAR_FOOD Food in your inventory"
		else
		    echo "You don't have enough Gold to buy $QUANTITY food yet. Try a little less!"
		fi
		read -n 1		
		;;
	    t | T )
		GX_Marketplace_Grocer
		read -p "How much food you want to buy? " QUANTITY 2>&1
		# TODO check for QUANTITY - if falls if QUANTITY != [0-9]+
		local COST=$( bc <<< "${PRICE_FxT} * $QUANTITY" )
		if (( $(bc <<< "$CHAR_TOBACCO > $COST") )); then
		    CHAR_TOBACCO=$(bc <<< "$CHAR_TOBACCO - $COST")
		    CHAR_FOOD=$(bc <<< "${CHAR_FOOD} + ${QUANTITY}")
		    echo "You traded $COST Tobacco for $QUANTITY food, and have $CHAR_FOOD Food in your inventory"
		else
		    echo "You don't have enough Tobacco to trade for $QUANTITY food yet. Try a little less!"
		fi
		read -n 1		
		;;
	    *) break;
	esac
    done
    unset PRICE_IN_GOLD PRICE_IN_TOBACCO
} # Return to GoIntoTown()

#-----------------------------------------------------------------------
# CheckForStarvation()
# Food check 
# Used: NewSector() and should be used also in Rest()
# TODO: may be it shold be renamed to smth more understandable? #kstn
# TODO: add it to Rest() after finishing
# TODO: not check for food at the 1st turn ???
# TODO: Tavern also should reset STARVATION and restore starvation penalties if any
#-----------------------------------------------------------------------
CheckForStarvation(){ 
    if (( $(bc <<< "${CHAR_FOOD} > 0") )) ; then
	CHAR_FOOD=$( bc <<< "${CHAR_FOOD} - 0.25" )
	echo "You eat .25 food from your stock: $CHAR_FOOD remaining .." 
	if (( STARVATION > 0 )) ; then
	    if (( STARVATION >= 8 )) ; then # Restore lost ability after overcoming starvation
		case "$CHAR_RACE" in
		    1 | 3 ) (( STRENGTH++ )) && echo "+1 STRENGTH: You restore your body to healthy condition (Strength: $STRENGTH)" ;; 
		    2 | 4 ) (( ACCURACY++ )) && echo "+1 ACCURACY: You restore your body to healthy condition (Accuracy: $ACCURACY)" ;; 
		esac		    
	    fi
	    STARVATION=0
	fi
    else
	case $(( ++STARVATION )) in # ++STARVATION THEN check
	    1 ) echo "You're starving on the ${STARVATION}st day and feeling hungry .." ;;
	    2 ) echo "You're starving on the ${STARVATION}nd day and feeling famished .." ;;
	    3 ) echo "You're starving on the ${STARVATION}rd day and feeling weak .." ;;
	    * ) echo "You're starving on the ${STARVATION}th day, feeling weaker and weaker .." ;;
	esac

	(( CHAR_HEALTH -= 5 ))
	echo "-5 HEALTH: Your body is suffering from starvation .. (Health: $HEALTH)" # Light Starvation penalty - decrease 5HP/turn	    
	
	if (( STARVATION == 8 )); then # Extreme Starvation penalty
	    case "$CHAR_RACE" in
		1 | 3 ) (( STRENGTH-- )) && echo "-1 STRENGTH: You're slowly starving to death .. (Strength: $STRENGTH)" ;; 
		2 | 4 ) (( ACCURACY-- )) && echo "-1 ACCURACY: You're slowly starving to death .. (Accuracy: $ACCURACY)" ;;
	    esac
	fi
	((HEALTH <= 0)) && echo "You have starved to death" && sleep 2 && Death
    fi
    sleep 2 ### DEBUG
}

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
	    sleep 2;;
    esac
    if ((COLOR == 1)) ; then
	YELLOW='\033[1;33m' # Used in MapNav() and GX_Map()
	RESET='\033[0m'
    fi
    # Define escape sequences
    # TODO replace to tput or similar
    CLEAR_LINE="\e[1K\e[80D" # \e[1K - erase to the start of line \e[80D - move cursor 80 columns backward
}
#                           END FUNCTIONS                              #
#                                                                      #
#                                                                      #
########################################################################


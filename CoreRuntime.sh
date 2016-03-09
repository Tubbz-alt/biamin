
########################################################################
#                                                                      #
#                        2. RUNTIME BLOCK                              #
#                   All running code goes here!                        #

# Make place for game (BEFORE CLI opts! Mostly because of Higscore and
# CLI_CreateCustomMapTemplate())

if [[ ! -d "$GAMEDIR" ]] ; then                                           # Check whether gamedir exists...
    echo -e "Game directory default is $GAMEDIR/\nYou can change this in $CONFIG. Creating directory ..."
    mkdir -p "$GAMEDIR/" || Die "ERROR! You do not have write permissions for $GAMEDIR ..."
fi

if [[ ! -f "$CONFIG" ]] ; then                                            # Check whether $CONFIG exists...
    echo "Creating ${CONFIG} ..."
    echo -e "GAMEDIR: ${GAMEDIR}\nCOLOR: NA" > "$CONFIG"
fi

[[ -f "$HIGHSCORE" ]] || touch "$HIGHSCORE";                              # Check whether $HIGHSCORE exists...
grep -q 'd41d8cd98f00b204e9800998ecf8427e' "$HIGHSCORE" && > "$HIGHSCORE" # Backwards compatibility: replaces old-style empty HS...

if [[ ! "$PAGER" ]] ; then                                                # Define PAGER (for ShowLicense() ) # Not defined by-default in some systems.
    for PAGER in less more ; do PAGER=$(which "$PAGER" 2>/dev/null); [[ "$PAGER" ]] && break; done
fi

CLI_ParseArguments "$@"			  # Parse CLI args if any
echo "Putting on the traveller's boots.." # OK lets play!

# Load variables from $GAMEDIR/config. Need if player wants to keep
# his saves not in ~/.biamin . NB variables should not be empty !

while IFS=": " read VAR VAL; do
    case "$VAR" in
	"GAMEDIR" ) GAMEDIR="${VAL}";;
	"COLOR"   ) COLOR="${VAL}";;
    esac
done < "${CONFIG}"
unset VAR VAL

CheckBiaminDependencies		   # Check all needed programs and screen size
ColorConfig "$COLOR"               # Color configuration
ReseedRandom			   # Reseed random numbers generator
trap CleanUp SIGHUP SIGINT SIGTERM # Direct termination signals to CleanUp
tput civis			   # Make annoying cursor invisible
################################# Main game part ###############################
[[ "$CHAR" ]] || MainMenu          # Run main menu (Define $CHAR) if game wasn't run as biamin -p <charname>
BiaminSetup                        # Load or make new char
Intro	                           # Set world
NewSector                          # And run main game loop
############################## Main game part ends #############################
Exit 0                             # This should never happen:
                                   # .. but why be 'tardy when you can be tidy?

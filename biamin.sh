#!/bin/bash
# Back In A Minute by Sigg3.net (C) 2014
# Code is GNU GPLv3 & ASCII art is CC BY-NC-SA 4.0
VERSION="1.2"
WEBURL="http://sigg3.net/biamin/"

########################################################################
# BEGIN CONFIGURATION                                                  #
# Game directory used for game files (no trailing slash!)              #
GAMEDIR="/home/$(whoami)/Games/biamin"                                 #
#                                                                      #
# Disable BASH history for this session                                #
unset HISTFILE                                                         #
#                                                                      #
# Hero start location e.g. Home (custom maps only):                    #
START_LOCATION="C2"                                                    #
#                                                                      #
# Disable Cheats 1 or 0 (chars with >150 health set to 100 health )    #
DISABLE_CHEATS=0                                                       #
#                                                                      #
# Editing beyond this line is considered unsportsmanlike by some..!    #
# END CONFIGURATION                                                    #
#                                                                      #
# 'Back in a minute' uses the following coding conventions:            #
#                                                                      #
#  0. Variables are written in ALL_CAPS                                #
#  1. Functions are written in CamelCase                               #
#  2. Loop variables are written likeTHIS                              #
#  3. Put the right code in the right blocks (see INDEX below)         #
#  4. Please explain functions right underneath function declarations  #
#  5. Comment out unfinished or not working new features               #
#  6. If something can be improved, mark with TODO + ideas             #
#  7. Follow the BASH FAQ practices @ www.tinyurl.com/bashfaq          #
#  8. Please properly test your changes, don't break anyone's heart    #
#  9. $(grep "$ALCOHOLIC_BEVERAGE" fridge) only AFTER coding!          #
#                                                                      #
#  INDEX                                                               #
#  0. GFX Functions Block (~ 600 lines ASCII banners)			       #
#  1. Functions Block                                                  #
#  2. Runtime Block (should begin by parsing CLI arguments)            #
#                                                                      #
#  Please observe conventions when updating the script, thank you.     #
#						                 - Sigg3                       #
#                                                                      #
########################################################################



########################################################################
#                                                                      #
#                        0. GFX FUNCTIONS                              #
#                All ASCII banner-functions go here!                   #
									       

# Horizontal ruler used almost everywhere in the game
HR="- ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ "

GX_Banner() {
clear
cat <<"EOT"
            ______                                                     
          (, /    )       /)     ,                    ,               
            /---(  _   _ (/_      __     _     ___     __      _/_  _ 
         ) / ____)(_(_(__/(__  _(_/ (_  (_(_   // (__(_/ (_(_(_(___(/_
        (_/ (                                                         
                                                     ___________(  )_ 
                                                    /   \      (  )  \
                                                   /     \     |`|    \   
                                                  /   _   \      ~ ^~  \ ~ ^~  
                                                 /|  |.|  |\___ (     ) (     )
                                                  |  | |  |    ( (     ) (     )
                                             """"""";::;"""""""(    )  )    )  )
                                                  ,::;;.        (_____) (_____)
                                                 ,:;::;           | |     | |
                                               ;:;:;:;            | |     | |
                                            ,;;;;;;;,            """""  """"""

                    
          /a/ |s|i|m|p|l|e| /b/a/s/h/ |a|d|v|e|n|t|u|r|e| /g/a/m/e/

              Sigg3.net (C) 2014 CC BY-NC-SA 4.0 and GNU GPL v.3
EOT
echo "$HR"
}
GX_Credits() {
clear
cat <<"EOT"
            ______                                                     
          (, /    )       /)     ,                    ,               
            /---(  _   _ (/_      __     _     ___     __      _/_  _ 
         ) / ____)(_(_(__/(__  _(_/ (_  (_(_   // (__(_/ (_(_(_(___(/_
        (_/ (   
                         
   Back in a minute is an adventure game with 4 playable races, 6 enemies,
   8 items and 6 scenarios spread across the 270 sections of the world map.
   Biamin saves character sheets between sessions and keeps a highscore!
   The game supports custom maps too! See --help or --usage for information.
EOT
echo -e "\n   Game directory: "$GAMEDIR"/\n"
cat <<"EOT"
   This timekiller's written entirely in BASH. It was intended for sysadmins
   but please note that it isn't console-friendly and it looks best in 80x24
   terminal emulators (white on black). Make sure it's a window you can close.
      
   BASH code (C) Sigg3.net GNU GPL Version 3 2014
   ASCII art (C) Sigg3.net CC BY-NC-SA 4.0 2014 (except figlet banners)

EOT
echo "   Visit the Back in a minute website at <"$WEBURL">"
echo "   for updates, feedback and to report bugs. Thank you."
echo "$HR"
}
GX_HighScore() {
clear
cat <<"EOT"
         _________     _    _ _       _                            
        |o x o x o|   | |__| (_) __ _| |__  ___  ___ ___  _ __ ___ 
         \_*.*.*_/    |  __  | |/ _` | '_ \/ __|/ __/ _ \| '__/ _ \
           \-.-/      | |  | | | (_| | | | \__ \ (_| (_) | | |  __/
           _| |_      |_|  |_|_|\__, |_| |_|___/\___\___/|_|  \___|
          |_____|                |___/                              
                                       Y e   H a l l e   o f   F a m e
EOT
echo "$HR"
}
GX_LoadGame() {
clear
cat << "EOT"
        ___________ 
       (__________()   _                    _    ____                      
       / ,,,,,,,  /   | |    ___   __ _  __| |  / ___| __ _ _ __ ___   ___ 
      / ,,,,,,,  /    | |   / _ \ / _` |/ _` | | |  _ / _` | '_ ` _ \ / _ \
     / ,,,,,,,  /     | |__| (_) | (_| | (_| | | |_| | (_| | | | | | |  __/
   _/________  /      |_____\___/ \__,_|\__,_|  \____|\__,_|_| |_| |_|\___|
  (__________(/ 
 
EOT
echo "$HR"
}
GX_CharSheet() {
clear
cat <<"EOT"
 
                               /T\                           /""""""""\ 
      o-+----------------------------------------------+-o  /  _ ++ _  \
        |/                                            \|   |  / \  / \  \
        |  C  H  A  R  A  C  T  E  R     S  H E  E  T  |   | | , | |, | |
        |                                              |   | |   |_|  | |
        |\             s t a t i s t i c s            /|    \|   ...; |; 
      o-+----------------------------------------------+-o    \______/

EOT
echo "$HR"
}
GX_Death() {
clear
cat <<"EOT"

     
         __   _  _  _/_   ,  __
        / (__(/_/_)_(__  _(_/ (_    __    _  _   _   _                __ 
                                    /_)__(/_(_(_(___(/_              /\ \
                                 .-/                                /  \ \   
         YOU ARE A STIFF,       (_/           # #  # #  # # #      /  \/\ \  
         PUSHING UP THE DAISIES          # # #  # # # # # # #  #  /   /\ \_\ 
         YOU ARE IRREVOCABLY DEAD     # # # # # #  # # # # #  # # \  /   / / 
                                    # # # # # # # # # ## # # # # # \    / /     
         Better luck next time!   # # # # #  # # # # # # # # #  # # \  / /
                                 # # #  #  # # # # # # # # # # # # # \/_/
                                   # #  # # # # # # ## # # # # ## #


EOT
echo "$HR"
}
GX_Intro() {
clear
cat <<"EOT"
                                                                         
       YOU WAKE UP TO A VAST AND UNFAMILIAR LANDSCAPE !                   
                                                                          
       Use the MAP to move around                                         
       REST to regain health points                                             
                                 ___                ^^                /\        
       HOME, TOWNS and the    __/___\__                   ^^         /~~\      
       CASTLE are safest       _(   )_                           /\ /    \  /\
                              /       \    1                  __/  \      \/  \
___                          (         \__ 1                _/             \   \
   \________                  \       L___| )           @ @ @ @ @@ @ @@ @
            \_______________   |     |     1     @ @ @ @@ @ @ @@ @ @ @ @ @@ @
                            \__|  |  |_____1____                    @ @ @@ @@ @@
                               |  |  |_    1    \___________________________  
                               |__| ___\   1                                \___
EOT
echo "$HR"
}
GX_Races() {
clear
cat <<"EOT"

                        C H A R A C T E R   R A C E S :

      1. MAN            2. ELF              3. DWARF            4. HOBBIT
 
   Healing:  3/6      Healing:  4/6       Healing:  1/6        Healing:  4/6   
   Strength: 3/6      Strength: 2/6       Strength: 5/6        Strength: 3/6
   Accuracy: 3/6      Accuracy: 4/6       Accuracy: 4/6        Accuracy: 3/6
   Flee:     3/6      Flee:     2/6       Flee:     2/6        Flee:     2/6
   
   Dice rolls on each turn. Accuracy also initiative. Healing during resting.

EOT
echo $HR
}
GX_Castle() {
clear
cat <<"EOT"
                             __   __   __                         __   __   __ 
                            |- |_|- |_| -|   ^^                  |- |_|- |_|- |
                            | - - - - - -|                       |- - - - - - |
                             \_- - - - _/    _       _       _    \_ - - - -_/
         O L D B U R G         |- - - |     |~`     |~`     |~`     | - - -| 
         C A S T L E           | - - -|  _  |_   _  |_   _  |_   _  |- - - | 
                               |- - - |_|-|_|-|_|-|_|-|_|-|_|-|_|-|_| - - -| 
         Home of The King,     | - - -|- - - - - -_-_-_-_- - - - - -|- - - | 
         The Royal Court and   |- - - | - - - - //        \ - - - - | - - -| 
         other silly persons.  | - - -|- - - - -||        |- - - - -|- - - | 
                               |- - - | - - - - ||        | - - - - | - - -| 
                               | - - -|- - - - -||________|- - - - -|- - - | 
                               |- - - | - - - - /        /- - - - - | - - -| 
                               |_-_-_-_-_-_-_-_/        /-_-_-_-_-_-_-_-_-_| 
                                              7________/
EOT
echo "$HR"
}
GX_Town() {
clear
cat <<"EOT"
                                                           ___ 
                                                          / \_\   town house
                                 zig's inn                | | |______
         YOU HAVE REACHED   ______________________________| | |\_____\____
         A PEACEFUL TOWN   |\| | | | _|_|_| | | |/\____\ .|_|_|______| | |\
                            |\   _  /\____\  ....||____| :........  ____  |\
         A warm bath and     |  [x] ||____|  :   _____ ..:_____  : /\___\  |\
         cozy bed awaits    ........:        :  /\____\  /\____\ :.||___|   |\
         the weary traveller   |\   :........:..||____|  ||____|             |\
                                ||==|==|==|==|==|==|==|==|==|==|==|==|==|==|==|


EOT
echo "$HR"
}
GX_Forest() {
clear
cat <<"EOT"
                                                                    /\
                                                                   //\\     
                                        /\  /\               /\   /\/\/\ 
                                       /  \//\\             //\\ //\/\\/\
         YOU'RE IN THE WOODS          /    \^#^\           /\/\/\/\^##^\/\      
                                     /      \#            //\/\\/\  ##      
         It feels like something    /\/^##^\/\        .. /\/^##^\/\ ##      
         is watching you ..             ##        ..::;      ##     ##      
                                        ##   ..::::::;       ##
                                       ....::::::::;;        ##           
                                   ...:::::::::::;;
                                ..:::::::::::::::;
EOT
echo "$HR"
}
GX_Mountains() {
clear
cat <<"EOT"


                                           ^^      /\  /\_/\/\
         YOU'RE TRAVELLING IN           ^^     _  /~~\/~~\~~~~\   
         THE MOUNTAINS                        / \/    \/\      \
                                             /  /    ./  \ /\   \/\ 
         The calls of the wilderness  ............:;'/    \     /  
         turn your blood to ice        '::::::::::; /     




EOT
echo "$HR"
}
GX_Home() {
clear
cat <<"EOT"
                                                     ___________(  )_ 
                                                    /   \      (  )  \
                                                   /     \     |`|    \   
                                                  /   _   \      ~ ^~  \ ~ ^~  
         MY HOME IS MY CASTLE                    /|  |.|  |\___ (     ) (     )
                                                  |  | |  |    ( (     ) (     )
         You are safe here                   """"""";::;"""""""(    )  )    )  )
         and fully healed.                        ,::;;.        (_____) (_____)
                                                 ,:;::;           | |     | |
                                               ;:;:;:;            | |     | |
                                            ,;;;;;;;,            """""  """"""

EOT
echo "$HR"
}
GX_Road() {
clear
cat <<"EOT"
                             /V/V7/V/\V\V\V\
                            /V/V/V/V/V/V/V\V\                ,      ^^ 
                           /7/V/V/V###V\V\V\V\    ^^      , /X\           ,
                                   ###     ,____________ /x\ T ____  ___ /X\ ___
         ON THE ROAD AGAIN         ###   ,-               T        ; ;    T  
                              ____ ### ,-______  ., . . . . , ___.'_;_______
         Safer than the woods      ###        .;'          ;                \_
         but beware of robbers!            .:'            ;                   \ 
                                        .:'              ;   ___               `
                                *,    .:'               .:  | 3 |     
                               `)    :;'                :; '"""""'    
                                   .;:                   `::.            
EOT
echo "$HR"
}
GX_Rest() {
clear
cat <<"EOT"


                                                          _.._    
                               *         Z Z Z   *       -'-. '.             *
                                                             \  \          
         YOU TRY TO GET                                .      | |
         SOME MUCH NEEDED REST    *                    ;.___.'  /     *    
                                    Z Z    *            '.__ _.'          * 
                            *                                               



EOT
echo "$HR"
}
GX_Monster_chthulu() {
clear
cat <<"EOT"
                        \ \_|\/\     ________      / /            \ \ 
                         \ _    \   /        \    /  /             \ \
         T H E            \ \____\_|          \--/  /__   ____      \ \ 
         M I G H T Y       \_    _|            |       ) / __ )      \ \
                             \  / \    .\  /.  |        / |  (_   __  \ \
         C H T H U L U ' S    \/    \         /       _/ /|  | \_/  )  \ \     
                              /   _/         \      / _/   \/   /-/|    \ \     
         W R A T H   I S     /   //.(/((| |\(\\    / /          \/ |     \ \   (
         U P O N   Y O U    /   / ||__ "| |   \|  |_ |----------L /       \ \ _/
                           /   /  \__/  | |/|      \_) \        |/         \_/
                          /   /     |    \_/            \               __(
                          |   (      |                   \           __(
                          \|\|\\      |                   `         (  

EOT
echo "$HR"
}
GX_Monster_orc() {
clear
cat <<"EOT"
                                                  |\            /|
                                                  | \_.::::::._/ |
                                                   |  __ \/__   |
                                                    |          |
         AN ANGRY ORC APPEARS,                  ____| _/|__/|_ |____
         BLOCKING YOUR WAY!                    /     \________/     \
                                              /                      \
         "Prepare to die", it growls.        |    )^|    _|_   |^(    |
                                             |   )  |          |  (   |
                                             |   |   |        |   (   |
                                              \_\_) |          | (_/_/
                                                   /     __     \
                                                  |     /  \     |
                                                  |    (    )    |
                                                  |____'    '____|
                                                 (______)  (______)
EOT
echo "$HR"
}
GX_Monster_varg() {
clear
cat <<"EOT"

                                                     ______
                                               ____.:      :.
                                        _____.:               \___
         YOU ENCOUNTER A         _____/  _  )      __            :.__
         TERRIBLE VARG!         |       7             `      _       \ 
                                  ^^^^^ \    ___        1___ /        |
         It looks hungry.           ^^^^  __/   |    __/    \1     /\  |
                                     \___/     /   _|        |    / | /  _
                                            __/   /           |  \  | | | |
                                           /_    /           /   |   \ ^  |
                                             /__/           |___/     \__/


EOT
echo "$HR"
}
GX_Monster_mage() {
clear
cat <<"EOT"
                                             ---.         _/""""""\
                                            (( ) )       /_____  |'
                                             \/ /       // \/  \  \
                                             / /       ||(.)_(.)|  |
                                             (|`\      ||  ( ;  |__|
         A FIERCE MAGE STANDS                (|  \      7| +++   /
         IN YOUR WAY!                        ||__/\____/  \___/  \___
                                             ||      |             /  \
         Before you know it, he begins       ||       \     \/    /    \
         his evil incantations..             ||\       \   ($)   /      \
                                             || \   /^\ \ ______/  ___   \
         "Lorem ipsum dolor sit amet..."     ||  \_/  |           /  __   |
                                             ||       |          |  /__|  |
                                             ||       |          \  |__/  | 
                                             ||      /            \_____/ 
                                             ^      /               \
                                                   |        \        \
EOT
echo "$HR"
}
GX_Monster_goblin() {
clear
cat <<"EOT"
                                                    _______                   _
                                                   (       )/|    ===[]]]====(_)
                                                ____0(0)    /       7 _/^
                                                L__  _)  __/       / / 
         A GOBLIN JUMPS YOU!                      /_V)__/ 1       / / 
                                             ______/_      \____ / /
         He raises his club to attack..     /   .    \      _____/
                                           |  . _ .   | .__/|
                                           | . (_) .  |_____|
                                           |  . . .   |$$$$$|  
                                            \________/$$$$$/ \
                                                 /  /\$$$$/\  \
                                             ___/  /      __|  \
                                            (_____/      (______)
EOT
echo "$HR"
}
GX_Monster_bandit() {
clear
cat <<"EOT"
                                                       /""""""';   ____
                                                      d = / =  |3 /1--\\
                                                 _____| _____  |_|11 ||||
         YOU ARE INEXPLICABLY                   /     \_\\\\\\_/  \111/// 
         AMBUSHED BY A LOWLIFE CRIMINAL!       /  _ /             _\1// \ 
                                              /  ) (     |        \ 1|\  \
         "Hand over your expensive stuffs,   /   )(o____ (   ____o) 1|(  7
         puny poncer, or have your skull     \   \ :              . 1/  /
         cracked open by the mighty club!"    \\\_\'.     *       ;|___/
                                                   /\____________/ 
                                                  / #############/
                                                 (    ##########/ \
                                                __\    \    \      )__
                                               (________)    (________)
EOT
echo "$HR"
}
GX_Item0() {
clear
cat <<"EOT"
		
                          G I F T   O F   S I G H T

                                .............. 
                                ____________**:,.                      
                             .-'  /      \  ``-.*:,..             
                         _.-*    |  .jM O |     `-..*;,,              
                        `-.      :   WW   ;       .-'                 
                   ....    '._    \______/     _.'   .:              
                      *::...  `-._ _________,;'    .:*
                          *::...                 ..:*      
                               *::............::*                  
                                                                   
     You give aid to an old woman, carry her firewood and water from the
     stream, and after a few days she reveals herself as a White Witch!
	
     She gives you a blessing and the Gift of Sight in return for your help.
     "The Gift of Sight," she says, "will aide you as you aided me."

     Look for a ~ symbol in your map to discover new items in your travels.
     However, from the 7 remaining items only 1 is made visible at a time.

EOT
echo "$HR"
}
GX_Item1() {
clear
cat <<"EOT"

                  E M E R A L D   O F   N A R C O L E P S Y
                             .   .  ____  .   .
                                .  /.--.\  .  
                               .  //    \\  .  
                            .  .  \\    //  .  .
                                .  \\  //  .     
                             .   .  \`//  .   .        
                                     \/     
     You encounter a strange merchant from east of all maps who joins you
     for a stretch of road. He is a likeable fellow, so when he asks if he
     could share a campfire with you and finally get some much needed rest in
     these strange lands, you comply.

     The following day he presents you with a brilliant emerald that he says
     will help you sleep whenever you need to get some rest. Or at least
     fetch you a good price at the market. Then you bid each other farewell.

     +1 Healing, Chance of Healing Sleep when you are resting.
	
EOT
echo "$HR"
}
GX_Item2() {
clear
cat <<"EOT"

                          G U A R D I A N   A N G E L
                        .    . ___            __ ,  .            
                      .      /* * *\  ,~-.  / * *\    .         
                            /*   .:.\ l`; )/*    *\             
                     .     |*  /\ :-,_,' ()*  /\  *|    .       
                           \* |  ||\__   ~'  |  | */           
                      .     \* \/ |  / /\ \  \ / */   .      
                             \*     / ^  ^ \    */               
                        .     )* _  ^|^|^|^^ _ *(    .
                             /* /     |  |    \ *\ 
                       .    (*  \__,   | | .__/  *)   .
                             \*  *_*_ // )*_*   */     
                        .     \* /.,  `-'   .\* /    .  
                          .    \/    .   .   `\/        
                            .     .         .     .
                              .                 .
     You rescue a magical fairy caught in a cobweb, and in return she
     promises to come to your aid when you are caught in a similar bind.

     +5 Health in Death if criticality is less than or equal to -5

EOT
echo "$HR"
}
GX_Item3() {
clear
cat <<"EOT"

                        F A S T   M A G I C   B O O T S
                              _______  _______                                 
                             /______/ /______/                            
                              |   / __ |   / __                           
                             /   /_(  \'  /_(  \                       
                            (_________/________/       
                                                                     
     You are taken captive by a cunning gnome with magic boots, holding you
     with a spell that can only be broken by guessing his riddles.
     After a day and a night in captivity you decide to counter his riddles
     with one of your own: "What Creature of the Forest is terribly Red and
     Whiny, and Nothing Else without the Shiny?"
     
     The gnome ponders to and fro, talking to himself and spitting, as he gets
     more and more agitated. At last, furious, he demands "Show me!" and 
     releases you from the spell. Before he knows it you've stripped off his
     boots and are running away, magically quicker than your normal pace.

     +1 Flee

EOT
echo "$HR"
}
GX_Item4() {
clear
cat <<"EOT"

                    Q U I C K   R A B B I T   R E A C T I O N

                                   .^,^   
                                __/ ; /____
                               / c   -'    `-.                            
                              (___            )              
                                  _) .--     _')                
                                  `--`  `---'               
                                                        
     Having spent quite a few days and nights out in the open, you have grown
     accustomed to sleeping with one eye open and quickly react to the dangers
     of the forests, roads and mountains in the old world, that seek every
     opportunity to best you.

     Observing the ancient Way of the Rabbit, you find yourself reacting more
     quickly to any approaching danger, whether it be day or night.

     +1 Initiative upon enemy attack

EOT
echo "$HR"
}
GX_Item5() {
clear
cat <<"EOT"

                  F L A S K   O F   T E R R I B L E   O D O U R
                        /  /    * *  /    _\ \       ___ _
                        ^ /   /  *  /     ____)     /,- \ \              
                         /      __*_     / / _______   \ \ \             
                 ,_,_,_,_ ^_/  (_+ _) ,_,_/_/       ) __\ \_\___        
                /          /  / |  |/     /         \(   \7     \    
           ,   :'      \    ^ __| *|__    \    \  ___):.    ___) \____/)
          / \  :.       |    / +      \  __\    \      :.              (\  
        _//^\\  ;.      )___(~~~~~~~*~~)_\_____  )_______:___            }   
        \ |  \\_) ) _____,)  \________/   /_______)          vvvVvvvVvvvV 
         \|   `-.,'               
     Under a steep rock wall you encounter a dragon pup's undiscovered carcass.
     You notice that its rotten fumes curiously scare away all wildlife and
     lowlife in the surrounding area.
     You are intrigued and collect a sample of the liquid in a small flask that
     you carry, to sprinkle on your body for your own protection.

     +1 Chance of Enemy Flee

EOT
echo "$HR"
}
GX_Item6() {
clear
cat <<"EOT"

                   T W O - H A N D E D    B R O A D S W O R D
                       .   .   .  .  .  .  .  .  .  .  .  . 
                  .  .   /]______________________________   .
                .  ,~~~~~|/_____________________________ \   
                .  `=====|\______________________________/  .
                  .  .   \]   .  .  .  .  .  .  .  .  .   .      
                        .  .                                                           
     From the thickest of forests you come upon and traverse a huge unmarked 
     marsh and while crossing, you stumble upon trinkets, shards of weaponry
     and old equipment destroyed by the wet. Suddenly you realize that you are
     standing on the remains of a centuries old, long forgotten battlefield.

     On the opposite side, you climb a mound only to find the wreckage of a
     chariot, crashed on retreat, its knight pinned under one of its wheels.
     You salvage a beautiful piece of craftmanship from the wreckage;
     a powerful two-handed broadsword, untouched by time.
		
     +1 Strength
	
EOT
echo "$HR"
}
GX_Item7() {
clear
cat <<"EOT"

                      S T E A D Y   H A N D   B R E W
                              ___                                
                             (___)            _  _  _ _             
                              | |           ,(  ( )  ) )                
                             /   \         (. ^ ( ^) ^ ^)_
                            |     |        ( ~( _)- ~ )-_ \    
                            |-----|         [_[[ _[[ _{  } :       
                            |X X X|         [_[[ _[[ _{__; ;      
                            |-----|         [_[[ _[[ _)___/                    
              ______________|     |   _____ [_________]                 
             |     | >< |   \___ _| _(     )__
             |     | >< |    __()__           )_                              
             |_____|_><_|___/     (__          _)                      
                                    (_________)      

     Through the many years of travel you have found that your acquired taste
     of a strong northlandic brew served cool keeps you on your toes.

     +1 Accuracy and Initiative

EOT
echo "$HR"
}

# GFX MAP FUNCTIONS

# FILL THE $MAP file using either default or custom map
MapCreate() {
if [ -f ""$GAMEDIR"/CUSTOM.map" ]; then
	if grep -q 'Z' ""$GAMEDIR"/CUSTOM.map" ; then
		echo "Whoops! Custom map file still contains Z's!"
		echo "Use ONLY symbols from the legend (x . T @ H C) in your custom maps!"
		CustomMapError
	else
		cat ""$GAMEDIR"/CUSTOM.map" > "$MAP"
	fi
else
	cat <<"EOT" > "$MAP"
       A | B | C | D | E | F | G | H | I | J | K | L | M | N | O | P | Q | R 
   #=========================================================================#
 1 )   x   x   x   x   x   @   .   .   .   T   x   x   x   x   x   x   @   T (
 2 )   x   x   H   x   @   @   .   @   @   x   x   x   x   x   @   @   @   @ (
 3 )   @   @   .   @   @   @   .   x   x   x   x   x   @   x   @   x   @   @ (
 4 )   @   @   .   @   @   @   .   @   x   x   x   @   T   x   x   x   x   x (
 5 )   @   @   .   .   T   .   .   @   @   @   @   @   .   @   x   x   x   x (
 6 )   @   @   @   @   .   @   @   @   @   @   @   @   .   @   @   x   x   x (
 7 )   @   @   @   @   .   .   .   T   @   @   @   @   .   @   @   x   x   x (
 8 )   @   @   T   .   .   @   @   @   @   @   @   .   .   .   .   .   .   x (
 9 )   @   @   .   @   @   @   @   @   @   @   .   .   @   x   @   @   .   . (
10 )   @   @   .   @   @   @   T   @   @   @   .   @   @   x   x   x   x   . (
11 )   T   .   .   .   .   .   .   .   @   @   .   x   x   C   x   x   x   . (
12 )   x   @   @   @   .   @   @   .   .   .   .   x   x   x   x   x   x   . (
13 )   x   x   @   x   .   @   @   @   @   @   .   @   x   x   @   @   @   . (
14 )   x   x   x   x   .   @   @   @   @   T   .   @   x   x   @   @   .   . (
15 )   x   x   x   T   .   @   @   @   @   @   @   @   @   T   .   .   .   @ (
   #=========================================================================#
          LEGEND: x = Mountain, . = Road, T = Town, @ = Forest         N
                  H = Home (Heal Your Wounds) C = Oldburg Castle     W + E
                                                                       S
EOT
fi
}

# Map template generator (CLI arg function)
MapCreateCustom() {
if [ -d "$GAMEDIR" ] ; then
	cat <<"EOT" > ""$GAMEDIR"/rename_to_CUSTOM.map"
       A | B | C | D | E | F | G | H | I | J | K | L | M | N | O | P | Q | R 
   #=========================================================================#
 1 )   Z   Z   Z   Z   Z   Z   Z   Z   Z   Z   Z   Z   Z   Z   Z   Z   Z   Z (
 2 )   Z   Z   Z   Z   Z   Z   Z   Z   Z   Z   Z   Z   Z   Z   Z   Z   Z   Z (
 3 )   Z   Z   Z   Z   Z   Z   Z   Z   Z   Z   Z   Z   Z   Z   Z   Z   Z   Z (
 4 )   Z   Z   Z   Z   Z   Z   Z   Z   Z   Z   Z   Z   Z   Z   Z   Z   Z   Z (
 5 )   Z   Z   Z   Z   Z   Z   Z   Z   Z   Z   Z   Z   Z   Z   Z   Z   Z   Z (
 6 )   Z   Z   Z   Z   Z   Z   Z   Z   Z   Z   Z   Z   Z   Z   Z   Z   Z   Z (
 7 )   Z   Z   Z   Z   Z   Z   Z   Z   Z   Z   Z   Z   Z   Z   Z   Z   Z   Z (
 8 )   Z   Z   Z   Z   Z   Z   Z   Z   Z   Z   Z   Z   Z   Z   Z   Z   Z   Z (
 9 )   Z   Z   Z   Z   Z   Z   Z   Z   Z   Z   Z   Z   Z   Z   Z   Z   Z   Z (
10 )   Z   Z   Z   Z   Z   Z   Z   Z   Z   Z   Z   Z   Z   Z   Z   Z   Z   Z (
11 )   Z   Z   Z   Z   Z   Z   Z   Z   Z   Z   Z   Z   Z   Z   Z   Z   Z   Z (
12 )   Z   Z   Z   Z   Z   Z   Z   Z   Z   Z   Z   Z   Z   Z   Z   Z   Z   Z (
13 )   Z   Z   Z   Z   Z   Z   Z   Z   Z   Z   Z   Z   Z   Z   Z   Z   Z   Z (
14 )   Z   Z   Z   Z   Z   Z   Z   Z   Z   Z   Z   Z   Z   Z   Z   Z   Z   Z (
15 )   Z   Z   Z   Z   Z   Z   Z   Z   Z   Z   Z   Z   Z   Z   Z   Z   Z   Z (
   #=========================================================================#
          LEGEND: x = Mountain, . = Road, T = Town, @ = Forest         N
                  H = Home (Heal Your Wounds) C = Oldburg Castle     W + E
                                                                       S
EOT
	echo "Custom map template created in $GAMEDIR/rename_to_CUSTOM.map"
	echo -e "\n1. Change all 'Z' symbols in map area with any of these:  x . T @ H C"
	echo "   See the LEGEND in rename_to_CUSTOM.map file for details."
	echo "   Tip: Hero starts in "$START_LOCATION". Change this in line 16 of CONFIGURATION."
	echo "2. Spacing must be accurate, so don't touch whitespace or add new lines."
	echo -e "3. When you are done, simply rename your map file to CUSTOM.map\n"
	echo -e "Please submit bugs and feedback at <"$WEBURL">"
	exit
else
	echo "Please create "$GAMEDIR"/ directory before running" && exit
fi
}
								       
#                          END GFX FUNCTIONS                           #
#                                                                      #       
#                                                                      #
########################################################################





########################################################################       
#                                                                      #
#                          1. FUNCTIONS                                #
#                    All program functions go here!                    #
									       


# CLEANUP Function
CleanUp() {
if [ -f "$MAP" ]; then
	rm -f "$MAP" 
fi
echo -e "\nLeaving the realm of magic behind ...." 
echo -e "Please submit bugs and feedback at <"$WEBURL">"
exit
}

# PRE-CLEANUP tidying function for buggy custom maps
CustomMapError() {
echo -e "What to do? We can either 1) rename CUSTOM.map to CUSTOM_err.map or\n2) delete template file CUSTOM.map (deletion is irrevocable).\n"
MAP_CLEAN_OPTS="Rename Delete"
select OPT in $MAP_CLEAN_OPTS; do
if [ "$OPT" = "Rename" ]; then
	echo "Custom map file moved to "$GAMEDIR"/CUSTOM_err.map"
	mv ""$GAMEDIR"/CUSTOM.map" ""$GAMEDIR"/CUSTOM_err.map"
	CleanUp
elif [ "$OPT" = "Delete" ]; then
	echo -en "If you are sure you want to delete CUSTOM.map, type YES: " && read -n 3 "del_map_opt"
	if [ "$del_map_opt" = "YES" ] ; then
		echo -e "\nDeleting "$GAMEDIR"/CUSTOM.map.."
		rm -f ""$GAMEDIR"/CUSTOM.map"
		CleanUp
	else
		echo "Not deleting anything. Quitting.."
		CleanUp
	fi
else
	echo "Bad option! Quitting.."
	CleanUp
fi
done
}


# Setup Highscore File
SetupHighscore() {
if [ -d "$GAMEDIR" ] ; then
	HIGHSCORE=""$GAMEDIR"/highscore"

	if [ -f "$HIGHSCORE" ]; then
		touch -a "$HIGHSCORE"
	else
		echo "d41d8cd98f00b204e9800998ecf8427e" > "$HIGHSCORE"
	fi
else
	echo "Please create "$GAMEDIR"/ directory before running" && exit
fi	
}



### DISPLAY MAP
GX_Map() {
clear
MAP_Y_TMP=$[ $MAP_Y_TMP-1 ]
if [ $COLOR -eq 1 ] ; then
	sed -n 1,"${MAP_Y_TMP}"p "$MAP" | sed ''/~/s//$(printf "\033[1;33m~\033[0m")/''	# orig: `printf "\033[1;33m~\033[0m"`
else
	sed -n 1,"${MAP_Y_TMP}"p "$MAP"
fi
MAP_Y_TMP=$[ $MAP_Y_TMP+1 ]
if [ $MAP_Y -gt 9 ]; then
	echo -en "$MAP_Y )   "
else
	echo -en " $MAP_Y )   "
fi
if [ $MAP_X -eq 18 ]; then
	# Lazy fix to add border ASCII "(" when X pos is R (fully east)
	if [ $COLOR -eq 1 ] ; then
		sed -n "${MAP_Y_TMP}"p "$MAP" | sed 's/.[0-9].)   //g' | gawk -F "   " -v OFS="   " '{$'$MAP_X'="o ("; print }' | sed ''/o/s//$(printf "\033[1;33mo\033[0m")/'' | sed ''/~/s//$(printf "\033[1;33m~\033[0m")/'' # orig: `printf ...`
	else
		sed -n "${MAP_Y_TMP}"p "$MAP" | sed 's/.[0-9].)   //g' | gawk -F "   " -v OFS="   " '{$'$MAP_X'="o ("; print }'
	fi
else
	if [ $COLOR -eq 1 ] ; then
		sed -n "${MAP_Y_TMP}"p "$MAP" | sed 's/.[0-9].)   //g' | gawk -F "   " -v OFS="   " '{$'$MAP_X'="o"; print }' | sed ''/o/s//$(printf "\033[1;33mo\033[0m")/'' | sed ''/~/s//$(printf "\033[1;33m~\033[0m")/''
	else
		sed -n "${MAP_Y_TMP}"p "$MAP" | sed 's/.[0-9].)   //g' | gawk -F "   " -v OFS="   " '{$'$MAP_X'="o"; print }'
	fi
fi
MAP_Y_TMP=$[ $MAP_Y_TMP+1 ]
if [ $COLOR -eq 1 ] ; then
	sed -n "${MAP_Y_TMP}",21p "$MAP" | sed ''/~/s//$(printf "\033[1;33m~\033[0m")/''	# orig: `printf ...`
else
	sed -n "${MAP_Y_TMP}",21p "$MAP"
fi
MAP_Y_TMP=$[ $MAP_Y_TMP-1 ]
}

### DISPLAY MAP with GIFT OF SIGHT
GX_MapSight() {

# Show ONLY the NEXT item viz. "Item to see" (ITEM2C)
# Since 1st item is item0, and CHAR_ITEMS begins at 0, ITEM2C=CHAR_ITEMS
ITEM2C=$(echo ${HOTZONE[$CHAR_ITEMS]})

# If ITEM2C has been found earlier, it is now 20-20 and must be changed
# Remember, the player won't necessarily find items in HOTZONE array's sequence
if [ "$ITEM2C" = "20-20" ] ; then
	ITEM_X && ITEM_Y
	HOTZONE[$CHAR_ITEMS]="$ITEM_X-$ITEM_Y"
	ITEM2C=$(echo ${HOTZONE[$CHAR_ITEMS]})
fi

# Retrieve item map positions e.g. 1-15 >> X=1 Y=15
local IFS="-"
set $ITEM2C
ITEM2C_X=$(echo $1)
ITEM2C_Y=$(echo $2)

# If the item is the same as last time, don't repeat operations
if [ -n "$ITEM2C_prev" ] && [ "$ITEM2C" = "$ITEM2C_prev" ]; then
	GX_Map # Avoids unnecessary IO
else
	# Reset map-file to default
	MapCreate

	ITEM2C_Y=$[ $ITEM2C_Y+2 ] # Padding for ASCII borders

	# Replace item pos in map file with s symbol
	if [ $ITEM2C_X -eq 18 ]; then
		# Lazy fix for most eastern col
		ITEM2C_STR=$(sed -n "${ITEM2C_Y}"p "$MAP" | sed 's/.[0-9].)   //g' |  gawk -F "   " -v OFS="   " '{$'$ITEM2C_X'="~ ("; print }')
	else
		ITEM2C_STR=$(sed -n "${ITEM2C_Y}"p "$MAP" | sed 's/.[0-9].)   //g' |  gawk -F "   " -v OFS="   " '{$'$ITEM2C_X'="~"; print }')
	fi

	ITEM2C_Y=$[ $ITEM2C_Y-2 ] # Remove padding

	if [ $ITEM2C_Y -gt 9 ]; then	
		ITEM2C_STR=""$ITEM2C_Y" )   "$ITEM2C_STR""
	else
		ITEM2C_STR=" "$ITEM2C_Y" )   "$ITEM2C_STR""
	fi
	
	# Replace line in $MAP file with ITEM2C_STR
	MAP_TMP=$(mktemp "$GAMEDIR"/map.tmp.XXXXXXXX)		# TODO change sed below to -i to avoid tmp file?
	ITEM2C_Y=$[ $ITEM2C_Y+2 ] # Add padding again
	REMOVE_STR=$(sed -n "${ITEM2C_Y}"p "$MAP")
	sed -e "s/"$REMOVE_STR"/"$ITEM2C_STR"/g" "$MAP" > "$MAP_TMP" && mv "$MAP_TMP" "$MAP"
	unset MAP_TMP
	
	# Last item logged to avoid unnecessary IO
	ITEM2C_Y=$[ $ITEM2C_Y-2 ] # Remove padding 
	ITEM2C_prev=""$ITEM2C_X"-"$ITEM2C_Y""

	# Display map with updated ~ symbol
	GX_Map
fi
}


# SAVE CHARSHEET
SaveCurrentSheet() {
# Saves current game values to CHARSHEET file (overwriting)
echo "CHARACTER: "$CHAR"" > "$CHARSHEET"
echo "RACE: "$CHAR_RACE"" >> "$CHARSHEET"
echo "BATTLES: "$CHAR_BATTLES"" >> "$CHARSHEET"
echo "EXPERIENCE: "$CHAR_EXP"">> "$CHARSHEET"
echo "LOCATION: "$CHAR_GPS"" >> "$CHARSHEET"
echo "HEALTH: "$CHAR_HEALTH"" >> "$CHARSHEET"
echo "ITEMS: "$CHAR_ITEMS"" >> "$CHARSHEET"
echo "KILLS: "$CHAR_KILLS"" >> "$CHARSHEET"
}

# CHAR SETUP
BiaminSetup() {
# Set CHARSHEET variable to gamedir/char.sheet (lowercase)
CHARSHEET=""$GAMEDIR"/$(echo "$CHAR" | tr '[:upper:]' '[:lower:]' | tr -d " ").sheet"

# Check whether CHAR exists if not create CHARSHEET
if [ -f "$CHARSHEET" ] ; then
	echo " Welcome back, "$CHAR"!"
	echo " Loading character sheet ..."
	CHAR=$(grep 'CHARACTER:' "$CHARSHEET" | sed 's/CHARACTER: //g')
	CHAR_RACE=$(grep 'RACE:' "$CHARSHEET" | sed 's/RACE: //g')
	CHAR_BATTLES=$(grep 'BATTLES:' "$CHARSHEET" | sed 's/BATTLES: //g')
	CHAR_EXP=$(grep 'EXPERIENCE:' "$CHARSHEET" | sed 's/EXPERIENCE: //g')
	CHAR_GPS=$(grep 'LOCATION:' "$CHARSHEET" | sed 's/LOCATION: //g')
	CHAR_HEALTH=$(grep 'HEALTH:' "$CHARSHEET" | sed 's/HEALTH: //g')
	CHAR_ITEMS=$(grep 'ITEMS:' "$CHARSHEET" | sed 's/ITEMS: //g')
	CHAR_KILLS=$(grep 'KILLS:' "$CHARSHEET" | sed 's/KILLS: //g')
	sleep 2
else
	echo " "$CHAR" is a new character!"
	CHAR_BATTLES=0
	CHAR_EXP=0
	CHAR_GPS="$START_LOCATION"
	CHAR_HEALTH=100
	CHAR_ITEMS=0
	CHAR_KILLS=0
	GX_Races
	echo -en " Select character race (1-4): " && read -sn 1 CHAR_RACE
	case $CHAR_RACE in
		2 ) echo "You chose to be an ELF" ;;
		3 ) echo "You chose to be a DWARF" ;;
		4 ) echo "You chose to be a HOBBIT" ;;
		1 | *) echo "You chose to be a HUMAN" ;;
	esac
	echo " Creating fresh character sheet for "$CHAR" ..."
	SaveCurrentSheet
	sleep 1
fi

# Set abilities according to race (equal to 12)
case $CHAR_RACE in
1 ) HEALING=3 && STRENGTH=3 && ACCURACY=3 && FLEE=3 ;; # human
2 ) HEALING=4 && STRENGTH=2 && ACCURACY=4 && FLEE=2 ;; # elf
3 ) HEALING=1 && STRENGTH=5 && ACCURACY=4 && FLEE=2 ;; # dwarf
4 ) HEALING=4 && STRENGTH=3 && ACCURACY=3 && FLEE=2 ;; # hobbit
esac

# Adjust abilities according to items and spells
if [ $CHAR_ITEMS -ge 2 ]; then
	HEALING=$[ $HEALING+1]				  # Adjusting for Emerald of Narcolepsy
	if [ $CHAR_ITEMS -ge 4 ]; then
		FLEE=$[ $FLEE+1 ]		 	  # Adjusting for Fast Magic Boots
		if [ $CHAR_ITEMS -ge 7 ]; then
			STRENGTH=$[ $STRENGTH+1 ]	  # Adjusting for Broadsword
			if [ $CHAR_ITEMS -ge 8 ]; then # Allows tampered files!
				ACCURACY=$[ $ACCURACY+1 ] # Adjusting for Steady Hand Brew
			fi
		fi
	fi
fi

# If Cheating is disabled (in CONFIGURATION) restrict health to 149
if [ $DISABLE_CHEATS -eq 1 ] && [ $CHAR_HEALTH -ge 150 ] ; then
	CHAR_HEALTH=100
	SaveCurrentSheet
fi

# Zombie fix
if [ $DEATH -eq 1 ]; then
	DEATH=0 && Intro
fi
}

# Today's Date (used in Highscore, Charsheet and in DEATH!)
# An adjusted version of warhammeronline.wikia.com/wiki/Calendar
TodaysDate() {
TODAYS_DATE=$(date +%F)		# YEAR-MM-DD
local IFS="-"
set $TODAYS_DATE
TODAYS_YEAR=$(echo $1)
TODAYS_MONTH=$(echo $2)
TODAYS_DATE=$(echo $3)

# Adjust date
case "$TODAYS_DATE" in
	01 ) TODAYS_DATE="1st" ;;
	02 ) TODAYS_DATE="2nd" ;;
	03 ) TODAYS_DATE="3rd" ;;
	04 | 05 | 06 | 07 | 08 | 09 ) TODAYS_DATE=$(echo ${dato#?}) && TODAYS_DATE+="th" ;;
	21 | 31 ) TODAYS_DATE+="st" ;;
	22 ) TODAYS_DATE+="nd" ;;
	23 ) TODAYS_DATE+="rd" ;;
	* ) TODAYS_DATE+="th" ;;
esac

# Adjust month
case "$TODAYS_MONTH" in
	01 ) TODAYS_MONTH="After-Witching" ;;
	02 ) TODAYS_MONTH="Year-Turn" ;;
	03 ) TODAYS_MONTH="Plough Month" ;;
	04 ) TODAYS_MONTH="Sigmar Month" ;;
	05 ) TODAYS_MONTH="Summer Month" ;;
	06 ) TODAYS_MONTH="Fore-Mystery" ;;
	07 ) TODAYS_MONTH="After-Mystery" ;;
	08 ) TODAYS_MONTH="Harvest Month" ;;
	09 ) TODAYS_MONTH="Brew Month" ;;
	10 ) TODAYS_MONTH="Chill Month" ;;
	11 ) TODAYS_MONTH="Ulric Month" ;;
	12 ) TODAYS_MONTH="Fore-Witching" ;;
	* ) TODAYS_MONTH="Biamin Festival" ;;  # rarely happens, if ever :(
esac

# Adjust year (removes 20 from 2013)
TODAYS_YEAR=$(echo ${TODAYS_YEAR#??})

# Output example "3rd of Year-Turn in the 13th cycle"
TODAYS_DATE_STR=$(echo ""$TODAYS_DATE" of "$TODAYS_MONTH" in the "$TODAYS_YEAR"th Cycle")	# "date sentence" LOL
}


################### MENU SYSTEM #################
# Main menu
MainMenu() {
	# The actual menu we use..
	TopMenu() {
	GX_Banner
	echo -en "        (P)lay    (L)oad game    (H)ighscore    (C)redits    (Q)uit   "
	read -sn 1 TOPMENU_OPT
	}
	TopMenu
	case "$TOPMENU_OPT" in
	p ) GX_Banner && echo -en " Enter character name (case sensitive): " && read "CHAR" && BiaminSetup;;
	h ) HighScore ;;
	l ) LoadGame ;;
	c ) Credits ;;
	q | * ) CleanUp ;;
	esac
}

# Highscore
HighscoreRead() {
sort -g -r "$HIGHSCORE" -o "$HIGHSCORE"
HIGHSCORE_TMP=$(mktemp "$GAMEDIR"/high.XXXXXX) # Dirty workaround to allow nice tabbed output..
echo -e " #;Hero;EXP;Wins;Items;Entered History\n; " > "$HIGHSCORE_TMP"
i=1
# Read values from highscore file (BashFAQ/001)
while IFS=";" read -r highEXP highCHAR highRACE highBATTLES highKILLS highITEMS highDATE highMONTH highYEAR; do
if [ $i -gt $SCORES_2_DISPLAY ]; then
	break
fi
case "$highRACE" in
	1 ) highRACE="Human" ;;
	2 ) highRACE="Elf" ;;
	3 ) highRACE="Dwarf" ;;
	4 ) highRACE="Hobbit" ;;
esac

echo " $i.;"$highCHAR" the "$highRACE";"$highEXP";"$highKILLS"/"$highBATTLES";"$highITEMS"/8;"$highMONTH" "$highDATE" ("$highYEAR")" >> "$HIGHSCORE_TMP"
((i++))
done < "$HIGHSCORE"
column -t -s ";" "$HIGHSCORE_TMP"			# Nice tabbed output!
rm -f "$HIGHSCORE_TMP" && unset HIGHSCORE_TMP
}

HighScore() {
GX_HighScore
echo -en "\n"
if grep -q 'd41d8cd98f00b204e9800998ecf8427e' "$HIGHSCORE" ; then
	echo " The highscore list is unfortunately empty right now."
	echo " You have to play some to get some!"
else
	SCORES_2_DISPLAY=10	# Show 10 highscore entries
	HighscoreRead
fi
echo -en "\n                   Press the any key to go to (M)ain menu    " && read -sn 1
MainMenu
}

Credits() {
GX_Credits
echo -en "                      (M)ain menu    (L)icense   (Q)uit               " && read -sn 1 "CREDITS_OPT"
case "$CREDITS_OPT" in
L | l ) License ;;
Q | q ) CleanUp ;;
M | * ) MainMenu ;;
esac
}

PrepareLicense() {
# wgets licenses and concatenates into "LICENSE" in $GAMEDIR
wget "http://www.gnu.org/licenses/gpl-3.0.txt" -q -O ""$GAMEDIR"/code-license"
wget "http://creativecommons.org/licenses/by-nc-sa/4.0/legalcode.txt" -q -O ""$GAMEDIR"/art-license"
LIC-PRE=$(mktemp "$GAMEDIR"/pre.XXXXXX)
LIC-INTER=$(mktemp "$GAMEDIR"/inter.XXXXXX)
echo -e "\t\t   BACK IN A MINUTE BASH CODE LICENSE:\n\n"$HR"\n" >> "$LIC-PRE"
echo -e "\n\n"$HR"\n\n\t\t   BACK IN A MINUTE ARTWORK LICENSE:\n\n" >> "$LIC-INTER"
cat "$LIC-PRE" ""$GAMEDIR"/code-license" "$LIC-INTER" ""$GAMEDIR"/art-license" > ""$GAMEDIR"/LICENSE"
rm -f ""$GAMEDIR"/code-license" && rm -f ""$GAMEDIR"/art-license" && rm -f "$LIC-PRE" && rm -f "$LIC-INTER"
echo "Licenses downloaded and concatenated!" && sleep 2
}

License() {
# Displays license if present or runs PrepareLicense && then display it..
clear
if [ -f ""$GAMEDIR"/LICENSE" ]; then
	less ""$GAMEDIR"/LICENSE"
else
	echo "License file currently missing in "$GAMEDIR"/ !"
	echo -en "To wget licenses, about 60kB, type YES (requires internet access): " && read "DL_LICENSE_OPT"
	case "$DL_LICENSE_OPT" in
	YES ) PrepareLicense && less ""$GAMEDIR"/LICENSE" ;;
	* ) echo -e "Find licensing info @ <"$WEBURL"about#license>\nPress any key to go back to main menu!" && read -sn 1;;
	esac
fi
MainMenu
}

LoadGame() {
# TODO This function could be more userfriendly (one typically hits a number, not writes a name...)
if [ $(find "$GAMEDIR"/ -name '*.sheet' | wc -l) -ge 1 ]; then
	GX_LoadGame && echo -en "\n"
	i=1
	for loadSHEET in "$GAMEDIR"/*.sheet ; do
		loadCHAR=$(grep 'CHARACTER:' "$loadSHEET" | sed 's/CHARACTER: //g')
		loadRACE=$(grep 'RACE:' "$loadSHEET" | sed 's/RACE: //g')
		case "$loadRACE" in
			1 ) loadRACE="Human" ;;
			2 ) loadRACE="Elf" ;;
			3 ) loadRACE="Dwarf" ;;
			4 ) loadRACE="Hobbit" ;;
		esac
		loadGPS=$(grep 'LOCATION:' "$loadSHEET" | sed 's/LOCATION: //g')
		loadHEALTH=$(grep 'HEALTH:' "$loadSHEET" | sed 's/HEALTH: //g')
		loadITEMS=$(grep 'ITEMS:' "$loadSHEET" | sed 's/ITEMS: //g')
	echo -en " $i. \""$loadCHAR"\" the "$loadRACE" (health: "$loadHEALTH", location: "$loadGPS", items: "$loadITEMS")\n"
	i=$[ $i+1 ]
	done
else
	GX_LoadGame && echo -en "\n"
	echo -e " Sorry! No character sheets in "$GAMEDIR"/"
fi
echo -en "\n Enter NAME of character to load or create (case sensitive): " && read "CHAR" && BiaminSetup
}

# GAME ITEMS
# Randomizer for Item Positions used in e.g. HotzonesDistribute
ITEM_X() {
ITEM_X=$(echo $((RANDOM%18+1)))
}
ITEM_Y() {
ITEM_Y=$(echo $((RANDOM%15+1)))
}

HotzonesDistribute() {
# Scatters special items across the map
if [ $CHAR_ITEMS -lt 8 ]; then
	ITEMS_2_SCATTER=$[ 8-$CHAR_ITEMS ]
	# default x-y HOTZONEs to extraterrestrial section 20-20
	HOTZONE=( 20-20 20-20 20-20 20-20 20-20 20-20 20-20 20-20 )
	i=7
	while [ $ITEMS_2_SCATTER -gt 0 ]; do
		ITEM_X && ITEM_Y
		HOTZONE[$i]="$ITEM_X-$ITEM_Y"
		((i--))
		ITEMS_2_SCATTER=$[ $ITEMS_2_SCATTER-1 ]
	done
fi
}


################### GAME SYSTEM #################

## GAME FUNCTIONS: DICE ROLLS
# TODO: Re-write to 1 function taking $1 as roll_d 6 = RANDOM%6+1
Roll_D6() {
DICE=$(echo $((RANDOM%6+1)))
}
Roll_D100() {
DICE=$(echo $((RANDOM%100+1)))
}
Roll_D20() {
DICE=$(echo $((RANDOM%20+1)))
}




## GAME FUNCTIONS: MAP LOCATION (gps fix)
# Fixes LOCATION in CHARSHEET "A1" to a place on the MapNav "X1,Y1"
GPS_Fix() {
MAP_X_TMP=$(grep 'LOCATION:' "$CHARSHEET" | sed 's/LOCATION: //g' | cut -c 1-1)
case "$MAP_X_TMP" in
 A ) MAP_X=1 ;;
 B ) MAP_X=2 ;;
 C ) MAP_X=3 ;;
 D ) MAP_X=4 ;;
 E ) MAP_X=5 ;;
 F ) MAP_X=6 ;;
 G ) MAP_X=7 ;;
 H ) MAP_X=8 ;;
 I ) MAP_X=9 ;;
 J ) MAP_X=10 ;;
 K ) MAP_X=11 ;;
 L ) MAP_X=12 ;;
 M ) MAP_X=13 ;;
 N ) MAP_X=14 ;;
 O ) MAP_X=15 ;;
 P ) MAP_X=16 ;;
 Q ) MAP_X=17 ;;
 R ) MAP_X=18 ;;
esac
unset MAP_X_TMP

MAP_Y=$(grep 'LOCATION:' "$CHARSHEET" | sed 's/LOCATION: .//g')
MAP_Y_TMP=$[ $MAP_Y + 2 ]

SCENARIO=$(sed -n "${MAP_Y_TMP}p" "$MAP" | sed 's/...)//g' | tr -d " " | cut -c $MAP_X-$MAP_X)
}

# Translate MAP_X numeric back to A-R
TranslatePosition() {
case $MAP_X in
1 ) MAP_X="A" ;;
2 ) MAP_X="B" ;;
3 ) MAP_X="C" ;;
4 ) MAP_X="D" ;;
5 ) MAP_X="E" ;;
6 ) MAP_X="F" ;;
7 ) MAP_X="G" ;;
8 ) MAP_X="H" ;;
9 ) MAP_X="I" ;;
10 ) MAP_X="J" ;;
11 ) MAP_X="K" ;;
12 ) MAP_X="L" ;;
13 ) MAP_X="M" ;;
14 ) MAP_X="N" ;;
15 ) MAP_X="O" ;;
16 ) MAP_X="P" ;;
17 ) MAP_X="Q" ;;
18 ) MAP_X="R" ;;
esac
}

## GAME FUNCTIONS: ITEMS IN LOOP
ItemWasFound() {
case "$CHAR_ITEMS" in
0 ) GX_Item0 ;;					# Gift of Sight (set in MapNav)
1 ) HEALING=$[ $HEALING+1 ] && GX_Item1 ;;	# Emerald of Narcolepsy (set now & setup)
2 ) GX_Item2 ;;					# Guardian Angel (set in battle loop)
3 ) FLEE=$[ $FLEE+1 ] && GX_Item3 ;; # Fast Magic Boots (set now & setup)
4 ) GX_Item4 ;;					# Quick Rabbit Reaction (set in battle loop)
5 ) GX_Item5 ;;					# Flask of Terrible Odour (set in battle loop)
6 ) STRENGTH=$[ $STRENGTH+1 ] && GX_Item6 ;;	# Two-Handed Broadsword	(set now & setup)
7 | *) ACCURACY=$[ $ACCURACY+1 ] && GX_Item7 ;;	# Steady Hand Brew (set now & setup)
esac
COUNTDOWN=180
while [ $COUNTDOWN -ge 0 ]; do
GX_Item$CHAR_ITEMS
echo "                      Press any letter to continue  ("$COUNTDOWN")" && read -sn 1 -t 1 SKIP
if [ -z "$SKIP" ]; then
	((COUNTDOWN--))
else
	COUNTDOWN=$[ $COUNTDOWN-180 ]
fi
done
unset SKIP

# Remove the item that is found from the world
i=0
while [ $i -le 7 ]; do
	if [ "$HERE_STR" = "${HOTZONE[$i]}" ] ; then
		HOTZONE[$i]="20-20"
	fi
	((i++))
done

# BUGFIX: re-distribute items to increase randomness. Fix to avoid items
# previously shown still there (but hidden) after a diff item was found..
HotzonesDistribute

# Save CHARSHEET items
CHAR_ITEMS=$[ $CHAR_ITEMS+1 ] && SaveCurrentSheet

if [ -n "$ITEM2C_prev" ] && [ "$HERE_STR" = "$ITEM2C_prev" ] ; then
	MapCreate		# makes sure $SCENARIO isn't invalid $ symbol
	GPS_Fix			# fetch the correct $SCENARIO from updated map
fi

DICE=99      		# no fighting if item is found..
}

LookForItem() {
# Checks current section HERE_STR for treasure
HERE_STR="$MAP_X-$MAP_Y"

if $(echo ${HOTZONE[@]/"$HERE_STR"/"ITEM_POSSIBLY_FOUND"} | grep -q "ITEM_POSSIBLY_FOUND") ; then # quick! but inaccurate
	# Rule out false positives of the above (e.g. HERE_STR 6-3 and HOTZONE 16-3)
	for i in "${HOTZONE[@]}" ; do
	if [ "$i" = "$HERE_STR" ] ; then
        	ItemWasFound
    	fi
	done
fi
}


## GAME ACTION: MAP + MOVE
MapNav() {
clear # Don't remove this

# Check for Gift of Sight
if [ $CHAR_ITEMS -eq 0 ] ; then
	GX_Map
elif [ $CHAR_ITEMS -gt 7 ]; then
	GX_Map
else
	GX_MapSight
fi

if [ $COLOR -eq 1 ] ; then
	echo -en " \033[1;33mo "$CHAR"\033[0m is currently in "$CHAR_GPS""
else
	echo -en " o "$CHAR" is currently in "$CHAR_GPS""
fi

case "$SCENARIO" in
H ) echo -e " (Home)" ;;
x ) echo -e " (Mountain)" ;;
. ) echo -e " (Road)" ;;
T ) echo -e " (Town)" ;;
@ ) echo -e " (Forest)" ;;
C ) echo -e " (Oldburg Castle)" ;;
esac
echo "$HR"
echo -en " I want to go  (N)orth  (E)ast  (S)outh  (W)est  (Q)uit  :  "
read -sn 1 DEST
case "$DEST" in
n | N ) # Going North (Reversed: Y-1)
	echo -en "Going North"
	if [ $[ $MAP_Y-1 ] -lt 1 ]; then
		echo -e "\nYou wanted to visit Santa, but walked in a circle.." && sleep 3
	else
		MAP_Y=$[ $MAP_Y-1 ]
		TranslatePosition
		CHAR_GPS="$MAP_X$MAP_Y"
		SaveCurrentSheet
		sleep 1
	fi
	;;
e | E ) # Going East (X+1)
	echo -en "Going East"
	if [ $[ $MAP_X+1 ] -gt 18 ]; then
		echo -e "\nYou tried to go East of the map, but walked in a circle.." && sleep 3
	else
		MAP_X=$[ $MAP_X+1 ]
		TranslatePosition
		CHAR_GPS="$MAP_X$MAP_Y"
		SaveCurrentSheet
		sleep 1
	fi
	;;
s | S ) # Going South (Reversed: Y+1)
	echo -en "Going South"
	if [ $[ $MAP_Y+1 ] -gt 15 ]; then
		echo -e "\nYou tried to go someplace warm, but walked in a circle.." && sleep 3
	else
		MAP_Y=$[ $MAP_Y+1 ]
		TranslatePosition
		CHAR_GPS="$MAP_X$MAP_Y"
		SaveCurrentSheet
		sleep 1
	fi		
	;;
w | W ) # Going West (X-1)
	echo -en "Going West"
	if [ $[ $MAP_X-1 ] -lt 1 ]; then
		echo -e "\nYou tried to go West of the map, but walked in a circle.." && sleep 3
	else
		MAP_X=$[ $MAP_X-1 ]
		TranslatePosition
		CHAR_GPS="$MAP_X$MAP_Y"
		SaveCurrentSheet
		sleep 1
	fi
	;;
q | Q ) SaveCurrentSheet && CleanUp ;;
* ) echo -en "Walking in circle" && sleep 2
esac
unset DEST
NewSection
}

# GAME ACTION: DISPLAY CHARACTER SHEET 
DisplayCharsheet() {
TodaysDate	# Fetches old world date format
if [ $CHAR_KILLS -gt 0 ] ; then
	MURDERSCORE=$(echo "scale=zero;100*$CHAR_KILLS/$CHAR_BATTLES" | bc -l) # kill/fight percentage
else
	MURDERSCORE=0
fi
GX_CharSheet
echo -en " Character:                 "$CHAR""
case $CHAR_RACE in
	1 ) echo " (Human)" ;;
	2 ) echo " (Elf)" ;;
	3 ) echo " (Dwarf)" ;;
	4 ) echo " (Hobbit)" ;;
esac
echo " Health Points:             "$CHAR_HEALTH""
echo " Experience Points:         "$CHAR_EXP""
echo -en " Current Location:          "$CHAR_GPS""
case "$SCENARIO" in
	H ) echo " (Home)" ;; 
	x ) echo " (Mountain)" ;;
	. ) echo " (Road)" ;;
	T ) echo " (Town)" ;;
	@ ) echo " (Forest)" ;;
	C ) echo " (Oldburg Castle)" ;;
esac
echo " Current Date:              "$TODAYS_DATE_STR""
echo " Number of Battles:         "$CHAR_BATTLES""
echo " Enemies Slain:             "$CHAR_KILLS" ("$MURDERSCORE"%)"
echo " Items found:               "$CHAR_ITEMS" of 8"
echo " Special Skills:            Healing "$HEALING", Strength "$STRENGTH", Accuracy "$ACCURACY", Flee "$FLEE""
echo -en "\n       (D)isplay Race Info       (R)est     (M)ap and Move     (Q)uit     "
read -sn 1 CHARSHEET_OPT
case "$CHARSHEET_OPT" in
	d | D ) GX_Races
		echo -en "\n                     (R)est     (M)ap and Move     (Q)uit     "
		read -sn1 CHARSHEET_OPT2
		case "$CHARSHEET_OPT2" in
		r | R ) Rest ;;
		m | M ) MapNav ;;
		q | Q | * ) SaveCurrentSheet && CleanUp ;;
		esac
		;;
	r | R ) Rest ;;
	m | M ) MapNav ;;
	q | Q | *) SaveCurrentSheet && CleanUp ;;
esac
}

# FIGHT MODE! (secondary loop for fights)
FightMode() {
LUCK=0		# Used to assess the match in terms of EXP..

# Determine enemy type
Roll_D20
case "$SCENARIO" in
H ) ENEMY="chthulu" ;; 
x ) if [ $DICE -le 10 ] ; then
	ENEMY="orc"
    elif [ $DICE -ge 16 ] ; then
	ENEMY="goblin"
    else
	ENEMY="varg"
    fi
    ;;
. ) if [ $DICE -le 12 ] ; then
	ENEMY="goblin"
    else
	ENEMY="bandit"
    fi
    ;;
T ) if [ $DICE -le 15 ] ; then
	ENEMY="bandit"
    else
	ENEMY="mage"
    fi
    ;;
@ ) if [ $DICE -le 8 ] ; then
	ENEMY="goblin"
    elif [ $DICE -ge 17 ] ; then
	ENEMY="orc"
    else
	ENEMY="bandit"
    fi
    ;;
C ) if [ $DICE -eq 1 ] ; then
	ENEMY="chthulu"
    else
	ENEMY="mage"
    fi
    ;;
esac
GX_Monster_$ENEMY

# ENEMY ATTRIBUTES; If you want to tune/balance the fights do it here!
case "$ENEMY" in
orc ) EN_STRENGTH=4 && EN_ACCURACY=4 && EN_FLEE=4 && EN_HEALTH=80 && EN_FLEE_THRESHOLD=40 ;;		# EN_FLEE_THRESHOLD
goblin ) EN_STRENGTH=3 && EN_ACCURACY=3 && EN_FLEE=5 && EN_HEALTH=30 && EN_FLEE_THRESHOLD=15 ;;		# At what Health will enemy flee?
bandit )EN_STRENGTH=2 && EN_ACCURACY=4 && EN_FLEE=7 && EN_HEALTH=30 && EN_FLEE_THRESHOLD=18 ;;
mage ) EN_STRENGTH=5 && EN_ACCURACY=5 && EN_FLEE=4 && EN_HEALTH=90 && EN_FLEE_THRESHOLD=45 ;;
varg ) EN_STRENGTH=5 && EN_ACCURACY=3 && EN_FLEE=3 && EN_HEALTH=80 && EN_FLEE_THRESHOLD=60 ;;
chthulu ) EN_STRENGTH=6 && EN_ACCURACY=5 && EN_FLEE=1 && EN_HEALTH=500 && EN_FLEE_THRESHOLD=350 ;;	# :)
esac
sleep 2

# Adjustments for items
if [ $CHAR_ITEMS -ge 5 ]; then
	ACCURACY=$[ $ACCURACY + 1 ]	# item4: Quick Rabbit Reaction
fi

if [ $CHAR_ITEMS -ge 6 ]; then
	EN_FLEE=$[ $EN_FLEE+1 ]	# item5: Flask of Terrible Odour
fi

# DETERMINE INITIATIVE (will usually be enemy)
if [ $EN_ACCURACY -gt $ACCURACY ]; then
	echo "The "$ENEMY" has initiative" && sleep 2
	NEXT_TURN="en"
else
	echo ""$CHAR" has the initiative!"
	echo -en "\n                            (F)ight or (E)scape?           "
	read -sn 1 FLEE_OPT
	case "$FLEE_OPT" in
		e | E ) echo -e "\nTrying to escape.. (Flee: "$FLEE")"
		Roll_D6
		if [ $DICE -le $FLEE ]; then
			echo "You rolled "$DICE" and managed to run away!" && sleep 2
			MapNav
		else
			echo "You rolled "$DICE" and lost your initiative.." && sleep 2
			NEXT_TURN="en"
		fi
		;;
		f | F | * ) NEXT_TURN="pl" ;;
	esac

fi

if [ $CHAR_ITEMS -ge 5 ]; then
	ACCURACY=$[ $ACCURACY-1 ]	# Resets Quick Rabbit Reaction setting..
fi




# GAME LOOP: FIGHT LOOP
while [ $EN_HEALTH -gt 0 ]
do
	if [ $CHAR_HEALTH -le 0 ] ; then
		echo -e "\nYour health points are "$CHAR_HEALTH"" && sleep 2
		echo "You WERE KILLED by the "$ENEMY", and now you are dead..." && sleep 2
		if [ $CHAR_EXP -ge 1000 ] && [ $CHAR_HEALTH -lt -5 ] && [ $CHAR_HEALTH -gt -15 ]; then
			echo "However, your "$CHAR_EXP" Experience Points relates that you have"
			echo "learned many wondrous and magical things in your travels..!"
			echo "+20 HEALTH: Health Restored to 20"
			CHAR_HEALTH=20
			LUCK=2 && EN_HEALTH=0
			sleep 8
			break	# bugfix: Resurrected player could continue fighting
		else
			if [ $CHAR_ITEMS -ge 3 ] && [ $CHAR_HEALTH -ge -5 ]; then
				echo "Suddenly you awake again, SAVED by your Guardian Angel!"
				echo "+5 HEALTH: Health Restored to 5"
				CHAR_HEALTH=5
				EN_HEALTH=0
				LUCK=2
				sleep 8
				break # bugfix: Resurrected player could continue fighting..
			else
				# DEATH!
				echo "Gain 1000 Experience Points to achieve magic healing!" && sleep 4
				case "$CHAR_RACE" in
					1 ) FUNERAL_RACE="human" ;;
					2 ) FUNERAL_RACE="elf" ;;
					3 ) FUNERAL_RACE="dwarf" ;;
					4 ) FUNERAL_RACE="hobbit" ;;
				esac
				TodaysDate		# Fetch today's date in Warhammer calendar
				COUNTDOWN=20
				while [ $COUNTDOWN -ge 0 ]; do
					GX_Death
					echo " The "$TODAYS_DATE_STR":"
					echo " In such a short life, this sorry "$FUNERAL_RACE" gained "$CHAR_EXP" Experience Points."
					echo " We honor "$CHAR" with "$COUNTDOWN" secs silence." && read -sn 1 -t 1 SKIP_FUNERAL
					if [ -z "$SKIP_FUNERAL" ]; then
						((COUNTDOWN--))
					else
						COUNTDOWN=$[ $COUNTDOWN-20 ]
					fi
				done
				unset SKIP_FUNERAL
				# overwrite or update highscore
				if grep -q 'd41d8cd98f00b204e9800998ecf8427e' "$HIGHSCORE" ; then
					echo ""$CHAR_EXP";"$CHAR";"$CHAR_RACE";"$CHAR_BATTLES";"$CHAR_KILLS";"$CHAR_ITEMS";"$TODAYS_DATE";"$TODAYS_MONTH";"$TODAYS_YEAR"" > "$HIGHSCORE"
				else
					echo ""$CHAR_EXP";"$CHAR";"$CHAR_RACE";"$CHAR_BATTLES";"$CHAR_KILLS";"$CHAR_ITEMS";"$TODAYS_DATE";"$TODAYS_MONTH";"$TODAYS_YEAR"" >> "$HIGHSCORE"
				fi
				rm -f "$CHARSHEET"			# A sense of loss is important for gameplay:)
				unset CHARSHEET				# Zombie fix
				unset CHAR
				unset CHAR_RACE
				unset CHAR_HEALTH
				unset CHAR_EXP
				unset CHAR_GPS
				unset SCENARIO
				unset CHAR_BATTLES
				unset CHAR_KILLS
				unset CHAR_ITEMS
				DEATH=1	&& EN_HEALTH=0 && break 	# Zombie fix
			fi
		fi
	fi
	GX_Monster_$ENEMY
	echo -e ""${SHORTNAME^}"\t\tHEALTH: "$CHAR_HEALTH"\tStrength: "$STRENGTH"\tAccuracy: "$ACCURACY"" | tr '_' ' '
	echo -e ""${ENEMY^}"\t\t\tHEALTH: "$EN_HEALTH"\tStrength: "$EN_STRENGTH"\tAccuracy: "$EN_ACCURACY""
	if [ "$NEXT_TURN" = "pl" ] ; then
		# Player's turn
		echo -en "\nIt's your turn, press the R key to (R)oll" && read -sn 1 "FIGHT_PROMPT" # Bugfix: repeated keys (not sure about these..)
		Roll_D6
		GX_Monster_$ENEMY
		echo -e ""${SHORTNAME^}"\t\tHEALTH: "$CHAR_HEALTH"\tStrength: "$STRENGTH"\tAccuracy: "$ACCURACY"" | tr '_' ' '
		echo -e ""${ENEMY^}"\t\t\tHEALTH: "$EN_HEALTH"\tStrength: "$EN_STRENGTH"\tAccuracy: "$EN_ACCURACY""
		echo -en "\nROLL D6: "$DICE""
		unset FIGHT_PROMPT # Bugfix: repeated keys
		if [ $DICE -le $ACCURACY ]; then
			echo -e "\tAccuracy [D6 "$DICE" < $ACCURACY] Your weapon hits the target!"
			echo -en "Press the R key to (R)oll for damage" && read -sn 1 "FIGHT_PROMPT" # Bugfix: repeated keys
			Roll_D6
			echo -en "\nROLL D6: "$DICE""
			DAMAGE=$[ $DICE * $STRENGTH ]
			echo -en "\tYour blow dishes out "$DAMAGE" damage points!"
			EN_HEALTH=$[ $EN_HEALTH-$DAMAGE ]		
			NEXT_TURN="en" && sleep 3
			unset FIGHT_PROMPT # Bugfix: repeated keys
		else
			echo -e "\tAccuracy [D6 "$DICE" > $ACCURACY] You missed!"
			NEXT_TURN="en" && sleep 2
		fi
	else
		# Enemy's turn
		if [ $EN_HEALTH -gt 0 ]; then
			echo -en "\nIt's the "$ENEMY"'s turn" && sleep 2
			Roll_D6
			if [ $DICE -le $EN_ACCURACY ] ; then
				echo -en "\nAccuracy [D6 "$DICE" < "$EN_ACCURACY"] The "$ENEMY" strikes you!"
				Roll_D6
				DAMAGE=$[ $DICE * $EN_STRENGTH ]
				echo -en "\n-"$DAMAGE" HEALTH: The "$ENEMY"'s blow hits you with "$DAMAGE" points!"
				CHAR_HEALTH=$[ $CHAR_HEALTH - $DAMAGE ]
				SaveCurrentSheet
				NEXT_TURN="pl" && sleep 3
			else
				echo -e "\nAccuracy [D6 "$DICE" > "$EN_ACCURACY"] The "$ENEMY" misses!"
				NEXT_TURN="pl" && sleep 2
			fi
		fi
	fi
	if [ "$NEXT_TURN" = "en" ] ; then
		if [ $EN_HEALTH -gt 0 ] && [ $EN_HEALTH -lt $EN_FLEE_THRESHOLD ] && [ $EN_HEALTH -lt $CHAR_HEALTH ] ; then
			Roll_D20
			echo -e "\nRolling for enemy flee: D20 < "$EN_FLEE"" && sleep 1
			if [ $DICE -lt $EN_FLEE ] ; then
				echo -en "ROLL D20: "$DICE""
				echo -e "\tThe "$ENEMY" uses an opportunity to flee!"
				LUCK=1 && EN_HEALTH=0
				sleep 2
			fi
		fi
	fi	
done

if [ $DEATH -eq 1 ]; then
	HighScore # zombie fix
else
	# VICTORY!
	if [ $LUCK -eq 2 ]; then
		# died but saved by guardian angel or 1000 EXP
		echo "When you come to, the "$ENEMY" has left the area ..."
	else
		if [ $LUCK -eq 1 ]; then
			# ENEMY ran away
			echo -en "You defeated the "$ENEMY" and gained"
			case "$ENEMY" in
				bandit ) echo " 10 Experience Points!" && CHAR_EXP=$[ $CHAR_EXP + 10 ] ;;
				goblin ) echo " 15 Experience Points!" && CHAR_EXP=$[ $CHAR_EXP + 15 ] ;;
				orc ) echo " 25 Experience Points!" && CHAR_EXP=$[ $CHAR_EXP + 25 ] ;;
				varg ) echo " 50 Experience Points!" && CHAR_EXP=$[ $CHAR_EXP + 50 ] ;;
				mage ) echo " 75 Experience Points!" && CHAR_EXP=$[ $CHAR_EXP + 75 ] ;;
				chthulu ) echo "500 Experience Points!" && CHAR_EXP=$[ $CHAR_EXP + 500 ] ;;
			esac
		else
			# enemy was slain!
			GX_Monster_$ENEMY
			echo -e ""${SHORTNAME^}"\t\tHEALTH: "$CHAR_HEALTH"\tStrength: "$STRENGTH"\tAccuracy: "$ACCURACY"" | tr '_' ' '
			echo -e ""${ENEMY^}"\t\t\tHEALTH: "$EN_HEALTH"\tStrength: "$EN_STRENGTH"\tAccuracy: "$EN_ACCURACY""
			echo -en "\nYou defeated the "$ENEMY" and gained"
			case "$ENEMY" in
				bandit ) echo " 20 Experience Points!" && CHAR_EXP=$[ $CHAR_EXP + 20 ] ;;
				goblin ) echo " 30 Experience Points!" && CHAR_EXP=$[ $CHAR_EXP + 30 ] ;;
				orc ) echo " 50 Experience Points!" && CHAR_EXP=$[ $CHAR_EXP + 50 ] ;;
				varg ) echo " 100 Experience Points!" && CHAR_EXP=$[ $CHAR_EXP + 100 ] ;;
				mage ) echo " 150 Experience Points!" && CHAR_EXP=$[ $CHAR_EXP + 150 ] ;;
				chthulu ) echo "1000 Experience Points!" && CHAR_EXP=$[ $CHAR_EXP + 1000 ] ;;
			esac
			CHAR_KILLS=$[ $CHAR_KILLS + 1 ]
		fi
	fi
	CHAR_BATTLES=$[ $CHAR_BATTLES + 1 ]
	SaveCurrentSheet
	sleep 3
	DisplayCharsheet
fi
}

RollForHealing() {
# For use in Rest
Roll_D6
echo "Rolling for healing: D6 <= "$HEALING""
echo "ROLL D6: "$DICE""
}


# GAME ACTION: REST
# Game balancing can also be done here, if you think players receive too much/little health by resting.
Rest() {
Roll_D100
GX_Rest
case "$SCENARIO" in
H ) if [ $CHAR_HEALTH -lt 100 ]; then
	CHAR_HEALTH=100 && echo "You slept well in your own bed. Health restored to 100."
	else
	echo "You slept well in your own bed, and woke up to a beautiful day."
    fi
    sleep 2
    ;;
x ) echo "Rolling for event: D100 <= 50" && echo "ROLL D100: "$DICE"" && sleep 2
    if [ $DICE -le 50 ]; then
	FightMode
    	else
		RollForHealing
		if [ $DICE -le $HEALING ]; then
			CHAR_HEALTH=$[ $CHAR_HEALTH+5 ]
			echo "You slept well and gained 5 Health."
				else
			echo "The terrors of the mountains kept you awake all night.."
		fi
		sleep 2
	fi ;;
. ) echo "Rolling for event: D100 <= 20" && echo "ROLL D100: "$DICE"" && sleep 2
    if [ $DICE -le 20 ]; then
	FightMode
    	else
		RollForHealing
		if [ $DICE -le $HEALING ]; then
			CHAR_HEALTH=$[ $CHAR_HEALTH+10 ]
			echo "You slept well and gained 10 Health."
				else
			echo "The dangers of the roads gave you little sleep if any.."
		fi
		sleep 2
	fi ;;
T ) echo "Rolling for event: D100 <= 15" && echo "ROLL D100: "$DICE"" && sleep 2
    if [ $DICE -le 15 ]; then
	FightMode
    	else
		RollForHealing
		if [ $DICE -le $HEALING ]; then
			CHAR_HEALTH=$[ $CHAR_HEALTH+20 ]
			echo "You slept well and gained 20 Health."
				else
			echo "The vices of town life kept you up all night.."
		fi
		sleep 2
	fi ;;
@ ) echo "Rolling for event: D100 <= 35" && echo "ROLL D100: "$DICE"" && sleep 2
    if [ $DICE -le 35 ]; then
	FightMode
    	else
		RollForHealing
		if [ $DICE -le $HEALING ]; then
			CHAR_HEALTH=$[ $CHAR_HEALTH+5 ]
			echo "You slept well and gained 5 Health."
				else
			echo "Possibly dangerous wood owls kept you awake all night.."
		fi
		sleep 2
	fi ;;
C ) echo "Rolling for event: D100 <= 5" && echo "ROLL D100: "$DICE"" && sleep 2
    if [ $DICE -le 5 ]; then
	FightMode
    	else
		RollForHealing
		if [ $DICE -le $HEALING ]; then
			CHAR_HEALTH=$[ $CHAR_HEALTH+50 ]
			echo "You slept well and gained 50 Health."
				else
			echo "Rowdy castle soldiers on a drinking binge kept you awake.."
		fi
		sleep 2
	fi ;;
esac
sleep 2
MapNav
}


# GAME ACTIONS MENU BAR
ActionsBar() {
	echo -en "          (C)haracter     (R)est     (M)ap and Travel     (Q)uit   "
	read -sn 1 ACTION
	case "$ACTION" in
		c | C ) DisplayCharsheet ;;
		r | R ) Rest ;;
		m | M ) MapNav ;;
		q | Q | *) SaveCurrentSheet && CleanUp ;;
	esac
}



# THE GAME LOOP
NewSection() {
Roll_D100

# Find out where we are
GPS_Fix

# Look for treasure @ current GPS location
if [ $CHAR_ITEMS -lt 8 ]; then
	LookForItem
fi

# Find out if we're attacked, else disp scenario
case "$SCENARIO" in
H ) GX_Home
	echo "Rolling for event: D100 = 66"
	echo "D100: "$DICE"" && sleep 2
	if [ $DICE -eq 66 ]; then
		FightMode
	else
		GX_Home
		CHAR_HEALTH=100
	fi
	;;
x ) GX_Mountains
	echo "Rolling for event: D100 <= 50"
	echo "D100: "$DICE"" && sleep 2
	if [ $DICE -le 50 ]; then
		FightMode
	else
		GX_Mountains
	fi
	;;
. ) GX_Road
	echo "Rolling for event: D100 <= 20"
	echo "D100: "$DICE"" && sleep 2
	if [ $DICE -le 20 ]; then
		FightMode
	else
		GX_Road
	fi
	;;
T ) GX_Town
	echo "Rolling for event: D100 <= 15"
	echo "D100: "$DICE"" && sleep 2
	if [ $DICE -le 15 ]; then
		FightMode
	else
		GX_Town
	fi
	;;
@ ) GX_Forest
	echo "Rolling for event: D100 <= 35"
	echo "D100: "$DICE"" && sleep 3
	if [ $DICE -le 35 ]; then
		FightMode
	else
		GX_Forest
	fi	
	;;
C ) GX_Castle
	echo "Rolling for event: D100 <= 10"
	echo "D100: "$DICE"" && sleep 2
	if [ $DICE -le 10 ]; then
		FightMode
	else
		GX_Castle
	fi
	;;
Z |* )  clear
        echo "Whoops! There is an error with your map file!"
	echo "Either it contains unknown characters or it uses incorrect whitespace."
	echo "Recognized characters are: x . T @ H C"
	echo -e "Please run game with --map argument to create a new template as a guide.\n"
	CustomMapError
	;;
esac
# Display Menu
ActionsBar
}

# Create FIGHT CHAR name
CosmeticName() {
SHORTNAME="$CHAR"
SHORTNAME_LENGTH=$(echo "${#SHORTNAME}")
if [ $SHORTNAME_LENGTH -le 7 ] ; then
	SPACER="_"
	while [ $SHORTNAME_LENGTH -le 12 ]
	do
		SHORTNAME=""$SHORTNAME""$SPACER""
		SHORTNAME_LENGTH=$(echo "${#SHORTNAME}")

	done
else
	SHORTNAME=$(echo "$SHORTNAME" | cut -c 1-15)
fi
}

# Intro function basically gets the game going
Intro() {
CosmeticName 		# Cosmetic name for fight loop
HotzonesDistribute 	# Place items randomly in map
COUNTDOWN=60
while [ $COUNTDOWN -ge 0 ]; do
GX_Intro
echo "                       Press any letter to continue" && read -sn 1 -t 1 SKIP
if [ -z "$SKIP" ]; then
	((COUNTDOWN--))
else
	COUNTDOWN=$[ $COUNTDOWN-61 ]
fi
done
unset SKIP

# DEBUG Display HOTZONEs
# Please Leave commented, has ill-effect on gameplay!)
#clear
#echo "Echo HOTZONEs"
#echo -e "${HOTZONE[0]}"
#i=0
#while [ $i -lt 8 ] ; do
#	echo -e ""$i". ${HOTZONE[$i]}"
#	((i++))
#done
#read -sn 1
# DEBUG

NewSection
}


Announce() {
# Simply outputs a 160 char text you can cut & paste to social media.
# I was gonna use pump.io for this, but too much hassle && dependencies..

SetupHighscore
if grep -q 'd41d8cd98f00b204e9800998ecf8427e' "$HIGHSCORE" ; then
	echo "Sorry, can't do that just yet!"
	echo "The highscore list is unfortunately empty right now."
	exit
else
	echo -e "TOP 10 BACK IN A MINUTE HIGHSCORES\n"
	SCORES_2_DISPLAY=10
	HighscoreRead
	echo -en "\nSelect the highscore (1-10) you'd like to display or CTRL+C to cancel: " && read SCORE_TO_PRINT
	if [ $SCORE_TO_PRINT -ge 1 ] && [ $SCORE_TO_PRINT -le 10 ]; then
		ANNOUNCEMENT_TMP=$(mktemp ""$GAMEDIR"/hello.XXXXXX")
		sed -n "${SCORE_TO_PRINT}","${SCORE_TO_PRINT}"p "$HIGHSCORE" > "$ANNOUNCEMENT_TMP"
		Roll_D6
		case "$DICE" in
		1 ) ADJECTIVE="honorable" ;;
		2 ) ADJECTIVE="fearless" ;;
		3 ) ADJECTIVE="courageos" ;;
		4 ) ADJECTIVE="brave" ;;
		5 ) ADJECTIVE="legendary" ;;
		6 ) ADJECTIVE="heroic" ;;
		esac
		while IFS=";" read -r highEXP highCHAR highRACE highBATTLES highKILLS highITEMS highDATE highMONTH highYEAR; do
			case $highRACE in
				1 ) highRACE="Human" ;;
				2 ) highRACE="Elf" ;;
				3 ) highRACE="Dwarf" ;;
				4 ) highRACE="Hobbit" ;;
			esac
			if [ $highBATTLES -eq 1 ]; then
				highBATTLES_STR="battle"
			else
				highBATTLES_STR="battles"
			fi
			if [ $highITEMS -eq 1 ]; then
				highITEMS_STR="item"
			else
				highITEMS_STR="items"
			fi
		highCHAR=$(echo ${highCHAR^})
		ANNOUNCEMENT=""$highCHAR" fought "$highBATTLES" "$highBATTLES_STR", "$highKILLS" victoriously, won "$highEXP" EXP and "$highITEMS" "$highITEMS_STR". This "$ADJECTIVE" "$highRACE" was finally slain the "$highDATE" of "$highMONTH" in the "$highYEAR"th Cycle."
		done < "$ANNOUNCEMENT_TMP"
		rm -f "$ANNOUNCEMENT_TMP" && unset ANNOUNCEMENT_TMP
		echo -en "\n"
		ANNOUNCEMENT_LENGHT=$(echo "${#ANNOUNCEMENT}")
		GX_HighScore
		echo "ADVENTURE SUMMARY to copy and paste to your social media of choice:"
		echo -e "\n"$ANNOUNCEMENT"\n"
		echo -e "$HR\n"
		if [ $ANNOUNCEMENT_LENGHT -gt 160 ] ; then
			echo "Warning! String longer than 160 chars ("$ANNOUNCEMENT_LENGHT")!"
		fi
		exit
	else
		echo -e "\nOut of range. Please select an entry between 1-10. Quitting.." && exit
	fi
fi
}

		        
#                           END FUNCTIONS                              #       
#                                                                      #       
#                                                                      #
########################################################################





########################################################################       
#                                                                      #
#                        2. RUNTIME BLOCK                              #
#                   All running code goes here!                        #
									       


# Parse CLI arguments if any
case "$1" in
	--announce )   	Announce ;;
	--h | --help )	echo "Run the game BACK IN A MINUTE without arguments to play!"
			echo "For usage: run biamin --usage"
			echo -e "\nCurrent dir for game files: "$GAMEDIR"/"
			echo "Change this setting on line 10 in the CONFIGURATION section of script."

			exit ;;
	--map )         echo -e "Create custom map template?"
			CUSTOM_MAP_PROMPT="Yes No"
			select OPT in $CUSTOM_MAP_PROMPT; do
			if [ "$OPT" = "Yes" ]; then
				echo "Creating custom map template.."
				break
			elif [ "$OPT" = "No" ]; then
				echo "Not doing anything! Quitting.."
				exit
			else
				echo "Bad option! Quitting.."
				exit
			fi
			done
			MapCreateCustom ;;
	--play | go ) 	echo "Launching Back in a Minute.." ;;
	--usage | * )	echo "Usage: biamin or ./biamin.sh"
            echo "  (NO ARGUMENTS)      display this usage text and exit"
            echo "  --play              PLAY the game \"Back in a minute\""
			echo "  --announce          DISPLAY an adventure summary for social media and exit"
			echo "  --map               CREATE custom map template with instructions and exit"
			echo "  --help              display help text and exit"
			echo "  --usage             display this usage text and exit" 
			echo "  --version           display version and licensing info and exit"
			exit ;;

        --v | --version )	echo -e "BACK IN A MINUTE VERSION "$VERSION" Copyright (C) 2014 Sigg3.net"
			echo -e "\nGame SHELL CODE released under GNU GPL version 3 (GPLv3)."
			echo "This is free software: you are free to change and redistribute it."
			echo "There is NO WARRANTY, to the extent permitted by law."
			echo "For details see: <http://www.gnu.org/licenses/gpl-3.0>"
			echo -e "\nGame ARTWORK released under Creative Commons CC BY-NC-SA 4.0."
			echo "You are free to copy, distribute, transmit and adapt the work."
			echo "For details see: <http://creativecommons.org/licenses/by-nc-sa/4.0/>"
			echo -e "\nGame created by Sigg3. Submit bugs & feedback at <"$WEBURL">"
			exit ;;
esac

# Check whether gamedir exists..
if [ -d "$GAMEDIR" ] ; then
	echo "Putting on the traveller's boots.."
else
	# TODO create a function for creating game dir..?
	# IT MUST a) ask for permission to do so
	#		  b) ask for path
	#		  c) copy itself "biamin.sh" to the path in b)
	#		  d) change line 10 in CONFIGURATION to reflect b)
	#		  e) exit itself and launch new gamedir's biamin.sh..!
	echo "Please create "$GAMEDIR"/ directory before running" && exit
fi

# Color configuration
if [ -f ""$GAMEDIR"/color" ] ; then
	read COLOR < ""$GAMEDIR"/color"
	if [ "$COLOR" = "ENABLE" ] ; then
		COLOR=1
		echo "Enabling color for maps!"
	elif [ "$COLOR" = "DISABLE" ] ; then
		COLOR=0
		echo "Enabling old black-and-white version!"
	else
		rm -f ""$GAMEDIR"/color"
		echo "Color config is faulty. Please run biamin again to configure colors!"
		exit
	fi
else
	echo "We need to configure terminal colors for the map!"
	echo "Note: A symbol that is colored is easier to see on the world map!"
	echo "Back in a minute was designed for white text on black background."
	echo -e "Does \033[1;33mthis text appear yellow\033[0m without any funny characters?"
	echo "Hit 1 for YES (enable color) and 2 for NO (disable color)."
	COLOR_CONFIG="Enable Disable"
	select OPT in $COLOR_CONFIG; do
	if [ "$OPT" = "Enable" ]; then
		echo "Enabling color!"
		COLOR=1
		echo "ENABLE" > ""$GAMEDIR"/color" && break
	elif [ "$OPT" = "Disable" ]; then
		echo "Disabling color!"
		COLOR=0
		echo "DISABLE" > ""$GAMEDIR"/color" && break
	else
		echo "Bad option! Quitting.."
		exit
	fi
	done
	sleep 1
fi

# Direct termination signals to CleanUp
trap CleanUp SIGHUP SIGINT SIGTERM

# Removes any stranded map files
if [ $(find "$GAMEDIR"/map.* | wc -l) -ge 1 ] ; then
	rm -f "$GAMEDIR"/map.*
else
	clear # removes 'file not found' from stdout
fi

# Setup highscore file
SetupHighscore

# Create session map
MAP=$(mktemp "$GAMEDIR"/map.XXXXXX)
MapCreate

# Zombie bugfix (DO NOT REMOVE)
DEATH=0

# Run main menu
MainMenu

# Runs Intro and starts the game
Intro

# This should never happen:
exit
# .. but why be 'tardy when you can be tidy?

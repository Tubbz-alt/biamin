########################################################################
#                       Marketplace-related ASCII                      #
#                             (gpl-version)                            #

GX_Marketplace() { 
    clear
    echo "Several Town shoppes view'd from end o' the street"
    echo "$HR"
}

#-----------------------------------------------------------------------
# GX_Marketplace_Grocer()
# Display Grocer ASCII. If $1 and $2 also display prices for FOOD and
# TOBACCO.
# Arguments: (optional) $PRICE_FxG(float), $PRICE_FxT(float).
#-----------------------------------------------------------------------
GX_Marketplace_Grocer() {
    clear
    echo "                                  THE GROCER"
    echo ""
    echo "        \"Welcome to my humble store, traveller, tell me what you need!"
    echo "           If we don't have it, I suspect nobody else will neither.\""           
    echo "$HR"
    if [[ "$@" ]]; then
	echo "                   1 FOOD costs $1 Gold or $2 Tobacco."
    fi
}


#-----------------------------------------------------------------------
# GX_Marketplace_Merchant()
# (Goatee == dashing, not hipster)
# Used: Marketplace_Merchant() 
#-----------------------------------------------------------------------
GX_Marketplace_Merchant() { 
    clear
    echo "                                 THE MERCHANT"
    echo "$HR"
}


#-----------------------------------------------------------------------
# GX_Marketplace_Beggar()
# Used: Marketplace_Beggar()
#-----------------------------------------------------------------------
GX_Marketplace_Beggar() {
    clear
    echo "                                THE OLD BEGGAR"
    echo "$HR"
}


#                                                                      #
#                                                                      #
########################################################################


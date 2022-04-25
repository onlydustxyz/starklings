function score() {
    echo "Type the player address: "
    read
    val=${REPLY}
    nile call tournament player_score $val
}

function dust_balance() {
    echo "Type the account address: "
    read
    val=${REPLY}
    nile call only_dust_token balanceOf $val
}

function boarding_pass_balance() {
    echo "Type the account address: "
    read
    val=${REPLY}
    nile call starkonquest_boarding_pass balanceOf $val
}

function mint_boarding_pass() {
    echo "Type the recipient address: "
    read
    to=${REPLY}
    echo "Type the token id (low): "
    read
    id_low=${REPLY}
    echo "Type the token id (high): "
    read
    id_high=${REPLY}
    nile invoke starkonquest_boarding_pass mint $to $id_low $id_high
}

while true; do
    select yn in "Score" "Dust-Balance" "Boarding-Pass-Balance" "Mint-Boarding-Pass" "Quit"; do
        case $yn in
            Score ) score; break;;
            Dust-Balance) dust_balance; break;;
            Boarding-Pass-Balance) boarding_pass_balance; break;;
            Mint-Boarding-Pass) mint_boarding_pass; break;;
            Quit ) exit;;
        esac
    done
done
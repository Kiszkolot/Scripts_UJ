game_state=(0 1 2 3 4 5 6 7 8)
turn=0

function draw () {
    separator="-------"
    echo ${separator}
    for i in 0 1 2
        do
            line="|"
            for j in 0 1 2
                do
                    line=${line}"${game_state[$i*3 +$j]}|"
                done
            echo ${line}
        echo ${separator}
        done
}

function move () {
    c=""
    if (( turn%2==0 )) ; then
        c="X"
    else
        c="O"
    fi
    if [ ${game_state[$1]} = "X" ] || [ ${game_state[$1]} = "O" ]; then
        echo "Cannot move there. Type another field please"
        read field
        move $field
    else 
        game_state[$1]=${c}
        turn=$(($turn+1))
    fi
}

function win_condition() {
    if [[ ${game_state[0]} == ${game_state[4]} && ${game_state[4]} = ${game_state[8]} ]] ||
            [[ ${game_state[2]} = ${game_state[4]} && ${game_state[4]} = ${game_state[6]} ]]; then
        return $(($turn%2))
    fi
    for i in 0 1 2
        do
            if [[ ${game_state[3*$i]} = ${game_state[3*$i+1]} && ${game_state[3*$i+2]} = ${game_state[3*$i+1]} ]] ||
                [[ ${game_state[$i]} = ${game_state[$i+3]} && ${game_state[$i+3]} = ${game_state[$i+6]} ]]; then
                return $(($turn%2))
            fi
        done
    if [[ $turn == 9 ]]; then
        return 2
    fi
    return 3
}

function save_game() {
    mkdir -p ./SAVES;
    name=$1
    res="$(join , ${game_state})"
    echo "$res" > "./SAVES/$name.txt"
}

function join() {
    local IFS="$1"
    shift
    echo "${game_state[@]}"
}

function load_game() {
    name=$1
    input="./SAVES/$name.txt"
    if [ -f $input ]; then
        while IFS= read -r line; do
            for ((i=0; i < 18; i=$i+2)); do
                game_state[$i/2]=${line:i:1}
                if [ ${game_state[$i/2]} = "X" ] || [ ${game_state[$i/2]} = "O" ]; then 
                    turn=$((turn+1))
                fi
            done
        done < "$input"
        if [[ $turn/2 == 0 ]]; then
            echo "O moves"
        else
            echo "X moves"
        fi
    else 
        echo "Such save file does not exist. Starting new game"
    fi
}

function bot_move() {
    echo "Bot move..."
    for ((i=0; i<9; i++)); do
        if [[ ${game_state[$i]} != "X"  &&  ${game_state[$i]} != "O" ]]; then
            move $i
            break
        fi
    done
}

function init() {
    echo "New Game (N) or Load Game (L)"
    read choice

    case $choice in

        L)
            echo "Gimme name"
            read name
            load_game $name
        ;;

        N)
            game_state=(0 1 2 3 4 5 6 7 8)
            turn=0
        ;;

    esac
    echo "Game created"
}

function win_message() {
    case $1 in

        0)
            echo "Winner is Cross (X)"
        ;;
        1)
            echo "Winner is Circle (O)"
        ;;
        2)
            echo "Draw"
        ;;
    esac
}

function check_win() {
    win_condition
    if [[ "$?" -ne "3" ]]; then
        win_message $?
        return 1
    fi
    return 0
}

function OneP() {
    while :; do
        draw
        echo "Choose one of the fields (0..8) or save game (S)"
        read choice

        case $choice in 

            S)
                echo "Give me the name of the file"
                read name
                save_game $name
            ;;

            0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8)
                move $choice
                check_win
                if [[ $? == 1 ]]; then
                    break
                fi
                bot_move
                draw
                check_win
                if [[ $? == 1 ]]; then
                    break
                fi
            ;;
        esac
    done
}

function TwoP() {
    while :; do
        draw
        echo "Choose one of the fields (0..8) or save game (S)"
        read choice

        case $choice in 

            S)
                echo "Give me the name of the file"
                read name
                save_game $name
            ;;

            0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8)
                move $choice
                check_win
                if [[ $? == 1 ]]; then
                    break
                fi
            ;;
        esac
    done
}

function game_mode() {
    case $1 in

        1)
        OneP
        ;;
        2) 
        TwoP
        ;;
        *)
        echo 
        ;;

    esac  
}

function run() {
    init
    echo "Choose game mode: 1P (1) or 2P (2)"
    read choice
    game_mode $choice
}

run
#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
USERS_FILE="$SCRIPT_DIR/users.csv"
HOME_DIR="$SCRIPT_DIR/user_homes"
mkdir -p "$HOME_DIR"
touch "$USERS_FILE"
LOGGED_IN_USERS=()

hash_password() {
    echo -n "$1" | sha256sum | cut -c1-64
}

generate_id() {
    echo "$((RANDOM + $$))" | sha256sum | cut -c1-8
}

show_menu() {
    echo ""
    echo "1. Creeaza un cont"
    echo "2. Intra in sistem"
    echo "3. Iesi din sistem"
    echo "4. Cerere raport de activitate"
    echo "0. Inchide Matrix"
    echo ""
    read -p "Alege o optiune: " opt
}

register_user() {
    echo "Creare utilizator nou.."
    read -p "Nume utilizator: " username_input
    username="$username_input"
    grep -q "^$username," "$USERS_FILE" && echo "Utilizatorul exista deja!" && return

    read -p "Email: " email
    [[ ! "$email" =~ "@" ]] && echo "Email invalid!" && return

    read -s -p "Seteaza parola: " password; echo
    read -s -p "Confirma parola: " password2; echo
    [[ "$password" != "$password2" ]] && echo "Parolele nu coincid!" && return

    pass_hash=$(hash_password "$password")
    uid=$(generate_id)
    mkdir -p "$HOME_DIR/$username"

    echo "$uid" > "$HOME_DIR/$username/agent_id.txt"
    echo "Contul tau a fost creat cu succes. ID: $uid" > "$HOME_DIR/$username/email_simulat.txt"
    echo "ID-ul unic al utilizatorului este: $uid"
    echo "$username,$email,$pass_hash,$uid,N/A" >> "$USERS_FILE"

    echo "Utilizatorul $username a fost inregistrat cu succes!"
}

login_user() {
    read -p "Cod utilizator: " username_input
    username="$username_input"
    line=$(grep "^$username," "$USERS_FILE") || { echo "Utilizator inexistent!"; return; }
    stored_hash=$(echo "$line" | cut -d',' -f3)
    email=$(echo "$line" | cut -d',' -f2)

    read -s -p "Parola: " password; echo
    [[ "$(hash_password "$password")" == "$stored_hash" ]] || { echo "Acces respins!"; return; }

    LOGGED_IN_USERS+=("$username")
    sed -i "s/^$username,\([^,]*\),\([^,]*\),\([^,]*\),.*/$username,\1,\2,\3,$(date)/" "$USERS_FILE"
    echo "Autentificare reusita! Directorul tau este: $HOME_DIR/$username"

    echo -e "Subject: Notificare login\n\nSalut $username, te-ai logat cu succes in sistemul Matrix." | msmtp "$email"

    if command -v cowsay &> /dev/null; then
        cowsay "Bine ai venit, $username!"
    fi
}

logout_user() {
    read -p "Cod utilizator: " username_input
    username="$username_input"
    for i in "${!LOGGED_IN_USERS[@]}"; do
        if [[ "${LOGGED_IN_USERS[$i]}" == "$username" ]]; then
            unset 'LOGGED_IN_USERS[i]'
            echo "Utilizator $username s-a deconectat."
            if command -v cowsay &> /dev/null; then
                cowsay "Paa, $username!"
            fi
            return
        fi
    done
    echo "Utilizatorul nu era autentificat."
}

generate_raport() {
    read -p "Cod utilizator: " username_input
    username="$username_input"
    [[ ! -d "$HOME_DIR/$username" ]] && echo "Utilizator inexistent!" && return

    (
        fcount=$(find "$HOME_DIR/$username" -type f | wc -l)
        dcount=$(find "$HOME_DIR/$username" -type d | wc -l)
        dsize=$(du -sh "$HOME_DIR/$username" | cut -f1)
        {
            echo "Raport pentru: $username"
            echo "Numar fisiere: $fcount"
            echo "Numar directoare: $dcount"
            echo "Spatiu total ocupat: $dsize"
            echo "Generat la: $(date)"
        } > "$HOME_DIR/$username/raport.txt"
    ) &

    echo "Raportul a fost generat in background. Verifica fisierul raport.txt in directorul tau."
}

while true; do
    show_menu
    case $opt in
        1) register_user ;;
        2) login_user ;;
        3) logout_user ;;
        4) generate_raport ;;
        0) echo "Sistemul se inchide..."; break ;;
        *) echo "Optiune necunoscuta!" ;;
    esac
done

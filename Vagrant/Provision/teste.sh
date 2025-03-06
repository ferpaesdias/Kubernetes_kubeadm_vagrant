
    a=0
    while [ $a -eq 0 ]
    do
        kubectl get nodes > /dev/null 2>&1

        if [ $? -eq 0 ]
        then
            echo -e "comando executado com sucesso\n"
            a=5
        else
            echo -e "comando executado com erro\n"
        fi
    done  

    kubectl get nodes -o wide

#!/bin/bash
# ● Zenity para escoller o ficheiro onde gardar os contrasinais de cada usuario
FILE=$( zenity --file-selection --title="Selecciona o ficheiro no que gardar as chaves de usuario" )
case $? in
         0)
            # ● Indica que ficheiro foi seleccionado
            echo "\"$FILE\" foi seleccionado";;
         1)
            # ● Indica que non se seleccionou ningún ficheiro
            echo "Non foi seleccionado ningún ficheiro";;
        -1)
            # ● Indica que ao non escoller ningún ficheiro nin nada se produciu un erro
            echo "Erro producido";;
esac
# ● Para sobreescribir os ficheiro escollido e que cada vez que se execute o script a contrasinal dos usuarios creados sexa só a actual
> $FILE
# ● Bucle while para coller os datos do ficheiro userlist.txt no IFS indicamos o delimitador : para poder gardar os datos nas variables
while IFS=":" read username group email birthday action;
do
    # ● Inserción das variables nos vectores/array correspondentes
    nomes[${indice}]=$username
    grupos[${indice}]=$group
    correos[${indice}]=$email
    aniversarios[${indice}]=$birthday
    accion[${indice}]=$action
    # ● Sumatorio da variable indice para que vaia cambiando a posición nos vectores
    (( indice ++ )) 
done < userlist.txt
# ● Creación dunha función para poñerlle os contrasinais aos usuarios
function contrasinais(){
    # ● Variable para conseguir a ruta do home do usuario que se lle pasa á función
    usuario=$( ls /home/$1 -d )
    # ● Variable para que solo colla o nome do usuario pasado da ruta que proporciona a variable
    user=$( basename $usuario )
    # ● Variable para que cree unha secuencia e poder poñela como contrasinal
    chave=$( pwgen -cn 8 1 )
    # ● Facemos que se garden tanto o usuario como a súa contrasinal no ficheiro escollido anteriormente
    echo "$user:$chave" >> $FILE
    # ● Cambiamoslle a contrasinal ao usuario proporcionado pasandolle ao comando chpasswd neste formato
    echo "$user:$chave" | sudo chpasswd
}
# ● Damoslle como valor á variable tamanho o total de voltas que fixo ao facer o while read
tamanho=$indice
# ● Indicamos que indice volva a ter o valor 0
indice=0
# ● Bucle while para crear ou borrar os usuarios mentres que o indice sexa menor o total das voltas dadas no anterior while
while [ $indice -lt $tamanho ] ;
do
    # ● Creación da variable para buscar se o grupo co indice proporcionado está creado
    grupo_existente=$( sudo egrep "${grupos[$indice]}" /etc/gshadow | awk -F ":" '{print $1}' )
    # ● Realizamos un if para comprobar se o grupo existe ou non
    if [[ $grupo_existente == ${grupos[$indice]} ]] ;
    then
        # ● Se o grupo existe indicamos que existe
        echo "O grupo ${grupos[$indice]} xa existe"
    else
        # ● Se non existe o grupo crease e indicamos que se creou o grupo
        sudo addgroup ${grupos[$indice]}
        echo "Se creo el grupo ${grupos[$indice]}"
    fi
    # ● Variable para comprobar se o usuario existe
    usuario_existente=$( sudo egrep "${nomes[$indice]}" /etc/shadow | awk -F ":" '{print $1}' )
    # ● If para comprobar se os usuarios non teñen correo
    if [[ ${correos[$indice]} == "" ]] ;
    then
        # ● Se non teñen correo indica que non o ten
        echo "O usuario non ten mail"
    # ● Se a acción que indica o indice é add se debe crear o usuario
    elif [[ ${accion[$indice]} == "add" ]] ;
    then  
        # ● If para comprobar se o usuario existe
        if [[ $usuario_existente == ${nomes[$indice]} ]] ;
        then
            # ● Se existe o usuario sale unha mensaxe indicándoo
            echo "O usuario ${nomes[$indice]} xa existe"
        # ● Se non existe crea o usuario, as subcarpetas,...
        else
            # ● Comando para crear o usuario co seu home co grupo principal que sexa polo índice co shell /bin/bash indicandolle o nome do usuario
            sudo useradd -d /home/${nomes[$indice]} -m -g ${grupos[$indice]} -c "${correo[$indice]} ${aniversarios[$indice]}" -s /bin/bash ${nomes[$indice]}
            # ● Aviso de que se creou o usuario
            echo "Se creo el usuario ${nomes[$indice]}"
            # ● Comandos para crear as subcarpetas public_html, zona_comun e zona_privada
            sudo mkdir /home/${nomes[$indice]}/public_html
            sudo mkdir /home/${nomes[$indice]}/zona_comun
            sudo mkdir /home/${nomes[$indice]}/zona_privada
            # ● Comandos para poñer os permisos ás subcarpetas
            sudo chmod 755 /home/${nomes[$indice]}/public_html
            sudo chmod 750 /home/${nomes[$indice]}/zona_comun
            sudo chmod 700 /home/${nomes[$indice]}/zona_privada
            # ● Comandos para cambiar a o usuario e o grupo propietario das subcarpetas do home do usuario
            sudo chown ${nomes[$indice]}:${grupos[$indice]} /home/${nomes[$indice]}/public_html
            sudo chown ${nomes[$indice]}:${grupos[$indice]} /home/${nomes[$indice]}/zona_comun
            sudo chown ${nomes[$indice]}:${grupos[$indice]} /home/${nomes[$indice]}/zona_privada
            # ● Chamado á función de contrasinais para que lle xere unha ao usuario e lla poña
            contrasinais "${nomes[$indice]}"
            echo "Puxoselle a contrasinal ao usuario"
            # ● Comando para indicar a quota do usuario (AVISO: Non me iba o das quotas polo que non puden comprobar se iba)
            sudo setquota -u ${nomes[$indice]} 665600 716800 -F ext4 /
        fi
    # ● Elif para ver que se a acción que indica o indice é delete
    elif [[ ${accion[$indice]} == "delete" ]] ;
    then
        # ● If para comprobar se o usuario que ten a acción delete existe
        if [[ $usuario_existente == ${nomes[$indice]} ]] ;
        then
            # ● Se o usuario existe borra o usuario e o seu home
            sudo userdel -r ${nomes[$indice]}
            echo "Se elimino al usuario ${nomes[$indice]}"
        else
            # ● Se o usuario non existe indica que non se pode borrar
            echo "O usuario ${nomes[$indice]} non existe e polo tanto non se pode borrar"
        fi
    fi
    # ● Sumatorio da variable indice para que vaia cambiando a posición nos vectores
    (( indice ++ ))
done
# ● Zenity para informar que se crearon todos os grupos e os usuarios
zenity --info --text="Creáronse todos os grupos e usuarios cos seus respectivos directorios"

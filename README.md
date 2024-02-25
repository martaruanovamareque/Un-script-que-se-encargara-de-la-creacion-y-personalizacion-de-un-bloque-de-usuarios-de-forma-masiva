# Un script que se encargara de la creación y personalización de un bloque de usuarios de forma masiva

En un fichero "userslist.txt", tendremos una lista de los usuarios que se deberán crear y su grupo principal.

El script deberá leer el contenido de un fichero userslist.txt, donde vendrán definidos los nombres de usuario, y deberá cargarlos en un array para luego procesarlos.

Para cada elemento del array deberemos ejecutar los comandos necesarios para eliminar/crear dicho usuario en un sistema GNU/Linux.

  ○ Si action=delete entonces el usuario se elimina

  ○ Si action=add el usuario se crea

○ Si el usuario no tiene email entonces se muestra un mensaje en pantalla indicando el problema pero no se hace nada con él.

El script leerá cada línea del fichero "userslist.txt", y extraerá la información de usuario y grupo.

  ● Crear el grupo si no existe. Consultar comandos groupadd y addgroup.

  ● Crear el usuario si no existe. Consultar comandos newusers, useradd y adduser.

  ● Crear en la carpeta del usuario ($HOME) los directorios siguientes, si no existen:

    ○ public_html: permisos 755

    ○ zona_comun: permisos 750

    ○ zona_privada: permisos 700.

  ● Establecer una clave aleatoria al usuario y registrar el "usuario:clave" en un fichero llamado "claves-de-usuario.txt".
  
  ● Establecer la cuota del usuario a 700 MB, command → edquota ou setquota.

Al principio del script se mostrará una ventana para seleccionar el fichero de
carga "claves-de-usuario.txt".

Al final del script para mostrar una ventana informativa de finalización.

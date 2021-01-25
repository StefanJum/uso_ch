Scriptul myadduser.sh parseaza in prima parte optiunile primite ca argumente,
asemanatoare optiunilor comenzii "useradd", dupa cum urmeaza:

-i (--interactive) primeste parametrii ce nu sunt introdusi in argumente in mod interactiv
Utilizatorul poate da scriptului parametrii in mod neinteractiv, iar daca optiunea -i, --interative
este prezenta, restul de optiuni vor putea fi introduse interactiv.
Parola nu apare in clar in terminal daca este introdusa in mod interactiv.

-c (--comment) seteaza un comentariu pentru user, salvat apoi in coloana a 5 a din /etc/passwd
-d (--home-dir) seteaza directorul home al userului
-s (--shell) seteaza shellul default al userului
	in cazul in care shellul nu se afla in /etc/shells, acesta devine nologin
-e (--expire-date) seteaza data expirarii userului
-f (--inactive) seteaza data dupa care parola va deveni inactiva
-m (--minimum) seteaza numarul minim de zile dupa care userul va putea schimba parola
-M (--maximum) seteaza numarul zile dupa care userul va fi obligat sa schimbe parola
-g (--group) seteaza numele grupului din care face parte userul
-h (--help) afiseaza instructiunile de folosire ale scriptului
--group-id seteaza gid dorit daca este unic
--user-id seteaza uid dorit daca este unic

Dupa primirea instructiunilor, scriptul creeaza intrarile specifice userului in fisierele
/etc/passwd, /etc/group si /etc/shadow, dupa care le adauga la sfarsitul acestora, si copiaza
continutul /etc/skel in directorul home al userului.
Se verifica unicitatea UID si GID, printr-un while ce porneste de la penultima valoare uid si gid
gasita in /etc/passwd si /etc/group, pentru a ignora existenta in sistem a unui user "nobody",
respectiv un grup "nogroup".
Daca sintaxa nu este corecta, se afiseaza un scurt mod de folosire, iar daca scriptul nu este
executat de catre root, cu orice optiune in afara de -h, --help, se afiseaza eroarea specifica
si returneaza valoarea 2.



Scriptul mydeluser.sh parseaza optiunile primite, asemanatoare celor ale comenzii "userdel":

-f (--force) sterge fortat tot continutul directorului home, chiar daca nu este detinut de user
-h (--help) afiseaza instructiunile de folosire ale scriptului
-r (--remove) sterge continutul directorului home ca userul ce urmeaza a fi sters
-g (--group) primeste ca parametru un intreg ce reprezinta GID grupului ce se doreste a fi sters
		nu mai necesita un argument pentru username, scriptul devine un inlocuitor al comenzii delgroup
-s (--skip-group) sterge doar userul dat, fara sa actioneze asupra grupului acestuia

Dupa parsarea optiunilor, scriptul verifica daca userul exista, si sterge intrarile specifice
din fisierele /etc/passwd, /etc/group, /etc/shaddow. 
Scriptul executat de catre al user in afara de root, cu alte optiuni decat -h, --help va afisa 
eroarea specifica si va returna valoarea 2.
Daca se primeste argumentul -g, --group se va sterge intrarea specifica din /etc/group.
In final se sterg toate aparitiile userului in lista utilizatorilor asociati unui grup din ultima
coloana a fisierului /etc/group

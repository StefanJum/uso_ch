	Scriptul verifica la inceput ca primeste cele 2 argumente si ca exista fisierul
de input. In caz contrar afiseaza mesaje de eroare specifice.

	Stergerea duplicatelor se face prin parcurgerea fisierului de input cu un while
ce retine liniile, si parcurgerea liniilor cuvant cu cuvant, verificandu-se daca
ultimul cuvant la care s-a ajuns este identic cu cel de dinaintea sa, dupa ce s-au
transformat toate literele in litere mici si s-au salvat noile cuvinte in 2 variabile.

	Se retine intr-o variabila primul simbol citit din sirul ".,?!;" si se scrie dupa
cuvantul din seria de duplicate la care s-a ajuns. La final am folosit 'sed' pentru a
sterse spatiile albe ramase in finalul fiecarei linie.

	Statisticile referitoare la cuvintele sterse se retin intr-un vector asociativ
(associative array) care retine numarul de cuvinte de forma "word" sterse in valoarea
$duplicates[word]. Se adauga intrari noi in vector daca este prima data cand a fost
sters cuvantul. Sintaxa folosita pentru acest tip de vectori am preluat-o din linkul [1].

	Ruland scriptul pe testul dat in enunt am primit rezultatul:
		real	2m17,019s
		user	2m5,946s
		sys		0m38,707s


[1] https://linuxhint.com/associative_arrays_bash_examples/

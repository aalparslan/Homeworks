:-[kb].




kbigram(X,R):-
    atom_chars(X,LIST),
    deneme(LIST,R,[]).
    

deneme([_], S, LIST):-
    member(S, LIST).

deneme([X,Y],S, LIST):-
    atom_chars(K,[X,Y]),
    append(LIST, [K], NEWLIST),
    member(S, NEWLIST).
        
deneme([X,Y|Z], S, LIST):-
    atom_chars(K,[X,Y]),
    append(LIST, [K], NEWLIST),
    deneme([Y|Z], S, NEWLIST).
    

div(L, A, B) :-
    append(A, B, L),
    length(A, N),
    length(B, N).


bigram(X,R):-
    findall(R,kbigram(X,R),OUT),
    div(OUT,K,_),
    member(R,K).


num_hobbies([X], LIST, LASTLIST):-
    person(X,_,H),
    append(LIST,[hobby(H,1)],LASTLIST).

num_hobbies([X|Y],LIST, LASTLIST):-
    person(X,_,H),
    append(LIST,[hobby(H,1)],NEWLIST),!,
    num_hobbies(Y,NEWLIST, LASTLIST).



count([],COUNT,TYPE2, P):-
    P is COUNT.

count([hobby(TYPE1,_)|Z],COUNT,TYPE2, P):-
    TYPE1 = TYPE2,
    K is COUNT+1,
    count(Z,K,TYPE2, P).

count([hobby(TYPE1,_)|Z], COUNT, TYPE2, P):-
    TYPE1 \= TYPE2,
    count(Z,COUNT, TYPE2, P).




construct([hobby(TYPE1,Y)], LIST, LLL):-
    count([hobby(TYPE1,Y)],0,TYPE1,OCCURANCE),
    append(LIST,[hobby(TYPE1,OCCURANCE)], LLL).


 

construct([hobby(TYPE1,Y)|Z], LIST, LLL):-
    count([hobby(TYPE1,Y)|Z],0,TYPE1,OCCURANCE),
    append(LIST,[hobby(TYPE1,OCCURANCE)], NEWLIST),
    construct(Z,LLL, LLL),!.


arit([hobby(TYPE1,Y)|Z]):-
    

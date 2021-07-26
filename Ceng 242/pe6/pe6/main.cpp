#include <iostream>
#include "person.h"
#include "corporation.h"
#include "villa.h"
#include "apartment.h"
#include "office.h"

using namespace std;

int main ()
{
    Person per = Person ("Ahmet", 1000 , 10) ;
    Corporation corp = Corporation ("ACME", 1000 , "cankaya") ;
    Villa est1 = Villa ("Villa 1", 150 , & per , 2, false );
    Apartment est2 = Apartment ("Apartment 1", 200 , & corp , 7 , 1) ;
    Apartment est3 = Apartment ("Apartment 2", 200 , & corp , 5 , 0) ;
    cout << "----------------------------\n";
    per . list_properties () ;
    corp . list_properties () ;
    cout << "----------------------------\n";
    // ACME do not own Villa 1
    per . buy (& est1 , & corp );
    // ACME do not own Villa 1
    corp . sell (& est1 , & per );
    cout << "----------------------------\n";
    per . list_properties () ;
    corp . list_properties () ;
    cout << "----------------------------\n";
    return 0;
}



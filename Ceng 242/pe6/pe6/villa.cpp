#include <iostream>
#include "villa.h"
#include "owner.h"

using namespace std;

Villa::Villa(const string &property_name, int area, Owner *owner, int number_of_floors, bool having_garden)
{
    this->property_name = property_name;
    this->area = area;
    this->owner = owner;
    this->number_of_floors = number_of_floors;
    this->having_garden = having_garden;
    if(owner != NULL){
        owner->add_property(this);
    }
}

float Villa::valuate()
{
    if(this->having_garden){
        return this->area * 10 * this->number_of_floors * 2;
    }else{
        return this->area * 10 * this->number_of_floors;
    }
}

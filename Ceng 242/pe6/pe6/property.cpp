#include <iostream>
#include "property.h"
#include "owner.h"

using namespace std;

Property::Property()
{
}

Property::Property(const string &property_name, int area, Owner *owner)
{
    this->property_name = property_name;
    this->area = area;
    this->owner = owner;
    owner->add_property(this);
    
}

void Property::set_owner(Owner *owner)
{
    this->owner = owner;
}

float Property::valuate()
{
    return 1; // will be changed!@@@
}

string &Property::get_name()
{
    return property_name;
}

void Property::print_info()
{
    if(this->owner == NULL){// no owner !
        cout<<this->get_name()<<" ("<<this->area<<" m2) Owner: No owner"<<endl;
    }else{// it has an owner
        cout<<this->get_name()<<" ("<<this->area<<" m2) Owner: "<<this->owner->get_name()<<endl;
    }
}

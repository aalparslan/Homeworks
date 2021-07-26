#include <iostream>
#include <string>
#include <vector>
#include "owner.h"

using namespace std;

Owner::Owner()
{
}

Owner::Owner(const string &name, float balance)
{
    this->name = name;
    this->balance = balance;
}

void Owner::print_info()
{
}

string &Owner::get_name()
{
    return name;
}

void Owner::add_property(Property *property)
{
    properties.push_back(property);
}

void Owner::buy(Property *property, Owner *seller)
{
    cout << "[BUY] Property: "<<property->get_name()<<" Value: "
    <<property->valuate()<<"$ "<<seller->get_name()<<"--->"<<this->get_name()<<endl;
    if (property->valuate() > this->balance){
        // not sufficient!
        cout << "[ERROR] Unaffordable  property"<<endl;
    }else{ // balance is sufficient!
        bool sellerOwnsTheProperty = false;
        for(int i = 0; i < seller->properties.size(); i++){
            if(property == seller->properties[i]){
                // property is found!
                sellerOwnsTheProperty = true;
            }
        }
            
        if(sellerOwnsTheProperty == false){ // seller does not own the property!
            cout << "[ERROR] Transaction  on  unowned  property"<<endl;
        }else{ // seller owns the property
            this->properties.push_back(property); // add to this list
            // remove it from the list of seller
            int itemToBeRemovedIndex = -1;
            for(int i = 0; i < seller->properties.size(); i++){
                if(property == seller->properties[i]){
                    itemToBeRemovedIndex = i;
                    break;
                }
            }
            if(itemToBeRemovedIndex != -1){
                seller->properties.erase(seller->properties.begin() + itemToBeRemovedIndex);
            }
 
            this->balance -= property->valuate(); // decrease the balance of this.
            seller->balance += property->valuate(); // increase the balance of the seller.
            property->set_owner(this); // set this as the owner
        }
    }
}

void Owner::sell(Property *property, Owner *owner)
{
    cout << "[SELL] Property: "<<property->get_name()<<" Value: "
    <<property->valuate()<<"$ "<<this->get_name()<<"--->"<<owner->get_name()<<endl;
    if(property->valuate() > owner->balance){
        // balance is not sufficient!
        cout << "[ERROR] Unaffordable  property"<<endl;
    }else{// balance is sufficient!
        bool thisOwnsTheProperty = false;
        for(int i = 0; i < this->properties.size(); i++){
            if(property == this->properties[i]){
                // property is found!
                thisOwnsTheProperty = true;
            }
        }
        
        if(thisOwnsTheProperty == false){// this does not own the property!
            cout << "[ERROR] Transaction  on  unowned  property"<<endl;
        }else{// this owns the property
            owner->properties.push_back(property);// add to owner list
            // remove it from the list of this
            
            int itemToBeRemovedIndex = -1;
            for(int i = 0; i < this->properties.size(); i++){
                if(property == this->properties[i]){
                    itemToBeRemovedIndex = i;
                    break;
                }
            }
            if(itemToBeRemovedIndex != -1){
                this->properties.erase(this->properties.begin() + itemToBeRemovedIndex);
            }
            
            this->balance += property->valuate();// increase the balance of the this.
            owner->balance -= property->valuate(); // decrease the balance of the owner.
            property->set_owner(owner);// set the owner as the owner of the property.
        }
    }
}

void Owner::list_properties()
{
    cout<<"Properties of "<<this->name<<":"<<endl;
    cout<<"Balance: "<< this->balance<<"$"<<endl;
    for(int i = 0; i < properties.size(); i++){
        cout<<i+1<<". "<< properties[i]->get_name()<<endl;
    }
}

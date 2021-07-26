//
// Created by ubuntu on 23.04.2021.
//
#include <iostream>
#include "semaphore.h"
#include <fcntl.h>
#include <vector>
#include <pthread.h>
#include <stdlib.h>
extern "C"{
#include "writeOutput.h"
	#include"writeOutput.c"
#include "helper.h"
	#include"helper.c"
}

using namespace  std;
/// DATA #############################################
class HubData {
public:
    int hubID; // 1 den basliyor
    int max_incomingPackageStorageSize;
    int max_outgoingPackageStorageSize;
    int numberOfChargingSpaces;
    std::vector<int> distance;

    std::vector<PackageInfo> incomingStorageVector;
    std::vector<PackageInfo> outgoingStorageVector;
    int waiting_package_count;
    bool active;
};
class SenderData {
public:
    int ID;
    int senderWaitTime;
    int hubID;
    int totalNumberOfPackagesToSend;
    bool active;
};
class ReceiverData {
public:
    int ID;
    int receiverWaitTime;
    int hubID;
    bool active;

};
class DroneData {
public:
    int ID;
    int travelSpeed;
    int hubID;
    int maxRange;

    int currentRange;
    PackageInfo  packetInfo;
   bool isAvailable;
   bool isCalled;
   long long timeStamp;
};
/// DATA END ########################################
vector<HubData> hubs_Vector;
vector<SenderData> senders_Vector;
vector<ReceiverData> receivers_Vector;
vector<DroneData> drones_Vector;

vector<sem_t*> SenderWaitCanDeposit;
vector<sem_t*> incomingVectorMutexes;
vector<sem_t*> outgoingVectorMutexes;
vector<sem_t*> WaitUntilPackageDeposited;
vector<sem_t*> senderIsActiveVectorMutexes;
vector<sem_t*> hubIsActiveVectorMutex;
vector<sem_t*> WaitSignalFromHub;
vector<sem_t*> chargingSpaces;
vector<sem_t*> DroneWaitCanDeposit;
vector<sem_t*> DroneMutexes;
sem_t* droneSignaler;

int numberOfHubs, numberOfDrones;

void *hubThreadMethod(void *p ){
    int hubIndex =  *((int*)p);
    HubInfo hubInfo;
    FillHubInfo(&hubInfo,hubs_Vector[hubIndex].hubID);
    WriteOutput(NULL,NULL,NULL, &hubInfo, HUB_CREATED);
    bool isTherePackagesInEitherStorage = true;
    bool isThereActiveSenders = true;
///##################################


    while(isTherePackagesInEitherStorage || isThereActiveSenders){
        //// below for checking the loop condition
        isTherePackagesInEitherStorage = false;  // if there are packages in either storage.
        isThereActiveSenders = false;
        ///######## control
        sem_wait(senderIsActiveVectorMutexes[hubIndex]); /// senkronize bir sekilde seders_vector[i] ya eris.
        for(int i = 0; i < numberOfHubs; i++){
            if(senders_Vector[i].active && senders_Vector[i].hubID != hubIndex+1){
                isThereActiveSenders = true;
            }
        }
        sem_post(senderIsActiveVectorMutexes[hubIndex]);

        for(int i = 0; i < numberOfHubs; i++){
            sem_wait(incomingVectorMutexes[i]);
            if( hubs_Vector[i].incomingStorageVector.size() > 0){/// @@@senkronize bir sekilde
                isTherePackagesInEitherStorage = true;
            }
            sem_post(incomingVectorMutexes[i]);
            sem_wait(outgoingVectorMutexes[i]);
            if(hubs_Vector[i].outgoingStorageVector.size() > 0){/// @@@senkronize bir sekilde
                isTherePackagesInEitherStorage = true;
            }
            sem_post(outgoingVectorMutexes[i]);
        }
        ///########### control ends

        bool isThereAnyDronesInTheHub = false;
        for(int i = 0; i < numberOfDrones; i++ ){

            sem_wait(DroneMutexes[i]);

            if(drones_Vector[i].hubID == hubs_Vector[hubIndex].hubID && drones_Vector[i].isAvailable == true ){
                // yes there are drones in the hub
                isThereAnyDronesInTheHub = true;
            }
        }

        sem_wait(outgoingVectorMutexes[hubIndex]);
        if(hubs_Vector[hubIndex].outgoingStorageVector.size() > 0){
            if(isThereAnyDronesInTheHub == true ){

                int droneIndexWithHighestCurrentRange = 0; // select the drone with the highest current range
                int dummyRange = 0;
                for(int i = 0; i < numberOfDrones; i++){
                    if(drones_Vector[i].hubID == hubs_Vector[hubIndex].hubID && drones_Vector[i].isAvailable == true ){
                        if(drones_Vector[i].currentRange > dummyRange){
                            dummyRange =  drones_Vector[i].currentRange;
                            droneIndexWithHighestCurrentRange = i;
                        }
                    }
                }
                // assign the package to the drone
                drones_Vector[droneIndexWithHighestCurrentRange].packetInfo.sending_hub_id = hubs_Vector[hubIndex].hubID;
                drones_Vector[droneIndexWithHighestCurrentRange].packetInfo.sender_id = senders_Vector[hubIndex].ID;
                drones_Vector[droneIndexWithHighestCurrentRange].packetInfo.receiving_hub_id = hubs_Vector[hubIndex].outgoingStorageVector.back().receiving_hub_id;
                drones_Vector[droneIndexWithHighestCurrentRange].packetInfo.receiver_id = hubs_Vector[hubIndex].outgoingStorageVector.back().receiver_id;
                drones_Vector[droneIndexWithHighestCurrentRange].isAvailable = false;
                drones_Vector[droneIndexWithHighestCurrentRange].isCalled = false;
                hubs_Vector[hubIndex].outgoingStorageVector.pop_back();
                sem_post(outgoingVectorMutexes[hubIndex]);
                sem_post(SenderWaitCanDeposit[hubIndex]); //notify sender by increasing semaphore. There is a new place in the outgoing vector.
                sem_post(WaitSignalFromHub[droneIndexWithHighestCurrentRange]); // notify the drone
                for(int i = 0; i < numberOfDrones; i++){// post
                    sem_post(DroneMutexes[i]);
                }
            }else{

                //no drones in this hub.
                int closestHubDistance  = INT_MAX;
                int droneIndexForCalling;
                bool isThereAvailableDronesInOtherHubs = false;
                for(int i = 0; i < numberOfDrones; i++){
                    if(drones_Vector[i].isAvailable == true && drones_Vector[i].isCalled == false){ /// ???
                        if(closestHubDistance >  hubs_Vector[drones_Vector[i].hubID -1].distance[hubIndex] && drones_Vector[i].hubID != hubIndex+1){
                            closestHubDistance = hubs_Vector[drones_Vector[i].hubID -1].distance[hubIndex];
                            droneIndexForCalling = i;
                            isThereAvailableDronesInOtherHubs = true;
                        }
                    }
                }

                if(isThereAvailableDronesInOtherHubs == true){
                    drones_Vector[droneIndexForCalling].packetInfo.sending_hub_id = hubs_Vector[hubIndex].hubID;
                    drones_Vector[droneIndexForCalling].packetInfo.sender_id = senders_Vector[hubIndex].ID;
                    drones_Vector[droneIndexForCalling].packetInfo.receiving_hub_id = hubs_Vector[hubIndex].outgoingStorageVector.back().receiving_hub_id;
                    drones_Vector[droneIndexForCalling].packetInfo.receiver_id = hubs_Vector[hubIndex].outgoingStorageVector.back().receiver_id;
                    drones_Vector[droneIndexForCalling].isAvailable = false;
                    drones_Vector[droneIndexForCalling].isCalled = true;
                    sem_post(WaitSignalFromHub[droneIndexForCalling]); // notify the drone
                    for(int i = 0; i < numberOfDrones; i++){// post
                        sem_post(DroneMutexes[i]);
                    }
                }else{
                    for(int i = 0; i < numberOfDrones; i++){// post
                        sem_post(DroneMutexes[i]);
                    }
                        wait(UNIT_TIME); /// @@ CHEKC THIS LATER@@
                }
                sem_post(outgoingVectorMutexes[hubIndex]);
            }
        }else{
            sem_post(outgoingVectorMutexes[hubIndex]);// eger outgoing bossa aldigin herseyi post et.
            for(int i = 0; i < numberOfDrones; i++){
                sem_post(DroneMutexes[i]);
            }
            if(sem_trywait(WaitUntilPackageDeposited[hubIndex]) != 0 ){
                // need to wait for semaphore
                wait(UNIT_TIME);
            }else{
                // got the semaphore
            }
        }
    }
    sem_wait(hubIsActiveVectorMutex[hubIndex]); /// CRITICAL SECTION
    hubs_Vector[hubIndex].active = false;
    sem_post(hubIsActiveVectorMutex[hubIndex]); /// CRITICAL SECTION
    FillHubInfo(&hubInfo, hubs_Vector[hubIndex].hubID);
    WriteOutput(NULL, NULL, NULL, &hubInfo, HUB_STOPPED);
}
void *senderThreadMethod(void *p ){
    int senderIndex =  *((int*)p);
    SenderInfo  senderInfo;
    FillSenderInfo(&senderInfo, senders_Vector[senderIndex].ID, senders_Vector[senderIndex].hubID, senders_Vector[senderIndex].totalNumberOfPackagesToSend, NULL);
    WriteOutput(&senderInfo, NULL, NULL, NULL, SENDER_CREATED);
    while (senders_Vector[senderIndex].totalNumberOfPackagesToSend > 0){
        // randomly select a hub
        srand( (unsigned ) time(0));
        int randomChosenHubID = 1 + (rand() % numberOfHubs); // between [1 , numberOfHubs] inclusive
        while(randomChosenHubID == senders_Vector[senderIndex].hubID){
            randomChosenHubID = 1 + (rand() % numberOfHubs); // between [1 , numberOfHubs] inclusive
        }
        int randomChosenHubReceiverID;
        for(int i = 0; i < numberOfHubs; i++){
            if(senders_Vector[i].hubID == randomChosenHubID){
                randomChosenHubReceiverID = senders_Vector[i].ID;
            }
        }
        for(int i = 0; i < numberOfHubs; i++){
            if(hubs_Vector[i].hubID == senders_Vector[senderIndex].hubID){
                // for this senders hub check if the outgoing storage is available
                sem_wait(SenderWaitCanDeposit[senderIndex]); // sender will be informed from hub. comes from the hub
                // there is an available space in the outgoing storage
                sem_wait(outgoingVectorMutexes[senderIndex]); // take the mutex to manipulate the vector
                PackageInfo  packageInfo;
                FillPacketInfo(&packageInfo, senders_Vector[senderIndex].ID, senders_Vector[senderIndex].hubID, randomChosenHubReceiverID, randomChosenHubID);
                hubs_Vector[senders_Vector[senderIndex].hubID-1].outgoingStorageVector.push_back(packageInfo);    // deposit the package
                sem_post(outgoingVectorMutexes[senderIndex]); // leave the mutex
                sem_post(WaitUntilPackageDeposited[senderIndex]); // inform the hub.
                FillSenderInfo(&senderInfo, senders_Vector[senderIndex].ID, senders_Vector[senderIndex].hubID, senders_Vector[senderIndex].totalNumberOfPackagesToSend, &packageInfo);
                WriteOutput(&senderInfo, NULL, NULL, NULL, SENDER_DEPOSITED);
                senders_Vector[senderIndex].totalNumberOfPackagesToSend = senders_Vector[senderIndex].totalNumberOfPackagesToSend -1;
                wait(senders_Vector[senderIndex].senderWaitTime * UNIT_TIME);  // sleep for some time
            }
        }
    }
    sem_wait(senderIsActiveVectorMutexes[senderIndex]);
    senders_Vector[senderIndex].active = false; // senkronize eris.
    sem_post(senderIsActiveVectorMutexes[senderIndex]);
    FillSenderInfo(&senderInfo, senders_Vector[senderIndex].ID, senders_Vector[senderIndex].hubID, senders_Vector[senderIndex].totalNumberOfPackagesToSend, NULL);
    WriteOutput(&senderInfo, NULL, NULL, NULL, SENDER_STOPPED);
}

void *receiverThreadMethod(void *p ){
    int receiverIndex =  *((int*)p);
    ReceiverInfo  receiverInfo;
    FillReceiverInfo(&receiverInfo, receivers_Vector[receiverIndex].ID, receivers_Vector[receiverIndex].hubID, NULL);
    WriteOutput(NULL, &receiverInfo, NULL, NULL, RECEIVER_CREATED);
    bool isThereAnyActiveHubs = true;
    while(isThereAnyActiveHubs){
        ///// loop control
        // first set it to false if there are any active hubs it will be set to true.
        isThereAnyActiveHubs = false;
        sem_wait(hubIsActiveVectorMutex[receiverIndex]); /// CRITICAL SECTION
        for(int  i = 0; i < numberOfHubs; i++){
            if(hubs_Vector[i].active == true){
                isThereAnyActiveHubs = true;
            }
        }
        sem_post(hubIsActiveVectorMutex[receiverIndex]); /// CRITICAL SECTION
        if(isThereAnyActiveHubs == false){
            break;
        }
        /////////////////////////////
        for(int i = 0; i < numberOfHubs; i++){
            if(hubs_Vector[i].hubID == receivers_Vector[receiverIndex].hubID){     // hubi bulduk
                sem_wait(incomingVectorMutexes[receiverIndex]); //take the mutex to manipulate the vector
                while(hubs_Vector[i].incomingStorageVector.size() > 0){ // process each of the packages
                    PackageInfo packageInfo;
                    FillPacketInfo(&packageInfo,
                                   hubs_Vector[i].incomingStorageVector.back().sender_id,
                                   hubs_Vector[i].incomingStorageVector.back().sending_hub_id,
                                   receivers_Vector[receiverIndex].ID, receivers_Vector[receiverIndex].hubID);
                    hubs_Vector[i].incomingStorageVector.pop_back();// empty the incoming vector
                    sem_post(DroneWaitCanDeposit[receiverIndex]); // leave the semaphore so that new drones can deposit
                    FillReceiverInfo(&receiverInfo, receivers_Vector[receiverIndex].ID, hubs_Vector[i].hubID, &packageInfo);
                    WriteOutput(NULL, &receiverInfo, NULL, NULL, RECEIVER_PICKUP);
                    wait(receivers_Vector[receiverIndex].receiverWaitTime * UNIT_TIME); // sleep for some time
                }
                sem_post(incomingVectorMutexes[receiverIndex]);
            }
        }
    }
    FillReceiverInfo(&receiverInfo, receivers_Vector[receiverIndex].ID, receivers_Vector[receiverIndex].hubID, NULL);
    WriteOutput(NULL, &receiverInfo, NULL, NULL, RECEIVER_STOPPED);
}

void *droneThreadMethod(void *p ){
    int droneIndex =  *((int*)p);
    DroneInfo droneInfo;
    FillDroneInfo(&droneInfo, drones_Vector[droneIndex].ID, drones_Vector[droneIndex].hubID, drones_Vector[droneIndex].currentRange, NULL, 0);
    WriteOutput(NULL, NULL, &droneInfo, NULL, DRONE_CREATED);
    bool isThereAnyActiveHubs = true;
    while(isThereAnyActiveHubs){
        ///// loop control

        isThereAnyActiveHubs = false;
        for(int  i = 0; i < numberOfHubs; i++){
            if(hubs_Vector[i].active == true){
                isThereAnyActiveHubs = true;
                break;
            }
        }

        if(isThereAnyActiveHubs == false){
            break;
        }
        /////////////////////////////


        if(sem_trywait(WaitSignalFromHub[droneIndex]) != 0 ){
            // need to wait for semaphore
            wait(UNIT_TIME);
            continue; // skip this turn
        }


        //sem_wait(WaitSignalFromHub[droneIndex]); ///Wait Signal From Hub drone

        sem_wait(DroneMutexes[droneIndex]);

        if(drones_Vector[droneIndex].hubID == drones_Vector[droneIndex].packetInfo.sending_hub_id){ // The hub that the drone is parked right now  wants to send package.
            sem_post(DroneMutexes[droneIndex]);
            sem_wait(chargingSpaces[drones_Vector[droneIndex].packetInfo.receiving_hub_id-1]);  /// @@ Wait and Reserve a charging in destination hub
            sem_wait(DroneMutexes[droneIndex]);
            int rangeToTheDestination = -100;
            for(int i = 0; i < numberOfHubs; i++){
                if (hubs_Vector[i].hubID == drones_Vector[droneIndex].hubID){
                    int receivingHubID = drones_Vector[droneIndex].packetInfo.receiving_hub_id;
                   for(int j = 0; j < numberOfHubs; j++){
                       if(hubs_Vector[j].hubID == receivingHubID){
                           rangeToTheDestination = hubs_Vector[i].distance[j];
                       }
                   }
                }
            }
            sem_wait(DroneWaitCanDeposit[drones_Vector[droneIndex].packetInfo.receiving_hub_id-1]); /// Reserve a place in the destination incomingVector
            long long timeDronesWaitedInThisHub = timeInMilliseconds() - drones_Vector[droneIndex].timeStamp;
            drones_Vector[droneIndex].currentRange = calculate_drone_charge(timeDronesWaitedInThisHub, drones_Vector[droneIndex].currentRange, drones_Vector[droneIndex].maxRange);
            if(rangeToTheDestination > drones_Vector[droneIndex].currentRange){ // not enough range
                int neededRange = rangeToTheDestination - drones_Vector[droneIndex].currentRange;
                wait(UNIT_TIME * neededRange); // gain the range that is needed.   /// @@ Wait For the range
                drones_Vector[droneIndex].currentRange = calculate_drone_charge(UNIT_TIME * neededRange, drones_Vector[droneIndex].currentRange, drones_Vector[droneIndex].maxRange);
            }
            PackageInfo  packageInfo;
            FillPacketInfo(&packageInfo, drones_Vector[droneIndex].packetInfo.sender_id,
                           drones_Vector[droneIndex].packetInfo.sending_hub_id,
                           drones_Vector[droneIndex].packetInfo.receiver_id,
                           drones_Vector[droneIndex].packetInfo.receiving_hub_id);
            FillDroneInfo(&droneInfo, drones_Vector[droneIndex].ID, drones_Vector[droneIndex].hubID, drones_Vector[droneIndex].currentRange, &packageInfo, 0);
            WriteOutput(NULL, NULL, &droneInfo, NULL, DRONE_PICKUP);
            sem_post(chargingSpaces[drones_Vector[droneIndex].hubID-1]); /// Leave one of the lock for this hub's charging station before departure
            travel(rangeToTheDestination, drones_Vector[droneIndex].travelSpeed);
            int rangeDecrease = range_decrease(rangeToTheDestination, drones_Vector[droneIndex].travelSpeed);
            drones_Vector[droneIndex].currentRange = drones_Vector[droneIndex].currentRange - rangeDecrease; /// update drone...
            drones_Vector[droneIndex].hubID = drones_Vector[droneIndex].packetInfo.receiving_hub_id;
            sem_wait(incomingVectorMutexes[drones_Vector[droneIndex].hubID-1]); /// DropPackageToHub
            FillPacketInfo(&packageInfo,
                           drones_Vector[droneIndex].packetInfo.sender_id,
                           drones_Vector[droneIndex].packetInfo.sending_hub_id,
                           drones_Vector[droneIndex].packetInfo.receiver_id,
                           drones_Vector[droneIndex].packetInfo.receiving_hub_id);
            hubs_Vector[drones_Vector[droneIndex].hubID-1].incomingStorageVector.push_back(packageInfo);
            sem_post(incomingVectorMutexes[drones_Vector[droneIndex].hubID-1]);
            drones_Vector[droneIndex].isAvailable = true;
            sem_post(droneSignaler);
            FillDroneInfo(&droneInfo, drones_Vector[droneIndex].ID, drones_Vector[droneIndex].hubID, drones_Vector[droneIndex].currentRange, &packageInfo, 0);
            WriteOutput(NULL, NULL, &droneInfo, NULL, DRONE_DEPOSITED);
            sem_post(DroneMutexes[droneIndex]);
        }else{
            // another hub is calling the drone...
            sem_post(DroneMutexes[droneIndex]);
            sem_wait(chargingSpaces[drones_Vector[droneIndex].packetInfo.sending_hub_id-1]);  /// @@ Wait and Reserve a charging in caller hub
            sem_wait(DroneMutexes[droneIndex]);
            int rangeToTheCaller = -100;
            for(int i = 0; i < numberOfHubs; i++){
                if (hubs_Vector[i].hubID == drones_Vector[droneIndex].hubID){
                    int receivingHubID = drones_Vector[droneIndex].packetInfo.sending_hub_id;
                    for(int j = 0; j < numberOfHubs; j++){
                        if(hubs_Vector[j].hubID == receivingHubID){
                            rangeToTheCaller = hubs_Vector[i].distance[j];
                        }
                    }
                }
            }
            if(rangeToTheCaller > drones_Vector[droneIndex].currentRange){ // not enough range
                int neededRange = rangeToTheCaller - drones_Vector[droneIndex].currentRange;
                wait(UNIT_TIME * neededRange); // gain the range that is needed.   /// @@ Wait For the range
                drones_Vector[droneIndex].currentRange = calculate_drone_charge(UNIT_TIME * neededRange, drones_Vector[droneIndex].currentRange, drones_Vector[droneIndex].maxRange);
            }
            // enough range
            FillDroneInfo(&droneInfo, drones_Vector[droneIndex].ID,
                          drones_Vector[droneIndex].hubID, drones_Vector[droneIndex].currentRange,
                          NULL, drones_Vector[droneIndex].packetInfo.sending_hub_id);
            WriteOutput(NULL, NULL, &droneInfo, NULL, DRONE_GOING);
            sem_post(chargingSpaces[drones_Vector[droneIndex].hubID-1]); /// Leave one of the lock for this hub's charging station before departure
            travel(rangeToTheCaller, drones_Vector[droneIndex].travelSpeed);
            int rangeDecrease = range_decrease(rangeToTheCaller, drones_Vector[droneIndex].travelSpeed);
            drones_Vector[droneIndex].currentRange = drones_Vector[droneIndex].currentRange - rangeDecrease;
            drones_Vector[droneIndex].hubID = drones_Vector[droneIndex].packetInfo.sending_hub_id;
            drones_Vector[droneIndex].isAvailable = true;
            drones_Vector[droneIndex].timeStamp = timeInMilliseconds();
            FillDroneInfo(&droneInfo, drones_Vector[droneIndex].ID, drones_Vector[droneIndex].hubID, drones_Vector[droneIndex].currentRange, NULL, 0);
            WriteOutput(NULL, NULL, &droneInfo, NULL, DRONE_ARRIVED);
            sem_post(DroneMutexes[droneIndex]);
        }

    }
    FillDroneInfo(&droneInfo, drones_Vector[droneIndex].ID, drones_Vector[droneIndex].hubID, drones_Vector[droneIndex].currentRange, NULL, 0);
    WriteOutput(NULL, NULL, &droneInfo, NULL, DRONE_STOPPED);
}

int main() {

    //// Below parse the data ///////
    cin >> numberOfHubs;
    for(int i = 0; i < numberOfHubs; i++){
        HubData hub;
        hub.hubID = (i+1);
        cin >> hub.max_incomingPackageStorageSize;
        cin >> hub.max_outgoingPackageStorageSize;
        cin >> hub.numberOfChargingSpaces;
        // push the distance vector to the hubData class
        for (int j = 0; j < numberOfHubs; j++){
            int dist;
            cin >> dist;
            hub.distance.push_back(dist);
        }
        hub.waiting_package_count = 0;
        hub.active = true;
        // push the acquired hub object to its vector.
        hubs_Vector.push_back(hub);
    }
    for(int i = 0; i < numberOfHubs; i++){
        SenderData sender;
        cin >> sender.senderWaitTime;
        cin >> sender.hubID;
        cin >> sender.totalNumberOfPackagesToSend;
        sender.active = true;
        sender.ID = i;
        // push the acquired sender object to its vector.
        senders_Vector.push_back(sender);
    }

    for(int i = 0; i < numberOfHubs; i++){
        ReceiverData receiver;
        cin >> receiver.receiverWaitTime;
        cin >> receiver.hubID;
        receiver.active = true;
        receiver.ID = i;
        // push the acquired receiver object to its vector.
        receivers_Vector.push_back(receiver);
    }
    cin >> numberOfDrones;
    for(int i = 0; i < numberOfDrones; i++){
        DroneData drone;
        cin >> drone.travelSpeed;
        cin >> drone.hubID;
        cin >> drone.maxRange;
        drone.ID = i;
        drone.currentRange = drone.maxRange; // initially drones are fully charged
        drone.isAvailable = true;
        drone.isCalled = false;
        drone.timeStamp = 0;
        // push the acquired drone object to its vector.
        drones_Vector.push_back(drone);
    }

    //////// Parsing ends..
    // Create thread vectors
    vector<pthread_t> hubThreads(numberOfHubs);
    vector<pthread_t> senderThreads(numberOfHubs);
    vector<pthread_t> receiverThreads(numberOfHubs);
    vector<pthread_t> droneThreads(numberOfDrones);
    // semaphores
    sem_t *dummy1;
    sem_t *dummy2;
    sem_t *dummy3;
    sem_t *dummy4;
    sem_t *dummy5;
    sem_t *dummy6;
    sem_t *dummy7;
    sem_t *dummy8;


    for(int i = 0; i < numberOfHubs; i++){
        const char* sName1  = "WaitCanDeposit" + i + 1;
        const char* sName2 = "incomingVectorMutexes" + i + 1;
        const char* sName3 = "outgoingVectorMutexes" + i + 1;
        const char* sName4 = "WaitUntilPackageDeposited" + i + 1;
        const char* sName5 = "senderIsActiveVectorMutexes" + i + 1;
        const char* sName6 = "hubIsActiveVectorMutex" + i + 1;
        const char* sName7 = "chargingSpaces" + i + 1;
        const char* sName8 = "DroneWaitCanDeposit" + i +1;
        const char* sName10= "droneSignaler" + i + 1;

        sem_unlink(sName1);
        sem_unlink(sName2);
        sem_unlink(sName3);
        sem_unlink(sName4);
        sem_unlink(sName5);
        sem_unlink(sName6);
        sem_unlink(sName7);
        sem_unlink(sName8);
        sem_unlink(sName10);

        dummy1 = sem_open(sName1, O_CREAT, 0600, hubs_Vector[i].max_outgoingPackageStorageSize);
        dummy2 = sem_open(sName2, O_CREAT, 0600, 1);
        dummy3 = sem_open(sName3, O_CREAT, 0600, 1);
        dummy4 = sem_open(sName4, O_CREAT, 0600, 0);
        dummy5 = sem_open(sName5, O_CREAT, 0600, 1);
        dummy6 = sem_open(sName6, O_CREAT, 0600, 1);
        dummy7 = sem_open(sName7, O_CREAT, 0600, hubs_Vector[i].numberOfChargingSpaces);
        dummy8 = sem_open(sName8, O_CREAT, 0600, hubs_Vector[i].max_incomingPackageStorageSize);
        droneSignaler = sem_open(sName10, O_CREAT, 0600, 1);

        SenderWaitCanDeposit.push_back(dummy1);
        incomingVectorMutexes.push_back(dummy2);
        outgoingVectorMutexes.push_back(dummy3);
        WaitUntilPackageDeposited.push_back(dummy4);
        senderIsActiveVectorMutexes.push_back(dummy5);
        hubIsActiveVectorMutex.push_back(dummy6);
        chargingSpaces.push_back(dummy7);
        DroneWaitCanDeposit.push_back(dummy8);

    }
    sem_t *dummyDrone;
    sem_t *dummy9;
    for(int i = 0; i <  numberOfDrones; i++){
        const char* sName = "WaitSignalFromHub" + i + 1;
        const char* sName9 = "DroneMutexes" + i + 1;

        sem_unlink(sName);
        sem_unlink(sName9);

        dummyDrone = sem_open(sName, O_CREAT, 0600, 0);
        dummy9 = sem_open(sName9, O_CREAT, 0600, 1);

        WaitSignalFromHub.push_back(dummyDrone);
        DroneMutexes.push_back(dummy9);
    }
    // to give ids as arguments to the threads create  arrays...
    int hubThreadsArg [numberOfHubs];
    int sendersThreadsArg [numberOfHubs];
    int receiversThreadsArg [numberOfHubs];
    int dronesThreadsArg [numberOfDrones];
    // Indicate Threads are about to be created.
    InitWriteOutput();
    // create threads
    for(int i = 0; i < numberOfHubs; i++){
        hubThreadsArg[i] = i;
        sendersThreadsArg[i] = i;
        receiversThreadsArg[i] = i;

        pthread_create(&hubThreads[i], NULL, hubThreadMethod, (void*) &hubThreadsArg[i]);
        pthread_create(&senderThreads[i], NULL, senderThreadMethod, (void*) &sendersThreadsArg[i]);
        pthread_create(&receiverThreads[i], NULL, receiverThreadMethod, (void*) &receiversThreadsArg[i]);
    }
    for(int i = 0; i< numberOfDrones; i++){
        dronesThreadsArg[i] = i;
        pthread_create(&droneThreads[i], NULL, droneThreadMethod, (void*) &dronesThreadsArg[i]);
    }
    // join all the threads
    for(int i = 0; i < numberOfHubs; i++){
        pthread_join(hubThreads[i], NULL);
        pthread_join(senderThreads[i], NULL);
        pthread_join(receiverThreads[i], NULL);
    }
    for(int i = 0; i < numberOfDrones; i++){
        pthread_join(droneThreads[i], NULL);
    }
    return 0;
}

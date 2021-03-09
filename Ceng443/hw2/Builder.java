package project.parts.logics;

import project.SimulationRunner;
import project.components.Robot;
import project.parts.Arm;
import project.parts.Base;
import project.parts.Part;
import project.parts.payloads.*;
import project.utility.Common;

import java.util.ArrayList;
import java.util.List;

public class Builder extends Logic
{
    @Override public void run ( Robot robot )
    {
        // TODO
        // Following messages are appropriate for this class
        // System.out.printf("Robot %02d : Builder cannot build anything, waiting!%n", ...);
        // System.out.printf("Robot %02d : Builder woke up, going back to work.%n", ...);
        // System.out.printf("Robot %02d : Builder attached some parts or relocated a completed robot.%n", ...);


        synchronized (SimulationRunner.factory.productionLine.parts){
            List<Part> parts = SimulationRunner.factory.productionLine.parts;

            ArrayList<Part> partsTobeRemovedFromPline = new ArrayList<>();
            outerLoop:
            for(int i = 0; i < parts.size(); i++){
                for(int j = 0;  j < parts.size(); j++){
                    if(parts.get(i) instanceof Base){

                        // if part i is a base then try to complete the base
                        Part part1 =  parts.get(i);
                        Part part2 =  parts.get(j);

                        if( Common.get(part1,"arm") == null){
                            // if arm field of the base is not set
                            if(part2 instanceof Arm){
                                // and part j is an arm then set it
                                Common.set(part1,"arm",part2);
                                partsTobeRemovedFromPline.add(part2);
                                System.out.printf("Robot %02d : Builder attached some" +
                                        " parts or relocated a completed robot.%n", Common.get(robot,"serialNo"));
                                break outerLoop;
                            }
                        }else{ // base - arm
                            // if arm field of the base is set
                            if(Common.get(part1,"payload") == null){
                                // if payload field of the base - arm is not set
                                if( part2 instanceof Payload){
                                    // if part2 is an instance of payload
                                    // try to set payload of the base - arm
                                    Common.set(part1,"payload",part2);
                                    partsTobeRemovedFromPline.add(part2);
                                    System.out.printf("Robot %02d : Builder attached some" +
                                            " parts or relocated a completed robot.%n", Common.get(robot,"serialNo"));
                                    break outerLoop;
                                }
                            }else {
                                // if payload field of the base - arm is already set
                                // try to set logic chip
                                if(Common.get(part1,"logic") == null){
                                    // if logic field of base - arm - payload is not set
                                    // try to set logic chip
                                    if( part2 instanceof Logic){
                                        // if part2 is an instance of logic then set part1 logic
                                        boolean isAttached = false;

                                        Object part1Payload = Common.get(part1,"payload");
                                        if(part1Payload instanceof Camera){
                                            if(part2 instanceof Inspector)
                                                Common.set(part1,"logic",part2);
                                            isAttached  = true;
                                        }
                                        if(part1Payload instanceof Gripper){
                                            if(part2 instanceof Supplier){
                                                Common.set(part1,"logic",part2);
                                                isAttached  = true;
                                            }
                                        }
                                        if(part1Payload instanceof MaintenanceKit){
                                            if(part2 instanceof  Fixer){
                                                Common.set(part1,"logic",part2);
                                                isAttached  = true;
                                            }
                                        }
                                        if(part1Payload instanceof Welder){
                                            if(part2 instanceof project.parts.logics.Builder){
                                                Common.set(part1,"logic",part2);
                                                isAttached  = true;

                                            }
                                        }

                                        if(isAttached){
                                            partsTobeRemovedFromPline.add(part2);
                                            System.out.printf("Robot %02d : Builder attached some" +
                                                    " parts or relocated a completed robot.%n", Common.get(robot,"serialNo"));

                                            break outerLoop;
                                        }
                                    }
                                }else{
                                    // if base - arm - payload - logic fields of part1 is already set.
                                    //Robot is completed pick i up and add it to working robots or store it.
                                    synchronized (SimulationRunner.factory.robots){
                                        List<Robot> workingRobots = SimulationRunner.factory.robots;
                                        if(SimulationRunner.factory.maxRobots > workingRobots.size()){
                                            // give life to the new working robot on a separate thread.
                                            workingRobots.add((Base) part1);
                                            Robot rob = workingRobots.get(workingRobots.size()-1);
                                            Thread th = new Thread(rob);
                                            th.start();
                                            partsTobeRemovedFromPline.add(part1);

                                            System.out.printf("Robot %02d : Builder attached some" +
                                                    " parts or relocated a completed robot.%n", Common.get(robot,"serialNo"));
                                            break outerLoop;
                                        }
                                    }
                                    synchronized (SimulationRunner.factory.storage.robots){

                                        if(SimulationRunner.factory.storage.maxCapacity > SimulationRunner.factory.storage.robots.size()){
                                            SimulationRunner.factory.storage.robots.add((Base) part1);

                                            partsTobeRemovedFromPline.add(part1);
                                            System.out.printf("Robot %02d : Builder attached some" +
                                                    " parts or relocated a completed robot.%n", Common.get(robot,"serialNo"));
                                            break outerLoop;
                                        }

                                    }
                                    // Robot is ready to be placed but There is no space anywhere
                                    SimulationRunner.factory.initiateStop();
                                }
                            }
                        }
                    }
                }
            }
            // Remove parts from from productionLine

            for(int i = 0; i < partsTobeRemovedFromPline.size(); i++){
                parts.remove(partsTobeRemovedFromPline.get(i));
            }
            // There is no more possibility of fulfilling  a production step, then builder waits...
            try{
                System.out.printf("Robot %02d : Builder cannot build anything, waiting!%n",
                        Common.get(robot,"serialNo"));
                parts.notifyAll();
                parts.wait();
            }catch (InterruptedException e){
                System.out.printf("Robot %02d : Builder woke up, going back to work.%n",
                        Common.get(robot,"serialNo"));
            }

        }
    }
}
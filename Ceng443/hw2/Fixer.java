package project.parts.logics;

import project.SimulationRunner;
import project.components.Factory;
import project.components.Robot;
import project.parts.Arm;
import project.parts.payloads.Camera;
import project.parts.payloads.Gripper;
import project.parts.payloads.MaintenanceKit;
import project.parts.payloads.Welder;
import project.utility.Common;

import java.util.ArrayList;

public class Fixer extends Logic
{
    @Override public void run ( Robot robot )
    {
        // TODO
        // Following messages are appropriate for this class
        // System.out.printf("Robot %02d : Fixed and waken up robot (%02d).%n", ...);
        // System.out.printf("Robot %02d : Nothing to fix, waiting!%n", ...);
        // System.out.printf("Robot %02d : Fixer woke up, going back to work.%n", ...);

        synchronized (SimulationRunner.factory.brokenRobots){

            ArrayList<Robot> robotsToBeRemovedFromBrokenRobots = new ArrayList<>();

            if(SimulationRunner.factory.brokenRobots.size() >0){
                // fix broken robots
                for(int i = 0; i < SimulationRunner.factory.brokenRobots.size(); i++){
                    Robot brokenRobot  = SimulationRunner.factory.brokenRobots.get(i);
                    if(Common.get(brokenRobot,"arm") == null){
                        // arm is broken
                        Common.set(brokenRobot,"arm",new Arm());
                        //wake up the robot ????@@@@

                        synchronized (brokenRobot){
                            brokenRobot.notify();
                        }
                        System.out.printf("Robot %02d : Fixed and waken up robot (%02d).%n",
                                Common.get(robot,"serialNo"),
                                Common.get(brokenRobot,"serialNo"));
                        robotsToBeRemovedFromBrokenRobots.add(brokenRobot);
                        break;
                    }else if(Common.get(brokenRobot, "payload") == null){
                        // payload is broken
                        Object logic = Common.get(brokenRobot,"logic");
                        if(logic instanceof Supplier){
                            Common.set(brokenRobot,"payload", Factory.createPart("Gripper"));
                        }else if(logic instanceof Inspector){
                            Common.set(brokenRobot,"payload",Factory.createPart("Camera"));
                        }else if(logic instanceof project.parts.logics.Fixer){
                            Common.set(brokenRobot,"payload",Factory.createPart("MaintenanceKit"));
                        }else if(logic instanceof Builder){
                            Common.set(brokenRobot,"payload",Factory.createPart("Welder"));
                        }
                        //wake up the robot ????@@@@
                        synchronized (brokenRobot){
                            brokenRobot.notify();
                        }
                        System.out.printf("Robot %02d : Fixed and waken up robot (%02d).%n",
                                Common.get(robot,"serialNo"),
                                Common.get(brokenRobot,"serialNo"));
                        robotsToBeRemovedFromBrokenRobots.add(brokenRobot);
                        break;
                    }else if(Common.get(brokenRobot, "logic") == null){
                        // logic is broken
                        Object payload = Common.get(brokenRobot,"payload");

                        if (payload instanceof Camera){
                            Common.set(brokenRobot,"logic", Factory.createPart("Inspector"));
                        }else if(payload instanceof Gripper){
                            Common.set(brokenRobot,"logic",Factory.createPart("Supplier"));
                        }else if(payload instanceof MaintenanceKit){
                            Common.set(brokenRobot,"logic",Factory.createPart("Fixer"));
                        }else if(payload instanceof Welder){
                            Common.set(brokenRobot,"logic",Factory.createPart("Builder"));
                        }
                        //wake up the robot ????@@@@
                        synchronized (brokenRobot){
                            brokenRobot.notify();
                        }
                        System.out.printf("Robot %02d : Fixed and waken up robot (%02d).%n",
                                Common.get(robot,"serialNo"),
                                Common.get(brokenRobot,"serialNo"));
                        robotsToBeRemovedFromBrokenRobots.add(brokenRobot);
                        break;
                    }else{

                    }
                }

                for(int i = 0; i < robotsToBeRemovedFromBrokenRobots.size(); i++){
                    SimulationRunner.factory.brokenRobots.remove(robotsToBeRemovedFromBrokenRobots.get(i));
                }

            }else{
                // no robot to fix wait
                try{
                    System.out.printf("Robot %02d : Nothing to fix, waiting!%n", Common.get(robot,"serialNo"));
                    SimulationRunner.factory.brokenRobots.wait();
                }catch (InterruptedException e){
                    System.out.printf("Robot %02d : Fixer woke up, going back to work.%n", Common.get(robot, "serialNo"));
                }
            }


        }

    }
}
package project.parts.logics;

import project.SimulationRunner;
import project.components.Robot;
import project.utility.Common;

import java.util.List;

public class Inspector extends Logic
{
    @Override public void run ( Robot robot )
    {
        // TODO
        // Following messages are appropriate for this class
        // System.out.printf( "Robot %02d : Detected a broken robot (%02d), adding it to broken robots list.%n", ...);
        // System.out.printf( "Robot %02d : Notifying waiting fixers.%n", ...);


        synchronized (SimulationRunner.factory.robots){
            synchronized (SimulationRunner.factory.brokenRobots){
                List<Robot> workerRobots = SimulationRunner.factory.robots;
                for(int i = 0; i < workerRobots.size(); i++){
                    if(Common.get(workerRobots.get(i),"arm") == null ||
                            Common.get(workerRobots.get(i),"payload") == null ||
                            Common.get(workerRobots.get(i),"logic") == null){
                        // if worker robot is broken put it into the list of worker robots.
                        if(SimulationRunner.factory.brokenRobots.indexOf(workerRobots.get(i)) == -1){
                            // if robot is not already placed in the brokenRobots, place it
                            SimulationRunner.factory.brokenRobots.add(workerRobots.get(i));
                            // NOTIFY FIXERS
                            SimulationRunner.factory.brokenRobots.notifyAll();
                        }
                        break;
                    }
                }
            }
        }
    }
}
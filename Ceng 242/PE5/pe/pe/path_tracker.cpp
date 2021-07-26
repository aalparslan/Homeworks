#include <iostream>
#include <math.h>
#include "path_tracker.h"

/* DO NOT EDIT HEADER FILE*/

/**
 * Empty constructor
 *
 * Initialize all attributes as 0
 */
PathTracker::PathTracker()
{
     final_x = 0;
     final_y = 0;
     displacement = 0;
     distance = 0;
}

/**
 * Constructor
 *
 * Given existing_path array contains x,y couples representing vectors
 * to add end-to-end.
 * [1, 2, 3, 4, 5, 6] -> 3 vectors: [1, 2], [3, 4], [5, 6]
 * Add them end-to end: [1, 2] + [3, 4] + [5, 6] -> [9, 12]
 * Note: Update displacement and distance at each addition.
 *
 * @param existing_path List of vectors to add end-to-end
 * @param number_of_vectors The number of vectors (not the size of the array)
*/

float calcDistanceToKL(int x, int y, int k, int l){
    int dispx = (x-k)*(x-k);
    int dispy = (y-l)*(y-l);
    float result = sqrt(dispx + dispy);
    if(result < 0.001){
        return 0;
    }
    return result;
}

float absFind(float x, float y){
    float val = x - y;
    if(val > 0){
        return val;
    }else{
        return -val;
    }
}

PathTracker::PathTracker(int *existing_path, int number_of_vectors)
{
    int x_pos = 0;
    int y_pos = 0;
    for (int i = 0; i < 2*number_of_vectors; i =  i+2){
        x_pos += existing_path[i];
        y_pos += existing_path[i+1];
        displacement = calcDistanceToKL(x_pos, y_pos, 0, 0);
        distance += calcDistanceToKL(existing_path[i], existing_path[i+1], 0, 0);
    }
    final_x = x_pos;
    final_y = y_pos;
}

/**
 * sum and equal operator
 * Adds new vector to the end of the path.
 *
 * Note: All properties of the object will be updated.
 * final_x and final_y coordinates, displacement and distance
 * values will be updated.
 *
 * @param rhs Integer array with length of 2, containing x, y components of the vector to be added.
 * @return this PathTracker after adding new vector to the end.
 */
PathTracker &PathTracker::operator+=(const int *new_vector)
{
    final_x += new_vector[0];
    final_y += new_vector[1];
    displacement = calcDistanceToKL(final_x, final_y, 0, 0);
    distance += calcDistanceToKL(new_vector[0], new_vector[1], 0, 0);
    return *this;
}

/**
 * Equality comparison overload
 *
 * This operator checks only displacements.
 *
 * @param rhs The PathTracker to compare
 * @return returns true if both displacements are same false otherwise
 */
bool PathTracker::operator==(const PathTracker &rhs) const
{
    float disp_to_RHS = rhs.displacement;
    float disp_to_this = this->displacement;
    if( absFind(disp_to_RHS, disp_to_this ) < 0.001f ){    //@@@@ floating point comparison yapiliyor dikkat et
        return true;
    }else{
        return false;
    }
}

/**
 * Comparison overload
 *
 * This operator checks only displacements.
 *
 * @param rhs The PathTracker to compare
 * @return returns true if the displacement of original PathTracker is longer, false otherwise
 */
bool PathTracker::operator>(const PathTracker &rhs) const
{
    float disp_to_RHS = rhs.displacement;
    float disp_to_this = this->displacement;
    if(disp_to_this > disp_to_RHS ){ //@@@@ floating point comparison yapiliyor dikkat et
        return true;
    }else{
        return false;
    }
}

/**
 * Comparison overload
 *
 * This operator checks only displacements.
 *
 * @param rhs The PathTracker to compare
 * @return returns true if the displacement of original PathTracker is shorter, false otherwise
 */
bool PathTracker::operator<(const PathTracker &rhs) const
{
    float disp_to_RHS = rhs.displacement;
    float disp_to_this = this->displacement;
    if(disp_to_this < disp_to_RHS ){ //@@@@ floating point comparison yapiliyor dikkat et
        return true;
    }else{
        return false;
    }
}

/**
 * Equality comparison overload
 *
 * This operator checks only distance of the PathTracker
 *
 * @param distance floating-point to compare
 * @return returns true if the distance value of PathTracker is bigger than comp value, false otherwise
 */
bool PathTracker::operator==(const float comp) const
{
    if(distance == comp){ //@@@@ floating point comparison yapiliyor dikkat et
        return  true;
    }else{
        return false;
    }
    
}

/**
 * Calculates and returns the displacement value of the path.
 * Displacement: Distance between final position and the first position (origin)
 *
 * @return value of the displacement
 */
float PathTracker::calculate_displacement()
{
    return calcDistanceToKL(final_x, final_y, 0, 0);
}

/**
 * Calculates and sets the distance value of the path.
 * Distance: Total length of the path.
 *
 * @param x x-component of the newly added vector
 * @param y y-component of the newly added vector
 */
void PathTracker::calculate_distance(int x, int y)
{
    float tempDist = calcDistanceToKL(x, y, 0, 0);
    distance += tempDist;
    
}

/**
 * It is a helper function which calculates Euclidean distance between two
 * points on the vector space.
 *
 * @param x1 x-component of the first point
 * @param y1 y-component of the first point
 * @param x2 x-component of the second point
 * @param y2 y-component of the second point
 * @return Euclidean distance value
 */
float PathTracker::calculate_l2(int x1, int y1, int x2, int y2)
{
    return calcDistanceToKL(x1, x2, y1, y2);
}

/**
 * Prints the summary of the PathTracker as:
 * Final position: [x,y] Displacement: #disp# Distance: #dist#
 * Do not forget the newline char at the end.
 */
void PathTracker::summary()
{
    /* do NOT remove this line */
    std::cout.precision(5);
    
    /* WRITE YOUR CODE HERE */
    if(distance < 0.001f){
        distance = 0;
    }
    
    if(displacement < 0.001f){
        displacement = 0;
    }
    std::cout<<"Final Position: ["<< final_x<<","<< final_y<<"] Displacement: "<< displacement<<" Distance: "<<distance<<std::endl;
}

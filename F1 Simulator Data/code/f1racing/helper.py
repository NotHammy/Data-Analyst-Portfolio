import math
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import heapq

def worldpos_into_list(x, y):
    """
        Combines two floats into a 2 element list (2e-list)
        Parameters: 
            x: WORLDPOSX (float)
            y: WORLDPOSY (float)
        Returns: A list of 2e lists, where each 2e-list contains (x_i,y_i)
        TC: O(1)
    """
    return list(zip(x, y))


def distance_formula(A, B):
    """
        Function takes two coordinates (x,y), outputs straight-line distance between points using distance formula.
        Parameters: Two lists: A and B, each with two elements within them (x,y).
        Returns: Float of the distance
        TC: O(1)
    """
    return math.sqrt((A[0] - B[0])**2 + (A[1] - B[1])**2)


def angle_between_vectors(v1, v2):
    """
    Calculates the angle (in degrees) between two 2D vectors v1 and v2.

    Parameters:
        v1 (tuple or list): The first vector, given as (x1, y1).
        v2 (tuple or list): The second vector, given as (x2, y2).

    Returns:
        float: The angle between the two vectors in degrees.
    """
    # Compute the dot product of v1 and v2
    dot_prod = v1[0]*v2[0] + v1[1]*v2[1]

    # Compute the magnitudes (lengths) of v1 and v2
    mag_v1 = math.sqrt(v1[0]**2 + v1[1]**2)
    mag_v2 = math.sqrt(v2[0]**2 + v2[1]**2)

    # Avoid division by zero in case of zero-length vectors
    if mag_v1 == 0 or mag_v2 == 0:
        raise ValueError("One of the vectors has zero magnitude.")

    # Compute the cosine of the angle using the dot product formula
    cos_theta = dot_prod / (mag_v1 * mag_v2)

    # Clamp the cosine value to the valid range [-1, 1] to avoid numerical errors
    cos_theta = max(min(cos_theta, 1), -1)

    # Compute the angle in radians
    angle_rad = math.acos(cos_theta)

    # Convert the angle from radians to degrees
    angle_deg = math.degrees(angle_rad)

    return angle_deg


def closest_two_points(A, B_list):
    """
    Finds the closest and second closest points to A in B_list.

    Parameters:
        A: A point represented as a list [x, y].
        B_list: A list of points, each represented as a list [x, y].

    Returns:
        Two lists: 
            B1: Coordinates of the closest point.
            B2: Coordinates of the second closest point.

    Time Complexity: O(n), where n is the number of points in B_list.
    """
    if len(B_list) < 2:
        raise ValueError("B_list must contain at least two points.")

    # Compute distances to all points and store them with their corresponding points
    distances = [(distance_formula(A, B), B) for B in B_list]

    # Use heapq.nsmallest to find the two points with the smallest distances
    two_smallest = heapq.nsmallest(2, distances)

    # Extract the points corresponding to the smallest distances
    B1 = two_smallest[0][1]
    B2 = two_smallest[1][1]

    return B1, B2


def project_point_onto_line(A, B1, B2):
    """
        Project a point A onto the line defined by points B1 and B2, then gives projected point, distance to projected point, and then relative distance between projected point and two points (B1, B2) forming the line.
        Designed to be used by finding distance between the car and left/right/line files given about the track.
        Parameters:
            A (x,y): The coordinates of the point to be projected
            B1 (x1, y1): The first point defining the line
            B2 (x2,y2): The second point defining the line
        Returns: 3 items
            A_p (2e-list): The coordinates of the projected point on the line.
            d (float): The distance between the point A and the projected point A_p.
            c (float): A float between 0 and 1, which gives the proportion of the distance A_p is from B_1 vs distance A_p is from B_2. 
        TC: O(1)
    """
    # Step 1: Calculate 'c' for the projection
    c = ((A[0] - B1[0]) * (B2[0] - B1[0]) + (A[1] - B1[1]) * (B2[1] - B1[1])) / (distance_formula(B1, B2)**2)
    
    # Step 2: Find the coordinates of the projected point A_p
    A_p = (B1[0] + c * (B2[0] - B1[0]), B1[1] + c * (B2[1] - B1[1]))
    
    # Step 3: Calculate the distance between A and A_p
    d = distance_formula(A, A_p)
    
    return A_p, d, c


def project_point_onto_line_side(A, B1, B2):
    """
    Project a point A onto the line defined by points B1 and B2, and determine which side of the line A is on.
    
    Parameters:
        A (x,y): The coordinates of the point to be projected.
        B1 (x1, y1): The first point defining the line.
        B2 (x2, y2): The second point defining the line.
        
    Returns: 
        A_p (tuple): The coordinates of the projected point on the line.
        d (float): The distance between the point A and the projected point A_p.
        c (float): A float between 0 and 1, which gives the proportion of the distance A_p is from B1 vs from B2.
        side (int): 1 if A is on one side, -1 if on the opposite side, and 1 if directly on the line.
        
    TC: O(1)
    """
    # Step 1: Calculate 'c' for the projection
    c = ((A[0] - B1[0]) * (B2[0] - B1[0]) + (A[1] - B1[1]) * (B2[1] - B1[1])) / (distance_formula(B1, B2)**2)
    
    # Step 2: Find the coordinates of the projected point A_p
    A_p = (B1[0] + c * (B2[0] - B1[0]), B1[1] + c * (B2[1] - B1[1]))
    
    # Step 3: Calculate the distance between A and A_p
    d = distance_formula(A, A_p)
    
    # Step 4: Determine which side of the line A is on using the cross product
    # Vector AB1 = A - B1 and B2B1 = B2 - B1
    cross_product = (B2[0] - B1[0]) * (A[1] - B1[1]) - (B2[1] - B1[1]) * (A[0] - B1[0])
    
    if cross_product > 0:
        side = 1  # A is on the left side of the line
    elif cross_product < 0:
        side = -1  # A is on the right side of the line
    else:
        side = 1  # A is directly on the line
    
    return A_p, d, c, side


def distance_to_projection(A, B1, B2):
    """
    Calculate the distance between point A and its projection onto the line defined by B1 and B2.

    Parameters:
    A (iterable): Coordinates of point A.
    B1 (iterable): Coordinates of point B1.
    B2 (iterable): Coordinates of point B2.

    Returns:
    float: The distance between point A and its projection onto the line.

    Raises:
    ValueError: If B1 and B2 are the same point (cannot define a line).
    """
    # Compute vector v = B2 - B1 (direction vector of the line)
    v = [b2 - b1 for b2, b1 in zip(B2, B1)]
    # Compute vector w = A - B1
    w = [a - b1 for a, b1 in zip(A, B1)]
    # Compute dot product w ⋅ v
    dot_product = sum(w_i * v_i for w_i, v_i in zip(w, v))
    # Compute magnitude squared of v
    v_magnitude_squared = sum(v_i ** 2 for v_i in v)
    # Avoid division by zero
    if v_magnitude_squared == 0:
        raise ValueError("B1 and B2 are the same point; cannot define a line.")
    # Compute scalar projection factor
    scalar_proj = dot_product / v_magnitude_squared
    # Compute projection point P = B1 + scalar_proj * v
    P = [b1 + scalar_proj * v_i for b1, v_i in zip(B1, v)]
    # Compute distance between A and P
    distance = math.sqrt(sum((a - p) ** 2 for a, p in zip(A, P)))

    return P, distance


def interpolate_time_of_crossing_known_closest(target_dist, point1_dist, point2_dist, point1_time, point2_time):
    """
        Function takes in two points that are closest to the ending distance given, then outputs an interpolated time at which the car passed/drove a certain 'distance'.
        You put in two points that seem the closest to the lap distance of the target_point, 
        then since its unlikely there will be a frame where the car is at that exact point in the data, 
        this function will linearly interpolate a exact time when the car was at that point. 
        Parameters: 
            target_dist (float): Distance of desired target_point.
            point1_dist (float): The distance reading at the first close point
            point2_dist (float): The distance reading at the second close point
            point1_time (float): Time of car at first point
            point2_time (float): Time of car at second points
        Returns: Interpolated time at which car passed target distance
        TC: O(1)
        Note!: This function assumes you know the closest two points (based on distance), if you don't know closest two points see below.
    """
    if not ((point1_dist < target_dist < point2_dist) or (point2_dist < target_dist < point1_dist)):
        raise ValueError(f"The two closest points both have larger or smaller distances than target_distance")

    c = (point1_dist - target_dist) / abs(point1_dist - point2_dist)
    interpolate_time = (1 - c) * point1_time + c * point2_time
    return interpolate_time


def interpolate_time_of_crossing_unknown_closest(target_dist, point_dist_list, point_times_list):
    """
        Function takes in list of points, then outputs an interpolated time at which the car passed/drove a certain 'distance'.
        Function takes in a list of points, and their associated times.
        Parameters: 
            target_dist (float): Distance of desired target_point.
            point_dist_list (list): List of distances of points
            point_times_list (list): List of corresponding times of points 
                Note: ensure indexes of both lists line up (same index same row!!)
        Returns: Interpolated time at which car passed target distance
        TC: O(n)
        Note!: This function assumes you don't know the closest two points (based on distance).
    """
    if len(point_dist_list) < 2:
        raise ValueError("point_dist_list must contain at least two points.")
    if len(point_times_list) < 2:
        raise ValueError("point_times_list must contain at least two points.")

    #point 1 is larger dist
    #point 2 is smaller dist
    point1 = None
    point1_index = None
    point2 = None
    point2_index = None

    for index, value in enumerate(point_dist_list):
        if value >= target_dist:
            if point1 is None or value < point1:
                point1 = value
                min_larger_index = index
        if value <= target_dist:
            if point2 is None or value > point2:
                point2 = value
                point2_index = index
    if point1 == None or point2 == None:
        raise ValueError("couldn't find applicable point in list")

    return interpolate_time_of_crossing_known_closest(target_dist, point1, point2, point_times_list[point1_index], point_times_list[point2_index])


def is_car_on_track(car_world_pos, left_side_points, right_side_points):
    """
    Function checks if a car is on the track or slightly off with a specified overhang allowance.
    Parameters:
        car_world_pos (list): Position of the car's midpoint in the world (x, y).
        left_side_points (list of lists): List of coordinates of the left side of the track.
        right_side_points (list of lists): List of coordinates of the right side of the track.
    Return: boolean indicating if the car is on the track (True if on track, False if off track).
    TC: O(n)
    """
    
    # Step 1: Find the two nearest points on the left and right sides of the track
    Ln1, Ln2 = closest_two_points(car_world_pos, left_side_points)
    Rn1, Rn2 = closest_two_points(car_world_pos, right_side_points)
    
    # Step 2: Project the car position onto the left and right track boundaries
    L_track_point, dist_to_left = distance_to_projection(car_world_pos, Ln1, Ln2)
    R_track_point, dist_to_right = distance_to_projection(car_world_pos, Rn1, Rn2)
    
    # Step 3: Compute track width between the projected points
    track_width = distance_formula(L_track_point, R_track_point)
    
    # Step 4: Account for the car's width and allow a total of 2-meter overhang
    car_half_width = 1  # Car is 2 meters wide, so half is 1 meter
    
    # Calculate the effective distance including overhang allowance
    car_to_left_edge = dist_to_left - car_half_width
    car_to_right_edge = dist_to_right - car_half_width
    
    # Calculate the effective distance between edges
    car_effective_distance = car_to_left_edge + car_to_right_edge

    # Step 5: Check if the car is on the track or within allowable overhang
    if car_effective_distance <= track_width:
        return True
    else:
        return False


def line_intersection(point1, point2, ref_point1, ref_point2):

    """
        Function that finds the intersection between two lines, if one exists.
        Parameters:
            point1: 2 element list containing x, y coordinates
            point2: 2 element list containing x, y coordinates
            ref_point1: 2 element list containing x, y coordinates
            ref_point2: 2 element list containing x, y coordinates
        Return: (x,y) tuple if intersection point found, or None is no intersection found.
    """

    a1 = point2[1] - point1[1]
    b1 = point1[0] - point2[0]
    c1 = a1*(point1[0]) + b1*(point1[1])

    # Line CD represented as a2x + b2y = c2
    a2 = ref_point2[1] - ref_point1[1]
    b2 = ref_point1[0] - ref_point2[0]
    c2 = a2*(ref_point1[0]) + b2*(ref_point1[1])

    determinant = a1*b2 - a2*b1

    if (determinant == 0):
        # The lines are parallel. This is simplified
        # by returning a pair of FLT_MAX
        return None
    else:
        x = (b2*c1 - b1*c2)/determinant
        y = (a1*c2 - a2*c1)/determinant
        return (x,y)


def is_point_in_segment(intersection, ref_point1, ref_point2):

    """
        Function that checks if a point lies between two other points.
        Parameters:
            intersection: 2 element tuple containing x, y coordinates
            ref_point1: 2 element list containing x, y coordinates
            ref_point2: 2 element list containing x, y coordinates
        Return: Boolean, true if intersection is between points, false otherwise.
    """

    if (ref_point1[0] > ref_point2[0]):
        return (ref_point1[0] >= intersection[0] >= ref_point2[0]) and (ref_point1[1] >= intersection[1] >= ref_point2[1])
    
    return (ref_point1[0] <= intersection[0] <= ref_point2[0]) and (ref_point1[1] >= intersection[1] >= ref_point2[1])


def find_point_intersection(point1, point2, ref_line_lst):

    """
        Function that finds the intersection between a line and a series of points, if one exists.
        Parameters:
            point1: 2 element list containing x, y coordinates
            point2: 2 element list containing x, y coordinates
            ref_list: a nested list containing a list of [x,y] coordinates
        Return: (x,y) tuple if intersection point found, or None is no intersection found.
    """

    # Iterate through each segment in the reference line list
    for i in range(len(ref_line_lst) - 1):
        ref_point1 = ref_line_lst[i]
        ref_point2 = ref_line_lst[i + 1]

        # Find intersection between the two line segments
        intersection = line_intersection(point1, point2, ref_point1, ref_point2)
        
        if intersection is not None:
            if is_point_in_segment(intersection, ref_point1, ref_point2):
                return intersection
    
    return None


def find_point_intersection_and_closest_points(point1, point2, ref_line_lst):

    """
        Function that finds the intersection between a line and a series of points, if one exists.
        Parameters:
            point1: 2 element list containing x, y coordinates
            point2: 2 element list containing x, y coordinates
            ref_list: a nested list containing a list of [x,y] coordinates
        Return: (x,y) tuple if intersection point found, or None is no intersection found.
    """

    # Iterate through each segment in the reference line list
    for i in range(len(ref_line_lst) - 1):
        ref_point1 = ref_line_lst[i]
        ref_point2 = ref_line_lst[i + 1]

        # Find intersection between the two line segments
        intersection = line_intersection(point1, point2, ref_point1, ref_point2)
        
        if intersection is not None:
            if is_point_in_segment(intersection, ref_point1, ref_point2):
                return intersection, ref_point1, ref_point2
    
    return None


def find_all_car_intersection_points_and_closest_points(f1sim_car_df, f1sim_turns, turn_coord1, turn_coord2):
    """
    Finds intersections between car paths and a line segment defined by given Turn corners.

    Parameters:
    - f1sim_car_df: DataFrame containing car positions with 'INDEX', 'WORLDPOSX', and 'WORLDPOSY'.
    - f1sim_turns: DataFrame containing turn information with columns for corner coordinates.
    - turn_coord1: Integer that represents the turn index of point 1.
    - turn_coord2: Integer that represents the turn index of point 2.

    Returns:
    - intersection_turn1_points: A dictionary where keys are lap IDs and values are dictionaries 
      containing the intersection point and two closest car points to the intersection.
    """
    unique_lap_ids = f1sim_car_df["INDEX"].unique()
    intersection_points = {}

    for lap in unique_lap_ids:
        df = f1sim_car_df[f1sim_car_df["INDEX"] == lap]
        point1 = [f1sim_turns.loc[turn_coord1].get(3), f1sim_turns.loc[turn_coord1].get(4)] # get coordinates of Turn 2 CORNER_X1, CORNER_Y1
        point2 = [f1sim_turns.loc[turn_coord2].get(5), f1sim_turns.loc[turn_coord2].get(6)] # get coordinates of Turn 2 CORNER_X2, CORNER_Y2
        car_line = df[['WORLDPOSX', 'WORLDPOSY']].values.tolist()
        if find_point_intersection_and_closest_points(point1, point2, car_line) is None:
            print(f"{lap}")
        else:
            car_intersection_point_turn1, car_point1, car_point2 = find_point_intersection_and_closest_points(point1, point2, car_line)
            intersection_points[lap] = {"intersection": car_intersection_point_turn1, "car_point1" : car_point1, "car_point2" : car_point2}

    return intersection_points


def plot_track_with_turns(f1sim_left_df, f1sim_right_df, turns_df, turn_start, turn_end, f1sim_line, x_coords, y_coords, x_min=100, x_max=None, y_min=-500, y_max=500):
    """
    Plots the track boundaries and annotates the apex and corners of specified turns.

    Parameters:
    - f1sim_left_df: DataFrame containing the world positions for the left boundary of the track.
    - f1sim_right_df: DataFrame containing the world positions for the right boundary of the track.
    - turns_df: DataFrame containing information about the turns (TURN, APEX_X1, APEX_Y1, CORNER_X1, CORNER_Y1, CORNER_X2, CORNER_Y2).
    - turn_start: an integer that describes the first turn to include.
    - turn_end: an integer that describes the last turn to include.
    - x_min: Minimum x-axis value for the plot (default is 100).
    - x_max: Maximum x-axis value for the plot (if None, it will use the maximum value from f1sim_left_df).
    - y_min: Minimum y-axis value for the plot (default is -500).
    - y_max: Maximum y-axis value for the plot (default is 500).
    """

    # Defines which turns to include in the plot
    turns_of_interest = turns_df[(turns_df['TURN'] >= turn_start) & (turns_df['TURN'] <= turn_end)]
    
    # Plot track boundaries and reference line
    plt.figure(figsize=(12, 8))
    plt.scatter(f1sim_left_df['WORLDPOSX'], f1sim_left_df['WORLDPOSY'], c='black', label='Left Boundary', s=0.05)
    plt.scatter(f1sim_right_df['WORLDPOSX'], f1sim_right_df['WORLDPOSY'], c='black', label='Right Boundary', s=0.05)
    plt.scatter(f1sim_line["WORLDPOSX"], f1sim_line["WORLDPOSY"], c='red', label='Reference Line', s=0.5)
    plt.scatter(x_coords, y_coords, c='blue', label='Segements of Car', s=10)

    # Annotate apex and corners
    for i, row in turns_of_interest.iterrows():
        offset = (-60, 60) if i < len(turns_of_interest) // 2 else (60, -50)
        plt.annotate(f"Turn {int(row['TURN'])} Apex", xy=(row['APEX_X1'], row['APEX_Y1']), 
                    xytext=offset, textcoords="offset points", ha='center', fontsize=11, color='red', weight='bold',
                    arrowprops=dict(facecolor='red', shrink=0.05))
        
        plt.scatter(row['CORNER_X1'], row['CORNER_Y1'], color='green', s=20)  # Corner 1 point
        plt.scatter(row['CORNER_X2'], row['CORNER_Y2'], color='green', s=20)  # Corner 2 point
        plt.plot([row['CORNER_X1'],row['CORNER_X2']], [row['CORNER_Y1'],row['CORNER_Y2']], color='green')
        
    # Set labels, title, and limits
    plt.xlabel('WORLDPOSX')
    plt.ylabel('WORLDPOSY')
    plt.title('Track: Turns 1 to 3')
    plt.xlim(x_min, x_max if x_max else f1sim_left_df['WORLDPOSX'].max())
    plt.ylim(y_min, y_max)
    plt.legend()
    plt.show()


def generate_segment_data(f1sim_car_df, intersection_points1, intersection_points2, f1sim_line, f1sim_left, f1sim_right, segment_name="", offset_start=0, offset_end=0, interval_samples=10, segment_num=1):
    """
    Generates segmented data for F1 simulation analysis between specified start and end points.

    This function extracts data from segments of an F1 car's lap between two intersection points. 
    It calculates key metrics such as speed, throttle, brake, and relative distance from a reference line at specified intervals.

    Args:
        f1sim_car_df (pd.DataFrame): Dataframe containing F1 simulation data, including car position, speed, throttle, and braking information.
        intersection_points1 (dict): Dictionary of intersection points (start) for each lap, with lap IDs as keys and car positions as values.
        intersection_points2 (dict): Dictionary of intersection points (end) for each lap, with lap IDs as keys and car positions as values.
        f1sim_line (pd.DataFrame): Dataframe containing the reference line data, including 'WORLDPOSX' and 'WORLDPOSY' columns.
        segment_name (str, optional): Name of the segment, used for labeling output keys (e.g., "TURN1"). Default is an empty string.
        offset_start (float, optional): Distance to adjust the start point in meters. Positive values move the start point forward. Default is 0.
        offset_end (float, optional): Distance to adjust the end point in meters. Positive values move the end point forward. Default is 0.
        interval_samples (int, optional): Number of samples (points) to generate between start and end points. Default is 10.
        segment_num (int, optional): Segment number that determines how start and end points are selected:
            - 1: Start from minimum LAP_DISTANCE, end at the intersection point.
            - 2 or 4: Start and end at the first intersection point.
            - 3 or 5: Start at the second intersection point, end at the first intersection point.

    Returns:
        tuple: 
            - segment_dict (dict): A dictionary where each lap ID is a key containing segment data such as brake, throttle, speed, distance from reference line, and lap distance for each sampled interval.
            - points_for_graphing (list): A list of car position coordinates (WORLDPOSX, WORLDPOSY) for visualizing the segment path.

    Example:
        segment_data, graph_points = generate_segment_data(f1sim_car_df, intersection_points1, intersection_points2, f1sim_line, segment_name="TURN1", offset_start=3, offset_end=5, interval_samples=10, segment_num=1)
    """
    segment_dict = {}
    ref_line = f1sim_line[['WORLDPOSX', 'WORLDPOSY']].values.tolist()
    left_line = f1sim_left[['WORLDPOSX', 'WORLDPOSY']].values.tolist()
    right_line = f1sim_right[['WORLDPOSX', 'WORLDPOSY']].values.tolist()

    for lap in intersection_points1.items():
        lap_id = lap[0]  # Extract the lap identifier
        df = f1sim_car_df[f1sim_car_df["INDEX"] == lap_id]
        df = df.reset_index(drop=True)

        if segment_num == 1:
            end_point = df.loc[(df['WORLDPOSX'] == lap[1]['car_point1'][0]) & (df["WORLDPOSY"] == lap[1]['car_point1'][1])]
            start_point = df.loc[df["LAP_DISTANCE"] == df["LAP_DISTANCE"].min()]
        elif segment_num == 4 or segment_num == 2:
            start_point = df.loc[(df['WORLDPOSX'] == lap[1]['car_point1'][0]) & (df["WORLDPOSY"] == lap[1]['car_point1'][1])]
            end_point = start_point
        elif segment_num == 3:
            start_point = df.loc[(df['WORLDPOSX'] == lap[1]['car_point1'][0]) & (df["WORLDPOSY"] == lap[1]['car_point1'][1])]
            end_point = df.loc[(df['WORLDPOSX'] == intersection_points2[lap_id]['car_point1'][0])]
        elif segment_num == 5 or segment_num == 3:
            # Find the row corresponding to the car's position at the start_point
            end_point = df.loc[(df['WORLDPOSX'] == lap[1]['car_point1'][0]) & (df["WORLDPOSY"] == lap[1]['car_point1'][1])]
            start_point = df.loc[(df['WORLDPOSX'] == intersection_points2[lap_id]['car_point1'][0]) & (df["WORLDPOSY"] == intersection_points2[lap_id]['car_point1'][1])]

        end_distance = end_point.iloc[0]["LAP_DISTANCE"] + offset_end
        start_distance = start_point.iloc[0]["LAP_DISTANCE"] + offset_start  # Adjusted start distance
        interval_distances = np.linspace(start_distance, end_distance, interval_samples)

        # Initialize count for segment numbering
        points_for_graphing = []
        count = 1
        # Loop through each interval distance
        for interval in interval_distances:
            # Find the closest row based on LAP_DISTANCE
            closest_index, closest_value = min(enumerate(df["LAP_DISTANCE"].values), key=lambda x: abs(x[1] - interval))
            row = df.loc[closest_index]

            points_for_graphing.append([row["WORLDPOSX"], row["WORLDPOSY"]])

            # Finding the distance of the car relative to the reference line
            car_coordinates = [row["WORLDPOSX"], row["WORLDPOSY"]]
            point1, point2 = closest_two_points(car_coordinates, ref_line)
            left_point1, left_point2 = closest_two_points(car_coordinates, left_line)
            right_point1, right_point2 = closest_two_points(car_coordinates, right_line)
            relative_car_distance_from_ref = project_point_onto_line_side(car_coordinates, point1, point2)
            relative_car_distance_from_left = project_point_onto_line_side(car_coordinates, left_point1, left_point2)
            relative_car_distance_from_right = project_point_onto_line_side(car_coordinates, right_point1, right_point2)
            
            # Check if the lap_id exists in the dictionary, if not, initialize it
            if lap_id not in segment_dict:
                segment_dict[lap_id] = {"INDEX": int(lap_id)}  # Use the lap_id as the key instead of the lap dictionary
            
            # Add segment data to the dictionary without overwriting previous entries
            segment_dict[lap_id][f"BRAKE_{segment_name}SEGMENT{count}"] = row["BRAKE"]
            segment_dict[lap_id][f"THROTTLE_{segment_name}SEGMENT{count}"] = row["THROTTLE"]
            segment_dict[lap_id][f"STEERING_{segment_name}SEGMENT{count}"] = row["STEERING"]
            segment_dict[lap_id][f"SPEED_KPH_{segment_name}SEGMENT{count}"] = row["SPEED_KPH"]
            segment_dict[lap_id][f"DISTANCE_FROM_REFLINE_{segment_name}SEGMENT{count}"] = relative_car_distance_from_ref[1] * relative_car_distance_from_ref[3]
            segment_dict[lap_id][f"DISTANCE_FROM_LEFT_{segment_name}SEGMENT{count}"] = relative_car_distance_from_left[1] * relative_car_distance_from_left[3]
            segment_dict[lap_id][f"DISTANCE_FROM_RIGHT_{segment_name}SEGMENT{count}"] = relative_car_distance_from_right[1] * relative_car_distance_from_right[3]
            segment_dict[lap_id][f"LAP_DISTANCE_{segment_name}SEGMENT{count}"] = row["LAP_DISTANCE"]
            
            count += 1  # Increment the segment counter

    return segment_dict, points_for_graphing

# Optimising F1 Car Dynamics for Maximum Exit Speed at Turn 2 of Albert Park Circuit

## Project Description and Objective:
The objective is to optimise an F1 car's position, braking, steering, and throttle parameters at Turns 1 and 2 of Albert Park Circuit, maximising the exit speed out of Turn 2. This is achieved by creating features that capture the results of this analysis, which is then packaged into a data product.

### Significance:
Oracle, a major technology sponsor for F1 and Red Bull Racing, plays a pivotal role in leveraging data to optimise race strategy, contributing to improvements in real-world driver performance.

### Previous Work:
Oracle’s OCI (Oracle Cloud Infrastructure) has been key in running Monte Carlo simulations and real-time analytics that guide racing strategies. This project aims to provide the underlying data that Oracle and other stakeholders can use to run these simulations and optimise individual car parameters. These insights could offer further value to their racing partnerships.

## Sources:
- **F1 Simulation Data (2022-2023)**  
  [Files: `f1sim-data-2022.csv`, `f1sim-data-2023.csv`]  
  Key columns:
  - **SESSION_IDENTIFIER**, **FRAME**, **LAP_NUM**
  - **Performance metrics:** `CURRENT_LAP_TIME_MS`, `SPEED_KPH`
  - **Driving parameters:** `THROTTLE`, `BRAKE`, `STEERING`
    - Note: Throttle and Brake have values between [0,1] where 0 represents no brake/throttle strength and 1 represents full brake/throttle strength
  - **Position data:** `WORLDPOSX`, `WORLDPOSY`, `LAP_DISTANCE`

- **Reference Data (Turn 1 & 2 Coordinates)**  
  [Files: `f1sim-ref-turns.csv`]  
  Key columns:
  - **Apex coordinates:** `APEX_X1`, `APEX_Y1`
  - **Corner Tangents:** `CORNER_X1`, `CORNER_Y1`, `CORNER_X2`, `CORNER_Y2`
    - Note: The Corner coordinates represent the radius of the turning arc around the Apex of each turn. See attached diagram in the ``workflow`` section for visualisation.

- **Reference Data (Left & Right Positions)**  
  [Files: `f1sim-ref-left.csv`, `f1sim-ref-right.csv`]  
  Key columns:  
  - Session-specific world coordinates `WORLDPOSX`, `WORLDPOSY` for left and right-hand sides of the track.

## Workflow:
This workflow ensures detailed analysis in critical segments while maintaining simplicity for broader track sections to optimise vehicle performance.

### Understanding the Data and Problem:
**Set Goals:** Optimise exit speed at Turn 2 by analysing braking, steering, throttle, and positioning using F1 simulation data from 2022 and 2023.

### Data Cleaning:
- **Merge and Concatenate Data:** Combined 2022 and 2023 datasets; excluded 2024 data due to format differences and low lap count.
- **Filtering** (explained in Observation Section)
- **Column Selection:** Removed irrelevant columns (`YAW`, `PITCH`, `ROLL`, `GEAR`, etc.) based on stakeholder feedback.

### Data Analysis:
- Summary statistics and correlation between features: Investigate the relationship between throttle, braking, steering angle, and exit speed.
- Visualise data: Use plots to understand trends and distributions of features.

### Feature Engineering:
**Lap Identifier:** Created `LAP_ID` by combining `SESSION_IDENTIFIER` and `LAP_NUM`.

**General Lap Features:** Focused on broader factors (e.g. braking distance before Turn 1, max speed between Turn 2 and Turn 3, lap validity).

**Segment Features:** To truly achieve a detailed view on the behaviour of the car through Turn 1 and Turn 2, we will take a segmented approach for track in these turns. Specifically, we will divide the track within a carefully chosen startpoint and endpoint (as discussed below) and dynamically spaced distance intervals to extract relevant information such as:
- Car position relative to the reference line
- Average speed K/H
- Average Throttle strength
- Average Brake strength

The chosen startpoint (just for the intervals - not the overall starting line) will be the position at which the first individual brakes coming into Turn 1. Which is determined as follows:
1. Find the distance when the average braking value is first at 0.1. (Our initial approach was to take the earliest brake time, however, there were drivers who braked right from the beginning of the track which would not help to focus solely on turn 1 and turn 2)
2. Find the coordinates of a car that has a lap distance closest to the distance found in step 1.
3. Remove all car, reference, left-side and right-side track coordinates with an x-coordinate less than the reference point found in step 2. 

The chosen endpoint (just for the intervals - not the overall finishing line) will be the reference point when crossing the tangent line (given to us) of Turn 2. Which is determined as follows:
1. Use the corner points provided in the Turns file to determine the straight line/tangent of Turn 2. 
2. Find the reference point on this line. 
3. Remove all car, reference, left-side and right-side track coordinates with an x-coordinate greater than the reference point found in step 2. 

The dynamic interval distances were chosen using the following methodology, intervals will be created between a lap distance of 242 and 516 metres:
- The first 110 metres of this interval from the defined startpoint will be the straight leading up to the tanget of Turn 1 - It will be sampled every 10 metres.
- The next 5 metres of the track will be sampled every metre (as we are coming to a crucial tangent line of Turn 1 where behaviour of the car will completely influence the success of the turns). 
- The next 65 metres around the apex of Turn 1 will be segmented at every 5 metres (roughly the car's length)
- The next 5 metres of the track will be segmented every metre (as we transition from the turning radius of Turn 1 to Turn 2)
- The next 88 metres around the apex of Turn 2 will be segmented every 5 metres (rougly the car's length)

A break down of the track between Turn 1 and Turn 2 can be seen below.

![IMG_0825.jpg](https://private-user-images.githubusercontent.com/181029606/373855956-495b9f9a-20c8-4034-995a-61805da01dfe.jpg?jwt=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmF3LmdpdGh1YnVzZXJjb250ZW50LmNvbSIsImtleSI6ImtleTUiLCJleHAiOjE3MjgxMTU0MDIsIm5iZiI6MTcyODExNTEwMiwicGF0aCI6Ii8xODEwMjk2MDYvMzczODU1OTU2LTQ5NWI5ZjlhLTIwYzgtNDAzNC05OTVhLTYxODA1ZGEwMWRmZS5qcGc_WC1BbXotQWxnb3JpdGhtPUFXUzQtSE1BQy1TSEEyNTYmWC1BbXotQ3JlZGVudGlhbD1BS0lBVkNPRFlMU0E1M1BRSzRaQSUyRjIwMjQxMDA1JTJGdXMtZWFzdC0xJTJGczMlMkZhd3M0X3JlcXVlc3QmWC1BbXotRGF0ZT0yMDI0MTAwNVQwNzU4MjJaJlgtQW16LUV4cGlyZXM9MzAwJlgtQW16LVNpZ25hdHVyZT0yNDcwMWYyZWY0ODVjMmUzOGY3MGI0ZDE1NmQ0OTNmODg1ZWJjNThjN2IyZDRmMTJjZGEyOTc0ZTY4M2FkZDQ2JlgtQW16LVNpZ25lZEhlYWRlcnM9aG9zdCJ9.SYVbIRIF12XgkAEQxLZ5zW_bRiOdUHY9CIVTakp5TGI)

## Data Description:

### Observations 
#### Filtering Process and Justification:
- **Lap Time:** Only laps with a time below 120 seconds were included, as laps exceeding this time are considered too slow for meaningful analysis according to the Oracle representative.
- **Frame Rate:** Laps with less than 12 frames per second were removed to ensure sufficient data resolution for precise analysis. The 12 FPS floor was calculated as an average across laps, eliminating those with low FPS hindering analysis.
- **Lap Distance:** Only frames with a lap distance of less than 1158 metres (distance covered up to Turn 3) were retained to ensure focus on the targeted track segment.

This filtering process yields a dataset of 657 rows, where each row represents a unique lap attempt. Data from all rows pertaining to the same lap will be condensed into features.

### Features

#### General Lap Features:

| **Feature Name**                   | **Feature Outline**                                                                                             | **Feature Construction**                                                                                                                                                    |
|------------------------------------|-----------------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| **LAP_ID**                         | Key/unique identifier                                                                                           | Combine `SESSION_IDENTIFIER` and `LAP_NUM`.                                                                                                                                 |
| **INVALID_LAP**                    | Specifies an 'Invalid' lap (all 4 wheels outside track) value of 0 if valid, value 1 if invalid                  | To be confirmed.                                                                                                                                                           |
| **EXIT_SPEED_KPH_TURN2**           | Speed in kilometres per hour upon exiting Turn 2                                                                | 1) Find the Euclidean distance between exit coordinates of Turn 2 and vehicle in all frames. 2) Find smallest distance and report `SPEED_KPH` as exit speed from Turn 2.    |
| **MAX_SPEED_BETWEEN_TURN2_TURN3**  | Maximum speed in the straight between Turn 2 and Turn 3                                                          | 1) Find frames closest to exit Turn 2 and entry Turn 3. 2) Extract all frames between these points. 3) Find max `SPEED_KPH` in frames grouped by `SESSION_IDENTIFIER` and `LAP_NUM`. |
| **THROTTLE_DOWN_LAP_DISTANCE_TURNS**| Position at which car begins to throttle between entry Turn 1 and exit Turn 2                                    | 1) Take `LAP_DISTANCE` where `THROTTLE` is greater than a threshold. 2) Record first instance where threshold is breached.                                                 |
| **STEERING_ANGLE_TURN1**           | Steering angle upon entering Turn 1                                                                              | 1) Take `LAP_DISTANCE` where `STEERING_ANGLE` exceeds threshold. 2) Record first instance of breach.                                                                        |
| **BRAKING_DISTANCE_TURN1**         | Distance where car begins to brake before entering Turn 1                                                        | 1) Take `LAP_DISTANCE` where `BRAKE` is greater than a threshold. 2) Record first instance of breach.                                                                       |
| **BRAKE_START**                    | Distance where the car begins braking during a braking event                                                     | 1) Detect the start of the event where `BRAKE` > 0.1 and record the `LAP_DISTANCE` of the first braking frame.                                                              |
| **BRAKE_PEAK**                     | Distance where the car reaches peak braking (maximum brake value) during a braking event                         | 1) Record the `LAP_DISTANCE` of the frame where the maximum brake value is reached during a braking event.                                                                  |
| **BRAKE_END**                      | Distance where the car finishes braking during a braking event                                                   | 1) Detect when `BRAKE` ≤ 0.1 and record the `LAP_DISTANCE` of the frame where braking ends.                                                                                 |
| **THROTTLE_START**                 | Distance where the car begins applying throttle during a throttle event                                          | 1) Detect the start of the event where `THROTTLE` > 0.1 and record the `LAP_DISTANCE` of the first throttle frame.                                                          |
| **THROTTLE_PEAK**                  | Distance where the car reaches peak throttle (maximum throttle value) during a throttle event                    | 1) Record the `LAP_DISTANCE` of the frame where the maximum throttle value is reached during a throttle event.                                                              |
| **THROTTLE_END**                   | Distance where the car finishes applying throttle during a throttle event                                        | 1) Detect when `THROTTLE` ≤ 0.1 and record the `LAP_DISTANCE` of the frame where throttle ends.                                                                             |

#### Segment Features:
- **SEG{num}_AVG_SPEED**: Average speed used through the segment.  
  
- **SEG{num}_AVG_STEER**: Average steering angle used through the segment.
  
- **SEG{num}_AVG_THROTTLE**: Average throttle used through the segment.
  
- **SEG{num}_AVG_POS_LEFT**: Average position between car reference point and closest left edge of track.
  
- **SEG{num}_AVG_POS_RIGHT**: Average position between car reference point and closest right edge of track.
  
- **SEG{num}_AVG_POS_LINE**: Average position between car reference point and closest point of the suggested line.
  
Note: Averages will be derived from the sum of all data points divided by frame count.

Note: These are the current planned features in the process of being developed and are subject to change.

## Project Status:
### Progress:
  - **GitHub repository** created and raw data loaded.
  - **Preliminary data exploration**: Engaged with Oracle Representative to understand terminology and constructed a data dictionary.
  - **Summary statistics performed**: Identified trends and distributions leading to feature creation and filtering decisions.
  - **Data cleaning**: Merged 2022 and 2023 datasets, removed anomalous observations (e.g., large lap times).
  - **Preliminary feature ideation and creation**: See the ‘Features’ section for details.

### Next Steps:
All contributors will partake in every aspect of the upcoming tasks, depending on individual strengths and availabilities:

#### Data Analysis:
- Investigate correlations between variables using statistical tests (e.g., t-tests).
- Create visualisations to better understand data distributions.

#### Feature Specification and Creation:
- Finalise the desired feature set.
- Implement code to calculate feature values.

#### Modelling Considerations:
Consider what optimisation models this data will be used for to appropriately define features.

## Usage:
### Performance Analysis of Features:
The refined dataset enables stakeholders to understand relationships between variables and their influence on optimising exit speed at Turn 2 Albert Park. This allows them to assess whether their racing strategy captures the interdependencies of these factors.

### Optimisation Approaches:
Once relationships between features are understood, several optimisation techniques can be considered:
- **Machine Learning Models**: Techniques like regression or reinforcement learning can predict optimal throttle, braking, and steering patterns.
- **Optimal Control Theory**: Focus on optimising dynamic systems by manipulating inputs to achieve the best outcome while satisfying constraints.

### Data-Driven Simulations:
Engineers can run simulations using this dataset to test the effectiveness of their racing strategies.

## Contributors:
| **Name**        | **Email**                |
|-----------------|--------------------------|
| Femke Keywood   | z5359213@ad.unsw.edu.au   |
| Amal Khan       | z5477807@ad.unsw.edu.au   |
| Vince Li        | z5482774@ad.unsw.edu.au   |
| Anvi Kohli      | z5257303@ad.unsw.edu.au   |
| Hamza Jalal     | z5361546@ad.unsw.edu.au   |

## Opportunities for Outside Involvement:
- **Simulation Modelling**: Users with simulation software experience can develop and refine models to replicate F1 car behaviour on track.
- **Data Visualisation**: Create dashboards and visuals to interpret complex data, making insights accessible to all team members.
- **Machine Learning**: Build predictive models using historical data to optimise car settings and driver behaviours for race decision-making.

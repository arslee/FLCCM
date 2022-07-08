# Field-Level California Crop Map 2007-2021
This repository contains code used to create the Field-Level California Crop Map (FLCCM). [master.R](https://github.com/arslee/FLCCM/blob/master/master.R) walks through key steps.

# Code dependencies
R version 4.2.0, 
data.table 1.14.2, dplyr 1.0.9, purrr 0.3.4, readxl 1.4.0, raster 3.5.21, sf 1.0.7, exactextractr 0.8.2, stringr 1.4.0, landscapemetrics 1.5.4, landscapetools 0.5.0, furrr 0.3.0, ranger 0.14.1,ggplot2 3.3.6, tigris 1.6.1, plyr1.8.7

# Dataset
Our dataset can be accessed through [here](https://zenodo.org/record/6775099#.YshfanbMKUk).

# Variables

| Variable Name | Description                                                                                                                                                                                                                                                        |
|---------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| uid           | Field ID                                                                                                                                                                                                                                                           |
| county        | County                                                                                                                                                                                                                                                             |
| year          | Year                                                                                                                                                                                                                                                               |
| lng           | Longitude of field centroid                                                                                                                                                                                                                                        |
| lat           | Latitude of field centroid                                                                                                                                                                                                                                         |
| acres         | Size of field in acre                                                                                                                                                                                                                                              |
| crop1         | Crop class with the highest probability at a given data point based on a (probabilistic) random forest classifier trained using the dominant CDL crop class (m1) as the only predictor.                                                                            |
| prob1         | Class probability for crop1                                                                                                                                                                                                                                        |
| pa1           | Producer accuracy for crop1                                                                                                                                                                                                                                        |
| ua1           | User accuracy for crop1                                                                                                                                                                                                                                            |
| crop2         | Crop class with the highest probability at a given data point based on a (probabilistic) random forest classifier trained using 18 features: field-specific top five dominant crops (m1 to m5), their corresponding shares (s1 to s5), and spatial patterns of CDL |
| prob2         | Class probability for crop2                                                                                                                                                                                                                                        |
| pa2           | Producer accuracy for crop2                                                                                                                                                                                                                                        |
| ua2           | User accuracy for crop2                                                                                                                                                                                                                                            |
| crop3         | Post processed crop2 (See Methods)                                                                                                                                                                                                                                 |
| prob3         | Class probability for crop3                                                                                                                                                                                                                                        |
| pa3           | Producer accuracy for crop3                                                                                                                                                                                                                                        |
| ua3           | User accuracy for crop3                                                                                                                                                                                                                                            |
| cropLIQ       | Ground truth labels from Land IQ crop maps; available only in 2014, 2016, and  2018                                                                                                                                                                                |

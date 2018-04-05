%This vector determines how vils are allocated. To make sure we have some
%feasible designs, we put two on food and one on build (for a house)
%immediately. The next two created also go on food.

%1. Free food 2. farms 3. wood 4. gold 5. stone 6. build
vil_assignments=ceil(rand(max_Vils,1)*6);
vil_assignments(1:2)=[1,1];
vil_assignments(3)=[6];
vil_assignments(4:5)=[1,1];

%This vector is made up of the first turns that we will attempt to build
%a certain building. The slots, in order, represent:
%1. mill 2. lumber camp 3. mining 4. farm 5. blacksmith 6. barracks 7.
%archery range 8. stable

build_times=ceil(rand(num_buildings,1)*36);

%This vector is made up of the first turns that we will attempt to research
%a certain technology.
tech_times=ceil(rand(num_techs,1)*36);

%The chromosome is made up of all of our choices.
chromosome=[vil_assignments;build_times;tech_times];

x=AoEModel(chromosome)
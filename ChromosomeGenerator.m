function [chromosome] = ChromosomeGenerator()
%This function randomly generates an allowable chromosome.


max_Vils=39; %One vil is created every 25 seconds of game time.
%in 15 minutes, this works out to 36 vils, plus three starting vils.
%However, we will research wheelbarrow (75 sec; -3 vils) and Feudal age
%(130 sec, ~-5 vils), so we should probably actually have a total of 31 vils.
num_buildings=8; %Currently, 8 buildings are implemented
num_techs=2;    %Currently, 2 techs are implemented


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

end
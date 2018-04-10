function [chromosome] = ChromosomeGenerator()
%This function randomly generates an allowable chromosome.

num_steps = 20*60;
max_Vils=num_steps/25+3; 
num_buildings=8; %Currently, 8 buildings are implemented
num_techs=8;    %Currently, 8 techs are implemented


%This vector determines how vils are allocated. To make sure we have some
%feasible designs, we put two on food and one on build (for a house)
%immediately. The next two created also go on food.

%1. Free food 2. farms 3. wood 4. gold 5. stone 6. build
vil_assignments{1}=ceil(rand(max_Vils,1)*6);
vil_assignments{1}(1:2)=[1,1];
vil_assignments{1}(3)=[6];
vil_assignments{1}(4:5)=[1,1];

for i=2:8
    vil_assignments{i}=ceil(rand(max_Vils,1)*6);
end

%This vector is made up of the first turns that we will attempt to build
%a certain building. The slots, in order, represent:
%1. mill 2. lumber camp 3. mining 4. farm 5. blacksmith 6. barracks 7.
%archery range 8. stable

build_times=ceil(rand(num_buildings,1)*num_steps);

%This vector is made up of the first turns that we will attempt to research
%a certain technology.
tech_times=ceil(rand(num_techs,1)*num_steps);
vil_assignments_longform=[];
for i=1:8
    vil_assignments_longform=[vil_assignments_longform;vil_assignments{i}];
end
%The chromosome is made up of all of our choices.
chromosome=[vil_assignments_longform;build_times;tech_times];

%%[spend,vils]=AoEModel(chromosome)

end
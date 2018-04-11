function [fitness] = findFitness(spend,vils)
%FINDFITNESS is a function that, given the spend and vils values of a
%chromosome, generates the chromosome's fitness value and corresponding index value. 
% This one uses minimax.

%This function needs scaling- PERHAPS.
% spend_scaling=50;
% spend=spend./spend_scaling;


for i=1:length(spend)
        for j=1:length(vils)
            find_fitness(i,j) = max(spend(i)-spend(j),vils(i)-vils(j));
        end
        if ~isempty(find(find_fitness(i,:)~=0,2,'first'))
            if (min(find_fitness(i,find_fitness(i,:) ~=0)) >0 && length(find(find_fitness(i,:)==0,2,'first'))>1)
                fitness(i,1) = 0;
            else
                fitness(i,1) = min(find_fitness(i,find_fitness(i,:) ~=0));
            end
        else
            fitness(i,1)=0;
        end
        fitness(i,2) = i;
end

end


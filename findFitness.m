function [fitness] = findFitness(spend,vils)
%FINDFITNESS is a function that, given the spend and vils values of a
%chromosome, generates the chromosome's fitness value. This one uses
%maximin.

%This function needs scaling.
spend_scaling=50;
spend=spend./spend_scaling;

spend_domination_vec=zeros(length(spend),length(spend));
vils_domination_vec=zeros(length(spend),length(spend));

for i=1:length(spend)
% %     for j=1:length(vils)
% %         %If the domination vector is positive, that's good (the item is not
% %         %dominated). If the element in the domination vector is negative,
% %         %that's bad (the 
% %         spend_domination_vec(i,j)=spend(i)-spend(j);
% %         vils_domination_vec(i,j)=vils(i)-vils(j);
% %         
% %     end
    fit_vec(i,1)=spend(i)-max(spend);
    fit_vec(i,2)=vils(i)-max(vils);
%     fit_vec(i,1)=min(spend_domination_vec(i,:));
%     fit_vec(i,2)=min(vils_domination_vec(i,:));
end

    fitness=min(abs(fit_vec),[],2)';


end


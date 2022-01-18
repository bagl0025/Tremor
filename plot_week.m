% Brian Bagley
% May 2011
% University of Minnesota
% This script sums the daily output from compareFiles.m
% by week intervals. This makes the plots easier to read
% and compare

clear all; close all;

% NEED TO SET THE ARRAYS TO THE CORRECT COLUMN
% THE COLUMN WHERE MINUTES ARE STORED

col=3;
%x=load('/home/brian/Desktop/Tremor/tremor_plot_b17.txt');
%x=load('/home/brian/Desktop/Tremor/tremor_plot_b19.txt');
%x=load('/home/brian/Desktop/Tremor/tremor_plot_b79.txt');
x=load('/home/brian/Desktop/Tremor/tremor_plot_a32b32.txt');
%x=load('/home/brian/Desktop/Tremor/tremor_plot_a32b33.txt');
%x=load('/home/brian/Desktop/Tremor/tremor_plot_b32b33.txt');
%x=load('/home/brian/Desktop/Tremor/tremor_plot_vcab_varb.txt');
%x=load('/home/brian/Desktop/Tremor/tremor_plot_varb_ghib.txt');
%x=load('/home/brian/Desktop/Tremor/tremor_plot_vcab_ghib.txt');

n=size(x,1);    % find number of rows
over=mod(n,7);  % This is the number of extra rows (less than a week)
r=1;

for i=1:7:n-over-6      
    total(r,1)=x(i,1);            % set 1st column to jday
    total(r,2)=sum(x(i:i+6,col)); % set 2nd column to week sum
    r=r+1;
end

% This part calculates the sum for the last part that is less
% than one week
extra=n-over+1;
total(r,1)=x(extra,1);
total(r,2)=sum(x(extra:extra+over-1,col));

% DIAGNOSTIC
%park=load('/home/brian/Desktop/Result_figs/cat.plot_week.txt');
%nw=load('/home/brian/Desktop/Result_figs/nw_plot.txt');
%van=load('/home/brian/Desktop/Result_figs/van_plot.txt');
%plot(total,'k')
%hold on;
%plot(park,'b')
%plot(van,'r')

% Save the array (total) to a file to plotted by gnuplot
save a32b32_week.txt total -ascii
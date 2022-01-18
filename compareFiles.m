% Program to find coherent tremor between 2 stations
% Brian Bagley
% May 2011
% University of Minnesota
%
% Input is trem_poss_array.[station name].txt (output from detect.m)
% Need to setup station names
% Pick how to count tremor
% i.e. second by second for Parkfield or 5 minute windows for Cascadia

% ##########     VARIABLE DEFINITIONS     ##########
% c         Column index	
% fid2		File name used to save tremor plotting file
% fid		File name used to save coherent tremor times
% hour		Hour
% j     	Array index
% M     	Flag for which counting method to use
% min		Minute
% n         Number of rows in s1 file      
% r         Row index
% s         Seconds (Range 0 to 60 seconds)
% s1		First station file
% s2		Second station file
% sec		Seconds (Range 0 to 86400 seconds)
% t1		Matrix for storing coherent tremor
% t2		Matrix for storing 5 minute segments
% Tcount	Counts cumulative tremor count per day
% tmp		Temp variable for checking array
% ##########       END OF VAR DEF         ##########

clear all;
format long g;

s1=load('/home/brian/Desktop/Tremor/trem_poss_array.a32.txt');
s2=load('/home/brian/Desktop/Tremor/trem_poss_array.b32.txt');
M=1;                % Choose method to count tremor (1 or 5)

% NOTE: M only effects the plot file. The tremor_times file
% will still be second by second

fid=fopen('tremor_times.txt', 'a'); 
fid2=fopen('tremor_plot.txt','a');

% Need to make the loop match the number of rows (Days)
% Add the rows for each station to check for coherency among stations
% If tremor is present at both stations sum=2
% First column contains Julian day
% Writes a file that contains the start and stop times for tremor

n=size(s1,1);        % How many rows are there
for r=1:1:n                                                                 
    t1(r,1)=s1(r,1);                                                        
    t1(r,2:86401)=s1(r,2:86401)+s2(r,2:86401);                              
    
    for c=2:1:86401                                                         
        if (t1(r,c)==2 && t1(r,c-1)~=2)                                         
            day=t1(r,1);                                                    
            sec=c; hour=idivide(sec,int32(3600)); 
            min=idivide(sec,int32(60))-int32((hour*60)); 
            s=sec - int32((hour*3600)) - int32((min*60));  
            fprintf (fid,'%3i %5i %02i:%02i:%02i',day,sec,hour,min,s);
        end
    
        if (t1(r,c)==2 && t1(r,c+1)~=2) 
            sec=c; hour=idivide(sec,int32(3600)); 
            min=idivide(sec,int32(60))-int32((hour*60)); 
            s=sec - int32((hour*3600)) - int32((min*60));  
            fprintf (fid,' %5i %02i:%02i:%02i\n',sec,hour,min,s);          
        end
    end
end

% Still need to count tremor / day to be used for plotting
% M=1 does second by second

if (M==1)
    for r=1:1:n
        Tcount=sum(t1(r,:)==2);
        fprintf (fid2, '%3i %5i %i\n', t1(r,1), Tcount, Tcount/60);
    end
end

% M=5 looks for tremor in each 5 minute window, if present
% count it as 5 minutes - the Cascadia way

if (M==5)
t2=zeros(r,289);     % Using 289 because 1st window is for jday
    for r=1:1:n
        j=2;
        t2(r,1)=t1(r,1);    % Insert jday into column 1
        for c=2:300:86401       % Search 5 minute windows for tremor
            tmp=ismember([2],t1(r,c:c+299));
            if (tmp==1)         % If tremor is found
                t2(r,j)=2;      % make 5 min window true
            end
            j=j+1;              % Advance 5 min window index
        end
    end
    % Tcount*5*60 = seconds     Tcount*5 = minutes Tcount*5/60 = hours
    for r=1:1:n
        Tcount=sum(t2(r,:)==2);
        fprintf (fid2, '%3i %5i %i %i\n', t2(r,1), Tcount*5*60, Tcount*5, Tcount*5/60);
    end
end
fclose(fid);
fclose(fid2);
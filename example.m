%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %Description
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%This m-file is used to provide an example on how to compute leave 
%out estimates on a two-way fixed effects model using a test sample.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                     %External Packages

%Note: cd is LeaveOutTwoWay                   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
path(path,'matlab_bgl/'); %note: matlab BGL obtained from http://www.mathworks.com/matlabcentral/fileexchange/10922
path(path,'codes'); %this contains the main LeaveOut Routines.
%Install CMG Routine: downloaded from here: http://www.cs.cmu.edu/~jkoutis/cmg.html
warning('off', 'all') 
cd codes;    
path(path,'CMG'); %this contains the main LeaveOut Routines.
MakeCMG;
cd ..
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                  %PARALLEL ENVIRONMENT
                  
%Note: The user should decide which set-up is most suitable given
%      her own configuration. Make sure to delete the pool once
%      estimation has been carried out.                  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
try
%pool=parpool(4);
pool=parpool(str2num(getenv('SLURM_CPUS_PER_TASK')),'IdleTimeout', Inf);
%pool = parpool('dcs', 64);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        %CALL
                        
%Note: This is where you should specify where is the input .csv file
%      and how you would like to call the log-file created by the
%      leave out functions. 
%      
%      The user should also specify where to save and name:
%      1. Log File
%      2. Saved Results (will be in .csv)
        

%Make sure that the input .csv file is sorted by worker id and year
%(xtset id year in Stata). 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                  
%Input File
namesrc='~/scratch/fake_matched_employer_employee.csv'; %where original data is in the cluster

%Log
placelog='logs/';
namelog='test';

%Saved File
nameFile='test';
placeFile='results/';
filename=[placeFile nameFile];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %LOAD DATA
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
data=importdata(namesrc);
data = data.data;
id=data(:,1);
firmid=data(:,2);
y=data(:,4);
clear data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %RUN LEAVE-OUT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
%Options (See Description in leave_out_COMPLETE)   
leave_out_level='obs';
andrews_estimates=0;
eigen_diagno=0;
restrict_movers=0;
resid_controls=0;
controls=[];
do_SE=0;
subsample_llr_fit=0;
type_of_algorithm='exact';
epsilon=0.005;


%Log File
logname=[placelog namelog  '.log'];
system(['rm ' logname])
diary(logname)

tic
%Run
[sigma2_psi,sigma_psi_alpha,sigma2_alpha] = leave_out_COMPLETE(y,id,firmid,leave_out_level,controls,resid_controls,andrews_estimates,eigen_diagno,subsample_llr_fit,restrict_movers,do_SE,type_of_algorithm,epsilon,filename);
toc

%Close
delete(pool)
diary off

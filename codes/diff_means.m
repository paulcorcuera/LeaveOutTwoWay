%This m-file replicates Table A1 of KSS.
%We start by loading the mat file generated by the function 'leave_out_COMPLETE'

%Saved in memory, there must be a province indicator that tells us whether 
%a given match is in the province of Rovigo or Belluno in the leave-out
%largest connected set.
%(see vector: prov_indicator)


%LOAD FILE
s=['mat/COMPLETE_' filename];
load(s)
prov_indicator_old=prov_indicator;
fe1=mean(fe(prov_indicator==1));
fe2=mean(fe(prov_indicator==-1));
NT1=sum(prov_indicator==1);
NT2=sum(prov_indicator==-1);

%Auxiliary
prov_indicator=accumarray(firmid,prov_indicator,[],@mean);
prov_indicator=prov_indicator(1:J-1);
sel=prov_indicator==1;
prov_indicator(sel)=prov_indicator(sel)/(NT1);
sel=prov_indicator==-1;
prov_indicator(sel)=prov_indicator(sel)/(NT2);

%BUILD A
if K == 0
v=[sparse(N,1); degree_firms.*prov_indicator];
end
if K > 0
v=[sparse(N,1); degree_firms.*prov_indicator; sparse(K,1)];
end

%CHECK CONDITIONS
A=v*v';
[Q, lambda_eig] = eigs(A,xx,1);
x1bar=X*Q;
norm=(sum(x1bar.^2))^(0.5);
x1bar=x1bar/norm;


%Inference
sigma_i=y.*eta_h;
sigma_i=spdiags(sigma_i,0,NT,NT);
right=pcg(xx,v,1e-5,1000,Lchol,Lchol');
left=right';
V_diff_mean=left*(X'*sigma_i*X)*right;


%Now compute the correlation
degree_firms=diag((F*S)'*(F*S));
degree=(F*S)'*F*S-(1/NT)*(degree_firms)*degree_firms'; 
if K>0
A=[sparse(N,N+J+K-1); sparse(J-1,N) degree sparse(J-1,K); sparse(K,K+N+J-1)];
end
if K==0
A=[sparse(N,N+J-1); sparse(J-1,N) degree];
end
[Q, lambda_eig] = eigs(A,xx,3);
clear A degree
q1=Q(:,1)'*xx;
q1=q1';


%Report
s=['Results: Difference in firm effects means across Provinces: ' filename];
disp(s);
s=['-*-*-*-*-*-*-*-*-*-*-*-*'];
disp(s)
s=['FE Mean in Province 1: ' num2str(fe1)];
disp(s)
s=['FE Mean in Province 2: ' num2str(fe2)];
disp(s)
s=['Difference in FE Mean: ' num2str(v'*b)];
disp(s)
s=['SE for the Diff in Mean: ' num2str(sqrt(V_diff_mean))];
disp(s)
s=['Lindeberg Condition: ' num2str(max(x1bar.^2))];
disp(s);
s=['Correlation: ' num2str(corr(v,q1))];
disp(s);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% PE now
if 0 == 1
s=['mat/COMPLETE_' filename];
load(s)
prov_indicator=prov_indicator_old;
%PE
pe1=mean(pe(prov_indicator==1));
pe2=mean(pe(prov_indicator==-1));
NT1=sum(prov_indicator==1);
NT2=sum(prov_indicator==-1);


%Auxiliary
prov_indicator=accumarray(id,prov_indicator,[],@mean);
sel=prov_indicator==1;
prov_indicator(sel)=prov_indicator(sel)/(NT1);
sel=prov_indicator==-1;
prov_indicator(sel)=prov_indicator(sel)/(NT2);

%BUILD A
if K == 0
v=[degree_workers.*prov_indicator; sparse(J-1,1)];
end
if K > 0
v=[degree_workers.*prov_indicator; sparse(J-1); sparse(K,1)];
end

%CHECK CONDITIONS
A=v*v';
[Q, lambda_eig] = eigs(A,xx,1);
x1bar=X*Q;
norm=(sum(x1bar.^2))^(0.5);
x1bar=x1bar/norm;
clear A

%Inference
sigma_i=y.*eta_h;
sigma_i=spdiags(sigma_i,0,NT,NT);
right=pcg(xx,v,1e-5,1000,Lchol,Lchol');
left=right';
V_diff_mean=left*(X'*sigma_i*X)*right;

%Now compute the correlation
degree_workers=diag((D)'*(D));
A=(D)'*D-(1/NT)*(degree_workers)*degree_workers'; %memory intensive, might make the computer run out of memory, this is why I commented out this part.
if K>0
A=[A sparse(N,K+J-1); sparse(J+K-1,N+J+K-1)];
end
if K==0
A=[A sparse(N,J-1); sparse(J-1,N+J-1)];
end
[Q, lambda_eig] = eigs(A,xx,3);
clear A
q1=Q(:,1)'*xx;
q1=q1';

%Report
s=['Results: Difference in person effects means across Provinces: ' filename];
disp(s);
s=['-*-*-*-*-*-*-*-*-*-*-*-*'];
disp(s)
s=['PE Mean in Province 1: ' num2str(pe1)];
disp(s)
s=['PE Mean in Province 2: ' num2str(pe2)];
disp(s)
s=['Difference in PE Mean: ' num2str(v'*b)];
disp(s)
s=['SE for the Diff in PE Mean: ' num2str(sqrt(V_diff_mean))];
disp(s)
s=['Lindeberg Condition: ' num2str(max(x1bar.^2))];
disp(s);
s=['Correlation: ' num2str(corr(v,q1))];
disp(s);
end

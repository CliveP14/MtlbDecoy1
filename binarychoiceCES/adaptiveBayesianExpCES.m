close all;
clearvars;
rng(1234567)
obsChoice = [];
obsX1 = [];
obsX2 = [];
%% Generate Particles from prior
theta = abs(3*randn(3,1024))';
sd_theta = std(theta);
sd_hist = sd_theta;

%% Simulate choice function
realbeta = [5,1,0.9];
LogitNum = @(x,b) exp(  (x.^b(3) * b(1:2)')^(1/b(3)) );
ProbaChoice1 = @(x1,x2,beta) LogitNum(x1,beta)/ (LogitNum(x1,beta)+LogitNum(x2,beta));
Choose = @(x1,x2,beta) binornd(1,1-ProbaChoice1(x1,x2,beta));

%% Experiment
counter = 0;
indifsd = 1;
while (sum(std(theta) > [0.05 , 0.05,0.05]) > 0) && counter < 200 %&& indifsd > 0.05
    counter = counter + 1;
    fprintf('\n==Loop %d==\n', counter );
    %optimal design
    [x1,x2] = OptimQuestionCES(theta);
    %x1 = [1 +  4 .* rand(1,1),10 +  20 .* rand(1,1)];
    %x2 = [1 +  4 .* rand(1,1),10 +  20 .* rand(1,1)];
    obsX1 = [obsX1;x1];
    obsX2 = [obsX2;x2];
    %simulate answer
    fprintf('Proba choice: %.2f\n', ProbaChoice1(x1,x2,realbeta) );
    obsChoice = [obsChoice;Choose(x1,x2,realbeta)];
    %update prior    
    theta = UpdatePriorDistCES( obsChoice, [obsX1,obsX2], theta );
    %theta = (theta - ones(512,1)*mean(theta)) ./2 + ones(512,1)*realbeta;
    
    %summary statistics
    avg = mean(theta);
    sd = std(theta);
    sd_hist = [sd_hist;sd];
    fprintf('AVG(theta) %.2f %.2f %.2f\n', avg(1), avg(2), avg(3));
    fprintf('SD(theta) %.2f %.2f %.2f\n', sd(1), sd(2), sd(3));
    
    %find indiference prices for qualities 2 and 3
    [xind1,xind2,indifsd] = FindIndifCoupon(2,3,theta);
    fprintf('SD(probachoice) for [%.2f,%.2f] vs [%.2f,%2f] is %4f \n', xind1(1),xind1(2),xind2(1),xind2(2), indifsd);
end

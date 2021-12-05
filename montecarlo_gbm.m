M=60000; %number of trajectories of Geometric Brownian motion
N=250;%Number of steps in one trajectory
X0=100; %initial point
T=1;  %Final Time in years in trajectory

mu = .015; % drift rate
sig = .15; % volatility

dt=T/N; %time step
Sqrtdt=sqrt(dt);

%X(j,:) j-th trajectory of Brownian Motion
X(1:M,1)=X0; % Initial value of Brownian Motion  X(j,1)=X0 for all j=1:M
             %here index starts with 1 and not 0 as in Matlab array index should be
             %positive


for j=1:M  %generate M trajectories
    for i = 2:N+1  %generate j-th trajectory
        X(j,i)=X(j,i-1)+ mu*X(j,i-1)*dt + sig*X(j,i-1)*Sqrtdt*randn; % See lecture 7, slide 13, formula for GBM
    end
end

call_100_20k = 0;
for i=1:20000
    call_100_20k = call_100_20k + max(X(i, 251)-100,0);
end

call_100_20k = exp(-mu)*(call_100_20k/20000);

call_101_20k = 0;
for i=1:20000
    call_101_20k = call_101_20k + max(X(i, 251)-101,0);
end 

call_101_20k = exp(-mu)*(call_101_20k/20000);

%%%%%%%%%%%%%%%%%%%%%%

call_100_40k = 0;
for i=1:40000
    call_100_40k = call_100_40k + max(X(i, 251)-100,0);
end

call_100_40k = exp(-mu)*(call_100_40k/40000);

call_101_40k = 0;
for i=1:40000
    call_101_40k = call_101_40k + max(X(i, 251)-101,0);
end 

call_101_40k = exp(-mu)*(call_101_40k/40000);

%%%%%%%%%%%%%%%%%%%%%%

call_100_60k = 0;
for i=1:60000
    call_100_60k = call_100_60k + max(X(i, 251)-100,0);
end

call_100_60k = exp(-mu)*(call_100_60k/60000);

call_101_60k = 0;
for i=1:60000
    call_101_60k = call_101_60k + max(X(i, 251)-101,0);
end

call_101_60k = exp(-mu)*(call_101_60k/60000);

sprintf('100 Call 20k: %f', call_100_20k)
sprintf('101 Call 20k: %f', call_101_20k)

sprintf('100 Call 40k: %f', call_100_40k)
sprintf('101 Call 40k: %f', call_101_40k)

sprintf('100 Call 60k: %f', call_100_60k)
sprintf('101 Call 60k: %f', call_101_60k)


%t=0:dt:T;
%plot(t,X(:,:));

M=20000; %number of trajectories of Geometric Brownian motion
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

call_100 = 0;
for i=1:N
    call_100 = call_100 + max(X(i, 251)-100,0);
end

call_100 = exp(-mu)*(call_100/N);

call_101 = 0;
for i=1:N
    call_101 = call_101 + max(X(i, 251)-101,0);
end 

call_101 = exp(-mu)*(call_101/N);

disp(call_100);
disp(call_101);

t=0:dt:T;
plot(t,X(:,:));

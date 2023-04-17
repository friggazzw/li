function [fmin,best_pos,Convergence_curve]=BOA(n,N_iter,Lb,Ub,dim,fobj)

% n is the population size
% N_iter represnets total number of iterations
p=0.8;                       % 切换概率
power_exponent=0.1;          %幂指数a
sensory_modality=0.01;       %感觉模态c

%Initialize the positions of search agents  初始化
Sol=initialization(n,dim,Ub,Lb);

for i=1:n,
    Fitness(i)=fobj(Sol(i,:));      %计算是适应度  fobj调用F1,()中是位置信息
end
%若维度为30，sol则为30*30的矩阵，但是为什么Fitness(i)不报错，主要是因为F1(x)=sum(x.^2)，有了sum之后30*30
%则会变为30*1，自然不会报错，dim的值越大，迭代曲线越光滑

% Find the current best_pos        %寻找初始化种群的最佳值（最小值），将它赋予初始全体最佳的称号
[fmin,I]=min(Fitness);
best_pos=Sol(I,:);
S=Sol; 

% Start the iterations -- Butterfly Optimization Algorithm 
for t=1:N_iter
  
        for i=1:n % Loop over all butterflies/solutions
         
          %Calculate fragrance of each butterfly which is correlated with objective function  计算蝴蝶的适应度  适应度即蝴蝶的香味，每只蝴蝶都不同
          Fnew=fobj(S(i,:));
          FP=(sensory_modality*Fnew^power_exponent);   
    
          %Global or local search   用切换概率P来决定是全局搜索还是局部搜索
          if rand<p,    
            dis = rand * rand * best_pos - Sol(i,:);        %全局搜索
            S(i,:)=Sol(i,:)+dis*FP;
           else
              % Find random butterflies in the neighbourhood
              epsilon=rand;
              JK=randperm(n);               
%randperm返回一个n个元素的行向量，这个行向量的元素是1到n的整数随机排列。 n在此代表种群数量，后面随机在种群中选择两只蝴蝶
              dis=epsilon*epsilon*Sol(JK(1),:)-Sol(JK(2),:);
              S(i,:)=Sol(i,:)+dis*FP;                         %局部搜索
          end
           
            % Check if the simple limits/bounds are OK 检查边界条件
            S(i,:)=simplebounds(S(i,:),Lb,Ub);
          
            % Evaluate new solutions
            Fnew=fobj(S(i,:));  %Fnew represents new fitness values
            
            % If fitness improves (better solutions found), update then
            % 更新个体最优
            if (Fnew<=Fitness(i))
                Sol(i,:)=S(i,:);
                Fitness(i)=Fnew;
            end
           
           % Update the current global best_pos 更新全局最优
           if Fnew<=fmin
                best_pos=S(i,:);
                fmin=Fnew;
           end
         end
            
         Convergence_curve(t,1)=fmin;   %记录每一次循环的最小值
         
         %Update sensory_modality 更新感觉模态
          sensory_modality=sensory_modality_NEW(sensory_modality, N_iter);
end

% Boundary constraints
function s=simplebounds(s,Lb,Ub)
  % Apply the lower bound
  ns_tmp=s;
  I=ns_tmp<Lb;
  ns_tmp(I)=Lb;     %ns_tmp<Lb返回布尔类型，返回是false，ns_tmp(0)=Lb不执行，true则执行，但是直接输入a(0)会报错
  
  % Apply the upper bounds 
  J=ns_tmp>Ub;
  ns_tmp(J)=Ub;
  % Update this new move 
  s=ns_tmp; 

  
function y=sensory_modality_NEW(x,Ngen)
y=x+(0.025/(x*Ngen));




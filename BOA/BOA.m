function [fmin,best_pos,Convergence_curve]=BOA(n,N_iter,Lb,Ub,dim,fobj)

% n is the population size
% N_iter represnets total number of iterations
p=0.8;                       % �л�����
power_exponent=0.1;          %��ָ��a
sensory_modality=0.01;       %�о�ģ̬c

%Initialize the positions of search agents  ��ʼ��
Sol=initialization(n,dim,Ub,Lb);

for i=1:n,
    Fitness(i)=fobj(Sol(i,:));      %��������Ӧ��  fobj����F1,()����λ����Ϣ
end
%��ά��Ϊ30��sol��Ϊ30*30�ľ��󣬵���ΪʲôFitness(i)��������Ҫ����ΪF1(x)=sum(x.^2)������sum֮��30*30
%����Ϊ30*1����Ȼ���ᱨ��dim��ֵԽ�󣬵�������Խ�⻬

% Find the current best_pos        %Ѱ�ҳ�ʼ����Ⱥ�����ֵ����Сֵ�������������ʼȫ����ѵĳƺ�
[fmin,I]=min(Fitness);
best_pos=Sol(I,:);
S=Sol; 

% Start the iterations -- Butterfly Optimization Algorithm 
for t=1:N_iter
  
        for i=1:n % Loop over all butterflies/solutions
         
          %Calculate fragrance of each butterfly which is correlated with objective function  �����������Ӧ��  ��Ӧ�ȼ���������ζ��ÿֻ��������ͬ
          Fnew=fobj(S(i,:));
          FP=(sensory_modality*Fnew^power_exponent);   
    
          %Global or local search   ���л�����P��������ȫ���������Ǿֲ�����
          if rand<p,    
            dis = rand * rand * best_pos - Sol(i,:);        %ȫ������
            S(i,:)=Sol(i,:)+dis*FP;
           else
              % Find random butterflies in the neighbourhood
              epsilon=rand;
              JK=randperm(n);               
%randperm����һ��n��Ԫ�ص��������������������Ԫ����1��n������������С� n�ڴ˴�����Ⱥ�����������������Ⱥ��ѡ����ֻ����
              dis=epsilon*epsilon*Sol(JK(1),:)-Sol(JK(2),:);
              S(i,:)=Sol(i,:)+dis*FP;                         %�ֲ�����
          end
           
            % Check if the simple limits/bounds are OK ���߽�����
            S(i,:)=simplebounds(S(i,:),Lb,Ub);
          
            % Evaluate new solutions
            Fnew=fobj(S(i,:));  %Fnew represents new fitness values
            
            % If fitness improves (better solutions found), update then
            % ���¸�������
            if (Fnew<=Fitness(i))
                Sol(i,:)=S(i,:);
                Fitness(i)=Fnew;
            end
           
           % Update the current global best_pos ����ȫ������
           if Fnew<=fmin
                best_pos=S(i,:);
                fmin=Fnew;
           end
         end
            
         Convergence_curve(t,1)=fmin;   %��¼ÿһ��ѭ������Сֵ
         
         %Update sensory_modality ���¸о�ģ̬
          sensory_modality=sensory_modality_NEW(sensory_modality, N_iter);
end

% Boundary constraints
function s=simplebounds(s,Lb,Ub)
  % Apply the lower bound
  ns_tmp=s;
  I=ns_tmp<Lb;
  ns_tmp(I)=Lb;     %ns_tmp<Lb���ز������ͣ�������false��ns_tmp(0)=Lb��ִ�У�true��ִ�У�����ֱ������a(0)�ᱨ��
  
  % Apply the upper bounds 
  J=ns_tmp>Ub;
  ns_tmp(J)=Ub;
  % Update this new move 
  s=ns_tmp; 

  
function y=sensory_modality_NEW(x,Ngen)
y=x+(0.025/(x*Ngen));




pd1 = makedist('Lognormal','mu',0,'sigma',1); %对数正态分布对象
y = cdf(pd1,x');
for i=1:size(x',2)
temp = makedist('Binomial','N',size(x',2),'p',y(i));%二项分布
pd2(i) = pdf(temp,int8(y1(i,1)*size(x',2)));   %发生obj.Pcon(i)次的概率
end
sumofR=sum(log(pd2));
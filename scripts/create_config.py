import itertools

def genAllCombs(listOfLists):
    combs = list(itertools.product(*listOfLists))
    return combs

lr = ["2e-4", "3e-5", "4e-5", "5e-5"]
batch = ["16", "32"]

combs = genAllCombs([lr, batch])
for i, comb in enumerate(combs):
    with open('configs/'+str(i)+'.sh','w') as f:
	f.write("LR=\""+str(comb[0])+'\"\n')
	f.write("BS=\""+str(comb[1])+'\"\n')


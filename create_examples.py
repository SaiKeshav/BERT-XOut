if 1==1:
    inp_file = open('test.tsv')
    rows = csv.reader(inp_file, delimiter='\t')
    out_file = open('test_examples','w')
    for i,row in enumerate(rows):
        if(i == 0):
            continue
        out_file.write(row[1]+"\n")
    out_file.close()


import matplotlib.pyplot as plt
import re
import pandas as pd
import numpy as np



def read_data(filename):
    blocks = []
    threads = []
    matsize = []
    thtd = []
    htdbw = []
    tdth = []
    dthbw = []
    tmm = []
    suwo = []
    suw = []

    htd = False
    with open(filename) as file:
        for line in file:
            start = "*** Grid Dim:"
            if line[:len(start)] == start:
                blocks.append(int(re.search(r'Grid Dim:\s*(.+?)x.+x.+', line).group(1)))

            start = "*** Block Dim:"
            if line[:len(start)] == start:
                threads.append(int(re.search(r'Block Dim:\s*(.+?)x.+x.+', line).group(1)))

            start = "***    Matrix Size:"
            if line[:len(start)] == start:
                matsize.append(int(re.search(r'Matrix Size: (.+?)\n', line).group(1)))
            
            start = "***    Time to Copy to Device:"
            if line[:len(start)] == start:
                htd = True
                thtd.append(float(re.search(r'Time to Copy to Device: (.+?) ms', line).group(1)))
            
            start = "***    Copy Bandwidth:"
            if line[:len(start)] == start and htd:
                htdbw.append(float(re.search(r'Copy Bandwidth: (.+?) GB/s', line).group(1)))
            
            start = "***    Time to Copy from Device:"
            if line[:len(start)] == start:
                htd = False
                tdth.append(float(re.search(r'Time to Copy from Device: (.+?) ms', line).group(1)))
            
            start = "***    Copy Bandwidth:"
            if line[:len(start)] == start and not htd:
                dthbw.append(float(re.search(r'Copy Bandwidth: (.+?) GB/s', line).group(1)))
            
            start = "***    Time for Matrix Multiplication:"
            if line[:len(start)] == start:
                tmm.append(float(re.search(r'Time for Matrix Multiplication: (.+?) ms', line).group(1)))


            start = "*** Speedup without Data Movement:"
            if line[:len(start)] == start:
                suwo.append(float(re.search(r'Speedup without Data Movement: (.+?)\n', line).group(1)))

            start = "*** Speedup with Data Movement:"
            if line[:len(start)] == start:
                suw.append(float(re.search(r'Speedup with Data Movement: (.+?)\n', line).group(1)))
            
            

    stats = [
        blocks,
        threads,
        matsize,
        thtd,
        htdbw,
        tdth,
        dthbw,
        tmm,
        suwo,
        suw
    ]

    df = pd.DataFrame(stats).transpose()
    df.columns = [
        'blocks',
        'threads',
        'matsize',
        'thtd',
        'htdbw',
        'tdth',
        'dthbw',
        'tmm',
        'suwo',
        'suw'
    ]

    return df

if __name__ == '__main__':
    

    # find best thread num with fixed matsize
    df = read_data('5_2_threads.txt')

    plt.plot(df['threads'], df['tmm'])
    plt.yscale('log')
    plt.xscale('log')
    plt.ylabel('multiplication time [ms]')
    plt.xlabel('Thread Count')
    plt.title('Differing Thread Numbers with fixed matrix size')
    plt.savefig('threads.png')
    plt.clf()

    # vary matrix size
    df = read_data('5_2.txt')

    #print(df)
    #plt.plot(df['matsize'], df['tmm'] + df['thtd'] + df['tdth'])
    #plt.yscale('log')
    #plt.xscale('log')
    #plt.ylabel('Overall Runtime [ms]')
    #plt.xlabel('Matrix Size')
    #plt.title('Differing Thread Numbers with fixed matrix size')
    #plt.savefig('vary_sum.png')
    #plt.clf()
#
#
    #plt.plot(df['matsize'], df['tmm'])
    #plt.yscale('log')
    #plt.xscale('log')
    #plt.ylabel('Overall Runtime [ms]')
    #plt.xlabel('Matrix Size')
    #plt.title('Differing Thread Numbers with fixed matrix size')
    #plt.savefig('vary_tmm.png')
    #plt.clf()
#
    #plt.plot(df['matsize'], df['thtd'])
    #plt.yscale('log')
    #plt.xscale('log')
    #plt.ylabel('Overall Runtime [ms]')
    #plt.xlabel('Matrix Size')
    #plt.title('Differing Thread Numbers with fixed matrix size')
    #plt.savefig('vary_thtd.png')
    #plt.clf()
#
    #plt.plot(df['matsize'], df['tdth'])
    #plt.yscale('log')
    #plt.xscale('log')
    #plt.ylabel('Overall Runtime [ms]')
    #plt.xlabel('Matrix Size')
    #plt.title('Differing Thread Numbers with fixed matrix size')
    #plt.savefig('vary_tdth.png')
    #plt.clf()


    plt.plot(df['matsize'], df['tmm'] + df['thtd'] + df['tdth'], label='Overall')
    plt.plot(df['matsize'], df['tmm'], label='Matrix Mult')
    plt.plot(df['matsize'], df['thtd'], label='Host-Device')
    plt.plot(df['matsize'], df['tdth'], label='Device-Host')
    plt.yscale('log')
    plt.xscale('log')
    plt.ylabel('Overall Runtime [ms]')
    plt.xlabel('Matrix Size')
    plt.title('Times for differing matrix sizes')
    plt.legend()
    plt.savefig('vary_all.png')
    plt.clf()


    if len(df['suwo']) != 0:
        idx1 = np.argmax(df['suwo'])
        idx2 = np.argmax(df['suw'])

        print(f'Max speedup wo data movement: {df["suwo"][idx1]} with matrix size: {df["matsize"][idx1]}')
        print(f'Max speedup w data movement: {df["suw"][idx2]} with matrix size: {df["matsize"][idx2]}')
from os import path
data_dir = '/cellar/users/hsher/Data/popgen'
import pandas as pd
import matplotlib.pyplot as plt
import numpy as np

sample_info = pd.read_pickle(path.join(data_dir, 'sample_info.pickle'))

# make unique population df
pop_color = sample_info[['pop', 'super_pop']].drop_duplicates().sort_values(by = 'super_pop')

# customized color for super_pop
super_pop_color = {'AFR':'tomato', # reds
                  'EUR': 'sandybrown', # Oranges
                     'AMR': 'gold', # YlGn
                    'MIDDLE_EAST': 'yellowgreen',#lues
                     'CENTRAL_SOUTH_ASIA': 'seagreen', # Greens
                     
                     'EAS':'royalblue',# purples
                     'OCEANIA':'orchid'} #PuRd
# customized color for each pop in super_pop
super_pop_colormap = {'AFR':plt.cm.Reds, # reds
                  'EUR': plt.cm.Oranges, # Oranges
                     'AMR': plt.cm.YlOrBr, # YlGn
                      'MIDDLE_EAST': plt.cm.YlGn,#blues
                     'CENTRAL_SOUTH_ASIA': plt.cm.Greens, # Greens
                     
                     'EAS':plt.cm.Blues,
                     'OCEANIA':plt.cm.PuRd} #PuRd

# map each pop to their color
import math
def map_to_super_color(df):
    pop_to_color = {}
    for sup_pop in df['super_pop'].unique():
        cmap = super_pop_colormap[sup_pop]
        cmaplist = [cmap(i) for i in range(cmap.N)][10:] # avoid colors that are too light
        
        # how many pop
        pop_index = df.loc[df['super_pop'] == sup_pop].index
        
        step = math.floor(len(cmaplist)/len(pop_index))
        
        colors = np.array(cmaplist)[np.arange(0, len(cmaplist), step)]
        
        #print(len(pop_index), colors, len(colors[:len(pop_index)]))
        pops = df.loc[pop_index, 'pop'] 
        cols = colors[:len(pop_index)]
        #cols = [c.reshape(1,-1) for c in cols]
        pop_to_color.update(zip(pops, cols))
    return pop_to_color
        
pop_to_color = map_to_super_color(pop_color)
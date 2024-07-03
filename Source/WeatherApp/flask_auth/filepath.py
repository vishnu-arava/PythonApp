import os
import pandas as pd

filename = 'Forest_fire.csv'
filepath = os.path.abspath(filename)
#filefullpath = os.path.join(filepath, filename)
print(filepath)
data = pd.read_csv(filepath)
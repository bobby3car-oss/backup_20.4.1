from PIL import Image
import numpy as np

img = Image.open('/Users/jan/projects/operationsbegleiter_v3/assets/images/bella_avatar.png')
arr = np.array(img)
r, g, b, a = arr[:,:,0], arr[:,:,1], arr[:,:,2], arr[:,:,3]

blue_left = ((b.astype(int) > r.astype(int) + 30) & (b > 140) & (a > 80)).sum()
pink_left = ((r > 190) & (b > 110) & (g < 170) & (a > 80) & (r.astype(int) > b.astype(int) + 30)).sum()
print(f'Blue pixels remaining: {blue_left}')
print(f'Pink bg pixels remaining: {pink_left}')
print(f'Transparent corner TL: {a[0,0]}')
print(f'Transparent corner TR: {a[0,-1]}')

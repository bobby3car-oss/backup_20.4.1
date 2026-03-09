from PIL import Image
import numpy as np
from rembg import remove

inp = Image.open('/Users/jan/Downloads/ChatGPT Image 9. März 2026, 00_18_56.png').convert('RGBA')

# Remove background
no_bg = remove(inp, alpha_matting=True,
               alpha_matting_foreground_threshold=230,
               alpha_matting_background_threshold=20,
               alpha_matting_erode_size=10)
no_bg_arr = np.array(no_bg)

r, g, b, a = no_bg_arr[:,:,0], no_bg_arr[:,:,1], no_bg_arr[:,:,2], no_bg_arr[:,:,3]

# The icon background is blue/purple gradient — remove any remaining opaque
# blue or purple pixels that rembg kept as "foreground"
icon_bg = ((b.astype(int) > r.astype(int) + 30) & (b > 140) & (a > 80))
pink_bg = ((r > 190) & (b > 110) & (g < 170) & (a > 80) & (r.astype(int) > b.astype(int) + 30))

result = no_bg_arr.copy()
result[icon_bg | pink_bg, 3] = 0

# Crop to bunny (center of 1024x1024)
left, top = 87, 30
result_img = Image.fromarray(result).crop((left, top, left + 850, top + 850))
result_final = result_img.resize((192, 192), Image.LANCZOS)
result_final.save('/Users/jan/projects/operationsbegleiter_v3/assets/images/bella_avatar.png')
print('Done', result_final.mode, result_final.size)

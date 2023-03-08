import ujson
import os
from PIL import Image



def extract(filename):
    im = Image.open(filename+'.png') # Can be many different formats.
    pixel = im.load()
    width, height = im.size
    os.mkdir(filename)
    new_im = Image.new('RGBA', (16,16), color=0)
    new_pixel = new_im.load()
    for i in range(width//16):
        for j in range(height//16):
            for a in range(16):
                for b in range(16):
                    new_pixel[a,b] = pixel[i*16+a,j*16+b]
            new_im.save(filename+'/'+str(i)+'_'+str(j)+'.png')


if __name__ == "__main__":
    command = input().strip().split()
    print(command[0])
    extract(command[0])
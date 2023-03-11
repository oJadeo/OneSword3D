import ujson
import os
from PIL import Image



def extract(filename,size):
    im = Image.open(filename+'.png') # Can be many different formats.
    pixel = im.load()
    width, height = im.size
    os.mkdir(filename)
    new_im = Image.new('RGBA', (size,size), color=0)
    new_pixel = new_im.load()
    for i in range(width//size):
        for j in range(height//size):
            for a in range(size):
                for b in range(size):
                    new_pixel[a,b] = pixel[i*size+a,j*size+b]
            new_im.save(filename+'/'+str(i)+'_'+str(j)+'.png')


if __name__ == "__main__":
    command = input().strip().split()
    extract(command[0],int(command[1]))
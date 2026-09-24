"""Independently verify all SWF tags and reconstructed premultiplied pixels."""
import sys,zlib,struct,io
from pathlib import Path
import numpy as np
from PIL import Image
def read(p):
 b=Path(p).read_bytes(); d=zlib.decompress(b[8:]); assert len(d)+8==struct.unpack_from('<I',b,4)[0]
 pos=(5+4*(d[0]>>3)+7)//8+4
 header=d[:pos]; tags=[]
 while pos<len(d):
  h,=struct.unpack_from('<H',d,pos);pos+=2;t,n=h>>6,h&63
  if n==63:n,=struct.unpack_from('<I',d,pos);pos+=4
  tags.append((t,d[pos:pos+n]));pos+=n
  if not t:break
 assert pos==len(d)
 return header,tags
h,a=read(sys.argv[1]);j,b=read(sys.argv[2]);assert h==j and len(a)==len(b)
converted=0
for (t,p),(u,q) in zip(a,b):
 if (t,p)==(u,q):continue
 assert t==36 and u==21 and p[:2]==q[:2] and p[2]==5
 w,ht=struct.unpack_from('<HH',p,3)
 img=Image.open(io.BytesIO(q[2:]));assert img.size==(w,ht)
 rgba=np.array(img.convert('RGBA')).astype(np.uint32)
 original=np.frombuffer(zlib.decompress(p[7:]),dtype=np.uint8).reshape(ht,w,4)
 assert np.array_equal(rgba[:,:,3],original[:,:,0])
 assert np.array_equal((rgba[:,:,:3]*rgba[:,:,3:]+127)//255,original[:,:,1:])
 converted+=1
print('PASS: %d tags; %d converted images; IDs/dimensions/alpha/premultiplied pixels preserved; all other tags identical'%(len(a),converted))

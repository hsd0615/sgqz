"""Re-encode SWF Lossless2 ARGB bitmaps as PNG (Flash 10+ JPEG2).
Preserves character IDs, dimensions, alpha, and every other SWF tag.
Checks recovered premultiplied pixels before replacing each bitmap.
"""
import io, json, struct, sys, zlib, hashlib
from pathlib import Path
import numpy as np
from PIL import Image

source, output = map(Path, sys.argv[1:3])
b = source.read_bytes()
assert b[:3] == b'CWS' and b[3] >= 10
d = zlib.decompress(b[8:])
pos = (5 + 4 * (d[0] >> 3) + 7) // 8 + 4
chunks = [d[:pos]]
report = []
while pos < len(d):
    start = pos
    h, = struct.unpack_from('<H', d, pos); pos += 2
    tag, size = h >> 6, h & 63
    if size == 63:
        size, = struct.unpack_from('<I', d, pos); pos += 4
    payload = d[pos:pos+size]; pos += size
    replacement = None
    if tag == 36 and payload[2] == 5:
        cid, fmt, w, ht = struct.unpack_from('<HBHH', payload)
        raw = zlib.decompress(payload[7:])
        argb = np.frombuffer(raw, dtype=np.uint8).reshape(ht,w,4)
        alpha = argb[:,:,0].astype(np.uint32)
        rgb = argb[:,:,1:].astype(np.uint32)
        straight = np.minimum(255, (rgb*255 + alpha[:,:,None]//2)//np.maximum(alpha[:,:,None],1)).astype(np.uint8)
        restored = (straight.astype(np.uint32)*alpha[:,:,None]+127)//255
        exact = np.array_equal(restored, rgb)
        if exact:
            rgba = np.concatenate((straight, argb[:,:,:1]), axis=2)
            png = io.BytesIO()
            Image.fromarray(rgba).save(png, format='PNG', optimize=True)
            encoded = png.getvalue()
            decoded = np.array(Image.open(io.BytesIO(encoded)))
            assert np.array_equal(decoded, rgba)
            if len(encoded)+2 < size:
                p = payload[:2]+encoded
                replacement = struct.pack('<HI', (21<<6)|63, len(p))+p
        report.append(dict(id=cid,width=w,height=ht,before=size,after=len(replacement)-6 if replacement else size,pixel_exact=exact))
    chunks.append(replacement if replacement else d[start:pos])
    if tag == 0:
        chunks.append(d[pos:]); break
body = b''.join(chunks)
result = b'CWS'+b[3:4]+struct.pack('<I',len(body)+8)+zlib.compress(body,9)
output.write_bytes(result)
Path(str(output)+'.json').write_text(json.dumps(dict(source_bytes=len(b),output_bytes=len(result),sha256=hashlib.sha256(result).hexdigest(),bitmaps=report),indent=2))
print(json.dumps(dict(before=len(b),after=len(result),converted=sum(r['after']<r['before'] for r in report),pixel_exact=all(r['pixel_exact'] for r in report))))
